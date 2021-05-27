variable "organization" {
  type = string
  description = "organization"
  default = "stevens_corp"
}

variable "workspace" {
  type = string
  description = "Workspace for which to add variables."
  default = null
}

variable "workspace_id" {
  type = string
  description = "Workspace id. If supplied, this will override workspace."
  default = null
}

variable "terraform_variables" {
  type = list(
    object({
      key = string
      value = string
      description = string
      type = string
      with_decryption = bool
      sensitive = bool
    })
  )

  validation  {
    condition = alltrue([
      for variable in var.terraform_variables: variable.type == "PLAIN_TEXT" || variable.type == "PARAMETER_STORE"
    ])
    error_message = "All Terraform variables must have a type equal to either \"PLAIN_TEXT\" or \"PARAMETER_STORE\"."
  }

  default = []
}

variable "environment_variables" {
  type = list(
    object({
      key = string
      value = string
      description = string
      type = string
      with_decryption = bool
      sensitive = bool
    })
  )

  validation {
    condition = alltrue([
      for variable in var.environment_variables: variable.type == "PLAIN_TEXT" || variable.type == "PARAMETER_STORE"
    ])
    error_message = "All Environment variables must have a type equal to either \"PLAIN_TEXT\" or \"PARAMETER_STORE\"."
  }

  default = []
}