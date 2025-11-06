# Cert-Manager Managed by Terraform

## Overview

Cert-manager and ClusterIssuer resources are now managed by Terraform instead of Helm. This breaks the circular dependency that was causing deployment issues.

## Architecture

### Before (Circular Dependency)
1. Helm tries to deploy Ingress → needs TLS secret
2. Cert-manager should create secret → but might not be ready
3. Certificate resource in Helm → depends on cert-manager being ready
4. Circular: Ingress needs secret, secret needs Certificate, Certificate needs ClusterIssuer, ClusterIssuer needs cert-manager

### After (Managed by Terraform)
1. **Terraform** deploys cert-manager via Helm provider
2. **Terraform** creates ClusterIssuer (`letsencrypt-prod`)
3. **Helm** deploys Ingress with `cert-manager.io/cluster-issuer: "letsencrypt-prod"` annotation
4. **Cert-manager** automatically watches Ingress and creates Certificate
5. **Certificate** creates TLS secret
6. **Ingress** uses the secret

## Benefits

- **No circular dependencies**: Terraform ensures infrastructure (cert-manager) is ready before Helm deploys applications
- **Clear separation**: Infrastructure (Terraform) vs Applications (Helm)
- **Automatic certificate creation**: Cert-manager watches Ingress annotations and creates certificates automatically
- **Idempotent**: Terraform manages cert-manager lifecycle

## Terraform Resources

- `helm_release.cert_manager`: Installs cert-manager via Helm
- `time_sleep.cert_manager_ready`: Waits for cert-manager to be ready
- `kubernetes_manifest.letsencrypt_prod_issuer`: Creates production ClusterIssuer
- `kubernetes_manifest.letsencrypt_staging_issuer`: Optional staging ClusterIssuer for testing

## Variables

- `cert_manager_email`: Email for Let's Encrypt notifications (default: `admin@lornu.com`)
- `cert_manager_create_staging`: Whether to create staging issuer (default: `false`)

## Deployment Order

1. Run `terraform apply` to ensure cert-manager and ClusterIssuer exist
2. Run Helm deployment - it will verify cert-manager exists before proceeding
3. Helm creates Ingress with cert-manager annotation
4. Cert-manager automatically creates Certificate and TLS secret

## How Certificates Are Created

When Helm creates the Ingress with the annotation `cert-manager.io/cluster-issuer: "letsencrypt-prod"`, cert-manager's ingress-shim controller:
1. Detects the annotation
2. Automatically creates a Certificate resource
3. Certificate uses the ClusterIssuer to obtain Let's Encrypt certificate
4. Certificate stores the result in a TLS secret
5. Ingress uses the TLS secret

**No explicit Certificate resource needed in Helm** - the annotation is sufficient!

