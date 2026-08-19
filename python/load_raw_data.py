"""
Step 3: Load raw data into MySQL staging table
Retail Sales Intelligence Project

Purpose: Load the raw Excel data AS-IS into a staging table.
No cleaning here — that happens in Step 4. This just gets data
out of Excel and into the database.
"""

import pandas as pd
from sqlalchemy import create_engine

# ---- CONFIG ----
RAW_PATH = "data/raw/online_retail_II.xlsx"
DB_CONNECTION = "mysql+mysqlconnector://root:Your_PASSWORD@localhost/retail_db"

# ---- Load Excel (both sheets) ----
print("Reading Excel file... this may take 20-30 seconds")
sheet_names = ["Year 2009-2010", "Year 2010-2011"]
dfs = []
for sheet in sheet_names:
    df = pd.read_excel(RAW_PATH, sheet_name=sheet)
    df["source_sheet"] = sheet
    dfs.append(df)

data = pd.concat(dfs, ignore_index=True)
print(f"Loaded {len(data):,} rows from Excel")

# ---- Rename columns to match staging_raw table ----
data = data.rename(columns={
    "Invoice": "invoice",
    "StockCode": "stock_code",
    "Description": "description",
    "Quantity": "quantity",
    "InvoiceDate": "invoice_date",
    "Price": "price",
    "Customer ID": "customer_id",
    "Country": "country",
    "source_sheet": "source_sheet"
})

# Customer ID needs to be string, not float (it currently has NaN + floats like 13085.0)
data["customer_id"] = data["customer_id"].apply(
    lambda x: str(int(x)) if pd.notnull(x) else None
)

# ---- Connect and load into staging table ----
print("Connecting to MySQL...")
engine = create_engine(DB_CONNECTION)

print("Writing to staging_raw table... this may take 1-2 minutes for 1M+ rows")
data.to_sql(
    "staging_raw",
    con=engine,
    if_exists="append",  # schema.sql already created the table structure
    index=False,
    chunksize=5000        # load in batches so it doesn't overwhelm memory
)

print(f"Done! Loaded {len(data):,} rows into staging_raw table.")