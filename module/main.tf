
terraform {
  backend "remote" {
    hostname = "app.terraform.io"
    organization = "stevens_corp"

    workspaces {
      prefix = "tf-cloud-workspaces-demo-"
    }
  }
}

provider "aws" {
  region = var.aws_region
  assume_role  {
    role_arn = var.assume_role_arn
  }
}

variable "environment" {
  type = string
  validation {
    condition = var.environment == "tst" || var.environment == "stg" || var.environment == "prd" 
    error_message = "Environment must be one of tst, stg, prd."
  }
}

variable "aws_region" {
  type = string
  default = "us-west-2"
  validation {
    condition = var.aws_region == "us-west-2"
    error_message = "Region  must be one of us-west-2."
  }
}

variable "assume_role_arn" {
  type = string 
  description = "Deployment role to be assumed during Terraform plan/apply."
}

variable "variables" {
  type = map(object({
    force_destroy = bool
    tags = map(string)
  }))
}

locals {
  workspace = "${var.environment}-${var.aws_region}"
}

resource "aws_s3_bucket" "demo" {
  bucket = "tf-cloud-workspaces-demo-${local.workspace}"
  force_destroy = var.variables[local.workspace].force_destroy
  tags =  var.variables[local.workspace].tags
}

resource "aws_s3_bucket_object" "object" {
  bucket = aws_s3_bucket.demo.bucket
  key    = "demo_obj.txt"
  content = "this is bucket ${local.workspace}"
}
