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

  # Each candidate VM in the chain is 2 vCPUs; total vCPUs needed = count x 2.
  required_vcpus = var.instance_count * 2

  # Names of all VM SKUs available in var.location with no restrictions
  # (filters out region/zone-level capacity holds reported by ARM).
  available_skus = local.auto_select ? toset([
    for sku in jsondecode(data.azapi_resource_action.vm_skus[0].output).value :
    sku.name
    if try(sku.resourceType, "") == "virtualMachines"
    && contains(try(sku.locations, []), var.location)
    && length(try(sku.restrictions, [])) == 0
  ]) : toset([])

  # Per-SKU vCPU family name (e.g. Standard_B2ps_v2 -> standardBpsv2Family).
  # Used to join against the per-family quotas returned by the usages API.
  # Restricted to candidates from our preference chain to keep the map small.
  candidate_sku_families = local.auto_select ? {
    for sku in jsondecode(data.azapi_resource_action.vm_skus[0].output).value :
    sku.name => try(sku.family, "")
    if try(sku.resourceType, "") == "virtualMachines"
    && contains(try(sku.locations, []), var.location)
    && contains(local.sku_preference, sku.name)
  } : {}

  # Per-family vCPU headroom: limit - currentValue.
  # Azure assigns vCPU quota per-family per-region; many subscription types
  # (CSP, MSDN, Visual Studio, freshly-provisioned EA) default several
  # families to 0 and surface QuotaExceeded only at deploy time. Checking
  # quota here turns that runtime failure into a clear plan-time error.
  vcpu_headroom_by_family = local.auto_select ? {
    for u in jsondecode(data.azapi_resource_action.vm_usages[0].output).value :
    u.name.value => try(u.limit, 0) - try(u.currentValue, 0)
  } : {}

  # A SKU qualifies when it is offered in the region AND its family has
  # enough vCPU headroom in the subscription. try() defaults to false when
  # the usages API doesn't return the family for any reason.
  matched_skus = [
    for s in local.sku_preference : s
    if contains(local.available_skus, s)
    && try(local.vcpu_headroom_by_family[local.candidate_sku_families[s]] >= local.required_vcpus, false)
  ]

  # Diagnostics surfaced in the precondition error so the user can tell
  # at a glance whether the failure is a regional or a quota issue.
  unavailable_skus = local.auto_select ? [
    for s in local.sku_preference : s if !contains(local.available_skus, s)
  ] : []
  quota_blocked_skus = local.auto_select ? [
    for s in local.sku_preference : s
    if contains(local.available_skus, s)
    && try(local.vcpu_headroom_by_family[local.candidate_sku_families[s]] < local.required_vcpus, true)
  ] : []

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

# Per-region, per-family vCPU usage (currentValue) and quota (limit).
# Used to filter SKU candidates whose family has zero or insufficient quota
# in the subscription, preventing QuotaExceeded at apply time.
# Requires Microsoft.Compute/locations/usages/read (included in Reader).
data "azapi_resource_action" "vm_usages" {
  count                  = local.auto_select ? 1 : 0
  type                   = "Microsoft.Compute/locations/usages@2022-11-01"
  resource_id            = "${data.azurerm_subscription.current.id}/providers/Microsoft.Compute/locations/${var.location}/usages"
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
        "No VM SKU from preference chain %s is usable in location '%s' (need %d vCPUs). Not offered in region: %s. Available but insufficient vCPU quota: %s. Request quota at https://aka.ms/azurequotaincrease for the corresponding family, or set var.instance_size and var.image_sku explicitly.",
        jsonencode(local.sku_preference),
        var.location,
        local.required_vcpus,
        jsonencode(local.unavailable_skus),
        jsonencode(local.quota_blocked_skus),
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
