
DROP TABLE IF EXISTS clickhouse.default.sales_by_product;

CREATE TABLE clickhouse.default.sales_by_product
ENGINE = MergeTree()
ORDER BY (product_category, total_revenue) AS
SELECT 
    p.product_id,
    p.product_name,
    p.product_category,
    p.product_brand,
    p.product_rating,
    p.product_reviews,
    p.rating_category,
    SUM(f.total_price) AS total_revenue,
    COUNT(DISTINCT f.sale_id) AS total_sales_count,
    SUM(f.quantity) AS total_units_sold,
    AVG(f.total_price / f.quantity) AS avg_selling_price,
    AVG(p.product_rating) AS avg_product_rating,
    COUNT(DISTINCT f.customer_id) AS unique_customers
FROM clickhouse.default.fact_sales f
JOIN clickhouse.default.dim_product p ON f.product_id = p.product_id
GROUP BY p.product_id, p.product_name, p.product_category, p.product_brand, 
         p.product_rating, p.product_reviews, p.rating_category;

-- Топ-10 продуктов
DROP TABLE IF EXISTS clickhouse.default.top_10_products;

CREATE TABLE clickhouse.default.top_10_products
ENGINE = MergeTree()
ORDER BY (total_units_sold DESC) AS
SELECT 
    product_id, product_name, product_category,
    total_units_sold, total_revenue,
    row_number() OVER (ORDER BY total_units_sold DESC) AS sales_rank
FROM clickhouse.default.sales_by_product
ORDER BY total_units_sold DESC
LIMIT 10;


DROP TABLE IF EXISTS clickhouse.default.sales_by_customer;

CREATE TABLE clickhouse.default.sales_by_customer
ENGINE = MergeTree()
ORDER BY (customer_country, total_spent DESC) AS
SELECT 
    c.customer_id, c.full_name, c.customer_email,
    c.customer_country, c.customer_age, c.age_group, c.customer_pet_type,
    SUM(f.total_price) AS total_spent,
    COUNT(DISTINCT f.sale_id) AS total_purchases,
    AVG(f.total_price) AS avg_order_value,
    AVG(f.quantity) AS avg_items_per_order,
    SUM(f.quantity) AS total_items_bought,
    MAX(toDate(f.date_id)) AS last_purchase_date,
    COUNT(DISTINCT f.product_id) AS unique_products_bought
FROM clickhouse.default.fact_sales f
JOIN clickhouse.default.dim_customer c ON f.customer_id = c.customer_id
GROUP BY c.customer_id, c.full_name, c.customer_email, c.customer_country,
         c.customer_age, c.age_group, c.customer_pet_type;

-- Топ-10 клиентов
DROP TABLE IF EXISTS clickhouse.default.top_10_customers;

CREATE TABLE clickhouse.default.top_10_customers
ENGINE = MergeTree()
ORDER BY (total_spent DESC) AS
SELECT 
    customer_id, full_name, customer_country,
    total_spent, total_purchases, avg_order_value,
    row_number() OVER (ORDER BY total_spent DESC) AS spending_rank
FROM clickhouse.default.sales_by_customer
ORDER BY total_spent DESC
LIMIT 10;

-- Распределение по странам
DROP TABLE IF EXISTS clickhouse.default.customers_by_country;

CREATE TABLE clickhouse.default.customers_by_country
ENGINE = MergeTree()
ORDER BY (customer_country) AS
SELECT 
    customer_country,
    COUNT(DISTINCT customer_id) AS total_customers,
    SUM(total_spent) AS total_revenue_from_country,
    AVG(avg_order_value) AS avg_order_value_by_country
FROM clickhouse.default.sales_by_customer
GROUP BY customer_country
ORDER BY total_customers DESC;


DROP TABLE IF EXISTS clickhouse.default.sales_by_time;

CREATE TABLE clickhouse.default.sales_by_time
ENGINE = MergeTree()
ORDER BY (year, month) AS
SELECT 
    d.year, d.month, d.month_name, d.quarter,
    SUM(f.total_price) AS total_revenue,
    COUNT(DISTINCT f.sale_id) AS total_sales,
    COUNT(DISTINCT f.customer_id) AS unique_customers,
    AVG(f.total_price) AS avg_order_value,
    SUM(f.quantity) AS total_units_sold,
    COUNT(DISTINCT f.product_id) AS unique_products_sold
FROM clickhouse.default.fact_sales f
JOIN clickhouse.default.dim_date d ON f.date_id = d.date_id
GROUP BY d.year, d.month, d.month_name, d.quarter
ORDER BY d.year, d.month;

-- Месячные тренды
DROP TABLE IF EXISTS clickhouse.default.sales_monthly_trend;

CREATE TABLE clickhouse.default.sales_monthly_trend
ENGINE = MergeTree()
ORDER BY (year, month) AS
SELECT 
    year, month, month_name, total_revenue, total_sales, avg_order_value,
    lagInFrame(total_revenue, 1) OVER (ORDER BY year, month) AS prev_month_revenue,
    total_revenue - lagInFrame(total_revenue, 1) OVER (ORDER BY year, month) AS revenue_change,
    round((total_revenue / lagInFrame(total_revenue, 1) OVER (ORDER BY year, month) - 1) * 100, 2) AS revenue_growth_percent
