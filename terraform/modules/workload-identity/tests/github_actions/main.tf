terraform {
  required_version = ">= 1.5.0"

  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "~> 5.0"
    }
  }
}

module "workload_identity" {
  source = "../.."

  project_id = "test-project"

  service_account = {
    create       = true
    account_id   = "github-actions"
    display_name = "GitHub Actions CI"
    roles        = ["roles/run.admin"]
  }

  workload_identity_pool = {
    id          = "github-actions-pool"
    display_name = "GitHub Actions"
  }

  identity_providers = {
    "github-provider" = {
      issuer_uri = "https://token.actions.githubusercontent.com"
      attribute_mapping = {
        "google.subject"       = "assertion.sub"
        "attribute.repository" = "assertion.repository"
      }
      attribute_condition = "assertion.repository=='org/repo'"
    }
  }

  workload_identity_bindings = [
    {
      member = "principalSet://iam.googleapis.com/projects/123456789/locations/global/workloadIdentityPools/github-actions-pool/attribute.repository/org/repo"
    }
  ]
}
