import pandas as pd
import sqlite3

# Load the cleaned athletes data
df = pd.read_csv('../data/athletes.csv')

# Create SQLite database in memory
conn = sqlite3.connect(':memory:')

# Load DataFrame into SQLite
df.to_sql('athletes', conn, index=False, if_exists='replace')

# Your SQL query
query = """
SELECT 
    name,
    bodyweight,
    snatch,
    ROUND(snatch * 1.0 / bodyweight, 2) AS snatch_ratio
FROM athletes
WHERE gender = 'F'
ORDER BY snatch_ratio DESC
LIMIT 10;
"""

# Execute the query
result = pd.read_sql_query(query, conn)

# Display results
print("Top 10 Female Athletes by Snatch-to-Bodyweight Ratio:")
print(result)

# Close connection
conn.close()</content>
<parameter name="filePath">/workspaces/Sports-Analysis-Portfolio/crossfit-analysis/scripts/run_sql_query.py