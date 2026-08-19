USE retail_db;

-- ============================================
-- STEP 4a: Populate customers table
-- Missing Customer IDs get bucketed as 'GUEST'
-- ============================================
INSERT INTO customers (customer_id, country)
SELECT DISTINCT
    COALESCE(customer_id, 'GUEST') AS customer_id,
    country
FROM staging_raw
WHERE country IS NOT NULL
ON DUPLICATE KEY UPDATE country = VALUES(country);

-- ============================================
-- STEP 4b: Populate products table
-- Take the most recent/common price per stock_code
-- (some stock codes have multiple prices over time)
-- ============================================
INSERT INTO products (stock_code, description, unit_price)
SELECT
    stock_code,
    MAX(description) AS description,   -- pick one description if it varies
    AVG(price) AS unit_price            -- average price across records
FROM staging_raw
WHERE stock_code IS NOT NULL
GROUP BY stock_code
ON DUPLICATE KEY UPDATE
    description = VALUES(description),
    unit_price = VALUES(unit_price);

-- ============================================
-- STEP 4c: Populate orders table
-- One row per invoice, flag cancellations
-- ============================================
INSERT INTO orders (invoice_no, customer_id, invoice_date, is_cancelled)
SELECT
    invoice AS invoice_no,
    COALESCE(customer_id, 'GUEST') AS customer_id,
    MIN(invoice_date) AS invoice_date,   -- earliest timestamp for that invoice
    CASE WHEN invoice LIKE 'C%' THEN TRUE ELSE FALSE END AS is_cancelled
FROM staging_raw
WHERE invoice IS NOT NULL
GROUP BY invoice, customer_id
ON DUPLICATE KEY UPDATE
    is_cancelled = VALUES(is_cancelled);

-- ============================================
-- STEP 4d: Populate order_items table
-- One row per line item, skip zero/negative price junk rows
-- (negative QUANTITY is fine -- that's a legit return)
-- ============================================
INSERT INTO order_items (invoice_no, stock_code, quantity, unit_price)
SELECT
    invoice AS invoice_no,
    stock_code,
    quantity,
    price AS unit_price
FROM staging_raw
WHERE invoice IS NOT NULL
  AND stock_code IS NOT NULL
  AND price > 0;   -- drop the zero-price junk rows found in Step 2