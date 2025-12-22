import mlflow
import pandas as pd


def run_agent_eval(agent_uri, requests, expected):
    data = pd.DataFrame({"request": requests, "expected_response": expected})

    return mlflow.evaluate(
        agent_uri,
        data=data,
        model_type="databricks-agent",
        evaluator_config={
            "databricks-agent": {"metrics": ["safety", "groundedness", "correctness"]}
        },
    )
