# Business Insights — Retail Sales Intelligence Project

**Dataset:** Online Retail II (UK-based online retailer, Dec 2009 – Dec 2011)
**Scope:** 1,067,371 raw transaction records → 1,055,717 cleaned line items across 53,628 orders, 5,943 customers, and 4,768 products.

---

## Key Finding 1: A small "Champions" segment drives disproportionate revenue

Customer RFM segmentation shows that **Champions make up just 22.6% of the customer base (1,335 customers) but average ₹8,996 in spend per customer** — roughly 4.5x the average across all other segments combined.

**Recommendation:** Build a loyalty/VIP program specifically for this segment (early access to new stock, dedicated support, personalized offers). Even a 5% improvement in Champion retention could meaningfully protect a large share of total revenue, since losing even a handful of these customers has an outsized impact compared to losing several Lost/New customers.

---

## Key Finding 2: "At Risk" customers spend more than "Loyal" customers — a retention red flag

At Risk customers (711 people, low recency but historically high frequency) have an **average spend of ₹2,214 — higher than the Loyal Customers segment (₹1,922)**. This means some of the highest-value customers are showing early signs of churn before they've been fully retained.

**Recommendation:** Prioritize win-back campaigns (personalized discount codes, "we miss you" email flows) specifically targeted at At Risk customers rather than broad-based retention campaigns — this segment has the highest ROI potential per customer reached.

---

## Key Finding 3: Nearly a quarter of transactions come from unidentified "guest" customers

**22.77% of all transaction records had no Customer ID.** Rather than discard this data, it was bucketed into a "GUEST" segment during cleaning, preserving revenue visibility while keeping identified-customer analysis clean.

**Recommendation:** Introduce incentives for guest checkouts to create an account (e.g., a small discount on next purchase) — converting even 10-15% of guest transactions into identified customers would significantly improve the ability to run targeted retention and loyalty programs going forward.

---

## Key Finding 4: Revenue is heavily concentrated in the UK, with untapped adjacency markets

United Kingdom accounts for the large majority of total revenue (~₹13.8M of ~₹19.45M total), with Switzerland and Netherlands as distant second and third markets.

**Recommendation:** Rather than spreading marketing thin across 40+ countries with negligible sales, focus expansion efforts on the next 2-3 highest-performing non-UK markets where a beachhead already exists, instead of markets with near-zero current traction.

---

## Key Finding 5: Data quality issues initially distorted product-level insights

During analysis, internal operational notes (e.g., "wonky bottom/broken", "missing", "mailout", damage/adjustment logs) were found embedded in the product description field, incorrectly overriding legitimate product names for the same stock code — corrupting the top-products-by-revenue view.

**Recommendation (methodological, not business):** This was resolved by filtering out non-product description patterns before aggregation. This finding reinforces the importance of validating "top N" results against raw source data before presenting them — a good practice to mention when discussing this project's rigor.

---

## Summary Table

| Segment | Customers | Avg Spend |
|---|---|---|
| Champions | 1,335 | ₹8,996.54 |
| Loyal Customers | 1,465 | ₹1,921.80 |
| At Risk | 711 | ₹2,214.03 |
| Needs Attention | 700 | ₹826.29 |
| Lost | 1,353 | ₹263.09 |
| New Customers | 289 | ₹393.03 |
