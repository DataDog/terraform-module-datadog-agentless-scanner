resource "azurerm_role_definition" "orchestrator_role" {
  name        = "Datadog Agentless Scanner Orchestrator Role"
  description = "Role used by the Datadog Agentless Scanner to manage resources in its own resource group."
  scope       = var.resource_group_id

  permissions {
    actions = [
      "Microsoft.Authorization/*/read",
      "Microsoft.Resources/subscriptions/resourceGroups/read",

      "Microsoft.Compute/availabilitySets/*",
      "Microsoft.Compute/locations/*",
      "Microsoft.Compute/virtualMachines/*",
      "Microsoft.Compute/virtualMachineScaleSets/*",

      "Microsoft.Compute/disks/read",
      "Microsoft.Compute/disks/write",
      "Microsoft.Compute/disks/delete",
      "Microsoft.Compute/disks/beginGetAccess/action",
      "Microsoft.Compute/disks/endGetAccess/action",

      "Microsoft.Compute/snapshots/read",
      "Microsoft.Compute/snapshots/write",
      "Microsoft.Compute/snapshots/delete",
      "Microsoft.Compute/snapshots/beginGetAccess/action",
      "Microsoft.Compute/snapshots/endGetAccess/action",

      "Microsoft.Storage/storageAccounts/listkeys/action",
      "Microsoft.Storage/storageAccounts/read",
      "Microsoft.Storage/storageAccounts/write",
      "Microsoft.Storage/storageAccounts/delete"
    ]
    not_actions = []
  }
}

resource "azurerm_role_definition" "worker_role" {
  name              = "Datadog Agentless Scanner Worker Role"
  description       = "Role used by the Datadog Agentless Scanner to scan resources."
  scope             = var.scan_scopes[0]
  assignable_scopes = var.scan_scopes

  permissions {
    actions = [
      "Microsoft.Compute/virtualMachines/read",
      "Microsoft.Compute/virtualMachines/instanceView/read",
      "Microsoft.Compute/virtualMachineScaleSets/read",
      "Microsoft.Compute/virtualMachineScaleSets/instanceView/read",
      "Microsoft.Compute/virtualMachineScaleSets/virtualMachines/read",
      "Microsoft.Compute/virtualMachineScaleSets/virtualMachines/instanceView/read",

      "Microsoft.Compute/disks/read",
      "Microsoft.Compute/disks/beginGetAccess/action",
      "Microsoft.Compute/disks/endGetAccess/action",

      "Microsoft.ContainerRegistry/registries/pull/read"
    ]
    not_actions = []
  }
}

resource "azurerm_role_assignment" "orchestrator_role_assignment" {
  scope              = azurerm_role_definition.orchestrator_role.scope
  role_definition_id = azurerm_role_definition.orchestrator_role.role_definition_resource_id
  principal_id       = var.principal_id
  principal_type     = "ServicePrincipal"
}

resource "azurerm_role_assignment" "worker_role_assignments" {
  for_each = toset(var.scan_scopes)
  scope    = each.key
  # This is a workaround for a bug in the azurerm provider: https://github.com/hashicorp/terraform-provider-azurerm/issues/4847
  # We replace the subscription of the role definition ID by the subscription of the scope to avoid eternal TF drift.
  role_definition_id = format("%s/%s",
    substr(each.key, 0, 51),                                                        # scope subscription ID
    substr(azurerm_role_definition.worker_role.role_definition_resource_id, 52, -1) # rest of the role definition ID
  )
  principal_id   = var.principal_id
  principal_type = "ServicePrincipal"
}

resource "azurerm_role_assignment" "api_key_role_assignment" {
  count                = var.api_key_secret_id != null ? 1 : 0
  scope                = var.api_key_secret_id
  role_definition_name = "Key Vault Secrets User"
  principal_id         = var.principal_id
  principal_type       = "ServicePrincipal"
}
