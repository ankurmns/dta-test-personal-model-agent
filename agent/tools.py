from databricks_langchain import VectorSearchRetrieverTool
from config.tables import HELHUB_MASTER_TABLE, vector_index_name


def build_tools():
    return [
        VectorSearchRetrieverTool(
            index_name=vector_index_name(HELHUB_MASTER_TABLE),
            description="Help Hub knowledge base",
        )
    ]
