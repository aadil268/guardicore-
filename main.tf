provider "azurerm" {
  features {}
  subscription_id = var.subscription_id
}

resource "azurerm_resource_group" "rg" {
  name     = var.resource_group_name
  location = var.location
}

resource "azurerm_virtual_network" "vnet" {
  name                = "vnet-guardicore"
  address_space       = ["10.0.0.0/16"]
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
}

resource "azurerm_subnet" "subnet" {
  name                 = "sn-guardicore"
  resource_group_name  = azurerm_resource_group.rg.name
  virtual_network_name = azurerm_virtual_network.vnet.name
  address_prefixes     = ["10.0.1.0/24"]
}

resource "azurerm_network_security_group" "nsg" {
  name                = "nsg-guardicore"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name

  security_rule {
    name                       = "Allow-RDP"
    priority                   = 1001
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "3389"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }
}

resource "azurerm_subnet_network_security_group_association" "nsg_assoc" {
  subnet_id                 = azurerm_subnet.subnet.id
  network_security_group_id = azurerm_network_security_group.nsg.id
}

resource "azurerm_public_ip" "public_ip" {
  name                = "pip-guardicore"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  allocation_method   = "Dynamic"
  sku                 = "Basic"
}

resource "azurerm_network_interface" "nic" {
  name                = "nic-guardicore"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name

  ip_configuration {
    name                          = "internal"
    subnet_id                     = azurerm_subnet.subnet.id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = azurerm_public_ip.public_ip.id
  }
}

resource "azurerm_windows_virtual_machine" "vm" {
  count               = var.vm_count
  name                = "vm${var.instance_name}${format("%03d", count.index + 1)}"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  network_interface_ids = [
    azurerm_network_interface.nic.id,
  ]
  size           = "Standard_B2ms"
  admin_username = "azureuser"
  admin_password = "P@ssword1234!"

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
    name                 = "osd-guardicore"
  }

  source_image_reference {
    publisher = "MicrosoftWindowsServer"
    offer     = "WindowsServer"
    sku       = "2022-datacenter-smalldisk"
    version   = "latest"
  }
}

resource "azurerm_storage_account" "sa" {
  name                     = "saguardicoretfiles${random_integer.rand.result}"
  resource_group_name      = azurerm_resource_group.rg.name
  location                 = azurerm_resource_group.rg.location
  account_tier             = "Standard"
  account_replication_type = "LRS"
}

resource "random_integer" "rand" {
  min = 10000
  max = 99999
}

# Guardicore Agent Installation Extension
resource "azurerm_virtual_machine_extension" "guardicore_agent_install" {
  count                = var.enable_guardicore_agent_installation ? var.vm_count : 0
  name                 = "GuardicoreAgentInstall"
  virtual_machine_id   = azurerm_windows_virtual_machine.vm[count.index].id
  publisher            = "Microsoft.Compute"
  type                 = "CustomScriptExtension"
  type_handler_version = var.guardicore_customscript_handler_version

  settings = jsonencode({
    fileUris         = [var.guardicore_script_url]
    commandToExecute = "powershell -ExecutionPolicy Unrestricted -File install_guardicore_agent.ps1 -IdpHostname '${var.guardicore_idp_hostname}' -Token '${var.guardicore_token}' -ExeUrl '${var.guardicore_exe_url}'"
  })

  protected_settings = jsonencode({
    "IdpHostname" = var.guardicore_idp_hostname,
    "Token"       = var.guardicore_token,
    "ExeUrl"      = var.guardicore_exe_url
  })

  depends_on = [
    azurerm_windows_virtual_machine.vm
  ]
}