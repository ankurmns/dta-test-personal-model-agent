variable "databricks_host" {
  description = "Databricks workspace URL"
  type        = string
}

variable "databricks_token" {
  description = "Databricks PAT token"
  type        = string
  sensitive   = true
}

variable "catalog_name" {
  default = "ai_build"
}

variable "schema_name" {
  default = "helphub_serve_build"
}

variable "llm_endpoint_name" {
  default = "gpt-oss-aibuild"
}

variable "embedding_endpoint_name" {
  default = "databricks-gte-large-en"
}

variable "vector_search_endpoint_name" {
  default = "helphub-vector-search"
}

variable "vector_index_name" {
  default = "helphub_knowledgebase_champion_idx"
}

variable "workspace_root" {
  description = "Root path in Databricks workspace"
  type        = string
  default     = "/Shared/helphub-agent"
}
