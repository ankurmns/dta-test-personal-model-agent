from langgraph.graph import StateGraph
from langchain.schema import AIMessage

def build_graph(llm, tools):
    graph = StateGraph()

    def call_llm(state):
        response = llm.invoke(state["messages"])
        return {"messages": state["messages"] + [response]}

    graph.add_node("llm", call_llm)
    graph.set_entry_point("llm")

    return graph.compile()
