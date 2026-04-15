import pandas as pd
import sqlite3

conn = sqlite3.connect("data/crossfit.db")

df = pd.read_sql("SELECT * FROM athlete_strength_analysis", conn)

df.to_csv("outputs/strength_analysis.csv", index=False)

print("Export successful!")