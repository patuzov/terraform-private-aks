variable resource_group {
  description = "Resource group name"
  type        = string
}

variable vnet_1_name {
  description = "VNET 1 name"
  type        = string
}

variable vnet_1_id {
  description = "VNET 1 ID"
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

variable peering_name_1_to_2 {
  description = "Peering 1 to 2 name"
  type        = string
  default     = "peering1to2"
}

variable peering_name_2_to_1 {
  description = "Peering 2 to 1 name"
  type        = string
  default     = "peering2to1"
}