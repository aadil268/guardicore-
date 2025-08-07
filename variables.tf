variable "resource_group_name" {
  default = "rg-guardicore"
}
variable "location" {
  default = "North Europe"
}

variable "subscription_id" {
  description = "Azure subscription ID"
  type        = string
}

variable "instance_name" {
  description = "Base name for the VM instances"
  type        = string
  default     = "vmguardicore"
}

variable "vm_count" {
  description = "Number of VMs to create"
  type        = number
  default     = 1
}

# Guardicore Agent Installation Variables
variable "enable_guardicore_agent_installation" {
  description = "Enable Guardicore Agent installation if true."
  type        = bool
  default     = true
}

variable "guardicore_idp_hostname" {
  description = "The Identity Provider (IdP) hostname for Guardicore Agent authentication."
  type        = string
}

variable "guardicore_token" {
  description = "The ETP activation or entitlement code for Guardicore Agent."
  type        = string
  sensitive   = true
}

variable "guardicore_exe_url" {
  description = "URL to download the Guardicore Agent EXE installer. If empty, assumes EXE is pre-staged."
  type        = string
}

variable "guardicore_customscript_handler_version" {
  description = "The version of the Custom Script Extension handler to use for Guardicore installation."
  type        = string
  default     = "1.10"
}

variable "guardicore_script_url" {
  description = "URL to the Guardicore installation script"
  type        = string
}