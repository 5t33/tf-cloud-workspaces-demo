
resource "tfe_workspace" "workspaces" {
  for_each = var.workspaces
  name         = each.key
  organization = var.organization
  trigger_prefixes = each.value.trigger_prefixes
  allow_destroy_plan = false
  queue_all_runs = each.value.queue_all_runs
  execution_mode = "remote" 
  working_directory = each.value.working_directory
  ssh_key_id = each.value.ssh_key_id
  speculative_enabled = each.value.speculative_enabled
  dynamic "vcs_repo" {
    for_each = each.value.vcs_repo == null ? [] : [each.value.vcs_repo] 
    content {
      branch = vcs_repo.value.branch
      identifier = vcs_repo.value.identifier
      ingress_submodules = vcs_repo.value.ingress_submodules
      oauth_token_id = var.oauth_token_id
    }
  }
}

module "variables" {
  for_each = var.workspaces
  source = "../tf-cloud-variables"
  workspace_id = tfe_workspace.workspaces[each.key].id
  terraform_variables = each.value.variables
  environment_variables = each.value.environment_variables
}

