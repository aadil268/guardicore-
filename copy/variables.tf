variable "resource_group_name" {
  default = "rg-cloudbaseinit"
}
variable "location" {
  default = "North Europe"
}

variable "subscription_id" {
  description = "Azure subscription ID"
  type        = string
}