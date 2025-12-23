locals {
  knowledgebase_table = "${var.catalog_name}.${var.schema_name}.knowledgebase"
  vector_index_fqn    = "${var.catalog_name}.${var.schema_name}.${var.vector_index_name}"
  notebooks = {
    main_agent = {
      source = "${path.module}/../notebooks/03_test_agent.ipynb"
      path   = "${var.workspace_root}/notebooks/agent/main_agent"
    }
    tools = {
      source = "${path.module}/../notebooks/01_setup.ipynb"
      path   = "${var.workspace_root}/notebooks/agent/tools"
    }
    evaluation = {
      source = "${path.module}/../notebooks/04_evaluate.ipynb"
      path   = "${var.workspace_root}/notebooks/agent/evaluation"
    }
  }
}
