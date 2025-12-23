resource "databricks_catalog" "ai_build" {
  name          = var.catalog_name
  comment       = "Catalog for Helphub AI agent"
  force_destroy = false
}

resource "databricks_schema" "helphub" {
  name         = var.schema_name
  catalog_name = databricks_catalog.ai_build.name
  comment      = "Schema for Helphub serving & vector search"
}
