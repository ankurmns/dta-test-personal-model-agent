resource "databricks_serving_endpoint" "llm" {
  name = var.llm_endpoint_name

  config {
    served_entities {
      name                  = "llm"
      entity_name           = var.llm_endpoint_name
      entity_version        = "1"
      workload_size         = "Medium"
      scale_to_zero_enabled = true
    }
  }
}

resource "databricks_serving_endpoint" "embedding" {
  name = var.embedding_endpoint_name

  config {
    served_entities {
      name                  = "embedding"
      entity_name           = var.embedding_endpoint_name
      entity_version        = "1"
      workload_size         = "Small"
      scale_to_zero_enabled = true
    }
  }
}
