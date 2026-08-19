"""
Customer Lifetime Value (CLV) calculation
Retail Sales Intelligence Project

Purpose: Calculate a simple historical CLV per customer and write
results back to MySQL so Power BI can use it directly.
"""

import pandas as pd
from sqlalchemy import create_engine

DB_CONNECTION = "mysql+mysqlconnector://root:2005@localhost/retail_db"
engine = create_engine(DB_CONNECTION)

print("Pulling RFM data from MySQL...")
rfm = pd.read_sql("SELECT * FROM rfm_segments", con=engine)

print(f"Loaded {len(rfm):,} customers")

# ---- Simple CLV calculation ----
# CLV here = average order value * frequency * a rough 12-month projection factor
# (This is a simplified historical CLV, not a predictive model -- 
#  good enough for a portfolio project, and you can explain the assumption in interviews)

rfm["avg_order_value"] = rfm["monetary"] / rfm["frequency"]

# Purchase frequency per month based on their actual activity span
# We don't have "months active" directly, so we approximate using recency as a proxy
# Simplified: assume each customer's frequency represents their behavior over ~24 months
# (dataset spans Dec 2009 - Dec 2011, i.e. 2 years)
rfm["estimated_annual_frequency"] = (rfm["frequency"] / 24) * 12

rfm["clv_12_month"] = round(
    rfm["avg_order_value"] * rfm["estimated_annual_frequency"], 2
)

# ---- Write back to MySQL as a new table ----
print("Writing CLV table back to MySQL...")
rfm.to_sql(
    "customer_clv",
    con=engine,
    if_exists="replace",  # safe here -- we WANT to overwrite each time this runs
    index=False
)

print(f"Done! customer_clv table created with {len(rfm):,} rows.")
print("\nTop 5 customers by CLV:")
print(rfm.sort_values("clv_12_month", ascending=False)[
    ["customer_id", "segment", "monetary", "clv_12_month"]
].head())