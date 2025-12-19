variable "databricks_host" {
  type        = string
  description = "Databricks workspace URL"
}

variable "databricks_token" {
  type        = string
  sensitive   = true
}

variable "catalog" {
  type    = string
  default = "beam_ndev"
}

variable "schema" {
  type    = string
  default = "helpdesk_sst"
}

variable "model_name" {
  type    = string
  default = "v5_help_hub_agent"
}
