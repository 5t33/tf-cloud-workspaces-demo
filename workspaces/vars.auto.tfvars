aws_region = "us-west-2"
aws_profile = "personal"
workspaces = {
  tf-cloud-workspaces-demo-tst-us-west-2 = {
    trigger_prefixes = null,
    queue_all_runs = true,
    working_directory = "module",
    ssh_key_id = null,
    speculative_enabled = true,
    vcs_repo = null,
    variables = [
      {
        key = "environment",
        value = "tst",
        description = "Environment.",
        type = "PLAIN_TEXT",
        sensitive = false,
        with_decryption = null
      },
      {
        key = "aws_region",
        value = "us-west-2",
        description = "Region.",
        type = "PLAIN_TEXT",
        sensitive = false,
        with_decryption = null
      },
      {
        key = "assume_role_arn",
        value = "/tf-cloud-demo/deployment_user/deployment_role_arn/tst-us-west-2"
        description = "Deployment role arn tst-us-west-2"
        type = "PARAMETER_STORE"
        sensitive = false,
        with_decryption = false
      }
    ],
    environment_variables = [
      {
        key = "AWS_ACCESS_KEY_ID",
        value = "/tf-cloud-demo/deployment_user/aws_access_key_id"
        description = "Deployment users' access key id"
        type = "PARAMETER_STORE"
        sensitive = true,
        with_decryption = true
      },
      {
        key = "AWS_SECRET_ACCESS_KEY",
        value = "/tf-cloud-demo/deployment_user/secret_access_key"
        description = "Deployment users' secret access key"
        type = "PARAMETER_STORE"
        sensitive = true,
        with_decryption = true
      }
    ]
  },
  tf-cloud-workspaces-demo-stg-us-west-2 = {
    trigger_prefixes = null,
    queue_all_runs = true,
    working_directory = "module"
    ssh_key_id = null
    speculative_enabled = true
    vcs_repo = null,
    variables = [
      {
        key = "environment",
        value = "stg",
        description = "Environment."
        type = "PLAIN_TEXT"
        sensitive = false
        with_decryption = null
      },
      {
        key = "aws_region",
        value = "us-west-2",
        description = "Region."
        type = "PLAIN_TEXT"
        sensitive = false
        with_decryption = null
      },
      {
        key = "assume_role_arn",
        value = "/tf-cloud-demo/deployment_user/deployment_role_arn/stg-us-west-2"
        description = "Deployment role arn stg-us-west-2"
        type = "PARAMETER_STORE"
        sensitive = false,
        with_decryption = false
      }
    ],
    environment_variables = [
      {
        key = "AWS_ACCESS_KEY_ID",
        value = "/tf-cloud-demo/deployment_user/aws_access_key_id"
        description = "Deployment users' access key id"
        type = "PARAMETER_STORE"
        sensitive = true,
        with_decryption = true
      },
      {
        key = "AWS_SECRET_ACCESS_KEY",
        value = "/tf-cloud-demo/deployment_user/secret_access_key"
        description = "Deployment users' secret access key"
        type = "PARAMETER_STORE"
        sensitive = true,
        with_decryption = true
      }
    ]
  },
  tf-cloud-workspaces-demo-prd-us-west-2 = {
    trigger_prefixes =  null,
    queue_all_runs = true,
    working_directory = "module"
    ssh_key_id = null
    speculative_enabled = true
    vcs_repo = null,
    variables = [
      {
        key = "environment",
        value = "prd",
        description = "Environment."
        type = "PLAIN_TEXT"
        sensitive = false
        with_decryption = null
      },
      {
        key = "aws_region",
        value = "us-west-2",
        description = "Region."
        type = "PLAIN_TEXT"
        sensitive = false
        with_decryption = null
      },
      {
        key = "assume_role_arn",
        value = "/tf-cloud-demo/deployment_user/deployment_role_arn/prd-us-west-2"
        description = "Deployment role arn prd-us-west-2"
        type = "PARAMETER_STORE"
        sensitive = false,
        with_decryption = false
      }
    ],
    environment_variables = [
      {
        key = "AWS_ACCESS_KEY_ID",
        value = "/tf-cloud-demo/deployment_user/aws_access_key_id"
        description = "Deployment users' access key id"
        type = "PARAMETER_STORE"
        sensitive = true,
        with_decryption = true
      },
      {
        key = "AWS_SECRET_ACCESS_KEY",
        value = "/tf-cloud-demo/deployment_user/secret_access_key"
        description = "Deployment users' secret access key"
        type = "PARAMETER_STORE"
        sensitive = true,
        with_decryption = true
      }
    ]
  }
}
