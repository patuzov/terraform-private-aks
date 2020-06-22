variable resource_group {
  description = "Resource group name"
  type        = string
}

variable location {
  description = "Location where Firewall will be deployed"
  type        = string
}

variable pip_name {
  description = "Firewal public IP name"
  type        = string
  default     = "azure-fw-ip"
}

variable fw_name {
  description = "Firewal name"
  type        = string
}

variable subnet_id {
  description = "Subnet ID"
  type        = string
}