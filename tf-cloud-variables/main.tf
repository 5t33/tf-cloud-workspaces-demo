

locals {
  ssm_terraform_variables = [
    for variable in var.terraform_variables: variable if variable.type == "PARAMETER_STORE"
  ]
  ssm_environment_variables = [
    for variable in var.environment_variables: variable if variable.type == "PARAMETER_STORE"
  ]
  ssm_terraform_keys = [
    for variable in var.terraform_variables: variable.key if variable.type == "PARAMETER_STORE"
  ]
  ssm_environment_keys = [
    for variable in var.environment_variables: variable.key if variable.type == "PARAMETER_STORE"
  ]
}

locals {
  ssm_terraform_variable_map = zipmap(local.ssm_terraform_keys, local.ssm_terraform_variables)
  ssm_environment_variable_map = zipmap(local.ssm_environment_keys, local.ssm_environment_variables)
}

data "tfe_workspace" "this" {
  count        = var.workspace == null ? 0 : 1
  name         = var.workspace
  organization = var.organization
}


data "aws_ssm_parameter" "terraform_variable_parameters" {
  for_each = local.ssm_terraform_variable_map
  name = each.value.value
  with_decryption = each.value.with_decryption
}

data "aws_ssm_parameter" "terraform_environment_parameters" {
  for_each = local.ssm_environment_variable_map
  name = each.value.value
  with_decryption = each.value.with_decryption
}

locals {
  workspace_id = var.workspace_id == null ? data.tfe_workspace.this[0].id : var.workspace_id
  full_terraform_variables = [
    for variable in var.terraform_variables: 
      variable.type == "PLAIN_TEXT" ? 
      {
        key = variable.key
        description = variable.description
        type = variable.type
        value = variable.value
        sensitive = variable.sensitive
      } :
      {
        key = variable.key
        description = variable.description
        type = variable.type
        value = data.aws_ssm_parameter.terraform_variable_parameters[variable.key].value
        sensitive = variable.sensitive
      }
   ]
   full_environment_variables = [
    for variable in var.environment_variables: 
      variable.type == "PLAIN_TEXT" ? 
      {
        key = variable.key
        description = variable.description
        type = variable.type
        value = variable.value
        sensitive = variable.sensitive
      } :
      {
        key = variable.key
        description = variable.description
        type = variable.type
        value = data.aws_ssm_parameter.terraform_environment_parameters[variable.key].value
        sensitive = variable.sensitive
      }
   ]
}

resource "tfe_variable" "terraform_variables" {
  count = length(local.full_terraform_variables)
  key          = local.full_terraform_variables[count.index].key
  value        = local.full_terraform_variables[count.index].value
  category     = "terraform"
  workspace_id = local.workspace_id
  description  = local.full_terraform_variables[count.index].description
  sensitive     = local.full_terraform_variables[count.index].sensitive
}

resource "tfe_variable" "environment_variables" {
  count = length(local.full_environment_variables)
  key          = local.full_environment_variables[count.index].key
  value        = local.full_environment_variables[count.index].value
  category     = "env"
  workspace_id = local.workspace_id
  description  = local.full_environment_variables[count.index].description
  sensitive    = local.full_environment_variables[count.index].sensitive
}