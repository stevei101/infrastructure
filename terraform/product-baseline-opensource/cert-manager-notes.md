# Cert-Manager Management Strategy

Cert-manager installation has been moved OUT of Terraform because:
- Terraform Cloud runs in remote execution mode (no gcloud/kubectl/helm available)
- `local-exec` provisioners run in Terraform Cloud runners, not GitHub Actions

## Solution: Install cert-manager in GitHub Actions workflow

Cert-manager is now installed in `.github/workflows/terraform.yml` AFTER Terraform apply completes.
This ensures gcloud/helm/kubectl are available.

## Terraform resources

The `cert-manager.tf` file now only contains:
- ClusterIssuer configuration notes (for reference)
- The actual installation happens in GitHub Actions

