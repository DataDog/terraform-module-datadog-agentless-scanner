locals {
  dd_tags = {
    Datadog                 = "true"
    DatadogAgentlessScanner = "true"
  }
}

resource "azurerm_user_assigned_identity" "managed_identity" {
  name                = var.name
  location            = var.location
  resource_group_name = var.resource_group_name
  tags                = merge(var.tags, local.dd_tags)
}

resource "azurerm_role_definition" "role_definition" {
  name        = "Datadog Agentless Scanner Role (${var.resource_group_name})"
  description = "Role used by the Datadog Agentless Scanner to manage resources in its resource group."
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

resource "azurerm_role_assignment" "role_assignment" {
  scope              = azurerm_role_definition.role_definition.scope
  role_definition_id = azurerm_role_definition.role_definition.role_definition_resource_id
  principal_id       = azurerm_user_assigned_identity.managed_identity.principal_id
  principal_type     = "ServicePrincipal"
}
