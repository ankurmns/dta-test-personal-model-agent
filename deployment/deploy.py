from databricks import agents

def deploy_agent(model_name, version):
    agents.deploy(
        model_name,
        version,
        scale_to_zero_enabled=False,
        workload_size="Large"
    )
