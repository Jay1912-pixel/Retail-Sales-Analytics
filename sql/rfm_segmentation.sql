USE retail_db;

-- ============================================
-- RFM Segmentation
-- Recency, Frequency, Monetary scoring per customer
-- ============================================

CREATE OR REPLACE VIEW rfm_base AS
SELECT
    o.customer_id,
    MAX(o.invoice_date) AS last_order_date,
    COUNT(DISTINCT o.invoice_no) AS frequency,
    SUM(oi.line_total) AS monetary
FROM orders o
JOIN order_items oi ON o.invoice_no = oi.invoice_no
WHERE o.is_cancelled = FALSE
  AND o.customer_id != 'GUEST'
GROUP BY o.customer_id;

-- Score each customer 1-5 on R, F, M using NTILE
-- (5 = best, 1 = worst)
CREATE OR REPLACE VIEW rfm_scores AS
SELECT
    customer_id,
    DATEDIFF(
        (SELECT DATE_ADD(MAX(invoice_date), INTERVAL 1 DAY) FROM orders),
        last_order_date
    ) AS recency_days,
    frequency,
    monetary,
    NTILE(5) OVER (ORDER BY DATEDIFF(
        (SELECT DATE_ADD(MAX(invoice_date), INTERVAL 1 DAY) FROM orders),
        last_order_date
    ) DESC) AS r_score,
    NTILE(5) OVER (ORDER BY frequency ASC) AS f_score,
    NTILE(5) OVER (ORDER BY monetary ASC) AS m_score
FROM rfm_base;

-- Combine into RFM segment tiers
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
        WHEN r_score >= 4 AND f_score >= 4 AND m_score >= 4 THEN 'Champions'
        WHEN r_score >= 3 AND f_score >= 3 THEN 'Loyal Customers'
        WHEN r_score >= 4 AND f_score <= 2 THEN 'New Customers'
        WHEN r_score <= 2 AND f_score >= 3 THEN 'At Risk'
        WHEN r_score <= 2 AND f_score <= 2 AND m_score <= 2 THEN 'Lost'
        ELSE 'Needs Attention'
    END AS segment
FROM rfm_scores;