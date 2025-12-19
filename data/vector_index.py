# data/vector_index.py

import time
from databricks.vector_search.client import VectorSearchClient
from config.env import EMBEDDING_ENDPOINT_NAME, VECTOR_SEARCH_ENDPOINT
from config.tables import vector_index_name

def create_vector_indexes(module_tables: dict):
    client = VectorSearchClient()

    for _, table in module_tables.items():
        index_name = vector_index_name(table)

        client.create_delta_sync_index(
            endpoint_name=VECTOR_SEARCH_ENDPOINT,
            source_table_name=table,
            index_name=index_name,
            pipeline_type="TRIGGERED",
            primary_key="id",
            embedding_source_column="text",
            embedding_model_endpoint_name=EMBEDDING_ENDPOINT_NAME,
        )

        time.sleep(1)
