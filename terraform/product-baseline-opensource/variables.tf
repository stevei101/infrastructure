# variables.tf

variable "gcp_project_id" {
  description = "The GCP project ID to create resources in."
  type        = string
}

variable "bucket_name" {
  description = "The name of the GCS bucket for frontend hosting. If not set, defaults to {project_id}-frontend-bucket"
  type        = string
  default     = ""
}

variable "gcp_region" {
  description = "The GCP region to create resources in."
  default     = "us-central1"
}

variable "environment" {
  description = "The environment (e.g., 'development', 'production')."
  default     = "development"
}

variable "tfc_workspace_prefix" {
  description = "The prefix for Terraform Cloud workspace names."
  type        = string
  default     = "product-baseline-opensource"
}

variable "POSTGRES_PASSWORD" {
  description = "The password for the PostgreSQL database."
  type        = string
  sensitive   = true
}

variable "github_organization" {
  description = "The GitHub organization name."
  type        = string
  default     = "stevei101"
}

variable "GCP_SA_KEY" {
  description = "The Google Cloud Service Account key (if needed)."
  type        = string
  sensitive   = true
  default     = ""
}

variable "create_new_resources" {
  description = "Whether to create new resources or import existing ones."
  type        = bool
  default     = false
}

variable "github_repository" {
  description = "The GitHub repository name."
  type        = string
  default     = "stevei101/product-baseline-opensource"
}

variable "github_repo" {
  description = "The GitHub repository in the format 'owner/repo' for WIF attribute conditions."
  type        = string
  default     = "stevei101/product-baseline-opensource"
}

variable "create_kubernetes_resources" {
  description = "Whether to create Kubernetes resources (service accounts, etc.)"
  type        = bool
  default     = false
}

variable "google_access_token" {
  description = "Google Cloud access token for authentication."
  type        = string
  sensitive   = true
  default     = ""
}

variable "cert_manager_email" {
  description = "Email address for Let's Encrypt certificate notifications."
  type        = string
  default     = "admin@lornu.com"
}

variable "cert_manager_create_staging" {
  description = "Whether to create a staging Let's Encrypt issuer for testing."
  type        = bool
  default     = false
}
