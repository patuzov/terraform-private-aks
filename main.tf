terraform {
  required_version = ">= 0.12"
}

provider "azurerm" {
  version = "~>2.5" //outbound_type https://github.com/terraform-providers/terraform-provider-azurerm/blob/v2.5.0/CHANGELOG.md
  features {}
}

resource "azurerm_resource_group" "vnet" {
  name     = var.vnet_resource_group_name
  location = var.location
}

module "hub_network" {
  source              = "./modules/vnet"
  resource_group_name = var.vnet_resource_group_name
  location            = var.location
  vnet_name           = var.hub_vnet_name
  address_space       = ["10.0.0.0/22"]
  subnets = [
    {
      name : "AzureFirewallSubnet"
      address_prefixes : ["10.0.0.0/24"]
    },
    {
      name : "jumpbox-subnet"
      address_prefixes : ["10.0.1.0/24"]
    }
  ]
}

resource "azurerm_resource_group" "kube" {
  name     = var.kube_resource_group_name
  location = var.location
}

module "kube_network" {
  source              = "./modules/vnet"
  resource_group_name = var.vnet_resource_group_name
  location            = var.location
  vnet_name           = var.kube_vnet_name
  address_space       = ["10.0.4.0/22"]
  subnets = [
    {
      name : "ing-1-subnet"
      address_prefixes : ["10.0.4.0/24"]
    },
    {
      name : "aks-2-subnet"
      address_prefixes : ["10.0.5.0/24"]
    }
  ]
}

module "vnet_peering" {
  source              = "./modules/vnet_peering"
  resource_group      = var.vnet_resource_group_name
  vnet_1_name         = var.hub_vnet_name
  vnet_1_id           = module.hub_network.vnet_id
  vnet_2_name         = var.kube_vnet_name
  vnet_2_id           = module.kube_network.vnet_id
  peering_name_1_to_2 = "HubToSpoke1"
  peering_name_2_to_1 = "Spoke1ToHub"
}

module "firewall" {
  source         = "./modules/firewall"
  resource_group = var.vnet_resource_group_name
  location       = var.location
  pip_name       = "azureFirewalls-ip"
  fw_name        = "kubenetfw"
  subnet_id      = module.hub_network.subnet_ids["AzureFirewallSubnet"]
}

module "routtable" {
  source             = "./modules/route_table"
  resource_group     = var.vnet_resource_group_name
  location           = var.location
  rt_name            = "kubenetfw_fw_rt"
  r_name             = "kubenetfw_fw_r"
  firewal_private_ip = module.firewall.fw_private_ip
  subnet_id          = module.kube_network.subnet_ids["aks-2-subnet"]
}


resource "azurerm_kubernetes_cluster" "privateaks" {
  name                    = "private-aks"
  location                = var.location
  kubernetes_version      = "1.16.9"
  resource_group_name     = var.kube_resource_group_name
  dns_prefix              = "private-aks"
  private_cluster_enabled = true

  default_node_pool {
    name           = "default"
    node_count     = var.nodepool_nodes_count
    vm_size        = var.nodepool_vm_size
    vnet_subnet_id = module.kube_network.subnet_ids["aks-2-subnet"]
  }

  identity {
    type = "SystemAssigned"
  }

  network_profile {
    docker_bridge_cidr = var.network_docker_bridge_cidr
    dns_service_ip     = var.network_dns_service_ip
    network_plugin     = "azure"
    outbound_type      = "userDefinedRouting"
    service_cidr       = var.network_service_cidr
  }
}

resource "azurerm_role_assignment" "vmcontributor" {
  role_definition_name = "Virtual Machine Contributor"
  scope                = azurerm_resource_group.vnet.id
  principal_id         = azurerm_kubernetes_cluster.privateaks.identity[0].principal_id
}

module "jumpbox" {
  source         = "./modules/jumpbox"
  location       = var.location
  resource_group = var.kube_resource_group_name
  subnet_id      = module.hub_network.subnet_ids["jumpbox-subnet"]
}