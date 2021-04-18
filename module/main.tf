
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
  region = var.region
  access_key = var.access_key
  secret_key = var.secret_key
  assume_role  {
    role_arn = "arn:aws:iam::${var.account_id}:role/terraform-cloud-demo/deploy-role-tf-cloud-demo-${local.workspace}"
  }
}

variable "environment" {
  type = string
  validation {
    condition = var.environment == "tst" || var.environment == "stg" || var.environment == "prd" 
    error_message = "Environment must be one of tst, stg, prd."
  }
}

variable "region" {
  type = string
  validation {
    condition = var.region == "us-west-2"
    error_message = "Region  must be one of us-west-2."
  }
}

variable "access_key" {
  type = string
  sensitive = true
}

variable "secret_key" {
  type = string
  sensitive = true
}

variable "account_id" {
  type = number
  sensitive = true
}

variable "force_destroy" {
  type = map(bool)
  default = {
    "tst-us-west-2" = true,
    "stg-us-west-2" = true,
    "prd-us-west-2" = false
  }
}

variable "tags" {
  type = map(map(string))
  default = {
    "tst-us-west-2" = {
      environment = "tst"
    },
    "stg-us-west-2" = {
      environment = "stg"
    },
    "prd-us-west-2" = {
      environment = "prd"
    }
  }
}

locals {
  workspace = "${var.environment}-${var.region}"
}

resource "aws_s3_bucket" "demo" {
  bucket = "tf-cloud-workspaces-demo-${local.workspace}"
  force_destroy = var.force_destroy[local.workspace]
  tags = var.tags[local.workspace]
}

resource "aws_s3_bucket_object" "object" {
  bucket = aws_s3_bucket.demo.bucket
  key    = "demo_obj.txt"
  content = "this is bucket ${local.workspace}"
}