FROM clickhouse.default.sales_by_time;


DROP TABLE IF EXISTS clickhouse.default.sales_by_store;

CREATE TABLE clickhouse.default.sales_by_store
ENGINE = MergeTree()
ORDER BY (store_country, total_revenue DESC) AS
SELECT 
    s.store_id, s.store_name, s.seller_full_name,
    s.store_city, s.store_state, s.store_country, s.seller_email,
    SUM(f.total_price) AS total_revenue,
    COUNT(DISTINCT f.sale_id) AS total_sales_count,
    COUNT(DISTINCT f.customer_id) AS unique_customers,
    AVG(f.total_price) AS avg_order_value,
    SUM(f.quantity) AS total_units_sold,
    COUNT(DISTINCT f.product_id) AS unique_products_sold
FROM clickhouse.default.fact_sales f
JOIN clickhouse.default.dim_store s ON f.store_id = s.store_id
GROUP BY s.store_id, s.store_name, s.seller_full_name, s.store_city, 
         s.store_state, s.store_country, s.seller_email;

-- Топ-5 магазинов
DROP TABLE IF EXISTS clickhouse.default.top_5_stores;

CREATE TABLE clickhouse.default.top_5_stores
ENGINE = MergeTree()
ORDER BY (total_revenue DESC) AS
SELECT 
    store_id, store_name, store_country, store_city,
    total_revenue, total_sales_count, avg_order_value,
    row_number() OVER (ORDER BY total_revenue DESC) AS revenue_rank
FROM clickhouse.default.sales_by_store
ORDER BY total_revenue DESC
LIMIT 5;


DROP TABLE IF EXISTS clickhouse.default.sales_by_supplier;

CREATE TABLE clickhouse.default.sales_by_supplier
ENGINE = MergeTree()
ORDER BY (supplier_country, total_revenue DESC) AS
SELECT 
    sup.supplier_id, sup.supplier_name, sup.supplier_contact,
    sup.supplier_email, sup.supplier_city, sup.supplier_country,
    SUM(f.total_price) AS total_revenue,
    COUNT(DISTINCT f.sale_id) AS total_sales_count,
    AVG(p.base_price) AS avg_product_price,
    SUM(f.quantity) AS total_units_sold,
    COUNT(DISTINCT f.product_id) AS unique_products_supplied,
    AVG(f.total_price / f.quantity - p.base_price) AS avg_margin_per_unit
FROM clickhouse.default.fact_sales f
JOIN clickhouse.default.dim_supplier sup ON f.supplier_id = sup.supplier_id
JOIN clickhouse.default.dim_product p ON f.product_id = p.product_id
GROUP BY sup.supplier_id, sup.supplier_name, sup.supplier_contact, sup.supplier_email,
         sup.supplier_city, sup.supplier_country;

-- Топ-5 поставщиков
DROP TABLE IF EXISTS clickhouse.default.top_5_suppliers;

CREATE TABLE clickhouse.default.top_5_suppliers
ENGINE = MergeTree()
ORDER BY (total_revenue DESC) AS
SELECT 
    supplier_id, supplier_name, supplier_country,
    total_revenue, total_sales_count, avg_product_price,
    row_number() OVER (ORDER BY total_revenue DESC) AS revenue_rank
FROM clickhouse.default.sales_by_supplier
ORDER BY total_revenue DESC
LIMIT 5;

DROP TABLE IF EXISTS clickhouse.default.product_quality;

CREATE TABLE clickhouse.default.product_quality
ENGINE = MergeTree()
ORDER BY (product_rating DESC) AS
SELECT 
    p.product_id, p.product_name, p.product_category,
    p.product_brand, p.product_rating, p.product_reviews, p.rating_category,
    SUM(f.total_price) AS total_revenue,
    COUNT(DISTINCT f.sale_id) AS sales_count,
    SUM(f.quantity) AS units_sold,
    COUNT(DISTINCT f.customer_id) AS unique_buyers,
    round(p.product_reviews / NULLIF(COUNT(DISTINCT f.sale_id), 0), 2) AS reviews_per_sale,
    AVG(f.total_price / f.quantity) AS avg_selling_price
FROM clickhouse.default.dim_product p
JOIN clickhouse.default.fact_sales f ON p.product_id = f.product_id
GROUP BY p.product_id, p.product_name, p.product_category, p.product_brand,
         p.product_rating, p.product_reviews, p.rating_category;

-- Топ и нижние продукты по рейтингу
DROP TABLE IF EXISTS clickhouse.default.top_bottom_rated_products;

CREATE TABLE clickhouse.default.top_bottom_rated_products
ENGINE = MergeTree()
ORDER BY (rating_category, product_rating DESC) AS
SELECT 
    product_id, product_name, product_category, product_brand,
    product_rating, product_reviews, rating_category,
    total_revenue, units_sold,
    multiIf(product_rating >= 4.5, 'Top Rated',
            product_rating <= 2.0, 'Bottom Rated',
            'Average') AS rating_tier
FROM clickhouse.default.product_quality
WHERE product_rating >= 4.5 OR product_rating <= 2.0
ORDER BY product_rating DESC;

SELECT 'All reports created successfully!' AS status;