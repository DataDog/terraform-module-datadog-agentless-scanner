locals {
  dd_tags = {
    Datadog                 = "true"
    DatadogAgentlessScanner = "true"
  }
}

resource "azurerm_resource_group" "resource_group" {
  name     = var.name
  location = var.location
  tags     = merge(var.tags, local.dd_tags)
}
