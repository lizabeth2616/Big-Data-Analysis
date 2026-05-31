
-- 1. Создание таблицы измерений "Дата"
DROP TABLE IF EXISTS clickhouse.default.dim_date;

CREATE TABLE clickhouse.default.dim_date AS
WITH dates AS (
    SELECT DISTINCT CAST(sale_date AS DATE) AS sale_date
    FROM postgresql.public.mock_data
    UNION
    SELECT DISTINCT CAST(sale_date AS DATE) AS sale_date
    FROM clickhouse.default.mock_data
)
SELECT 
    CAST(FORMAT_DATETIME(sale_date, 'yyyyMMdd') AS INTEGER) AS date_id,
    sale_date,
    EXTRACT(YEAR FROM sale_date) AS year,
    EXTRACT(MONTH FROM sale_date) AS month,
    EXTRACT(QUARTER FROM sale_date) AS quarter,
    EXTRACT(DAY FROM sale_date) AS day,
    EXTRACT(DOW FROM sale_date) AS day_of_week,
    FORMAT_DATETIME(sale_date, 'MMMM') AS month_name,
    FORMAT_DATETIME(sale_date, 'EEEE') AS week_day_name,
    CASE WHEN EXTRACT(DOW FROM sale_date) IN (6, 7) THEN 1 ELSE 0 END AS is_weekend
FROM dates;

-- 2. Создание таблицы измерений "Клиент"
DROP TABLE IF EXISTS clickhouse.default.dim_customer;

CREATE TABLE clickhouse.default.dim_customer AS
SELECT DISTINCT
    CAST(sale_customer_id AS BIGINT) AS customer_id,
    CAST(customer_first_name AS VARCHAR) AS customer_first_name,
    CAST(customer_last_name AS VARCHAR) AS customer_last_name,
    CAST(customer_first_name AS VARCHAR) || ' ' || CAST(customer_last_name AS VARCHAR) AS full_name,
    customer_age,
    CAST(customer_email AS VARCHAR) AS customer_email,
    CAST(customer_country AS VARCHAR) AS customer_country,
    CAST(customer_postal_code AS VARCHAR) AS customer_postal_code,
    CAST(customer_pet_type AS VARCHAR) AS customer_pet_type,
    CAST(customer_pet_name AS VARCHAR) AS customer_pet_name,
    CAST(customer_pet_breed AS VARCHAR) AS customer_pet_breed,
    CASE 
        WHEN customer_age < 18 THEN 'Under 18'
        WHEN customer_age BETWEEN 18 AND 25 THEN '18-25'
        WHEN customer_age BETWEEN 26 AND 35 THEN '26-35'
        WHEN customer_age BETWEEN 36 AND 50 THEN '36-50'
        WHEN customer_age BETWEEN 51 AND 65 THEN '51-65'
        ELSE '65+'
    END AS age_group
FROM postgresql.public.mock_data
UNION ALL
SELECT DISTINCT
    CAST(sale_customer_id AS BIGINT) AS customer_id,
    CAST(customer_first_name AS VARCHAR) AS customer_first_name,
    CAST(customer_last_name AS VARCHAR) AS customer_last_name,
    CAST(customer_first_name AS VARCHAR) || ' ' || CAST(customer_last_name AS VARCHAR) AS full_name,
    customer_age,
    CAST(customer_email AS VARCHAR) AS customer_email,
    CAST(customer_country AS VARCHAR) AS customer_country,
    CAST(customer_postal_code AS VARCHAR) AS customer_postal_code,
    CAST(customer_pet_type AS VARCHAR) AS customer_pet_type,
    CAST(customer_pet_name AS VARCHAR) AS customer_pet_name,
    CAST(customer_pet_breed AS VARCHAR) AS customer_pet_breed,
    CASE 
        WHEN customer_age < 18 THEN 'Under 18'
        WHEN customer_age BETWEEN 18 AND 25 THEN '18-25'
        WHEN customer_age BETWEEN 26 AND 35 THEN '26-35'
        WHEN customer_age BETWEEN 36 AND 50 THEN '36-50'
        WHEN customer_age BETWEEN 51 AND 65 THEN '51-65'
        ELSE '65+'
    END AS age_group
