locals {
  notebooks = {
    main_agent = {
      source = "${path.module}/../notebooks/agent/main_agent.ipynb"
      path   = "${var.workspace_root}/notebooks/agent/main_agent"
    }
    tools = {
      source = "${path.module}/../notebooks/agent/tools.ipynb"
      path   = "${var.workspace_root}/notebooks/agent/tools"
    }
    evaluation = {
      source = "${path.module}/../notebooks/agent/evaluation.ipynb"
      path   = "${var.workspace_root}/notebooks/agent/evaluation"
    }
  }
}

resource "databricks_notebook" "agent_notebooks" {
  for_each = local.notebooks

  source = each.value.source
  path   = each.value.path
  format = "JUPYTER"
}
