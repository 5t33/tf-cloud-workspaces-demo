provider "aws" {
  region = var.aws_region
  profile = var.aws_profile
}

data "aws_iam_user" "deployment_user" {
  user_name = var.user_name
}

variable "aws_region" {
  type = string
  default = "us-west-2"
}

variable "aws_profile" {
  type = string
}

variable "user_name" {
  type = string
  description = "name of deployment user"
} 

variable "workspaces" {
  type = list(string)
  validation {
    condition = alltrue([
      for workspace in var.workspaces: workspace == "tst-us-west-2" || workspace == "stg-us-west-2" || workspace == "prd-us-west-2"
    ])
    error_message = "Workspace must be one of \"tst-us-west-2\", \"stg-us-west-2\", \"prd-us-west-2\"."
  }
}

resource "aws_iam_role" "deploy_roles" {
  for_each = toset(var.workspaces)
  name     = "deploy-role-tf-cloud-demo-${each.value}"
  assume_role_policy = jsonencode(
    {
      Statement = [
          {
              Action    = "sts:AssumeRole"
              Effect    = "Allow"
              Principal = {
                  AWS = data.aws_iam_user.deployment_user.arn
              }
          },
      ]
      Version   = "2012-10-17"
    }
  )
  force_detach_policies = false
  max_session_duration  = 3600
  path                  = "/terraform-cloud-demo/"
}

resource "aws_iam_policy" "deploy_policies" {
  for_each = toset(var.workspaces)
  name = "tf-cloud-demo-deploy-${each.value}"  
  description = "deployment policy for terraform cloud demo ${each.value}"
  path = "/terraform-cloud-demo/"
  policy = jsonencode(
    {
      "Version": "2012-10-17",
      "Statement": [
        {
          "Sid": "BucketPolicies",
          "Effect": "Allow",
          "Action": [
            "s3:*"
          ],
          "Resource": [
            "arn:aws:s3:::tf-cloud-workspaces-demo-${each.value}",
            "arn:aws:s3:::tf-cloud-workspaces-demo-${each.value}/*"
          ]
        }
      ] 
    }
  )
}

resource "aws_iam_role_policy_attachment" "policy_attachments" {
  for_each   = toset(var.workspaces)
  role       = aws_iam_role.deploy_roles[each.value].id
  policy_arn = aws_iam_policy.deploy_policies[each.value].arn
}

resource "aws_iam_policy" "user_assume_role_policy" {
  name = "tf-cloud-user-assume-role"
  description = "assume role policy for user im terraform cloud demo"
  path = "/terraform-cloud-demo/"
  policy = jsonencode(
    {
      "Version": "2012-10-17",
      "Statement": [
        {
          "Sid": "AssumeRoles",
          "Effect": "Allow",
          "Action": [
            "sts:AssumeRole"
          ],
          "Resource": [ for k,v in aws_iam_role.deploy_roles: v.arn]
        }
      ]
    }
  )
}

resource "aws_iam_user_policy_attachment" "user_policy_attachment" {
  user       = data.aws_iam_user.deployment_user.user_name
  policy_arn = aws_iam_policy.user_assume_role_policy.arn
}

resource "aws_iam_access_key" "this" {
  user = data.aws_iam_user.deployment_user.user_name
}

resource "aws_ssm_parameter" "access_key_id" {
  name = "/tf-cloud-demo/deployment_user/aws_access_key_id"
  value = aws_iam_access_key.this.id
  type = "SecureString"
}

resource "aws_ssm_parameter" "secret_access_key" {
  name = "/tf-cloud-demo/deployment_user/secret_access_key"
  value = aws_iam_access_key.this.secret
  type = "SecureString"
}

resource "aws_ssm_parameter" "deployment_role_arn" {
  for_each = aws_iam_role.deploy_roles
  name = "/tf-cloud-demo/deployment_user/deployment_role_arn/${each.key}"
  value = each.value.arn
  type = "String"
}