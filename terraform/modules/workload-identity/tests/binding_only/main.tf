terraform {
  required_version = ">= 1.5.0"

  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "~> 5.0"
    }
  }
}

module "workload_identity" {
  source = "../.."

  project_id = "test-project"

  service_account = {
    create = false
    email  = "existing@test-project.iam.gserviceaccount.com"
  }

  workload_identity_bindings = [
    {
      member = "serviceAccount:test-project.svc.id.goog[default/app-ksa]"
    }
  ]
}
