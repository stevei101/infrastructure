# Example Project Workflow: Using Infrastructure Repository

This document shows how project repositories should call the reusable workflows from the infrastructure repository.

## For agentnav Project

Create or update `.github/workflows/terraform.yml` in the `stevei101/agentnav` repository:

```yaml
name: INFRA_VERIFICATION

on:
  push:
    branches: ['**']
    paths:
      - 'terraform/**'
      - '.github/workflows/terraform.yml'
  pull_request:
    branches:
      - main
    paths:
      - 'terraform/**'
      - '.github/workflows/terraform.yml'

jobs:
  terraform:
    uses: stevei101/infrastructure/.github/workflows/terraform-agentnav-reusable.yml@main
    secrets:
      GCP_PROJECT_ID: ${{ secrets.GCP_PROJECT_ID }}
      TF_CLOUD_ORGANIZATION: ${{ secrets.TF_CLOUD_ORGANIZATION }}
      TF_WORKSPACE: ${{ secrets.TF_WORKSPACE }}
      TF_API_TOKEN: ${{ secrets.TF_API_TOKEN }}
      WIF_PROVIDER: ${{ secrets.WIF_PROVIDER }}
      WIF_SERVICE_ACCOUNT: ${{ secrets.WIF_SERVICE_ACCOUNT }}
```

## For product-baseline-opensource Project

Create or update `.github/workflows/terraform.yml` in the `stevei101/product-baseline-opensource` repository:

```yaml
name: 'Terraform Cloud'

on:
  push:
    branches: [ main, flux-kustomize ]
    paths: 
      - 'terraform/**'
      - '.github/workflows/terraform.yml'
      - '**/*.tf'
      - '**/*.tfvars'
      - '**/*.tfvars.json'
  pull_request:
    branches: [ main, flux-kustomize ]
    paths:
      - 'terraform/**'
      - '.github/workflows/terraform.yml'
      - '**/*.tf'
      - '**/*.tfvars'
      - '**/*.tfvars.json'
  workflow_dispatch:
    inputs:
      environment:
        description: 'Environment to deploy to'
        required: true
        default: 'development'
        type: choice
        options:
          - development
          - staging
          - production
      destroy:
        description: 'Destroy all resources?'
        required: false
        default: 'false'
        type: boolean

jobs:
  terraform:
    # Note: A reusable workflow for product-baseline would need to be created
    # For now, you can keep the original workflow or adapt it to call the infrastructure repo
    uses: stevei101/infrastructure/.github/workflows/terraform-product-baseline-reusable.yml@main
    secrets:
      GCP_PROJECT_ID: ${{ secrets.GCP_PROJECT_ID }}
      TF_CLOUD_ORGANIZATION: ${{ secrets.TF_CLOUD_ORGANIZATION }}
      TF_WORKSPACE: ${{ secrets.TF_WORKSPACE }}
      TF_API_TOKEN: ${{ secrets.TF_API_TOKEN }}
      WIF_PROVIDER: ${{ secrets.WIF_PROVIDER }}
      WIF_SERVICE_ACCOUNT: ${{ secrets.WIF_SERVICE_ACCOUNT }}
```

## Required GitHub Secrets

Each project repository must have the following secrets configured (the reusable workflow receives the default `github.token` automatically, so no additional secret is needed for PR comments):

- `GCP_PROJECT_ID` - Google Cloud Project ID
- `TF_CLOUD_ORGANIZATION` - Terraform Cloud organization name (e.g., `disposable-org`)
- `TF_WORKSPACE` - Terraform Cloud workspace name (e.g., `agentnav` or `product-baseline-opensource`)
- `TF_API_TOKEN` - Terraform Cloud API token
- `WIF_PROVIDER` - Workload Identity Federation provider
- `WIF_SERVICE_ACCOUNT` - Workload Identity Federation service account email

## Alternative: Direct Workflow (Not Recommended)

If you prefer not to use reusable workflows, you can keep the original workflow files in project repositories, but they should reference the Terraform code from the infrastructure repository:

```yaml
- name: Checkout infrastructure repository
  uses: actions/checkout@v4
  with:
    repository: stevei101/infrastructure
    path: infrastructure

- name: Terraform Init
  working-directory: infrastructure/terraform/agentnav
  run: terraform init
```

However, using reusable workflows is recommended for consistency and easier maintenance.

