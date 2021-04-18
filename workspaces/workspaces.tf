terraform {
  required_providers {
    tfe = {
      source = "hashicorp/tfe"
      version = "0.24.0"
    }
  }
}

provider "tfe" {
  token    = var.tfe_token
}

variable "tfe_token" {
  type = string
}

variable "oauth_token_id" {
  description = "Id of Terraform Cloud OAuth connection to use. This most likely will not change considering we have a single machine user."
  type = string
}

variable "organization" {
  description = "Id of Terraform Cloud organization to use. This also most likely will not change."
  type = string
  default = "stevens_corp"
}

variable "workspaces" {
  type = map(object({
    trigger_prefixes = list(string)
    queue_all_runs = bool
    working_directory = string
    ssh_key_id = string
    speculative_enabled = bool
    vcs_repo = object({
      branch = string
      identifier = string
      ingress_submodules = bool
    })
    variables = list(
      object({
        key = string
        value = string
        description = string
    }))
    environment_variables = list(
      object({
        key = string
        value = string
        description = string
    }))
  }))
}

variable "sensitive_variables" {
  type = map(
    list(
      object({
        key = string
        value = string
        description = string
    })))
  description = "Map of workspaces to a list of sensitive terraform variables."
  default = {}
}

variable "sensitive_environment_variables" {
  type = map(
    list(
      object({
        key = string
        value = string
        description = string
    })))
  description = "Map of workspaces to a list of sensitive environment variables."
  default = {}
}


locals {
  workspace_variables = flatten([ 
    # loop through workspaces
    for workspace_name, workspace in var.workspaces: [
      # loop through each variable in the workspace,
      # and return a variable with the workspace ID
      for variable in workspace.variables: ({
        workspace_id =  tfe_workspace.workspaces[workspace_name].id
        key = variable.key,
        value = variable.value,
        description = variable.description
        sensitive  = false
      })
    ]
  ])
  sensitive_workspace_variables = flatten([ 
    # loop through lists of sensitive vars
    for workspace_name, variables in var.sensitive_variables: [
      # loop through each variable in the set,
      # and return a variable with the workspace ID
      for variable in variables: ({
        workspace_id =  tfe_workspace.workspaces[workspace_name].id
        key = variable.key,
        value = variable.value,
        description = variable.description
        sensitive  = true
      })
    ]
  ])
  environment_variables = flatten([ 
    # loop through workspaces
    for workspace_name, workspace in var.workspaces: [
      # loop through each variable in the workspace,
      # and return a variable with the workspace ID
      for variable in workspace.environment_variables: ({
        workspace_id =  tfe_workspace.workspaces[workspace_name].id
        key = variable.key,
        value = variable.value,
        description = variable.description
        sensitive  = false
      })
    ]
  ])
  sensitive_environment_variables = flatten([ 
    # loop through lists of sensitive vars
    for workspace_name, variables in var.sensitive_environment_variables: [
      # loop through each variable in the set,
      # and return a variable with the workspace ID
      for variable in variables: ({
        workspace_id =  tfe_workspace.workspaces[workspace_name].id
        key = variable.key,
        value = variable.value,
        description = variable.description
        sensitive  = true
      })
    ]
  ])
}
locals {
  final_env_vars = concat(local.environment_variables, local.sensitive_environment_variables)
  final_workspace_vars = concat(local.workspace_variables, local.sensitive_workspace_variables)
}



resource "tfe_workspace" "workspaces" {
  for_each = var.workspaces
  name         = each.key
  organization = var.organization
  trigger_prefixes = each.value.trigger_prefixes
  allow_destroy_plan = false
  queue_all_runs = each.value.queue_all_runs
  execution_mode = "remote" 
  working_directory = each.value.working_directory
  ssh_key_id = each.value.ssh_key_id
  speculative_enabled = each.value.speculative_enabled
  dynamic "vcs_repo" {
    for_each = each.value.vcs_repo == null ? [] : [each.value.vcs_repo] 
    content {
      branch = vcs_repo.value.branch
      identifier = vcs_repo.value.identifier
      ingress_submodules = vcs_repo.value.ingress_submodules
      oauth_token_id = var.oauth_token_id
    }
  }
}

resource "tfe_variable" "terraform_variables" {
  count = length(local.final_workspace_vars)
  key          = local.final_workspace_vars[count.index].key
  value        = local.final_workspace_vars[count.index].value
  category     = "terraform"
  workspace_id = local.final_workspace_vars[count.index].workspace_id
  description  = local.final_workspace_vars[count.index].description
  sensitive     = local.final_workspace_vars[count.index].sensitive
}

resource "tfe_variable" "environment_variables" {
  count = length(local.final_env_vars)
  key          = local.final_env_vars[count.index].key
  value        = local.final_env_vars[count.index].value
  category     = "env"
  workspace_id = local.final_env_vars[count.index].workspace_id
  description  = local.final_env_vars[count.index].description
  sensitive     = local.final_env_vars[count.index].sensitive
}
