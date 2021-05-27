variable "organization" {
  description = "Id of Terraform Cloud organization to use. This also most likely will not change."
  type = string
}

variable "policies" {
  description = "Map of policies to be created where the key will be the policy name"
  type = map(object({
    description = string
    file_path = string
    enforce_mode = string
  }))
  validation {
    condition = alltrue([ for k,v in var.policies: 
      v.enforce_mode == "hard-mandatory" || v.enforce_mode == "soft-mandatory" ||  v.enforce_mode == "advisory" 
    ])
    error_message = "Enforcement mode should be one of \"hard-mandatory\", \"soft_mandatory\", \"advisory\"." 
  }
}

variable "workspaces" {
  type = list(string)
  description = "Workspaces the policy set will be attached to."
}

variable "global" {
  type = bool
  description = "Whether the policy set is to be enforced globally"
}
variable "policy_set_name" {
  description = "Name of the policy set that each of the provided policies will be added to"
  type = string
} 

data "tfe_workspace_ids" "ids" {
  count = var.global == true ? 0 : 1
  organization = var.organization
  names = var.workspaces
}

resource "tfe_sentinel_policy" "policies" {
  for_each = var.policies
  name         = each.key
  description  = each.value.description
  organization = var.organization
  policy       = file("${path.root}/${each.value.file_path}")
  enforce_mode = each.value.enforce_mode
}

resource "tfe_policy_set" "policy_sets" {
  for_each = var.policies
  name          = each.key
  organization  =  var.organization
  policy_ids    = [for k,v in tfe_sentinel_policy.policies: v.id]
  workspace_ids = var.global == true ? null : values(data.tfe_workspace_ids.ids[0].ids)
  global = var.global == true ? true : null
} 
