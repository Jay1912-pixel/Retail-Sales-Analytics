
"""
Customer Lifetime Value (CLV) calculation
Retail Sales Intelligence Project

Purpose: Calculate a simple historical CLV per customer and write
results back to MySQL so Power BI can use it directly.
"""

import os
import pandas as pd
from dotenv import load_dotenv
from sqlalchemy import create_engine
from sqlalchemy.engine import URL

# ---- LOAD ENVIRONMENT VARIABLES ----
load_dotenv()

required_vars = ["DB_USER", "DB_PASSWORD", "DB_HOST", "DB_NAME"]
missing = [var for var in required_vars if not os.getenv(var)]

if missing:
    raise ValueError(
        f"Missing environment variables in .env: {', '.join(missing)}"
    )

# ---- SECURE DATABASE CONNECTION ----
db_url = URL.create(
    drivername="mysql+mysqlconnector",
    username=os.getenv("DB_USER"),
    password=os.getenv("DB_PASSWORD"),
    host=os.getenv("DB_HOST"),
    database=os.getenv("DB_NAME")
)

engine = create_engine(db_url)

try:
    print("Pulling RFM data from MySQL...")
    rfm = pd.read_sql("SELECT * FROM rfm_segments", con=engine)

    print(f"Loaded {len(rfm):,} customers")

    # ---- SIMPLE CLV CALCULATION ----
    # CLV = average order value * estimated annual frequency
    # This is a simplified historical CLV, not a predictive model.

    rfm["avg_order_value"] = rfm["monetary"] / rfm["frequency"]

    # Dataset spans approximately 24 months
    rfm["estimated_annual_frequency"] = (
        rfm["frequency"] / 24
    ) * 12

    rfm["clv_12_month"] = round(
        rfm["avg_order_value"] * rfm["estimated_annual_frequency"], 2
    )

    # ---- WRITE BACK TO MYSQL ----
    print("Writing CLV table back to MySQL...")

    rfm.to_sql(
        "customer_clv",
        con=engine,
        if_exists="replace",  # Overwrite the table each time
        index=False
    )

    print(f"Done! customer_clv table created with {len(rfm):,} rows.")

    print("\nTop 5 customers by CLV:")
    print(
        rfm.sort_values("clv_12_month", ascending=False)[
            ["customer_id", "segment", "monetary", "clv_12_month"]
        ].head()
    )

finally:
    engine.dispose()
