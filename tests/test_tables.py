from config.tables import vector_index_name


def test_vector_index_name():
    table = "catalog.schema.table"
    assert vector_index_name(table) == "catalog.schema.table_idx"
