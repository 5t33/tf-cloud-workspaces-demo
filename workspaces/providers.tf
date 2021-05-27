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

provider "aws" {
  region = var.aws_region
  profile = var.aws_profile
}
