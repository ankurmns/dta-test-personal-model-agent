resource "databricks_grants" "vector_search" {
  vector_search_endpoint = databricks_vector_search_endpoint.this.id

  grant {
    principal  = "users"
    privileges = ["USE"]
  }
}

resource "databricks_grants" "knowledgebase_table" {
  table = local.knowledgebase_table

  grant {
    principal  = "users"
    privileges = ["SELECT"]
  }
}
