output "llm_endpoint" {
  value = databricks_serving_endpoint.llm.name
}

output "embedding_endpoint" {
  value = databricks_serving_endpoint.embedding.name
}

output "vector_index" {
  value = local.vector_index_fqn
}

output "notebook_paths" {
  value = {
    for k, v in databricks_notebook.agent_notebooks :
    k => v.path
  }
}
