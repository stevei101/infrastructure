# Workload Identity Module

Reusable Terraform module that provisions Google Cloud Workload Identity components for both CI/CD federation (GitHub
Actions) and runtime identity bindings (GKE or Cloud Run). The module optionally creates a service account, manages a
Workload Identity Pool and associated providers, and grants `roles/iam.workloadIdentityUser` (or custom roles) to
authorized principals.

## Features

- Optional creation of a dedicated Google service account with project-level role bindings
- Workload Identity Pool management with lifecycle controls
- Multiple OIDC providers with custom attribute mappings and conditions
- Flexible Workload Identity bindings for GitHub repositories, GKE service accounts, and other principals
- Defensive input validation to prevent misconfiguration

## Usage

```hcl
module "github_wif" {
  source     = "../../modules/workload-identity"
  project_id = var.project_id

  service_account = {
    create       = true
    account_id   = "github-actions"
    display_name = "GitHub Actions CI"
    roles = [
      "roles/run.admin",
      "roles/artifactregistry.writer"
    ]
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
        "attribute.actor"      = "assertion.actor"
      }
      attribute_condition = "assertion.repository=='${var.github_repository}'"
    }
  }

  workload_identity_bindings = [
    {
      member = "principalSet://iam.googleapis.com/projects/${var.project_number}/locations/global/workloadIdentityPools/github-actions-pool/attribute.repository/${var.github_repository}"
    }
  ]
}

# Bind a GKE service account to the same Google service account
module "gke_identity" {
  source     = "../../modules/workload-identity"
  project_id = var.project_id

  service_account = {
    create = false
    email  = module.github_wif.service_account_email
  }

  workload_identity_bindings = [
    {
      member = "serviceAccount:${var.project_id}.svc.id.goog[default/app-ksa]"
    }
  ]
}
```

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|----------|
| `project_id` | GCP project containing the resources | `string` | n/a | yes |
| `service_account` | Service account configuration (create or reference existing) | `object` | `{ create = false, roles = [] }` | no |
| `workload_identity_pool` | Workload Identity Pool settings (optional) | `object` | `null` | no |
| `identity_providers` | Map of Workload Identity providers keyed by provider ID | `map(object)` | `{}` | no |
| `workload_identity_bindings` | List of Workload Identity bindings for principals | `list(object)` | `[]` | no |

Refer to `variables.tf` for full attribute documentation and validation logic.

## Outputs

| Name | Description |
|------|-------------|
| `service_account_email` | Email for the managed or referenced service account |
| `service_account_name` | Fully qualified resource name for the service account |
| `workload_identity_pool_name` | Resource name of the Workload Identity Pool (if managed) |
| `workload_identity_pool_id` | Pool identifier (if configured) |
| `provider_resource_names` | Map of provider IDs to resource names |

## Testing

Run `tests/run-tests.sh` from this module directory to initialize and validate the bundled Terraform fixtures for both
module configurations (GitHub Actions federation and existing service account bindings). The script uses local fixtures,
so no cloud credentials are required.

