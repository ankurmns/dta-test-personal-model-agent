import mlflow
from agent.agent import AGENT


def log_agent(resources):
    return mlflow.pyfunc.log_model(
        name="agent", python_model="agent/agent.py", resources=resources
    )
