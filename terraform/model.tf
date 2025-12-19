resource "databricks_registered_model" "helphub_agent" {
  name = "${var.catalog}.${var.schema}.${var.model_name}"
}
