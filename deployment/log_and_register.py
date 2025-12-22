import mlflow
from mlflow.tracking import MlflowClient
from agent.agent import AGENT
from config.env import CATALOG, SCHEMA, MODEL_NAME

mlflow.set_tracking_uri("databricks")
mlflow.set_registry_uri("databricks-uc")

with mlflow.start_run():
    model_info = mlflow.pyfunc.log_model(
        name="agent",
        python_model="agent/agent.py",
        pip_requirements="requirements.txt",
    )

full_model_name = f"{CATALOG}.{SCHEMA}.{MODEL_NAME}"

client = MlflowClient()
result = client.register_model(model_info.model_uri, full_model_name)

client.set_registered_model_alias(
    name=full_model_name, alias="champion", version=result.version
)

print(f"model_name={full_model_name}")
print(f"model_version={result.version}")
