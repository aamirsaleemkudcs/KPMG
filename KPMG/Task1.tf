########## Defining variable ##############

variable "Resource_Group_Location" {
  type = "string"
  default = "West US"
}

variable "Resource_Group_Name" {
  type = "string"
  default = "kpmg1"
}

variable "Storage_Account" {
  type = "string"
  default = "kpmg"
}

variable "Load_Balancer_FrontEnd_IP" {
  type = "string"
  default = "Public_IP_FEndLB"
}

variable "Load_Balancer" {
  type = "string"
  default = "LB"
}

variable "Load_Balancer_BackPool" {
  type = "string"
  default = "LB_BackPool"
}

variable "Tier1_Security_Group" {
  type = "string"
  default = "SG-Tier"
}

variable "Virtual_Network" {
  type = "string"
  default = "kpmg"
}

variable "VPN_Gateway" {
  type = "string"
  default = "kpmg"
}

############ Creating a Resource Group ##########

resource "azurerm_resource_group" "rg" {
  name     = "${var.Resource_Group_Name}-RGroup"
  location = "${var.Resource_Group_Location}"
}

################## Defining Storage Account ################

resource "azurerm_storage_account" "sa" {
  name                       = "${var.Storage_Account}saccount"
  resource_group_name        = "${azurerm_resource_group.rg.name}"
  location                   = "${var.Resource_Group_Location}"
  account_tier               = "Standard"
  account_replication_type   = "GRS"

}

############ Creating a Public IP for Load balancer ##########

resource "azurerm_public_ip" "public_ip1" {
  name                = "${var.Load_Balancer_FrontEnd_IP}-1"
  location            = "${var.Resource_Group_Location}"
  resource_group_name = "${azurerm_resource_group.rg.name}"
  allocation_method   = "Static"
}

############ Creating a Load Balancer 1 ##########
### load Balancer 1 
resource "azurerm_lb" "lb1" {
  name                = "${var.Load_Balancer}-1"
  location            = "${var.Resource_Group_Location}"
  resource_group_name = "${azurerm_resource_group.rg.name}"

  frontend_ip_configuration {
    name                 = "Tier1_PublicIPAddress"
    public_ip_address_id = "${azurerm_public_ip.public_ip1.id}"
  }
}

resource "azurerm_lb_backend_address_pool" "lb_bp1" {
  name                = "${var.Load_Balancer_BackPool}-1"
  resource_group_name = "${azurerm_resource_group.rg.name}"
  loadbalancer_id     = "${azurerm_lb.lb1.id}"
}

### load Balancer 2 
resource "azurerm_lb" "lb2" {
  name                = "${var.Load_Balancer}-2"
  location            = "${var.Resource_Group_Location}"
  resource_group_name = "${azurerm_resource_group.rg.name}"

  frontend_ip_configuration {
    name                 = "Subnet_1_IPAddress"
    subnet_id            = "${azurerm_subnet.subnet_1.id}"
    private_ip_address   = "10.0.1.100" 
    private_ip_address_allocation  = "Static"

  }
}

resource "azurerm_lb_backend_address_pool" "lb_bp2" {
  name                = "${var.Load_Balancer_BackPool}-2"
  resource_group_name = "${azurerm_resource_group.rg.name}"
  loadbalancer_id     = "${azurerm_lb.lb2.id}"
}

### load Balancer 3 
resource "azurerm_lb" "lb3" {
  name                = "${var.Load_Balancer}-3"
  location            = "${var.Resource_Group_Location}"
  resource_group_name = "${azurerm_resource_group.rg.name}"

  frontend_ip_configuration {
    name                 = "Subnet_2_IPAddress"
    subnet_id            = "${azurerm_subnet.subnet_2.id}"
    private_ip_address   = "10.0.2.100" 
    private_ip_address_allocation  = "Static"

  }
}

resource "azurerm_lb_backend_address_pool" "lb_bp3" {
  name                = "${var.Load_Balancer_BackPool}-3"
  resource_group_name = "${azurerm_resource_group.rg.name}"
  loadbalancer_id     = "${azurerm_lb.lb3.id}"
}





############ Creating three Network Securuty Group for each subnet - Adding one rule on priority 100 ##########

resource "azurerm_network_security_group" "sg1" {  
  name                = "${var.Tier1_Security_Group}-1"
  location            = "${var.Resource_Group_Location}"
  resource_group_name = "${azurerm_resource_group.rg.name}"

  security_rule {
    name                       = "Rule1"
    priority                   = 100
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "*"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }
}

