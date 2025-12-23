locals {
  knowledgebase_table = "${var.catalog_name}.${var.schema_name}.knowledgebase"
  vector_index_fqn    = "${var.catalog_name}.${var.schema_name}.${var.vector_index_name}"
}
