resource "databricks_directory" "agent_root" {
  path = var.workspace_root
}

resource "databricks_directory" "agent_notebooks" {
  path = "${var.workspace_root}/notebooks"
}

resource "databricks_directory" "agent_module" {
  path = "${var.workspace_root}/notebooks/agent"
}
