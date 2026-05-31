-- тчет 1: родажи по продуктам
DROP TABLE IF EXISTS sales_by_product;
CREATE TABLE sales_by_product AS
SELECT 
    p.product_id,
    p.product_name,
    p.product_category,
    SUM(f.total_price) AS total_revenue,
    COUNT(DISTINCT f.sale_id) AS total_sales_count,
    SUM(f.quantity) AS total_units_sold,
    AVG(p.product_rating) AS avg_product_rating
FROM fact_sales f
JOIN dim_product p ON f.product_id = p.product_id
GROUP BY p.product_id, p.product_name, p.product_category;

-- Топ 10 продуктов
DROP TABLE IF EXISTS top_10_products;
CREATE TABLE top_10_products AS
SELECT * FROM sales_by_product ORDER BY total_units_sold DESC LIMIT 10;

-- тчет 2: родажи по клиентам
DROP TABLE IF EXISTS sales_by_customer;
CREATE TABLE sales_by_customer AS
SELECT 
    c.customer_id,
    concat(c.customer_first_name, ' ', c.customer_last_name) AS full_name,
    c.customer_country,
    SUM(f.total_price) AS total_spent,
    COUNT(DISTINCT f.sale_id) AS total_purchases,
    AVG(f.total_price) AS avg_order_value
FROM fact_sales f
JOIN dim_customer c ON f.customer_id = c.customer_id
GROUP BY c.customer_id, c.customer_first_name, c.customer_last_name, c.customer_country;

-- Топ 10 клиентов
DROP TABLE IF EXISTS top_10_customers;
CREATE TABLE top_10_customers AS
SELECT * FROM sales_by_customer ORDER BY total_spent DESC LIMIT 10;

-- тчет 3: родажи по времени
DROP TABLE IF EXISTS sales_by_time;
CREATE TABLE sales_by_time AS
SELECT 
    d.year,
    d.month,
    d.month_name,
    SUM(f.total_price) AS total_revenue,
    COUNT(DISTINCT f.sale_id) AS total_sales,
    AVG(f.total_price) AS avg_order_value
FROM fact_sales f
JOIN dim_date d ON f.date_id = d.date_id
GROUP BY d.year, d.month, d.month_name
ORDER BY d.year, d.month;

-- тчет 4: родажи по магазинам
DROP TABLE IF EXISTS sales_by_store;
CREATE TABLE sales_by_store AS
SELECT 
    s.store_id,
    s.store_name,
    s.store_country,
    s.store_city,
    SUM(f.total_price) AS total_revenue,
    COUNT(DISTINCT f.sale_id) AS total_sales_count,
    AVG(f.total_price) AS avg_order_value
FROM fact_sales f
JOIN dim_store s ON f.store_id = s.store_id
GROUP BY s.store_id, s.store_name, s.store_country, s.store_city;

-- Топ 5 магазинов
DROP TABLE IF EXISTS top_5_stores;
CREATE TABLE top_5_stores AS
SELECT * FROM sales_by_store ORDER BY total_revenue DESC LIMIT 5;

-- тчет 5: родажи по поставщикам
DROP TABLE IF EXISTS sales_by_supplier;
CREATE TABLE sales_by_supplier AS
SELECT 
    sup.supplier_name,
    sup.supplier_country,
    SUM(f.total_price) AS total_revenue,
    COUNT(DISTINCT f.sale_id) AS total_sales_count,
    AVG(p.base_price) AS avg_product_price
FROM fact_sales f
JOIN dim_supplier sup ON f.supplier_id = sup.supplier_id
JOIN dim_product p ON f.product_id = p.product_id
GROUP BY sup.supplier_name, sup.supplier_country;

-- Топ 5 поставщиков
DROP TABLE IF EXISTS top_5_suppliers;
CREATE TABLE top_5_suppliers AS
SELECT * FROM sales_by_supplier ORDER BY total_revenue DESC LIMIT 5;

-- тчет 6: ачество продукции
DROP TABLE IF EXISTS product_quality;
CREATE TABLE product_quality AS
SELECT 
    p.product_id,
    p.product_name,
    p.product_category,
    p.product_rating,
    p.product_reviews,
    p.rating_category,
    SUM(f.total_price) AS total_revenue,
    COUNT(DISTINCT f.sale_id) AS sales_count,
    SUM(f.quantity) AS units_sold
FROM dim_product p
JOIN fact_sales f ON p.product_id = f.product_id
GROUP BY p.product_id, p.product_name, p.product_category, p.product_rating, p.product_reviews, p.rating_category;

-- Топ и нижние продукты по рейтингу
DROP TABLE IF EXISTS top_bottom_rated_products;
CREATE TABLE top_bottom_rated_products AS
SELECT * FROM product_quality 
WHERE product_rating >= 4.5 OR product_rating <= 2.0
ORDER BY product_rating DESC;

SELECT 'All reports created successfully!' AS status;
