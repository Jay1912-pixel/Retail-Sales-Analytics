"""
Step 2: Exploratory Data Analysis
Retail Sales Intelligence Project

Purpose: Inspect the raw dataset to build a documented list of data quality
issues BEFORE cleaning. Don't fix anything here — just observe and record.
"""

import pandas as pd

# ---- Load data ----
# Update the path/sheet name to match your downloaded file
RAW_PATH = "data/raw/online_retail_II.xlsx"

# The file has two sheets: one per year. Load both and combine.
sheet_names = ["Year 2009-2010", "Year 2010-2011"]
dfs = []
for sheet in sheet_names:
    df = pd.read_excel(RAW_PATH, sheet_name=sheet)
    df["source_sheet"] = sheet
    dfs.append(df)

data = pd.concat(dfs, ignore_index=True)

print("=" * 60)
print("BASIC SHAPE & STRUCTURE")
print("=" * 60)
print(f"Rows: {data.shape[0]:,}")
print(f"Columns: {data.shape[1]}")
print("\nColumn names and types:")
print(data.dtypes)

print("\n" + "=" * 60)
print("SAMPLE ROWS")
print("=" * 60)
print(data.head(10))

print("\n" + "=" * 60)
print("MISSING VALUES")
print("=" * 60)
missing = data.isnull().sum()
missing_pct = (missing / len(data) * 100).round(2)
missing_summary = pd.DataFrame({"missing_count": missing, "missing_pct": missing_pct})
print(missing_summary[missing_summary["missing_count"] > 0])

print("\n" + "=" * 60)
print("DUPLICATE ROWS")
print("=" * 60)
print(f"Full duplicate rows: {data.duplicated().sum():,}")

print("\n" + "=" * 60)
print("NEGATIVE / ZERO VALUES (Quantity, Price)")
print("=" * 60)
if "Quantity" in data.columns:
    print(f"Negative Quantity rows: {(data['Quantity'] < 0).sum():,}")
    print(f"Zero Quantity rows: {(data['Quantity'] == 0).sum():,}")
if "Price" in data.columns:
    print(f"Negative Price rows: {(data['Price'] < 0).sum():,}")
    print(f"Zero Price rows: {(data['Price'] == 0).sum():,}")

print("\n" + "=" * 60)
print("CANCELLED ORDERS (Invoice starting with 'C')")
print("=" * 60)
if "Invoice" in data.columns:
    cancelled = data["Invoice"].astype(str).str.startswith("C").sum()
    print(f"Cancelled order line items: {cancelled:,} ({cancelled/len(data)*100:.2f}%)")

print("\n" + "=" * 60)
print("MISSING CUSTOMER IDs")
print("=" * 60)
if "Customer ID" in data.columns:
    missing_cust = data["Customer ID"].isnull().sum()
    print(f"Rows with no Customer ID: {missing_cust:,} ({missing_cust/len(data)*100:.2f}%)")

print("\n" + "=" * 60)
print("DATE RANGE")
print("=" * 60)
if "InvoiceDate" in data.columns:
    print(f"Earliest: {data['InvoiceDate'].min()}")
    print(f"Latest: {data['InvoiceDate'].max()}")

print("\n" + "=" * 60)
print("UNIQUE COUNTS")
print("=" * 60)
for col in ["Customer ID", "Country", "StockCode", "Invoice"]:
    if col in data.columns:
        print(f"Unique {col}: {data[col].nunique():,}")

print("\n" + "=" * 60)
print("DONE — record these findings in your cleaning plan / README")
print("=" * 60)