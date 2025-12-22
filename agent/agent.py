from langchain.chat_models import ChatDatabricks
from config.env import LLM_ENDPOINT_NAME
from agent.tools import build_tools
from agent.graph import build_graph

llm = ChatDatabricks(endpoint=LLM_ENDPOINT_NAME)
tools = build_tools()

AGENT = build_graph(llm, tools)