FROM clickhouse.default.mock_data;

-- 3. Создание таблицы измерений "Продукт"
DROP TABLE IF EXISTS clickhouse.default.dim_product;

CREATE TABLE clickhouse.default.dim_product AS
SELECT DISTINCT
    CAST(sale_product_id AS BIGINT) AS product_id,
    CAST(product_name AS VARCHAR) AS product_name,
    CAST(product_category AS VARCHAR) AS product_category,
    product_price AS base_price,
    CAST(product_brand AS VARCHAR) AS product_brand,
    CAST(product_material AS VARCHAR) AS product_material,
    CAST(product_color AS VARCHAR) AS product_color,
    CAST(product_size AS VARCHAR) AS product_size,
    product_weight,
    product_rating,
    product_reviews,
    CAST(product_description AS VARCHAR) AS product_description,
    CAST(product_release_date AS DATE) AS release_date,
    CAST(product_expiry_date AS DATE) AS expiry_date,
    CASE 
        WHEN product_rating >= 4.5 THEN 'Excellent'
        WHEN product_rating >= 4.0 THEN 'Good'
        WHEN product_rating >= 3.0 THEN 'Average'
        WHEN product_rating >= 2.0 THEN 'Poor'
        ELSE 'Very Poor'
    END AS rating_category
FROM postgresql.public.mock_data
UNION ALL
SELECT DISTINCT
    CAST(sale_product_id AS BIGINT) AS product_id,
    CAST(product_name AS VARCHAR) AS product_name,
    CAST(product_category AS VARCHAR) AS product_category,
    product_price AS base_price,
    CAST(product_brand AS VARCHAR) AS product_brand,
    CAST(product_material AS VARCHAR) AS product_material,
    CAST(product_color AS VARCHAR) AS product_color,
    CAST(product_size AS VARCHAR) AS product_size,
    product_weight,
    product_rating,
    product_reviews,
    CAST(product_description AS VARCHAR) AS product_description,
    CAST(product_release_date AS DATE) AS release_date,
    CAST(product_expiry_date AS DATE) AS expiry_date,
    CASE 
        WHEN product_rating >= 4.5 THEN 'Excellent'
        WHEN product_rating >= 4.0 THEN 'Good'
        WHEN product_rating >= 3.0 THEN 'Average'
        WHEN product_rating >= 2.0 THEN 'Poor'
        ELSE 'Very Poor'
    END AS rating_category
FROM clickhouse.default.mock_data;

-- 4. Создание таблицы измерений "Магазин"
DROP TABLE IF EXISTS clickhouse.default.dim_store;

CREATE TABLE clickhouse.default.dim_store AS
SELECT DISTINCT
    CAST(sale_seller_id AS BIGINT) AS store_id,
    CAST(seller_first_name AS VARCHAR) AS seller_first_name,
    CAST(seller_last_name AS VARCHAR) AS seller_last_name,
    CAST(seller_first_name AS VARCHAR) || ' ' || CAST(seller_last_name AS VARCHAR) AS seller_full_name,
    CAST(seller_email AS VARCHAR) AS seller_email,
    CAST(seller_country AS VARCHAR) AS seller_country,
    CAST(seller_postal_code AS VARCHAR) AS seller_postal_code,
    CAST(store_name AS VARCHAR) AS store_name,
    CAST(store_location AS VARCHAR) AS store_location,
    CAST(store_city AS VARCHAR) AS store_city,
    CAST(store_state AS VARCHAR) AS store_state,
    CAST(store_country AS VARCHAR) AS store_country,
    CAST(store_phone AS VARCHAR) AS store_phone,
    CAST(store_email AS VARCHAR) AS store_email
