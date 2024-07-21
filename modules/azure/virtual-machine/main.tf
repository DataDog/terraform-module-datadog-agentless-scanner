locals {
  dd_tags = {
    Datadog                 = "true"
    DatadogAgentlessScanner = "true"
  }
}

resource "azurerm_linux_virtual_machine_scale_set" "vmss" {
  name                = var.name
  location            = var.location
  resource_group_name = var.resource_group_name
  tags                = merge(var.tags, local.dd_tags)

  sku       = var.instance_size
  instances = var.instance_count

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
    sku       = "server-arm64"
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
    type_handler_version = "1.0"
    settings = jsonencode({
      protocol          = "http",
      port              = 6253,
      requestPath       = "/health"
      intervalInSeconds = 10
      numberOfProbes    = 3
    })
  }
}

resource "azurerm_monitor_autoscale_setting" "autoscale_setting" {
  name                = "${azurerm_linux_virtual_machine_scale_set.vmss.name}-Autoscale"
  resource_group_name = azurerm_linux_virtual_machine_scale_set.vmss.resource_group_name
  location            = azurerm_linux_virtual_machine_scale_set.vmss.location
  target_resource_id  = azurerm_linux_virtual_machine_scale_set.vmss.id

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
