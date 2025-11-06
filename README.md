# Infrastructure as Code Repository

This repository contains shared infrastructure code for all projects in the `stevei101` GitHub organization. It centralizes Terraform configurations and GitHub Actions workflows for infrastructure management.

## Repository Structure

```
infrastructure/
├── .github/
│   └── workflows/
│       ├── terraform-agentnav.yml          # Terraform workflow for agentnav
│       └── terraform-product-baseline.yml  # Terraform workflow for product-baseline-opensource
├── terraform/
│   ├── agentnav/                           # Terraform config for agentnav project
│   └── product-baseline-opensource/        # Terraform config for product-baseline-opensource
└── docs/                                   # Documentation
```

## Overview

This repository was created as part of **FR 008** to extract GitHub Actions (GHA) workflows and Terraform Cloud configurations from individual project repositories into a centralized infrastructure repository.

### Benefits

- **Centralized Management**: All infrastructure code in one place
- **Reusability**: Shared workflows and patterns across projects
- **Consistency**: Standardized infrastructure practices
- **Easier Maintenance**: Update infrastructure code once, apply to all projects

## Projects

### agentnav

Terraform configuration for the Agentic Navigator project, including:
- Workload Identity Federation (WIF) for GitHub Actions
- Cloud Run services (frontend, backend, staging)
- Artifact Registry
- Firestore database
- Secret Manager
- Cloud Build triggers

**Terraform Cloud Workspace**: `disposable-org/agentnav`

### product-baseline-opensource

Terraform configuration for the Product Baseline Open Source project, including:
- GKE cluster
- Workload Identity Federation
- Artifact Registry
- GCS buckets
- DNS configuration
- IAM policies

**Terraform Cloud Workspace**: `disposable-org/product-baseline-opensource`

## Usage

### Running Terraform Locally

1. Navigate to the project's Terraform directory:
   ```bash
   cd terraform/agentnav  # or terraform/product-baseline-opensource
   ```

2. Initialize Terraform:
   ```bash
   terraform init
   ```

3. Create a `terraform.tfvars` file (see `terraform.tfvars.example` in each project directory)

4. Plan and apply:
   ```bash
   terraform plan
   terraform apply
   ```

### Using GitHub Actions Workflows

The workflows in `.github/workflows/` are designed to be called from the respective project repositories. Each project repository should reference these workflows using the `workflow_call` trigger.

**Example** (in project repository's workflow file):

```yaml
name: Infrastructure Verification

on:
  workflow_call:
  push:
    paths:
      - 'terraform/**'
      - '.github/workflows/terraform.yml'

jobs:
  terraform:
    uses: stevei101/infrastructure/.github/workflows/terraform-agentnav.yml@main
```

## Terraform Cloud Configuration

Both projects use Terraform Cloud for remote state management:

- **Organization**: `disposable-org`
- **Workspaces**: 
  - `agentnav`
  - `product-baseline-opensource`

### Required Secrets

Each project requires the following GitHub Secrets:

- `GCP_PROJECT_ID` - Google Cloud Project ID
- `TF_CLOUD_ORGANIZATION` - Terraform Cloud organization name
- `TF_WORKSPACE` - Terraform Cloud workspace name
- `TF_API_TOKEN` - Terraform Cloud API token
- `WIF_PROVIDER` - Workload Identity Federation provider
- `WIF_SERVICE_ACCOUNT` - Workload Identity Federation service account email

## Migration Notes

This repository was created by extracting infrastructure code from:
- `stevei101/agentnav` → `infrastructure/terraform/agentnav/`
- `stevei101/product-baseline-opensource` → `infrastructure/terraform/product-baseline-opensource/`

The original project repositories should be updated to reference this infrastructure repository for Terraform operations.

## Related Repositories

- **Template Repository**: [stevei101/ibm-template-project](https://github.com/stevei101/ibm-template-project) - Template for new projects
- **Podman/Kustomize**: `stevei101/podman-kustomize-k8s-deploy-gha` - Container builds and K8s deployments (FR 009)

## Contributing

When adding new infrastructure:

1. Create a new directory under `terraform/` for your project
2. Add a corresponding workflow file in `.github/workflows/`
3. Update this README with project details
4. Follow the existing patterns for consistency

## Documentation

- [Agentnav Terraform README](terraform/agentnav/README.md)
- [Product Baseline Terraform Documentation](terraform/product-baseline-opensource/)

## License

This repository follows the same license as the parent organization's projects.

