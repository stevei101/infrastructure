# Migration Guide: Extracting GHA/Terraform Cloud Code (FR 008)

This guide documents the migration of GitHub Actions workflows and Terraform Cloud configurations from individual project repositories to the centralized `stevei101/infrastructure` repository.

## Overview

**Feature Request**: FR 008  
**Goal**: Extract GitHub Actions (GHA) workflows and Terraform Cloud code into a new sub-repository in the `stevei101` GitHub organization.

## What Was Extracted

### From `stevei101/agentnav`
- `.github/workflows/terraform.yml` → `infrastructure/.github/workflows/terraform-agentnav.yml`
- `terraform/` directory → `infrastructure/terraform/agentnav/`

### From `stevei101/product-baseline-opensource`
- `.github/workflows/terraform.yml` → `infrastructure/.github/workflows/terraform-product-baseline.yml`
- `terraform/` directory → `infrastructure/terraform/product-baseline-opensource/`

## New Repository Structure

```
stevei101/infrastructure/
├── .github/
│   └── workflows/
│       ├── terraform-agentnav-reusable.yml    # Reusable workflow for agentnav
│       ├── terraform-agentnav.yml             # Original workflow (for reference)
│       └── terraform-product-baseline.yml     # Original workflow (for reference)
├── terraform/
│   ├── agentnav/                              # Agentnav Terraform config
│   └── product-baseline-opensource/           # Product Baseline Terraform config
├── docs/
│   └── MIGRATION_GUIDE.md                     # This file
└── README.md                                  # Main repository documentation
```

## Migration Steps

### Step 1: Create the Infrastructure Repository

1. Create a new repository `stevei101/infrastructure` in GitHub
2. Initialize with the extracted code from this branch
3. Set up repository secrets (see below)

### Step 2: Update Project Repositories

#### For `stevei101/agentnav`

1. **Remove the old Terraform workflow**:
   ```bash
   rm .github/workflows/terraform.yml
   ```

2. **Create a new workflow that calls the reusable workflow**:
   Create `.github/workflows/terraform.yml`:
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

The reusable workflow already has access to the default `github.token`, so no additional secret is required for posting Terraform plan comments.

3. **Remove the Terraform directory** (or keep as a reference):
   ```bash
   # Option 1: Remove completely
   rm -rf terraform/
   
   # Option 2: Keep as reference (add to .gitignore)
   echo "terraform/" >> .gitignore
   ```

#### For `stevei101/product-baseline-opensource`

Similar steps as above, but use `terraform-product-baseline-reusable.yml` (if created) or adapt the workflow.

### Step 3: Set Up Infrastructure Repository Secrets

The infrastructure repository needs the same secrets as the project repositories. These should be configured in the `stevei101/infrastructure` repository settings:

- `GCP_PROJECT_ID`
- `TF_CLOUD_ORGANIZATION`
- `TF_WORKSPACE` (for each project)
- `TF_API_TOKEN`
- `WIF_PROVIDER`
- `WIF_SERVICE_ACCOUNT`

**Note**: If using reusable workflows, secrets are passed from the calling repository, so they may not be needed in the infrastructure repo itself.

### Step 4: Update Documentation

1. Update project README files to reference the infrastructure repository
2. Update any documentation that references local Terraform paths
3. Add notes about where infrastructure code is now located

### Step 5: Test the Migration

1. Make a test change to Terraform code in the infrastructure repository
2. Verify the workflow runs correctly
3. Check that Terraform Cloud integration still works
4. Verify PR comments are posted correctly

## Benefits of This Migration

1. **Centralized Management**: All infrastructure code in one place
2. **Reusability**: Shared workflows can be used across projects
3. **Consistency**: Standardized infrastructure practices
4. **Easier Maintenance**: Update infrastructure code once, apply to all projects
5. **Separation of Concerns**: Infrastructure code separate from application code

## Rollback Plan

If issues arise, you can rollback by:

1. Restore the original workflows and Terraform directories in project repositories
2. Revert the infrastructure repository changes
3. Update project repositories to use the original workflows

## Future Enhancements

- Create more reusable workflows for common infrastructure patterns
- Add shared Terraform modules
- Create templates for new projects
- Automate infrastructure updates across projects

## Questions or Issues?

If you encounter issues during migration:

1. Check the infrastructure repository workflows
2. Verify all secrets are configured correctly
3. Ensure Terraform Cloud workspaces are accessible
4. Review workflow logs for specific errors

## Related Documentation

- [Infrastructure Repository README](../README.md)
- [Agentnav Terraform README](../terraform/agentnav/README.md)
- [Product Baseline Terraform Documentation](../terraform/product-baseline-opensource/)

