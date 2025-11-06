# Template Repository Reference

## Existing Template Repository

The `stevei101` organization maintains a template repository for new projects:

**Repository**: [stevei101/ibm-template-project](https://github.com/stevei101/ibm-template-project)

### Current Status
- **Status**: Nascent (minimal setup)
- **Purpose**: Template for new projects in the organization
- **Location**: https://github.com/stevei101/ibm-template-project

## Integration with Infrastructure Repositories

When creating new projects, you can leverage:

1. **Template Repository** (`ibm-template-project`)
   - Base project structure
   - Common files and configurations
   - Project scaffolding

2. **Infrastructure Repository** (`stevei101/infrastructure`)
   - Terraform configurations
   - Infrastructure as Code patterns
   - Reusable Terraform workflows

3. **Podman/Kustomize Repository** (`stevei101/podman-kustomize-k8s-deploy-gha`)
   - Container build workflows
   - Kubernetes deployment patterns
   - CI/CD templates

## Recommended Workflow for New Projects

### Step 1: Create from Template
```bash
# Use GitHub's template feature or clone
gh repo create my-new-project --template stevei101/ibm-template-project
```

### Step 2: Add Infrastructure
Reference the infrastructure repository for Terraform:
```yaml
# In .github/workflows/terraform.yml
jobs:
  terraform:
    uses: stevei101/infrastructure/.github/workflows/terraform-agentnav-reusable.yml@main
```

### Step 3: Add Container Builds
Reference the Podman/Kustomize repository:
```yaml
# In .github/workflows/build.yml
jobs:
  build:
    uses: stevei101/podman-kustomize-k8s-deploy-gha/.github/workflows/podman-build-reusable.yml@main
```

## Future Enhancements

Consider enhancing the template repository with:

- [ ] Common project structure (src/, tests/, docs/)
- [ ] Basic CI/CD workflow templates
- [ ] Common configuration files (.gitignore, .editorconfig, etc.)
- [ ] Documentation templates
- [ ] Links to infrastructure and deployment repositories
- [ ] Example integration with infrastructure repos

## Related Repositories

- **Template**: [stevei101/ibm-template-project](https://github.com/stevei101/ibm-template-project)
- **Infrastructure**: `stevei101/infrastructure` (FR 008)
- **Podman/Kustomize**: `stevei101/podman-kustomize-k8s-deploy-gha` (FR 009)

