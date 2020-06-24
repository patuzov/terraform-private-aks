variable vnet_1_name {
  description = "VNET 1 name"
  type        = string
}

variable vnet_1_id {
  description = "VNET 1 ID"
  type        = string
}

variable vnet_1_rg {
  description = "VNET 1 resource group"
  type        = string
}

variable vnet_2_name {
  description = "VNET 2 name"
  type        = string
}

variable vnet_2_id {
  description = "VNET 2 ID"
  type        = string
}

variable vnet_2_rg {
  description = "VNET 2 resource group"
  type        = string
}

variable peering_name_1_to_2 {
  description = "(optional) Peering 1 to 2 name"
  type        = string
  default     = "peering1to2"
}

variable peering_name_2_to_1 {
  description = "(optional) Peering 2 to 1 name"
  type        = string
  default     = "peering2to1"
}