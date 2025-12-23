from agent.graph import build_graph
from langchain.schema import HumanMessage


def test_agent_predict(dummy_llm, dummy_tools):
    # pass
    agent = build_graph(dummy_llm, dummy_tools)

    result = agent.invoke({
        "messages": [HumanMessage(content="Hello")]
    })

    assert result["messages"][-1].content == "dummy response"
