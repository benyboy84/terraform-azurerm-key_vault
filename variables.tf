# ------------------------------------------------------------------------------
# Key Vault
# ------------------------------------------------------------------------------

variable "name" {
  description = "(Required) Specifies the name of the Key Vault. Changing this forces a new resource to be created. The name must be globally unique. If the vault is in a recoverable state then the vault will need to be purged before reusing the name."
  type        = string
}

variable "location" {
  description = "(Required) Specifies the supported Azure location where the resource exists. Changing this forces a new resource to be created."
  type        = string
}

variable "resource_group_name" {
  description = "(Required) The name of the resource group in which to create the Key Vault. Changing this forces a new resource to be created."
  type        = string
}

variable "sku_name" {
  description = "(Required) The Name of the SKU used for this Key Vault. Possible values are `standard` and `premium`."
  type        = string
  default     = "standard"


  validation {
    condition     = var.sku_name != null ? contains(["standard", "premium"], var.sku_name) ? true : false : true
    error_message = "Possible values are `standard` and `premium`."
  }
}

# ------------------------------------------------------------------------------

variable "contacts" {
  description = <<DESCRIPTION
  (Optional) One or more contact block as defined below.
    email = (Required) E-mail address of the contact.
    name  = (Optional) Name of the contact.
    phone = (Optional) Phone number of the contact.
  DESCRIPTION
  type = list(object({
    email = string
    name  = optional(string)
    phone = optional(string)
  }))
  default = []

  validation {
    condition = length([
      for contact in var.contacts : true
      if can(regex("^.*@.*\\..*$", contact.email))
    ]) == length(var.contacts)
    error_message = "Email address is not in the right format"
  }
}

variable "enabled_for_deployment" {
  description = "(Optional) Boolean flag to specify whether Azure Virtual Machines are permitted to retrieve certificates stored as secrets from the key vault."
  type        = bool
  default     = false
}

variable "enabled_for_disk_encryption" {
  description = "(Optional) Boolean flag to specify whether Azure Disk Encryption is permitted to retrieve secrets from the vault and unwrap keys."
  type        = bool
  default     = false
}

variable "enabled_for_template_deployment" {
  description = "(Optional) Boolean flag to specify whether Azure Resource Manager is permitted to retrieve secrets from the key vault"
  type        = bool
  default     = false
}

variable "enable_rbac_authorization" {
  description = "(Optional) Boolean flag to specify whether Azure Key Vault uses Role Based Access Control (RBAC) for authorization of data actions."
  type        = bool
  default     = false
}

variable "network_acls" {
  description = <<DESCRIPTION
  (Optional) A network_acls block as defined below.
    bypass                     = (Required) Specifies which traffic can bypass the network rules. Possible values are `AzureServices` and `None`.
    default_action             = (Required) The Default Action to use when no rules match from `ip_rules` / `virtual_network_subnet_ids`. Possible values are `Allow` and `Deny`.
    ip_rules                   = (Optional) One or more IP Addresses, or CIDR Blocks which should be able to access the Key Vault.
    virtual_network_subnet_ids = (Optional) One or more Subnet IDs which should be able to access this Key Vault.
  DESCRIPTION
  type = object({
    bypass                     = string,
    default_action             = string,
    ip_rules                   = optional(list(string)),
    virtual_network_subnet_ids = optional(list(string)),
  })
  default = null

  validation {
    condition     = alltrue([for acls in var.network_acls : contains(["AzureServices", "None"], acls.bypass)])
    error_message = "Possible values are `AzureServices` and `None`."
  }
  validation {
    condition     = alltrue([for acls in var.network_acls : contains(["Allow", "Deny"], acls.default_action)])
    error_message = "Possible values are `Allow` and `Deny`."
  }

}

variable "purge_protection_enabled" {
  description = "(Optional) Is Purge Protection enabled for this Key Vault?"
  type        = bool
  default     = false
}

variable "public_network_access_enabled" {
  description = "(Optional) Whether public network access is allowed for this Key Vault. "
  type        = bool
  default     = true
}

variable "soft_delete_retention_days" {
  description = "(Optional) The number of days that items should be retained for once soft-deleted. This value can be between `7` and `90` days."
  type        = number
  default     = 7


  validation {
    condition     = var.soft_delete_retention_days >= 7 && var.soft_delete_retention_days <= 90
    error_message = "Retention days value can be between `7` and `90` days."
  }
}

variable "tags" {
  description = "(Optional) A mapping of tags to assign to the resource."
  type        = map(string)
  default     = {}
}

# ------------------------------------------------------------------------------
# Access
# ------------------------------------------------------------------------------

variable "admin_objects_ids" {
  description = "IDs of the objects that can do all operations on all keys, secrets and certificates."
  type        = list(string)
  default     = []

  validation {
    condition = length([
      for id in var.admin_objects_ids : true
      if can(regex("^[a-f\\d]{4}(?:[a-f\\d]{4}-){4}[a-f\\d]{12}$", id))
    ]) == length(var.admin_objects_ids)
    error_message = "Admin Objects IDs must contains GUID."
  }

}

variable "reader_objects_ids" {
  description = "IDs of the objects that can read all keys, secrets and certificates."
  type        = list(string)
  default     = []

  validation {
    condition = length([
      for id in var.reader_objects_ids : true
      if can(regex("^[a-f\\d]{4}(?:[a-f\\d]{4}-){4}[a-f\\d]{12}$", id))
    ]) == length(var.reader_objects_ids)
    error_message = "Reader Objects IDs must contains GUID."
  }
}