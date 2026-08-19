# Retail Sales Intelligence System

An end-to-end data analytics project covering the full pipeline: raw transactional data → SQL data modeling → Python transformation → RFM customer segmentation → interactive Power BI dashboards → business recommendations.

**Dataset:** [Online Retail II (UCI)](https://archive.ics.uci.edu/dataset/502/online+retail+ii) — 1M+ transactions from a UK-based online retailer, Dec 2009–Dec 2011.

---

## Problem Statement

Retail businesses generate large volumes of transactional data but often fail to convert it into actionable customer and product strategy. This project simulates a real analyst's workflow: taking messy raw sales data and turning it into a live, queryable, decision-ready system — identifying which customers to retain, which products drive revenue, and where data quality issues distort naive analysis.

---

## Approach

**1. Data Ingestion & Exploration (Python)**
Raw Excel data (1,067,371 rows) loaded and profiled for data quality issues — missing customer IDs (22.77%), cancelled orders, negative quantities, duplicate rows, and zero-price anomalies — before any cleaning was applied.

**2. Database Design & ETL (MySQL + SQL)**
Designed a normalized relational schema (`customers`, `products`, `orders`, `order_items`) fed by a staging table. Cleaning logic handled:
- Missing customer IDs bucketed into a `GUEST` segment rather than dropped
- Cancelled orders flagged (not deleted) to preserve business trend visibility
- Non-product entries (internal adjustment/damage notes embedded in the description field) filtered out after being discovered corrupting product-level aggregates

**3. Customer Segmentation (SQL window functions)**
Built RFM (Recency, Frequency, Monetary) scoring using `NTILE()` window functions, segmenting all 5,942 customers into six tiers: Champions, Loyal Customers, At Risk, Needs Attention, New Customers, and Lost.

**4. Customer Lifetime Value (Python)**
Calculated a simplified 12-month CLV estimate per customer using pandas, written back to MySQL as a queryable table.

**5. Dashboarding (Power BI, live MySQL connection)**
Three-page interactive dashboard connected directly to MySQL (not static CSV exports):
- **Executive Overview** — KPIs, monthly revenue trend, revenue by country
- **Customer Insights** — RFM segment distribution, average spend by segment, top customers by CLV
- **Product Trends** — top products by revenue and quantity, country-level breakdown

---

## Key Findings

- **Champions (22.6% of customers) average ₹8,996 in spend** — nearly 5x the typical customer, making retention here the single highest-leverage lever available.
- **At Risk customers out-spend Loyal Customers on average** (₹2,214 vs ₹1,922) — a churn warning sign hiding inside a segment that looks "fine" on the surface.
- **22.77% of transactions came from unidentified guest checkouts** — preserved as a distinct segment rather than discarded, to keep revenue visibility intact.

Full findings and recommendations: [`docs/business_insights.md`](docs/business_insights.md)

---

## Tools Used

| Layer | Tool |
|---|---|
| Data storage & modeling | MySQL 8.0 |
| Data cleaning & CLV calculation | Python (pandas, SQLAlchemy) |
| Segmentation logic | SQL (window functions — `NTILE`) |
| Visualization | Power BI (live MySQL connection) |
| Version control | Git / GitHub |

---

## How to Run This Project

1. Clone this repo
2. Set up a local MySQL 8.0+ instance, create a database named `retail_db`
3. Run `sql/schema.sql` to create the table structure
4. Download the [Online Retail II dataset](https://archive.ics.uci.edu/dataset/502/online+retail+ii) into `data/raw/`
5. Run `python python/load_raw_data.py` to load raw data into MySQL
6. Run `sql/transform_data.sql` to populate the normalized tables
7. Run `sql/rfm_segmentation.sql` to build the RFM segmentation views
8. Run `python python/calculate_clv.py` to generate the CLV table
9. Open `powerbi/retail_dashboard.pbix` in Power BI Desktop and connect to your local `retail_db`

---

## Project Structure

```
retail-sales-intelligence/
├── README.md
├── data/
│   ├── raw/                    ← original dataset (not committed — see step 4 above)
│   └── processed/
├── sql/
│   ├── schema.sql               ← table creation
│   ├── transform_data.sql       ← staging → normalized tables
│   └── rfm_segmentation.sql     ← RFM scoring with window functions
├── python/
│   ├── explore_data.py          ← data quality profiling
│   ├── load_raw_data.py         ← Excel → MySQL staging load
│   └── calculate_clv.py         ← CLV calculation
├── powerbi/
│   └── retail_dashboard.pbix
└── docs/
    └── business_insights.md     ← findings & recommendations
```

---

## Dashboard Preview

*(Add screenshots of your three Power BI pages here — Executive Overview, Customer Insights, Product Trends)*
