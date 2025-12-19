from config.env import (
    CATALOG,
    SCHEMA,
    MODEL_NAME,
    LLM_ENDPOINT_NAME
)

def test_env_constants_exist():
    assert CATALOG
    assert SCHEMA
    assert MODEL_NAME
    assert LLM_ENDPOINT_NAME
