from databricks.agents.evals import generate_evals_df

def generate_synthetic_eval(docs, guidelines, num_evals=500):
    return generate_evals_df(
        docs=docs,
        num_evals=num_evals,
        guidelines=guidelines
    )