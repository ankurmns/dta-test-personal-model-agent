resource "databricks_serving_endpoint" "agent_endpoint" {
  name = replace(
    "${var.catalog}_${var.schema}_${var.model_name}",
    ".", "_"
  )

  config {
    served_models {
      model_name    = databricks_registered_model.helphub_agent.name
      model_version = "champion"
      workload_size = "Large"
      scale_to_zero_enabled = false
    }
  }
}
