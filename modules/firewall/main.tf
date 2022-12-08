resource "azurerm_public_ip" "pip" {
  name                = var.pip_name
  resource_group_name = var.resource_group
  location            = var.location
  allocation_method   = "Static"
  sku                 = "Standard"
}

resource "azurerm_firewall" "fw" {
  name                = var.fw_name
  location            = var.location
  resource_group_name = var.resource_group
  sku_name = "AZFW_VNet"
  sku_tier = "Standard"

  ip_configuration {
    name                 = "fw_ip_config"
    subnet_id            = var.subnet_id
    public_ip_address_id = azurerm_public_ip.pip.id
  }
}

# Rules for a private cluster (non-gov/non-21vnet/linux based)

resource "azurerm_firewall_network_rule_collection" "time" {
  name                = "time"
  azure_firewall_name = azurerm_firewall.fw.name
  resource_group_name = var.resource_group
  priority            = 101
  action              = "Allow"

  rule {
    description           = "aks node time sync rule"
    name                  = "allow network"
    source_addresses      = ["*"]
    destination_ports     = ["123"]
    destination_addresses = ["*"]
    protocols             = ["UDP"]
  }
}

resource "azurerm_firewall_network_rule_collection" "dns" {
  name                = "dns"
  azure_firewall_name = azurerm_firewall.fw.name
  resource_group_name = var.resource_group
  priority            = 102
  action              = "Allow"

  rule {
    description           = "aks node dns rule"
    name                  = "allow network"
    source_addresses      = ["*"]
    destination_ports     = ["53"]
    destination_addresses = ["*"]
    protocols             = ["UDP"]
  }
}
resource "azurerm_firewall_application_rule_collection" "aksbasics" {
  name                = "azure_global_fqdn"
  azure_firewall_name = azurerm_firewall.fw.name
  resource_group_name = var.resource_group
  priority            = 101
  action              = "Allow"

  rule {
    name             = "allow network"
    source_addresses = ["*"]

    target_fqdns = [
      "mcr.microsoft.com",
      "*.data.mcr.microsoft.com",
      "management.azure.com",
      "login.microsoftonline.com",
      "packages.microsoft.com",
      "acs-mirror.azureedge.net"
    ]

    protocol {
      port = "443"
      type = "Https"
    }
  }
}

resource "azurerm_firewall_application_rule_collection" "osupdates" {
  name                = "osupdates"
  azure_firewall_name = azurerm_firewall.fw.name
  resource_group_name = var.resource_group
  priority            = 102
  action              = "Allow"

  rule {
    name             = "allow network"
    source_addresses = ["*"]

    target_fqdns = [
      "security.ubuntu.com",
      "changelogs.ubuntu.com",
      "azure.archive.ubuntu.com"
    ]

    protocol {
      port = "80"
      type = "Http"
    }

    protocol {
      port = "443"
      type = "Https"
    }
  }
}

resource "azurerm_firewall_application_rule_collection" "Defender" {
  action = "Allow"
  azure_firewall_name = azurerm_firewall.fw.name
  name = "Defender"
  priority = 103
  resource_group_name = var.resource_group
rule {
    name             = "allow network"
    source_addresses = ["*"]

    target_fqdns = [
      "login.microsoftonline.com",
      "*.ods.opinsights.azure.com",
      "*.oms.opinsights.azure.com"
    ]
    protocol {
      port = "443"
      type = "Https"
    }
  }
}

resource "azurerm_firewall_application_rule_collection" "CSI" {
  action = "Allow"
  azure_firewall_name = azurerm_firewall.fw.name
  name = "CSI"
  priority = 104
  resource_group_name = var.resource_group
rule {
    name             = "allow network"
    source_addresses = ["*"]

    target_fqdns = [
      "vault.azure.net"
    ]
    protocol {
      port = "443"
      type = "Https"
    }
  }
}

resource "azurerm_firewall_application_rule_collection" "Azure_Monitor" {
  action = "Allow"
  azure_firewall_name = azurerm_firewall.fw.name
  name = "Azure_Monitor"
  priority = 105
  resource_group_name = var.resource_group
rule {
    name             = "allow network"
    source_addresses = ["*"]

    target_fqdns = [
      "dc.services.visualstudio.com",
      "*.ods.opinsights.azure.com",
      "*.oms.opinsights.azure.com",
      "*.monitoring.azure.com"
    ]
    protocol {
      port = "443"
      type = "Https"
    }
  }
}

resource "azurerm_firewall_application_rule_collection" "Azure_Policy" {
  action = "Allow"
  azure_firewall_name = azurerm_firewall.fw.name
  name = "Azure_Policy"
  priority = 106
  resource_group_name = var.resource_group
rule {
    name             = "allow network"
    source_addresses = ["*"]

    target_fqdns = [
      "data.policy.core.windows.net",
      "store.policy.core.windows.net",
      "dc.services.visualstudio.com"
    ]
    protocol {
      port = "443"
      type = "Https"
    }
  }
}

resource "azurerm_firewall_application_rule_collection" "Cluster_Extensions" {
  action = "Allow"
  azure_firewall_name = azurerm_firewall.fw.name
  name = "Cluster_Extensions"
  priority = 107
  resource_group_name = var.resource_group
rule {
    name             = "allow network"
    source_addresses = ["*"]

    target_fqdns = [
      "*.dp.kubernetesconfiguration.azure.com",
      "mcr.microsoft.com",
      "dc.services.visualstudio.com"
    ]
    protocol {
      port = "443"
      type = "Https"
    }
  }
}

