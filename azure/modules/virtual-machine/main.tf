locals {
  dd_tags = {
    Datadog                 = "true"
    DatadogAgentlessScanner = "true"
  }

  # 3-tier VM SKU preference chain, tried in order. The first SKU available
  # (no restrictions) in var.location wins. Designed to cover every commercial
  # Azure region:
  #   1. Standard_B2ps_v2  ARM Burstable v2 - cheapest, ~major regions only
  #   2. Standard_D2pls_v6 ARM v6 D-series  - broad ARM coverage (e.g. brazilsouth)
  #   3. Standard_D2s_v3   x86 D-series v3  - universal fallback for ARM-less
  #                                           regions (e.g. qatarcentral). D2s_v3
  #                                           is picked over Bsv2 because its
  #                                           DSv3 family is one of the few Azure
  #                                           pre-allocates with non-zero default
  #                                           vCPU quota on fresh subscriptions.
  sku_preference = [
    "Standard_B2ps_v2",
    "Standard_D2pls_v6",
    "Standard_D2s_v3",
  ]

  # Each candidate SKU is paired with the matching Ubuntu 24.04 LTS image SKU.
  # ARM SKUs require the -arm64 image; x86 SKUs require the plain "minimal".
  sku_to_image_sku = {
    "Standard_B2ps_v2"  = "minimal-arm64"
    "Standard_D2pls_v6" = "minimal-arm64"
    "Standard_D2s_v3"   = "minimal"
  }

  auto_select = var.instance_size == null

  # Names of all VM SKUs available in var.location with no restrictions
  # (filters out region/zone-level capacity holds reported by ARM).
  available_skus = local.auto_select ? toset([
    for sku in jsondecode(data.azapi_resource_action.vm_skus[0].output).value :
    sku.name
    if try(sku.resourceType, "") == "virtualMachines"
    && contains(try(sku.locations, []), var.location)
    && length(try(sku.restrictions, [])) == 0
  ]) : toset([])

  matched_skus = [for s in local.sku_preference : s if contains(local.available_skus, s)]

  chosen_sku       = local.auto_select ? try(local.matched_skus[0], null) : var.instance_size
  chosen_image_sku = coalesce(var.image_sku, lookup(local.sku_to_image_sku, local.chosen_sku, "minimal-arm64"))
}

data "azurerm_subscription" "current" {}

# Lists all Microsoft.Compute SKUs visible to the current subscription.
# We filter to virtualMachines + var.location client-side in `available_skus`
# (the $filter URL parameter is intentionally omitted to keep this
# compatible with azapi v1.x's response_export_values list form).
# Requires Microsoft.Compute/skus/read on the subscription, which is
# included in the built-in Reader role.
data "azapi_resource_action" "vm_skus" {
  count                  = local.auto_select ? 1 : 0
  type                   = "Microsoft.Compute/skus@2021-07-01"
  resource_id            = "${data.azurerm_subscription.current.id}/providers/Microsoft.Compute/skus"
  method                 = "GET"
  response_export_values = ["value"]
}

resource "azurerm_linux_virtual_machine_scale_set" "vmss" {
  name                = var.name
  location            = var.location
  resource_group_name = var.resource_group_name
  tags                = merge(var.tags, local.dd_tags)

  sku       = local.chosen_sku != null ? local.chosen_sku : "Standard_B2ps_v2"
  instances = var.instance_count

  lifecycle {
    precondition {
      condition = local.chosen_sku != null
      error_message = format(
        "No VM SKU from preference chain %s is available in location '%s'. Set var.instance_size and var.image_sku explicitly to a SKU available in this region.",
        jsonencode(local.sku_preference),
        var.location,
      )
    }
  }

  identity {
    type = "UserAssigned"
    identity_ids = [
      var.user_assigned_identity
    ]
  }

  computer_name_prefix = "agentless-scanning-"
  custom_data          = base64encode(var.custom_data)
  admin_username       = var.admin_username
  admin_ssh_key {
    username   = var.admin_username
    public_key = var.admin_ssh_key
  }
  boot_diagnostics {}

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "StandardSSD_LRS"
    disk_size_gb         = var.instance_root_volume_size
  }

  source_image_reference {
    publisher = "canonical"
    offer     = "ubuntu-24_04-lts"
    sku       = local.chosen_image_sku
    version   = "latest"
  }

  network_interface {
    name    = "nic"
    primary = true
    ip_configuration {
      name      = "ipconfig"
      primary   = true
      subnet_id = var.subnet_id
    }
  }

  automatic_instance_repair {
    enabled      = true
    grace_period = "PT10M"
  }
  extension {
    name                 = "HealthExtension"
    publisher            = "Microsoft.ManagedServices"
    type                 = "ApplicationHealthLinux"
    type_handler_version = "2.0"
    settings = jsonencode({
      protocol          = "http",
      port              = 6253,
      requestPath       = "/health"
      intervalInSeconds = 10
      numberOfProbes    = 3
      gracePeriod       = 1200
    })
  }
}

resource "azurerm_monitor_autoscale_setting" "autoscale_setting" {
  name                = "${azurerm_linux_virtual_machine_scale_set.vmss.name}-Autoscale"
  resource_group_name = azurerm_linux_virtual_machine_scale_set.vmss.resource_group_name
  location            = azurerm_linux_virtual_machine_scale_set.vmss.location
  target_resource_id  = azurerm_linux_virtual_machine_scale_set.vmss.id
  tags                = merge(var.tags, local.dd_tags)

  profile {
    name = "Terminate all instances"

    capacity {
      default = 0
      minimum = 0
      maximum = 0
    }

    recurrence {
      days    = ["Monday", "Tuesday", "Wednesday", "Thursday", "Friday", "Saturday", "Sunday"]
      hours   = [floor(random_integer.restart_minute.result / 60)]
      minutes = [random_integer.restart_minute.result % 60]
    }
  }

  profile {
    name = jsonencode({
      "for"  = "Terminate all instances"
      "name" = "Auto created default scale condition"
    })

    capacity {
      default = var.instance_count
      minimum = var.instance_count
      maximum = var.instance_count
    }

    recurrence {
      days    = ["Monday", "Tuesday", "Wednesday", "Thursday", "Friday", "Saturday", "Sunday"]
      hours   = [floor((random_integer.restart_minute.result + 1) / 60) % 24]
      minutes = [(random_integer.restart_minute.result + 1) % 60]
    }
  }
}

resource "random_integer" "restart_minute" {
  keepers = {
    vmss_id = azurerm_linux_virtual_machine_scale_set.vmss.id
  }

  min = 0
  max = (24 * 60) - 1
}
