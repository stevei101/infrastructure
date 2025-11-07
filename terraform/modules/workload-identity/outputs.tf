output "service_account_email" {
  description = "Email of the managed or referenced Google service account."
  value       = local.service_account_email
}

output "service_account_name" {
  description = "Fully qualified resource name of the Google service account."
  value       = local.service_account_name
}

output "workload_identity_pool_name" {
  description = "Full resource name of the workload identity pool managed by the module."
  value       = local.workload_identity_pool_name
}

output "workload_identity_pool_id" {
  description = "Simple identifier of the workload identity pool."
  value       = local.workload_identity_pool_id
}

output "provider_resource_names" {
  description = "Map of provider IDs to fully qualified resource names for created workload identity providers."
  value = {
    for id, provider in google_iam_workload_identity_pool_provider.oidc : id => provider.name
  }
}

