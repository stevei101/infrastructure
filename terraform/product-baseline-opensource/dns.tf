# Cloud DNS Zone for lornu.com
resource "google_dns_managed_zone" "lornu_zone" {
  name        = "lornu-com"
  dns_name    = "lornu.com."
  description = "DNS zone for lornu.com domain"

  labels = {
    environment = var.environment
  }
}

# DNS A record for productbaseline subdomain
resource "google_dns_record_set" "productbaseline_a" {
  name = "productbaseline.${google_dns_managed_zone.lornu_zone.dns_name}"
  type = "A"
  ttl  = 300

  managed_zone = google_dns_managed_zone.lornu_zone.name

  rrdatas = [google_compute_global_address.ingress_ip.address]

  depends_on = [
    google_dns_managed_zone.lornu_zone,
    google_compute_global_address.ingress_ip
  ]
}

# Reserve a static IP for the ingress
resource "google_compute_global_address" "ingress_ip" {
  name         = "productbaseline-ingress-ip"
  description  = "Static IP for productbaseline.lornu.com"
  address_type = "EXTERNAL"

  labels = {
    environment = var.environment
  }
}

# Output the nameservers for domain configuration
output "nameservers" {
  description = "Nameservers to configure at your domain registrar"
  value       = google_dns_managed_zone.lornu_zone.name_servers
}

output "ingress_ip" {
  description = "Static IP address for the ingress"
  value       = google_compute_global_address.ingress_ip.address
}

# Trigger Terraform workflow - Force run