resource "azurerm_network_security_group" "sg2" {  
  name                = "${var.Tier1_Security_Group}-2"
  location            = "${var.Resource_Group_Location}"
  resource_group_name = "${azurerm_resource_group.rg.name}"

  security_rule {
    name                       = "Rule1"
    priority                   = 100
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "*"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }
}

resource "azurerm_network_security_group" "sg3" {  
  name                = "${var.Tier1_Security_Group}-3"
  location            = "${var.Resource_Group_Location}"
  resource_group_name = "${azurerm_resource_group.rg.name}"

  security_rule {
    name                       = "Rule1"
    priority                   = 100
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "*"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }
}

############ Creating a Virtual Network / And two subnets / Subnet associated with Security Group ##########

resource "azurerm_virtual_network" "vnet" {
  name                = "${var.Virtual_Network}-vnet"
  location            = "${var.Resource_Group_Location}"
  resource_group_name = "${azurerm_resource_group.rg.name}"
  address_space       = ["10.0.0.0/16"]

tags = {
    environment = "KPMG VNET"
  }
}

resource "azurerm_subnet" "subnet_1" {
  
  name                 = "Tier1_Subnet"
  resource_group_name  = "${azurerm_resource_group.rg.name}"
  virtual_network_name = "${azurerm_virtual_network.vnet.name}"
  address_prefix       = "10.0.1.0/24"
  network_security_group_id = "${azurerm_network_security_group.sg1.id}"
  
}

resource "azurerm_subnet" "subnet_2" {
  
  name                 = "Tier2_Subnet"
  resource_group_name = "${azurerm_resource_group.rg.name}"
  virtual_network_name = "${azurerm_virtual_network.vnet.name}"
  address_prefix       = "10.0.2.0/24"
  network_security_group_id = "${azurerm_network_security_group.sg2.id}"
    
}

resource "azurerm_subnet" "subnet_3" {
  
  name                 = "Tier3_Subnet"
  resource_group_name = "${azurerm_resource_group.rg.name}"
  virtual_network_name = "${azurerm_virtual_network.vnet.name}"
  address_prefix       = "10.0.3.0/24"
  network_security_group_id = "${azurerm_network_security_group.sg3.id}"
    
}

resource "azurerm_subnet" "gw" {
  name                 = "GatewaySubnet"
  resource_group_name = "${azurerm_resource_group.rg.name}"
  virtual_network_name = "${azurerm_virtual_network.vnet.name}"
  address_prefix       = "10.0.10.0/24"
}
/*
############ Creating Public IP for VPN Gateway ########################

resource "azurerm_public_ip" "p_ip_gw" {
  name                = "kpmg_ip_gw"
  location            = "${var.Resource_Group_Location}"
  resource_group_name = "${azurerm_resource_group.rg.name}"

  allocation_method = "Dynamic"
}

################### VPN Gateway #######################################

resource "azurerm_virtual_network_gateway" "vpn_gw" {
  name                = "${var.VPN_Gateway}-VPNGateway"
  location            = "${var.Resource_Group_Location}"
  resource_group_name = "${azurerm_resource_group.rg.name}"

  type     = "Vpn"
  vpn_type = "RouteBased"

  active_active = false
  enable_bgp    = false
  sku           = "Basic"

  ip_configuration {
    name                          = "vnetGatewayConfig"
    public_ip_address_id          = "${azurerm_public_ip.p_ip_gw.id}"
    private_ip_address_allocation = "Dynamic"
    subnet_id                     = "${azurerm_subnet.gw.id}"
  }

  vpn_client_configuration {
    address_space = ["10.2.0.0/24"]

    root_certificate {
      name = "AzureCert"

      public_cert_data = <<EOF
MIIDHTCCAgmgAwIBAgIQiPtqrRyOn7NIV0wW5oPulTAJBgUrDgMCHQUAMCIxIDAe
BgNVBAMTF2NhcGl0YWxBenVyZVZwblJvb3RDZXJ0MB4XDTIwMDIwMTAzNTIwNFoX
DTM5MTIzMTIzNTk1OVowIjEgMB4GA1UEAxMXY2FwaXRhbEF6dXJlVnBuUm9vdENl
cnQwggEiMA0GCSqGSIb3DQEBAQUAA4IBDwAwggEKAoIBAQCYHiCpjUsRgBAQJPiM
V63EAwueGOdTY0tsRvGjYxEo3L2PjAjusLJIOZSSVH0kTKZCBTrVqlppHOlVcPUS
T7EgDhmuknJv5g8gLdVeyGoGjaychnZwTOFt5ZmZVWqk2swchuHKy+SAJPFfcXfb
wOgoCqAH0vYd8IXGtHx+x3JEyTIV/xIFgQkp3g7GaIWshuobPRVl4gYUb6mEAKYF
8+7R8HFrGg86SgFqD9W/BGV8FWDJZUo1DVMhFmQ4vaFFKsrF0T8zrLvwhbv/o3oo
Azh9VjdUQj0Mw4WLSeMaEiauYLZGZuAAtnWb2sPpjIcccKQDyj8Z3kmwSG4luS0R
J8ihAgMBAAGjVzBVMFMGA1UdAQRMMEqAEBVZcx3sU+lhPRS/ryrf95ChJDAiMSAw
HgYDVQQDExdjYXBpdGFsQXp1cmVWcG5Sb290Q2VydIIQiPtqrRyOn7NIV0wW5oPu
lTAJBgUrDgMCHQUAA4IBAQA+hM0bicJgBNcz15xjL5Z4RFdAV+Iz4zHWrnIfdMI1
P9oNExilV4sUg4/qFnjhC0ufaosLCMDoEky369S6vrQcNA3LQwB3Uy1QSJ3vHgLk
0JNWbuaRdmV7Tfb095J6OEr9/8FwVweyo3xzL932jeXhM1nx+naEH3FGiMCJic6W
bABSAW7tgGNnkWRJMji0U9MJX0JBRIeLK2qFcQi2fm4o/oVyUIYRMFY7WWr880nE
K09OgyN97+4e0GkCADMkz8MuuvJvoSFnPSo2k95leM4pjCGJ0CPXcUO589NfFldj
CqxO1lzUsgJtAYNwsAZS7S6xm7Ur/2/7VbWp2uqHzjU4
EOF
    }

  }
}
*/

