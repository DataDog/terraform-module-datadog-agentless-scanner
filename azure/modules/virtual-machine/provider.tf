terraform {
  required_version = ">= 1.2.0"

  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = ">= 3.101.0"
    }
    azapi = {
      source = "Azure/azapi"
      # Pinned to the 1.x line: the SKU / usages lookups in main.tf use the
      # v1 response_export_values list form and jsondecode(.output). AzAPI v2
      # changed `output` from a JSON string to an HCL object, which would
      # break the jsondecode call at plan time. Revisit when the data-source
      # bodies are ported to the v2 map+JMESPath form.
      version = "~> 1.13"
    }
    random = {
      source  = "hashicorp/random"
      version = ">= 3.0.0"
    }
  }
}
