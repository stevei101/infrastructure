# terraform/iam-policies.tf

# --- GKE Application Service Account ---

# Dedicated Service Account for the GKE application workload
resource "google_service_account" "gke_application_sa" {
  account_id   = "gke-application-sa"
  display_name = "GKE Application Service Account"
  description  = "Service account for the application running in GKE"

  lifecycle {
    ignore_changes = all
  }
}

# Grant Storage Object Viewer role to the application service account
resource "google_project_iam_member" "app_storage_viewer" {
  project = var.gcp_project_id
  role    = "roles/storage.objectViewer"
  member  = "serviceAccount:${google_service_account.gke_application_sa.email}"
}

# Grant Kubernetes Engine Admin role for cluster management
# Now that GitHub Actions service account has resourcemanager.projectIamAdmin role
resource "google_project_iam_member" "app_k8s_admin" {
  project = var.gcp_project_id
  role    = "roles/container.admin"
  member  = "serviceAccount:${google_service_account.gke_application_sa.email}"
}

# Grant Kubernetes Engine Developer role for application deployment
resource "google_project_iam_member" "app_k8s_developer" {
  project = var.gcp_project_id
  role    = "roles/container.developer"
  member  = "serviceAccount:${google_service_account.gke_application_sa.email}"
}

# Grant Kubernetes Engine Cluster Admin role for Cert-Manager installation
# This allows creating ClusterRoles and ClusterRoleBindings
resource "google_project_iam_member" "app_k8s_cluster_admin" {
  project = var.gcp_project_id
  role    = "roles/container.clusterAdmin"
  member  = "serviceAccount:${google_service_account.gke_application_sa.email}"
}

# Trigger Terraform workflow - Add Cluster Admin permissions for Cert-Manager

