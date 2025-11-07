variable "project_id" {
  description = "GCP project identifier containing the workload identity resources."
  type        = string
}

variable "service_account" {
  description = <<-EOT
  Configuration for the Google service account that will be associated with Workload Identity bindings.
  When `create` is `true`, the module will create the service account using the supplied metadata. When `create`
  is `false`, the `email` attribute must reference an existing service account.
  EOT
  type = object({
    create       = optional(bool, true)
    account_id   = optional(string)
    display_name = optional(string)
    description  = optional(string)
    email        = optional(string)
    roles        = optional(list(string), [])
  })
  default = {
    create = false
    roles  = []
  }

  validation {
    condition = (
      (try(var.service_account.create, false) && try(var.service_account.account_id, "") != "") ||
      (!try(var.service_account.create, false) && try(var.service_account.email, "") != "")
    )
    error_message = "When creating a service account, `account_id` must be provided. When not creating a service account, `email` must be provided."
  }
}

variable "workload_identity_pool" {
  description = <<-EOT
  Optional workload identity pool configuration. When null, the module will not manage a pool. When provided, the
  `id` field is required. Set `create = false` to reference an existing pool without managing its lifecycle.
  EOT
  type = object({
    create       = optional(bool, true)
    id           = string
    display_name = optional(string)
    description  = optional(string)
    disabled     = optional(bool, false)
  })
  default  = null
  nullable = true

  validation {
    condition     = var.workload_identity_pool == null ? true : length(var.workload_identity_pool.id) > 0
    error_message = "`workload_identity_pool.id` must be supplied when configuring a workload identity pool."
  }
}

variable "identity_providers" {
  description = <<-EOT
  Map of Workload Identity Pool providers to create. Keys map to the provider ID. Attribute mappings must contain
  at least one entry. Provider creation requires a workload identity pool configuration.
  EOT
  type = map(object({
    display_name        = optional(string)
    description         = optional(string)
    attribute_mapping   = optional(map(string), {})
    attribute_condition = optional(string)
    issuer_uri          = string
    allowed_audiences   = optional(list(string), [])
    disabled            = optional(bool, false)
  }))
  default = {}

  validation {
    condition = alltrue([
      for provider in values(var.identity_providers) : length(try(provider.attribute_mapping, {})) > 0
    ])
    error_message = "Each provider must supply at least one attribute mapping."
  }
}

variable "workload_identity_bindings" {
  description = <<-EOT
  List of Workload Identity bindings granting `roles/iam.workloadIdentityUser` (or custom roles) to principals such
  as GitHub repositories, Cloud Run services, or GKE service accounts. Conditions are optional.
  EOT
  type = list(object({
    member = string
    role   = optional(string, "roles/iam.workloadIdentityUser")
    condition = optional(object({
      title       = string
      expression  = string
      description = optional(string)
    }), null)
  }))
  default = []
}

