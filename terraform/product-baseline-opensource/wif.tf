# Workload Identity Federation resources for GitHub Actions
# This creates the service account and IAM bindings needed for CI/CD

# GitHub Actions Service Account
resource "google_service_account" "github_actions_sa" {
  account_id   = "github-actions"
  display_name = "GitHub Actions Service Account"
  description  = "Service account for GitHub Actions CI/CD pipeline via Workload Identity Federation"

  lifecycle {
    prevent_destroy = true
  }
}

# Grant Editor role for general project operations
resource "google_project_iam_member" "github_actions_editor" {
  project = var.gcp_project_id
  role    = "roles/editor"
  member  = "serviceAccount:${google_service_account.github_actions_sa.email}"

  lifecycle {
    prevent_destroy = true
  }
}

# Grant Kubernetes Engine Developer role for GKE access
resource "google_project_iam_member" "github_actions_k8s_developer" {
  project = var.gcp_project_id
  role    = "roles/container.developer"
  member  = "serviceAccount:${google_service_account.github_actions_sa.email}"

  lifecycle {
    prevent_destroy = true
  }
}

# Grant Storage Admin role for Artifact Registry and GCS
resource "google_project_iam_member" "github_actions_storage_admin" {
  project = var.gcp_project_id
  role    = "roles/storage.admin"
  member  = "serviceAccount:${google_service_account.github_actions_sa.email}"

  lifecycle {
    prevent_destroy = true
  }
}

# Grant Artifact Registry Admin role for Docker images
resource "google_project_iam_member" "github_actions_artifact_admin" {
  project = var.gcp_project_id
  role    = "roles/artifactregistry.admin"
  member  = "serviceAccount:${google_service_account.github_actions_sa.email}"

  lifecycle {
    prevent_destroy = true
  }
}

# Grant Kubernetes Engine Admin for cluster management
resource "google_project_iam_member" "github_actions_k8s_admin" {
  project = var.gcp_project_id
  role    = "roles/container.admin"
  member  = "serviceAccount:${google_service_account.github_actions_sa.email}"

  lifecycle {
    prevent_destroy = true
  }
}

# Grant Resource Manager Project IAM Admin for managing IAM policies
resource "google_project_iam_member" "github_actions_iam_admin" {
  project = var.gcp_project_id
  role    = "roles/resourcemanager.projectIamAdmin"
  member  = "serviceAccount:${google_service_account.github_actions_sa.email}"

  lifecycle {
    prevent_destroy = true
  }
}

# Grant Workload Identity Pool Admin for creating/managing WIF pools
resource "google_project_iam_member" "github_actions_wif_admin" {
  project = var.gcp_project_id
  role    = "roles/iam.workloadIdentityPoolAdmin"
  member  = "serviceAccount:${google_service_account.github_actions_sa.email}"

  lifecycle {
    prevent_destroy = true
  }
}

# Workload Identity Pool for GitHub Actions
resource "google_iam_workload_identity_pool" "github_pool" {
  provider                  = google
  workload_identity_pool_id = "product-baseline-pool"
  display_name              = "GitHub Actions Pool"
  description               = "Workload Identity Pool for GitHub Actions"
  project                   = var.gcp_project_id
  disabled                  = false

  lifecycle {
    prevent_destroy = true
  }
}

# Workload Identity Provider for GitHub OIDC
# NOTE: This resource causes persistent 409 conflicts and is managed outside Terraform
# It's created/updated via gcloud commands in the GitHub Actions workflow
# See: .github/workflows/terraform.yml - "Create WIF Provider" step

# resource "google_iam_workload_identity_pool_provider" "github_provider" {
#   provider                           = google
#   workload_identity_pool_id          = google_iam_workload_identity_pool.github_pool.workload_identity_pool_id
#   workload_identity_pool_provider_id = "github-provider"
#   display_name                       = "GitHub Provider"
#   description                        = "OIDC provider for GitHub Actions"
#   project                            = var.gcp_project_id
#   disabled                           = false
#   attribute_condition                = "assertion.repository=='${var.github_repo}'"
#   attribute_mapping = {
#     "google.subject"             = "assertion.sub"
#     "attribute.repository"       = "assertion.repository"
#     "attribute.actor"            = "assertion.actor"
#     "attribute.aud"               = "assertion.aud"
#     "attribute.job_workflow_ref"  = "assertion.job_workflow_ref"
#   }
#   oidc {
#     issuer_uri = "https://token.actions.githubusercontent.com"
#   }
#
#   lifecycle {
#     prevent_destroy = true
#   }
# }

# Bind GitHub Actions service account to WIF
# NOTE: This is handled manually in the workflow to avoid permission issues
# The service account cannot set IAM policy on itself
# resource "google_service_account_iam_member" "github_actions_wif_binding" {
#   service_account_id = google_service_account.github_actions_sa.name
#   role               = "roles/iam.workloadIdentityUser"
#   member             = "principalSet://iam.googleapis.com/projects/${var.gcp_project_id}/locations/global/workloadIdentityPools/${google_iam_workload_identity_pool.github_pool.workload_identity_pool_id}/attribute.repository/${var.github_repo}"
# 
#   lifecycle {
#     prevent_destroy = true
#   }
# }

