# Azure module for Datadog Agentless Scanner
terraform {
  required_version = ">= 1.0"

  required_providers {
    azapi = {
      source  = "Azure/azapi"
      version = ">= 1.13.1"
    }
    azurerm = {
      source  = "hashicorp/azurerm"
      version = ">= 3.101.0"
    }
  }
}

provider "azurerm" {
  features {}
}
