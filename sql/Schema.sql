USE retail_db;

-- Staging table: raw data lands here first, untouched
CREATE TABLE IF NOT EXISTS staging_raw (
    id              INT AUTO_INCREMENT PRIMARY KEY,
    invoice         VARCHAR(20),
    stock_code      VARCHAR(20),
    description     TEXT,
    quantity        INT,
    invoice_date    DATETIME,
    price           DECIMAL(10,2),
    customer_id     VARCHAR(10),
    country         VARCHAR(50),
    source_sheet    VARCHAR(30)
);

-- Final normalized tables
CREATE TABLE IF NOT EXISTS customers (
    customer_id     VARCHAR(10) PRIMARY KEY,
    country         VARCHAR(50)
);

CREATE TABLE IF NOT EXISTS products (
    stock_code      VARCHAR(20) PRIMARY KEY,
    description     TEXT,
    unit_price      DECIMAL(10,2)
);

CREATE TABLE IF NOT EXISTS orders (
    invoice_no      VARCHAR(20) PRIMARY KEY,
    customer_id     VARCHAR(10),
    invoice_date    DATETIME,
    is_cancelled    BOOLEAN,
    FOREIGN KEY (customer_id) REFERENCES customers(customer_id)
);

CREATE TABLE IF NOT EXISTS order_items (
    id              INT AUTO_INCREMENT PRIMARY KEY,
    invoice_no      VARCHAR(20),
    stock_code      VARCHAR(20),
    quantity        INT,
    unit_price      DECIMAL(10,2),
    line_total      DECIMAL(10,2) GENERATED ALWAYS AS