locals {
  dd_tags = {
    Datadog                 = "true"
    DatadogAgentlessScanner = "true"
  }
}

resource "azurerm_orchestrated_virtual_machine_scale_set" "vmss" {
  name                = var.name
  location            = var.location
  resource_group_name = var.resource_group_name
  tags                = merge(var.tags, local.dd_tags)

  sku_name                    = var.instance_size
  instances                   = var.instance_count
  platform_fault_domain_count = 1

  identity {
    type = "UserAssigned"
    identity_ids = [
      var.user_assigned_identity
    ]
  }
  os_profile {
    linux_configuration {
      computer_name_prefix            = "agentless-scanning-"
      admin_username                  = var.admin_username
      disable_password_authentication = true
      admin_ssh_key {
        username   = var.admin_username
        public_key = var.admin_ssh_key
      }
    }
    custom_data = base64encode(var.custom_data)
  }
  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "StandardSSD_LRS"
    disk_size_gb         = var.instance_root_volume_size
  }
  source_image_reference {
    publisher = "canonical"
    offer     = "0001-com-ubuntu-server-jammy"
    sku       = "22_04-lts-arm64"
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
}
