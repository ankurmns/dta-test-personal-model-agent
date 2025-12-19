# config/tables.py

HELHUB_MASTER_TABLE = (
    "beam_ndev.helpdesk_sst.helphub_knowledgebase_v5"
)

MODULE_TABLES = {
    "Help Hub Master agent": HELHUB_MASTER_TABLE
}

def vector_index_name(table: str) -> str:
    return f"{table}_idx"
