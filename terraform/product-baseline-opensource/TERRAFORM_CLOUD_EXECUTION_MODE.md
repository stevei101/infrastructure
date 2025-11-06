# Terraform Cloud Execution Mode Configuration

## Issue
When Terraform Cloud runs in **remote execution mode**, the Helm provider cannot refresh state because:
- kubectl and helm are not available in the remote execution environment
- The Kubernetes cluster connection requires tools that aren't installed in Terraform Cloud runners

## Solution: Use Local Execution Mode

### Steps to Configure

1. **Go to Terraform Cloud Workspace**
   - Navigate to: https://app.terraform.io/app/disposable-org/workspaces/product-baseline-opensource

2. **Open Workspace Settings**
   - Click "Settings" > "General Settings"

3. **Change Execution Mode**
   - Scroll to "Execution Mode" section
   - Select **"Local"** instead of "Remote"
   - Click "Save settings"

### Why Local Execution Works

Local execution mode means:
- Terraform runs in **GitHub Actions** (not Terraform Cloud runners)
- GitHub Actions has kubectl, helm, and gcloud pre-installed
- The Helm provider can successfully connect to the GKE cluster
- All tools required for Kubernetes/Helm operations are available

### Alternative: Manual cert-manager Management

If you need to keep remote execution mode:
1. Remove `helm_release.cert_manager` from Terraform
2. Manage cert-manager separately via Helm in GitHub Actions
3. Keep only ClusterIssuer resources in Terraform (these use kubernetes_manifest which works with remote execution)

### Current Configuration

The workflow sets `TF_CLOUD_WORKSPACE_EXECUTION_MODE: "local"` but this may be overridden by workspace settings.

**Action Required**: Verify the workspace is set to "Local" execution mode in Terraform Cloud UI.

