terraform {
  required_version = ">= 1.2.0"

  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = ">= 3.101.0"
    }
    azapi = {
      source = "Azure/azapi"
      # Pinned to the 2.x line: the SKU/usages lookups in main.tf use
      # azapi_resource_list (introduced in v2) and the map+JMESPath form
      # of response_export_values. v1.x's azapi_resource_action validator
      # rejects the subscription-scoped collection URLs we need to call.
      version = "~> 2.0"
    }
    random = {
      source  = "hashicorp/random"
      version = ">= 3.0.0"
    }
  }
}
