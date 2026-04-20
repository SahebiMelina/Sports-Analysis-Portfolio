import pandas as pd
import sqlite3
from pathlib import Path

BASE_DIR = Path(__file__).resolve().parent.parent
CSV_IN = BASE_DIR / "data" / "Analysis.csv"
CSV_SELECTED = BASE_DIR / "data" / "Analysis_selected.csv"
DB_OUT = BASE_DIR / "data" / "analysis_selected.db"
SAMPLE_ROWS = 10000
SELECT_COLUMNS = [
    "name",
    "age",
    "gender",
    "experience",
    "train",
    "schedule",
    "fran",
]


def create_selected_csv():
    df = pd.read_csv(CSV_IN)
    missing = [col for col in SELECT_COLUMNS if col not in df.columns]
    if missing:
        raise ValueError(f"Missing columns in input CSV: {missing}")
    sample = df[SELECT_COLUMNS].head(SAMPLE_ROWS)
    sample.to_csv(CSV_SELECTED, index=False)
    print(f"Wrote selected CSV: {CSV_SELECTED} ({len(sample)} rows)")


def load_selected_to_sql():
    df = pd.read_csv(CSV_SELECTED)
    conn = sqlite3.connect(DB_OUT)
    df.to_sql("analysis", conn, if_exists="replace", index=False)
    conn.execute("CREATE INDEX IF NOT EXISTS idx_gender ON analysis(gender)")
    conn.commit()
    conn.close()
    print(f"Created SQLite DB: {DB_OUT} (table=analysis, rows={len(df)})")


if __name__ == "__main__":
    create_selected_csv()
    load_selected_to_sql()
