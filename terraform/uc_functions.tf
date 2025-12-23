resource "databricks_sql_function" "store_hours" {
  name          = "get_store_hours"
  catalog_name = var.catalog_name
  schema_name  = var.schema_name

  input_parameters {
    name = "store_id"
    type = "STRING"
  }

  return_type = "STRING"

  routine_definition = <<SQL
    RETURN 'Store hours are 9am to 9pm';
  SQL
}
