# Repository Ecosystem Overview

This document describes how the various repositories in the `stevei101` organization work together to provide a complete development and deployment ecosystem.

## Repository Architecture

```
stevei101 Organization
│
├── 📦 Template Repository (Project Factory)
│   └── ibm-template-project
│       └── Base template for new projects
│
├── 🏗️ Infrastructure Repository (FR 008)
│   └── infrastructure
│       └── Terraform configs & workflows
│
├── 🐳 Podman/Kustomize Repository (FR 009)
│   └── podman-kustomize-k8s-deploy-gha
│       └── Container builds & K8s deployments
│
└── 📁 Project Repositories
    ├── agentnav
    ├── product-baseline-opensource
    └── (other projects...)
```

## Repository Roles

### 1. Template Repository: `ibm-template-project`

**Purpose**: Project factory/template for new projects  
**Location**: https://github.com/stevei101/ibm-template-project  
**Status**: Nascent (minimal setup)

**What it provides**:
- Base project structure
- Common configuration files
- Project scaffolding
- Starting point for new projects

**Usage**:
```bash
# Create new project from template
gh repo create my-new-project --template stevei101/ibm-template-project
```

### 2. Infrastructure Repository: `infrastructure`

**Purpose**: Centralized infrastructure as code  
**Created**: FR 008  
**Location**: `stevei101/infrastructure`

**What it provides**:
- Terraform configurations for all projects
- Reusable Terraform workflows
- Infrastructure patterns and best practices
- Terraform Cloud integration

**Usage**:
```yaml
# In project's .github/workflows/terraform.yml
jobs:
  terraform:
    uses: stevei101/infrastructure/.github/workflows/terraform-agentnav-reusable.yml@main
```

### 3. Podman/Kustomize Repository: `podman-kustomize-k8s-deploy-gha`

**Purpose**: Container builds and Kubernetes deployments  
**Created**: FR 009  
**Location**: `stevei101/podman-kustomize-k8s-deploy-gha`

**What it provides**:
- Podman container build workflows
- Kustomize Kubernetes deployment patterns
- Container orchestration configurations
- CI/CD templates for containers and K8s

**Usage**:
```yaml
# In project's .github/workflows/build.yml
jobs:
  build:
    uses: stevei101/podman-kustomize-k8s-deploy-gha/.github/workflows/podman-build-reusable.yml@main
```

## Workflow: Creating a New Project

### Step 1: Create from Template
```bash
gh repo create my-new-project --template stevei101/ibm-template-project
cd my-new-project
```

### Step 2: Add Infrastructure
Reference the infrastructure repository for Terraform:
```yaml
# .github/workflows/terraform.yml
name: Infrastructure

on:
  push:
    paths: ['terraform/**']

jobs:
  terraform:
    uses: stevei101/infrastructure/.github/workflows/terraform-agentnav-reusable.yml@main
    secrets:
      GCP_PROJECT_ID: ${{ secrets.GCP_PROJECT_ID }}
      TF_CLOUD_ORGANIZATION: ${{ secrets.TF_CLOUD_ORGANIZATION }}
      # ... other secrets
```

### Step 3: Add Container Builds
Reference the Podman/Kustomize repository:
```yaml
# .github/workflows/build.yml
name: Build Containers

on:
  push:
    paths: ['src/**']

jobs:
  build:
    uses: stevei101/podman-kustomize-k8s-deploy-gha/.github/workflows/podman-build-reusable.yml@main
    with:
      backend_path: 'src/API'
      frontend_path: 'src/UI'
    secrets:
      GCP_PROJECT_ID: ${{ secrets.GCP_PROJECT_ID }}
      WIF_PROVIDER: ${{ secrets.WIF_PROVIDER }}
      # ... other secrets
```

### Step 4: Add Kubernetes Deployments
Reference Kustomize patterns:
```yaml
# .github/workflows/deploy.yml
name: Deploy to K8s

jobs:
  deploy:
    uses: stevei101/podman-kustomize-k8s-deploy-gha/.github/workflows/k8s-deploy.yml@main
    with:
      environment: production
      image_tag: ${{ github.sha }}
```

## Benefits of This Architecture

### 1. **Reusability**
- Common patterns shared across projects
- Update once, apply everywhere
- Consistent practices organization-wide

### 2. **Separation of Concerns**
- Infrastructure code separate from application code
- Container builds separate from deployments
- Templates separate from implementations

### 3. **Maintainability**
- Centralized updates
- Version control for shared components
- Easier to maintain and evolve

### 4. **Onboarding**
- New projects start from template
- Clear integration points
- Well-documented patterns

### 5. **Scalability**
- Easy to add new projects
- Consistent structure
- Predictable workflows

## Integration Points

### Template → Infrastructure
- Template includes references to infrastructure workflows
- New projects automatically get infrastructure integration

### Template → Podman/Kustomize
- Template includes container build workflows
- New projects get deployment patterns

### Infrastructure ↔ Projects
- Projects reference infrastructure workflows
- Infrastructure contains project-specific configs

### Podman/Kustomize ↔ Projects
- Projects reference build/deploy workflows
- Podman/Kustomize provides reusable patterns

## Future Enhancements

### Template Repository
- [ ] Add common project structure
- [ ] Include workflow templates
- [ ] Add configuration file templates
- [ ] Link to infrastructure and deployment repos

### Infrastructure Repository
- [ ] Add more project configurations
- [ ] Create shared Terraform modules
- [ ] Add environment-specific overlays

### Podman/Kustomize Repository
- [ ] Add more deployment patterns
- [ ] Create Helm chart examples
- [ ] Add multi-cloud support

## Related Documentation

- [Template Repository Guide](TEMPLATE_REPOSITORY.md)
- [Infrastructure README](../README.md)
- [Podman/Kustomize README](../../podman-kustomize-k8s-deploy-gha/README.md)

## Quick Reference

| Repository | Purpose | Created | Status |
|------------|---------|---------|--------|
| `ibm-template-project` | Project template | Existing | Nascent |
| `infrastructure` | Terraform/IaC | FR 008 | Ready |
| `podman-kustomize-k8s-deploy-gha` | Containers/K8s | FR 009 | Ready |