FROM postgresql.public.mock_data
UNION ALL
SELECT DISTINCT
    CAST(sale_seller_id AS BIGINT) AS store_id,
    CAST(seller_first_name AS VARCHAR) AS seller_first_name,
    CAST(seller_last_name AS VARCHAR) AS seller_last_name,
    CAST(seller_first_name AS VARCHAR) || ' ' || CAST(seller_last_name AS VARCHAR) AS seller_full_name,
    CAST(seller_email AS VARCHAR) AS seller_email,
    CAST(seller_country AS VARCHAR) AS seller_country,
    CAST(seller_postal_code AS VARCHAR) AS seller_postal_code,
    CAST(store_name AS VARCHAR) AS store_name,
    CAST(store_location AS VARCHAR) AS store_location,
    CAST(store_city AS VARCHAR) AS store_city,
    CAST(store_state AS VARCHAR) AS store_state,
    CAST(store_country AS VARCHAR) AS store_country,
    CAST(store_phone AS VARCHAR) AS store_phone,
    CAST(store_email AS VARCHAR) AS store_email
FROM clickhouse.default.mock_data;

-- 5. Создание таблицы измерений "Поставщик"
DROP TABLE IF EXISTS clickhouse.default.dim_supplier;

CREATE TABLE clickhouse.default.dim_supplier AS
SELECT DISTINCT
    ROW_NUMBER() OVER () AS supplier_id,
    CAST(supplier_name AS VARCHAR) AS supplier_name,
    CAST(supplier_contact AS VARCHAR) AS supplier_contact,
    CAST(supplier_email AS VARCHAR) AS supplier_email,
    CAST(supplier_phone AS VARCHAR) AS supplier_phone,
    CAST(supplier_address AS VARCHAR) AS supplier_address,
    CAST(supplier_city AS VARCHAR) AS supplier_city,
    CAST(supplier_country AS VARCHAR) AS supplier_country
FROM (
    SELECT supplier_name, supplier_contact, supplier_email, supplier_phone, supplier_address, supplier_city, supplier_country
    FROM postgresql.public.mock_data
    UNION
    SELECT supplier_name, supplier_contact, supplier_email, supplier_phone, supplier_address, supplier_city, supplier_country
    FROM clickhouse.default.mock_data
) t;

-- 6. Создание таблицы фактов "Продажи"
DROP TABLE IF EXISTS clickhouse.default.fact_sales;

CREATE TABLE clickhouse.default.fact_sales AS
SELECT 
    CAST(sale_id AS BIGINT) AS sale_id,
    CAST(FORMAT_DATETIME(CAST(sale_date AS DATE), 'yyyyMMdd') AS INTEGER) AS date_id,
    CAST(sale_customer_id AS BIGINT) AS customer_id,
    CAST(sale_product_id AS BIGINT) AS product_id,
    CAST(sale_seller_id AS BIGINT) AS store_id,
    (SELECT MAX(supplier_id) FROM clickhouse.default.dim_supplier) AS supplier_id,
    CAST(sale_quantity AS INTEGER) AS quantity,
    CAST(sale_total_price AS DECIMAL(15,2)) AS total_price
FROM postgresql.public.mock_data
UNION ALL
SELECT 
    CAST(sale_id AS BIGINT) AS sale_id,
    CAST(FORMAT_DATETIME(CAST(sale_date AS DATE), 'yyyyMMdd') AS INTEGER) AS date_id,
    CAST(sale_customer_id AS BIGINT) AS customer_id,
    CAST(sale_product_id AS BIGINT) AS product_id,
    CAST(sale_seller_id AS BIGINT) AS store_id,
    (SELECT MAX(supplier_id) FROM clickhouse.default.dim_supplier) AS supplier_id,
    CAST(sale_quantity AS INTEGER) AS quantity,
    CAST(sale_total_price AS DECIMAL(15,2)) AS total_price
FROM clickhouse.default.mock_data;

SELECT 'ETL completed successfully!' AS status;