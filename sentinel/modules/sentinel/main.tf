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

resource "tfe_sentinel_policy" "test" {
  name         = "my-policy-name"
  description  = "This policy always passes"
  organization = "my-org-name"
  policy       = "main = rule { true }"
  enforce_mode = "hard-mandatory"
}