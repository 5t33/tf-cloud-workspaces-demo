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

variable "organization" {
  description = "Id of Terraform Cloud organization to use. This also most likely will not change."
  type = string
  default = "stevens_corp"
}


variable "policy_sets" {
  type = map(
    object({
      policies = map(object({
        description = string,
        file_path = string,
        enforce_mode = string
      }))
      workspaces = list(string)
      global = bool
    })
  )
}

module "policy_sets" {
  for_each = var.policy_sets
  source = "./policy_set"
  policy_set_name = each.key
  policies = each.value.policies
  workspaces = each.value.workspaces
  global = each.value.global
  organization = var.organization
}

