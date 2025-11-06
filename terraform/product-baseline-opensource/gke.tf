# terraform/gke.tf

# --- GKE Cluster ---

# VPC Network for GKE
resource "google_compute_network" "vpc" {
  name                    = "gke-network"
  auto_create_subnetworks = false

  lifecycle {
    # Prevent destruction of the network if it causes issues
    prevent_destroy = false
    ignore_changes  = all
  }
}

# Subnetwork for GKE
resource "google_compute_subnetwork" "subnet" {
  name          = "gke-subnet"
  ip_cidr_range = "10.10.0.0/24"
  network       = google_compute_network.vpc.self_link
  region        = var.gcp_region

  lifecycle {
    # Prevent destruction of the subnet if it causes issues
    prevent_destroy = false
    ignore_changes  = all
  }
}

# GKE Cluster
resource "google_container_cluster" "primary" {
  name     = "product-baseline"
  location = var.gcp_region

  remove_default_node_pool = true
  initial_node_count       = 1
  deletion_protection      = false # Allow destruction

  network    = google_compute_network.vpc.self_link
  subnetwork = google_compute_subnetwork.subnet.self_link

  # Enable Workload Identity for pod-to-GCP service authentication
  workload_identity_config {
    workload_pool = "${var.gcp_project_id}.svc.id.goog"
  }

  # Enable GKE Dataplane V2 for improved networking performance
  datapath_provider = "ADVANCED_DATAPATH"
  # NetworkPolicy is not supported with ADVANCED_DATAPATH (Dataplane V2)
  # Dataplane V2 provides built-in network security features, so NetworkPolicy is not needed

  # Enable binary authorization (optional, can be enabled later)
  # binary_authorization {
  #   evaluation_mode = "PROJECT_SINGLETON_POLICY_ENFORCE"
  # }

  # Enable private cluster for better security (optional)
  # private_cluster_config {
  #   enable_private_nodes    = true
  #   enable_private_endpoint = false
  #   master_ipv4_cidr_block  = "172.16.0.0/28"
  # }

}

# GKE Node Pool
resource "google_container_node_pool" "primary_nodes" {
  name       = "primary-node-pool"
  location   = var.gcp_region
  cluster    = google_container_cluster.primary.name
  node_count = 2 # Increased from 1 to 2 nodes (fits within quota: 2 x 4 vCPU = 8 vCPU)

  # Enable automatic node repair
  management {
    auto_repair  = true
    auto_upgrade = true
  }

  node_config {
    preemptible  = true
    machine_type = "e2-standard-4" # Upgraded from e2-medium (2 vCPU) to e2-standard-4 (4 vCPU, 16 GB RAM)
    workload_metadata_config {
      mode = "GKE_METADATA"
    }

    oauth_scopes = [
      "https://www.googleapis.com/auth/cloud-platform"
    ]
  }
}

# --- Kubernetes Service Account for the Application ---
# Temporarily disabled to avoid Kubernetes API connection issues during infrastructure setup

# resource "kubernetes_service_account" "app_ksa" {
#   count = var.create_kubernetes_resources ? 1 : 0
#   
#   depends_on = [
#     google_container_cluster.primary,
#     google_container_node_pool.primary_nodes,
#     time_sleep.wait_for_cluster
#   ]
#   
#   metadata {
#     name      = "app-ksa"
#     namespace = "default" # This should be parameterized for different environments
#     annotations = {
#       "iam.gke.io/gcp-service-account" = google_service_account.gke_application_sa.email
#     }
#   }
# }

# Wait for cluster to be fully ready
resource "time_sleep" "wait_for_cluster" {
  depends_on = [google_container_cluster.primary, google_container_node_pool.primary_nodes]

  create_duration = "60s"
}

# Output cluster information for use in workflows
output "cluster_name" {
  description = "Name of the GKE cluster"
  value       = google_container_cluster.primary.name
}

output "cluster_location" {
  description = "Location of the GKE cluster"
  value       = google_container_cluster.primary.location
}

output "cluster_endpoint" {
  description = "Endpoint of the GKE cluster"
  value       = google_container_cluster.primary.endpoint
}

# Allow the Kubernetes Service Account to impersonate the Google Service Account
# Temporarily disabled to avoid Kubernetes API connection issues during infrastructure setup

# resource "google_service_account_iam_member" "gke_application_sa_impersonation" {
#   count = var.create_kubernetes_resources ? 1 : 0
#   
#   service_account_id = google_service_account.gke_application_sa.name
#   role               = "roles/iam.workloadIdentityUser"
#   member             = "serviceAccount:${var.gcp_project_id}.svc.id.goog[default/app-ksa]"
#   
#   depends_on = [kubernetes_service_account.app_ksa]
# }
