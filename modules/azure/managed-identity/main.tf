locals {
  dd_tags = {
    Datadog                 = "true"
    DatadogAgentlessScanner = "true"
  }
}

resource "azurerm_user_assigned_identity" "identity" {
  name                = var.name
  location            = var.location
  resource_group_name = var.resource_group_name
  tags                = merge(var.tags, local.dd_tags)
}
