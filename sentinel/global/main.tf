
variable "tfe_token" {
  type = string
} 

module "policies" {
  source = "../modules/sentinel"
  tfe_token = var.tfe_token
  policy_sets = {
    global = {
      global = true
      workspaces = null
      policies = {
        must_not_be_public = {
          file_path = "s3_must_not_be_public.sentinel",
          enforce_mode = "hard-mandatory"
          description = "all s3 buckets must be public"
        }
      }
    }
  }
}

