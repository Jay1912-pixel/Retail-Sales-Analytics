
USE retail_db;

-- =====================================================
-- 1. RFM BASE: Customer-level purchase metrics
-- =====================================================

CREATE OR REPLACE VIEW rfm_base AS
SELECT
    customer_id,
    MAX(invoice_date) AS last_order_date,
    COUNT(DISTINCT invoice) AS frequency,
    SUM(quantity * price) AS monetary

FROM staging_raw

WHERE customer_id IS NOT NULL
  AND invoice IS NOT NULL
  AND invoice NOT LIKE 'C%'
  AND invoice_date IS NOT NULL
  AND quantity > 0
  AND price > 0

GROUP BY customer_id;


-- =====================================================
-- 2. RFM SCORES: Calculate Recency, Frequency, Monetary
-- =====================================================

CREATE OR REPLACE VIEW rfm_scores AS
SELECT
    customer_id,

    DATEDIFF(
        (SELECT DATE_ADD(MAX(invoice_date), INTERVAL 1 DAY)
         FROM staging_raw
         WHERE invoice_date IS NOT NULL),
        last_order_date
    ) AS recency_days,

    frequency,
    monetary,

    -- Higher R score = more recent purchase
    NTILE(5) OVER (
        ORDER BY last_order_date ASC
    ) AS r_score,

    -- Higher F score = more frequent purchases
    NTILE(5) OVER (
        ORDER BY frequency ASC
    ) AS f_score,

    -- Higher M score = higher spending
    NTILE(5) OVER (
        ORDER BY monetary ASC
    ) AS m_score

FROM rfm_base
WHERE last_order_date IS NOT NULL;


-- =====================================================
-- 3. RFM SEGMENTS: Customer categorization
-- =====================================================

CREATE OR REPLACE VIEW rfm_segments AS
SELECT
    customer_id,
    recency_days,
    frequency,
    monetary,
    r_score,
    f_score,
    m_score,

    (r_score + f_score + m_score) AS rfm_total,

    CASE
        WHEN r_score >= 4
         AND f_score >= 4
         AND m_score >= 4
            THEN 'Champions'

        WHEN r_score >= 3
         AND f_score >= 3
         AND m_score >= 3
            THEN 'Loyal Customers'

        WHEN r_score >= 4
         AND f_score <= 2
            THEN 'Recent Customers'

        WHEN r_score <= 2
         AND f_score >= 3
            THEN 'At Risk'

        WHEN r_score <= 2
         AND f_score <= 2
         AND m_score <= 2
            THEN 'Lost'

        ELSE 'Needs Attention'
    END AS segment

FROM rfm_scores;


-- =====================================================
-- 4. CUSTOMER SEGMENT SUMMARY
-- =====================================================

SELECT
    segment,
    COUNT(*) AS customer_count

FROM rfm_segments

GROUP BY segment
ORDER BY customer_count DESC;


-- =====================================================
-- 5. CUSTOMER LIFETIME VALUE (12 MONTHS)
-- =====================================================

CREATE OR REPLACE VIEW customer_clv AS
SELECT
    customer_id,
    frequency,
    monetary,

    -- Average Order Value
    ROUND(
        monetary / NULLIF(frequency, 0),
        2
    ) AS average_order_value,

    -- Estimated annual purchase frequency
    ROUND(
        (frequency / 24.0) * 12,
        2
    ) AS estimated_annual_frequency,

    -- Estimated 12-month customer value
    ROUND(
        (monetary / NULLIF(frequency, 0))
        * ((frequency / 24.0) * 12),
        2
    ) AS clv_12_month

FROM rfm_segments;


-- =====================================================
-- 6. OVERALL CLV SUMMARY
-- =====================================================

SELECT
    COUNT(*) AS total_customers,
    ROUND(AVG(clv_12_month), 2) AS average_clv,
    ROUND(SUM(clv_12_month), 2) AS total_estimated_clv

FROM customer_clv;


-- =====================================================
-- 7. CLV BY CUSTOMER SEGMENT
-- =====================================================

SELECT
    r.segment,
    COUNT(*) AS customer_count,

    ROUND(
        AVG(c.clv_12_month), 2
    ) AS average_clv,

    ROUND(
        SUM(c.clv_12_month), 2
    ) AS total_clv

FROM customer_clv c

JOIN rfm_segments r
    ON c.customer_id = r.customer_id

GROUP BY r.segment
ORDER BY average_clv DESC;


-- =====================================================
-- 8. TOP 10 CUSTOMERS BY CLV
-- =====================================================

SELECT
    customer_id,
    frequency,
    monetary,
    average_order_value,
    estimated_annual_frequency,
    clv_12_month

FROM customer_clv

ORDER BY clv_12_month DESC
LIMIT 10;


-- =====================================================
-- 9. VERIFY CUSTOMER CLV RECORD COUNT
-- =====================================================

SELECT COUNT(*) AS total_clv_records
FROM customer_clv;
