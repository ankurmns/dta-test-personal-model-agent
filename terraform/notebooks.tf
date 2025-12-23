resource "databricks_notebook" "agent_notebooks" {
  for_each = local.notebooks

  source = each.value.source
  path   = each.value.path
  format = "JUPYTER"
}
