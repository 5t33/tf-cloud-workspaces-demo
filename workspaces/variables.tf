variable "tfe_token" {
  type = string
}

variable "aws_region" {
  type = string
  default = "us-west-2"
}

variable "aws_profile" {
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
        type = string
        sensitive = bool
        with_decryption = bool
    }))
    environment_variables = list(
      object({
        key = string
        value = string
        description = string
        type = string
        sensitive = bool
        with_decryption = bool
    }))
  }))
}