################# NIC defining for Subnet 1 ##################################
### NIC 1
resource "azurerm_network_interface" "nic_1" {
  name                = "vmnic-1"
  location            = "${var.Resource_Group_Location}"
  resource_group_name = "${azurerm_resource_group.rg.name}"

  ip_configuration {
    name                          = "vm_nic_1"
    subnet_id                     = "${azurerm_subnet.subnet_1.id}"
    private_ip_address_allocation = "Dynamic"
    load_balancer_backend_address_pools_ids = ["${azurerm_lb_backend_address_pool.lb_bp1.id}"]
  }

}

### NIC 2
resource "azurerm_network_interface" "nic_2" {
  name                = "vmnic-2"
  location            = "${var.Resource_Group_Location}"
  resource_group_name = "${azurerm_resource_group.rg.name}"

  ip_configuration {
    name                          = "vm_nic_2"
    subnet_id                     = "${azurerm_subnet.subnet_1.id}"
    private_ip_address_allocation = "Dynamic"
    load_balancer_backend_address_pools_ids = ["${azurerm_lb_backend_address_pool.lb_bp1.id}"]
  }

}

################# NIC defining for Subnet 2 ##################################
### NIC 3
resource "azurerm_network_interface" "nic_3" {
  name                = "vmnic-3"
  location            = "${var.Resource_Group_Location}"
  resource_group_name = "${azurerm_resource_group.rg.name}"

  ip_configuration {
    name                          = "vm_nic_3"
    subnet_id                     = "${azurerm_subnet.subnet_2.id}"
    private_ip_address_allocation = "Dynamic"
    load_balancer_backend_address_pools_ids = ["${azurerm_lb_backend_address_pool.lb_bp2.id}"]
  }

}

### NIC 4
resource "azurerm_network_interface" "nic_4" {
  name                = "vmnic-4"
  location            = "${var.Resource_Group_Location}"
  resource_group_name = "${azurerm_resource_group.rg.name}"

  ip_configuration {
    name                          = "vm_nic_4"
    subnet_id                     = "${azurerm_subnet.subnet_2.id}"
    private_ip_address_allocation = "Dynamic"
    load_balancer_backend_address_pools_ids = ["${azurerm_lb_backend_address_pool.lb_bp2.id}"]
  }

}

################# NIC defining for Subnet 3 ##################################
### NIC 5
resource "azurerm_network_interface" "nic_5" {
  name                = "vmnic-5"
  location            = "${var.Resource_Group_Location}"
  resource_group_name = "${azurerm_resource_group.rg.name}"

  ip_configuration {
    name                          = "vm_nic_5"
    subnet_id                     = "${azurerm_subnet.subnet_3.id}"
    private_ip_address_allocation = "Dynamic"
    load_balancer_backend_address_pools_ids = ["${azurerm_lb_backend_address_pool.lb_bp3.id}"]
  }

}

