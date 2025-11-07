locals {
  service_account_config = {
    create          = try(var.service_account.create, false)
    account_id      = try(var.service_account.account_id, null)
    display_name    = try(var.service_account.display_name, null)
    description     = try(var.service_account.description, null)
    email           = try(var.service_account.email, null)
    roles           = try(var.service_account.roles, [])
    prevent_destroy = try(var.service_account.prevent_destroy, true)
  }

  create_service_account = local.service_account_config.create
  service_account_email  = local.create_service_account ? google_service_account.this[0].email : local.service_account_config.email
  service_account_name = local.create_service_account ? google_service_account.this[0].name : (
    local.service_account_config.email == null ? null : format("projects/%s/serviceAccounts/%s", var.project_id, local.service_account_config.email)
  )

  workload_identity_pool_config = var.workload_identity_pool
  create_workload_identity_pool = local.workload_identity_pool_config != null && try(local.workload_identity_pool_config.create, true)
  workload_identity_pool_id     = local.workload_identity_pool_config == null ? null : local.workload_identity_pool_config.id
  workload_identity_pool_name = local.create_workload_identity_pool ? google_iam_workload_identity_pool.this[0].name : (
    local.workload_identity_pool_config == null ? null : format("projects/%s/locations/global/workloadIdentityPools/%s", var.project_id, local.workload_identity_pool_config.id)
  )
}

resource "google_service_account" "this" {
  count = local.create_service_account ? 1 : 0

  project      = var.project_id
  account_id   = local.service_account_config.account_id
  display_name = coalesce(local.service_account_config.display_name, local.service_account_config.account_id)
  description  = local.service_account_config.description

  lifecycle {
    prevent_destroy = true
  }
}

resource "google_project_iam_member" "service_account_roles" {
  for_each = local.service_account_email == null ? {} : { for role in local.service_account_config.roles : role => role }

  project = var.project_id
  role    = each.value
  member  = "serviceAccount:${local.service_account_email}"
}

resource "google_iam_workload_identity_pool" "this" {
  count = local.create_workload_identity_pool ? 1 : 0

  project                   = var.project_id
  workload_identity_pool_id = local.workload_identity_pool_config.id
  display_name              = coalesce(try(local.workload_identity_pool_config.display_name, null), local.workload_identity_pool_config.id)
  description               = try(local.workload_identity_pool_config.description, null)
  disabled                  = try(local.workload_identity_pool_config.disabled, false)

  lifecycle {
    prevent_destroy = true
  }
}

resource "google_iam_workload_identity_pool_provider" "oidc" {
  for_each = var.identity_providers

  project                            = var.project_id
  workload_identity_pool_id          = local.workload_identity_pool_id
  workload_identity_pool_provider_id = each.key
  display_name                       = coalesce(try(each.value.display_name, null), each.key)
  description                        = try(each.value.description, null)
  attribute_mapping                  = try(each.value.attribute_mapping, {})
  attribute_condition                = try(each.value.attribute_condition, null)
  disabled                           = try(each.value.disabled, false)

  oidc {
    issuer_uri        = each.value.issuer_uri
    allowed_audiences = try(each.value.allowed_audiences, [])
  }

  lifecycle {
    prevent_destroy = true

    precondition {
      condition     = local.workload_identity_pool_id != null
      error_message = "identity_providers requires `workload_identity_pool` configuration."
    }
  }

  depends_on = [google_iam_workload_identity_pool.this]
}

resource "google_service_account_iam_member" "workload_identity_bindings" {
  for_each = {
    for idx, binding in var.workload_identity_bindings : tostring(idx) => binding
  }

  service_account_id = local.service_account_name
  role               = lookup(each.value, "role", "roles/iam.workloadIdentityUser")
  member             = each.value.member

  dynamic "condition" {
    for_each = each.value.condition == null ? [] : [each.value.condition]
    content {
      title       = condition.value.title
      expression  = condition.value.expression
      description = try(condition.value.description, null)
    }
  }

  lifecycle {
    precondition {
      condition     = local.service_account_name != null
      error_message = "workload_identity_bindings requires a target service account email when not creating a new account."
    }
  }
}

