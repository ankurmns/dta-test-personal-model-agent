# tests/conftest.py

import pytest
from langchain.schema import AIMessage


class DummyLLM:
    def invoke(self, messages):
        return AIMessage(content="dummy response")


@pytest.fixture
def dummy_llm():
    return DummyLLM()


@pytest.fixture
def dummy_tools():
    return []
