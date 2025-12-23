resource "databricks_vector_search_endpoint" "this" {
  name = var.vector_search_endpoint_name
}

resource "databricks_vector_search_index" "knowledgebase" {
  name          = var.vector_index_name
  endpoint_name = databricks_vector_search_endpoint.this.name

  primary_key = "id"
  source_table = local.knowledgebase_table

  embedding_source_columns {
    name = "content"
  }

  embedding_model_endpoint_name = var.embedding_endpoint_name
}
