from unittest.mock import MagicMock, patch
from data.vector_index import create_vector_indexes

@patch("data.vector_index.VectorSearchClient")
def test_create_vector_indexes(mock_client):
    mock_instance = MagicMock()
    mock_client.return_value = mock_instance

    tables = {"test": "catalog.schema.table"}
    create_vector_indexes(tables)

    mock_instance.create_delta_sync_index.assert_called_once()
