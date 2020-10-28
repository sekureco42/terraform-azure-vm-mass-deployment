variable vm_count {
  description = "Define how many VMs you want to deploy"
  type        = number
  default     = 1
}

variable rg_location {
  description = "Define location for ressource group (switzerlandnorth/northeurope)"
  type        = string
  default     = "switzerlandnorth"
}

variable rg_base_name {
  description = "Define base name for ressource group"
  type        = string
  default     = "terraform-01"
}

variable vm_size {
  description = "Define the VM size, eg. Standard_DS1_v2, Standard_B2s"
  type        = string
  default     = "Standard_B2s"
}

variable vm_base_name {
  description = "Define base name for virtual machines (also used for DNS entries and names in Azure)"
  type        = string
  default     = "win-cl-%03s"
}

variable vm_image_name {
  description = "Define here the name of the image template created to deploy"
  type        = string
  default     = "win10-flare"
}

variable vm_admin_username {
    description = "Define default username for VMs"
    type        = string
    default     = "ircdemo"
}

variable vm_admin_password {
    description = "Define default password for VMs"
    type        = string
    default     = "SxiMlKxINaf77USjsGuzwJt9dLIIUUpk"
}