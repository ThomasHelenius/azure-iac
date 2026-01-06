# -----------------------------------------------------------------------------
# COMPUTE MODULE
# Creates virtual machines with managed identities and supporting resources
# -----------------------------------------------------------------------------

# -----------------------------------------------------------------------------
# NETWORK INTERFACES
# -----------------------------------------------------------------------------

resource "azurerm_network_interface" "main" {
  count = var.vm_count

  name                = "${var.nic_name_prefix}-${format("%02d", count.index + 1)}"
  location            = var.location
  resource_group_name = var.resource_group_name

  ip_configuration {
    name                          = "internal"
    subnet_id                     = var.subnet_id
    private_ip_address_allocation = "Dynamic"
  }

  accelerated_networking_enabled = true

  tags = var.tags
}

# -----------------------------------------------------------------------------
# VIRTUAL MACHINES
# -----------------------------------------------------------------------------

resource "azurerm_linux_virtual_machine" "main" {
  count = var.vm_count

  name                = "${var.vm_name_prefix}-${format("%02d", count.index + 1)}"
  location            = var.location
  resource_group_name = var.resource_group_name
  size                = var.vm_size

  # Distribute VMs across availability zones
  zone = length(var.availability_zones) > 0 ? var.availability_zones[count.index % length(var.availability_zones)] : null

  admin_username                  = var.admin_username
  disable_password_authentication = true

  admin_ssh_key {
    username   = var.admin_username
    public_key = var.ssh_public_key
  }

  network_interface_ids = [azurerm_network_interface.main[count.index].id]

  os_disk {
    name                 = "osdisk-${var.vm_name_prefix}-${format("%02d", count.index + 1)}"
    caching              = "ReadWrite"
    storage_account_type = "Premium_LRS"
    disk_size_gb         = var.os_disk_size_gb
  }

  source_image_reference {
    publisher = "Canonical"
    offer     = "ubuntu-24_04-lts"
    sku       = "server"
    version   = "latest"
  }

  identity {
    type = "SystemAssigned"
  }

  boot_diagnostics {
    # Use managed storage account
  }

  tags = var.tags
}

# -----------------------------------------------------------------------------
# AUTO-SHUTDOWN SCHEDULE
# -----------------------------------------------------------------------------

resource "azurerm_dev_test_global_vm_shutdown_schedule" "main" {
  count = var.enable_auto_shutdown ? var.vm_count : 0

  virtual_machine_id = azurerm_linux_virtual_machine.main[count.index].id
  location           = var.location
  enabled            = true

  daily_recurrence_time = var.auto_shutdown_time
  timezone              = "UTC"

  notification_settings {
    enabled = false
  }

  tags = var.tags
}

# -----------------------------------------------------------------------------
# KEY VAULT ACCESS FOR VMs
# Grant VMs access to read secrets from Key Vault using managed identity
# -----------------------------------------------------------------------------

resource "azurerm_role_assignment" "vm_keyvault_secrets_user" {
  count = var.keyvault_id != null ? var.vm_count : 0

  scope                = var.keyvault_id
  role_definition_name = "Key Vault Secrets User"
  principal_id         = azurerm_linux_virtual_machine.main[count.index].identity[0].principal_id
}

# -----------------------------------------------------------------------------
# VM EXTENSIONS
# -----------------------------------------------------------------------------

# Azure Monitor Agent for log collection
resource "azurerm_virtual_machine_extension" "ama" {
  count = var.log_analytics_workspace_id != null ? var.vm_count : 0

  name                       = "AzureMonitorLinuxAgent"
  virtual_machine_id         = azurerm_linux_virtual_machine.main[count.index].id
  publisher                  = "Microsoft.Azure.Monitor"
  type                       = "AzureMonitorLinuxAgent"
  type_handler_version       = "1.0"
  auto_upgrade_minor_version = true

  tags = var.tags
}