### NIC 6
resource "azurerm_network_interface" "nic_6" {
  name                = "vmnic-6"
  location            = "${var.Resource_Group_Location}"
  resource_group_name = "${azurerm_resource_group.rg.name}"

  ip_configuration {
    name                          = "vm_nic_6"
    subnet_id                     = "${azurerm_subnet.subnet_3.id}"
    private_ip_address_allocation = "Dynamic"
    load_balancer_backend_address_pools_ids = ["${azurerm_lb_backend_address_pool.lb_bp3.id}"]
  }

}

###########################  VM Defining in Subnet 1 ###################################################

##### Virtual Machine 1

resource "azurerm_virtual_machine" "vm_1" {
    
    name                    = "kpmg_server-vm1"
    location                = "${var.Resource_Group_Location}"
    resource_group_name     = "${azurerm_resource_group.rg.name}"
    network_interface_ids   = ["${azurerm_network_interface.nic_1.id}"]
    vm_size                 = "Standard_B1ms"
    
 
 
#--- Base OS Image ---
   storage_image_reference {
    publisher = "MicrosoftWindowsServer"
    offer     = "WindowsServer"
    sku       = "2012-R2-Datacenter"
    version   = "4.127.20180315"
  }
 
 
#--- Disk Storage Type
 
  storage_os_disk {
    name              = "kpmg_server-vm1-disk"
    caching           = "ReadWrite"
    create_option     = "FromImage"
    managed_disk_type = "Standard_LRS"
    os_type           = "Windows"
  }
 
 
 
#--- Define password + hostname ---
  os_profile {
    computer_name  = "Windows10"
    admin_username = "testadmin"
    admin_password = "Password2019"
  }
 
#---
 
  os_profile_windows_config {
    enable_automatic_upgrades = true
    provision_vm_agent = true
  }
 
#-- Windows VM Diagnostics 
 
  boot_diagnostics {
    enabled     = true
    storage_uri = "${azurerm_storage_account.sa.primary_blob_endpoint}"
 }
 
 }

##### Virtual Machine 3

resource "azurerm_virtual_machine" "vm_3" {
    
    name                    = "kpmg_server-vm3"
    location                = "${var.Resource_Group_Location}"
    resource_group_name     = "${azurerm_resource_group.rg.name}"
    network_interface_ids   = ["${azurerm_network_interface.nic_3.id}"]
    vm_size                 = "Standard_B1ms"
    
 
 
#--- Base OS Image ---
   storage_image_reference {
    publisher = "MicrosoftWindowsServer"
    offer     = "WindowsServer"
    sku       = "2012-R2-Datacenter"
    version   = "4.127.20180315"
  }
 
 
#--- Disk Storage Type
 
  storage_os_disk {
    name              = "kpmg_server-vm3-disk"
    caching           = "ReadWrite"
    create_option     = "FromImage"
    managed_disk_type = "Standard_LRS"
    os_type           = "Windows"
  }
 
 
 
#--- Define password + hostname ---
  os_profile {
    computer_name  = "Windows10"
    admin_username = "testadmin"
    admin_password = "Password2019"
  }
 
#---
 
  os_profile_windows_config {
    enable_automatic_upgrades = true
    provision_vm_agent = true
  }
 
#-- Windows VM Diagnostics 
 
  boot_diagnostics {
    enabled     = true
    storage_uri = "${azurerm_storage_account.sa.primary_blob_endpoint}"
 }
 
 }

##### Virtual Machine 5

resource "azurerm_virtual_machine" "vm_5" {
    
    name                    = "kpmg_server-vm5"
    location                = "${var.Resource_Group_Location}"
    resource_group_name     = "${azurerm_resource_group.rg.name}"
    network_interface_ids   = ["${azurerm_network_interface.nic_5.id}"]
    vm_size                 = "Standard_B1ms"
    
 
 
#--- Base OS Image ---
   storage_image_reference {
    publisher = "MicrosoftWindowsServer"
    offer     = "WindowsServer"
    sku       = "2012-R2-Datacenter"
    version   = "4.127.20180315"
  }
 
 
#--- Disk Storage Type
 
  storage_os_disk {
    name              = "kpmg_server-vm5-disk"
    caching           = "ReadWrite"
    create_option     = "FromImage"
    managed_disk_type = "Standard_LRS"
    os_type           = "Windows"
  }
 
 
 
#--- Define password + hostname ---
  os_profile {
    computer_name  = "Windows10"
    admin_username = "testadmin"
    admin_password = "Password2019"
  }
 
#---
 
  os_profile_windows_config {
    enable_automatic_upgrades = true
    provision_vm_agent = true
  }
 
#-- Windows VM Diagnostics 
 
  boot_diagnostics {
    enabled     = true
    storage_uri = "${azurerm_storage_account.sa.primary_blob_endpoint}"
 }
 
 }