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

### Security Scanning with TFSec

The repository includes automated TFSec security scanning:

- **Workflow**: `.github/workflows/tfsec-scan.yml`
- **Reusable Workflow**: `.github/workflows/tfsec-scan-reusable.yml`
- **Scans**: All Terraform configurations for security vulnerabilities
- **Runs**: On push, pull requests, and manual triggers

**Using the reusable workflow in your project:**

```yaml
# In your project's .github/workflows/security.yml
jobs:
  tfsec:
    permissions:
      contents: read
      pull-requests: write
      security-events: write
    uses: stevei101/infrastructure/.github/workflows/tfsec-scan-reusable.yml@v1.0.0
    with:
      terraform_path: 'terraform'
      minimum_severity: 'MEDIUM'
      fail_on_issues: true
```

### Using GitHub Actions Workflows

The workflows in `.github/workflows/` are designed to be called from the respective project repositories via `uses:`. Each project repository should reference these workflows and pass the Terraform directory and apply behaviour explicitly.

**Example** (project repository `.github/workflows/terraform.yml`):

```yaml
name: Infrastructure Verification

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
    uses: stevei101/infrastructure/.github/workflows/terraform-agentnav.yml@<tag>
    with:
      terraform_directory: terraform
      run_apply: false
    secrets: inherit
```

The reusable workflow already has access to the default `github.token`, so additional secrets are not required for posting plan comments as long as the calling workflow grants `pull-requests: write` permissions.

### Shared Terraform Modules

Shared modules (for example `