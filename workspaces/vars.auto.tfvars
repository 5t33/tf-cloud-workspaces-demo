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
        description = "Environment."
      },
      {
        key = "region"
        value = "us-west-2",
        description = "Region."
      }
    ],
    environment_variables = []
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
      },
      {
        key = "region",
        value = "us-west-2",
        description = "Region."
      }
    ],
    environment_variables = []
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
      },
      {
        key = "region",
        value = "us-west-2",
        description = "Region."
      }
    ],
    environment_variables = []
  }
}
