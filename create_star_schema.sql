-- 1. ата
DROP TABLE IF EXISTS dim_date;
CREATE TABLE dim_date AS
WITH dates AS (
    SELECT DISTINCT toDate(sale_date) AS sale_date FROM mock_data
)
SELECT 
    toYYYYMMDD(sale_date) AS date_id,
    sale_date,
    toYear(sale_date) AS year,
    toMonth(sale_date) AS month,
    toQuarter(sale_date) AS quarter,
    toDayOfMonth(sale_date) AS day,
    toDayOfWeek(sale_date) AS day_of_week,
    formatDateTime(sale_date, '%M') AS month_name,
    formatDateTime(sale_date, '%W') AS week_day_name,
    if(toDayOfWeek(sale_date) IN (6, 7), 1, 0) AS is_weekend
FROM dates;

-- 2. лиент
DROP TABLE IF EXISTS dim_customer;
CREATE TABLE dim_customer AS
SELECT DISTINCT
    sale_customer_id AS customer_id,
    customer_first_name,
    customer_last_name,
    concat(customer_first_name, ' ', customer_last_name) AS full_name,
    customer_age,
    customer_email,
    customer_country,
    customer_postal_code,
    customer_pet_type,
    customer_pet_name,
    customer_pet_breed,
    multiIf(customer_age < 18, 'Under 18',
            customer_age BETWEEN 18 AND 25, '18-25',
            customer_age BETWEEN 26 AND 35, '26-35',
            customer_age BETWEEN 36 AND 50, '36-50',
            customer_age BETWEEN 51 AND 65, '51-65',
            '65+') AS age_group
FROM mock_data;

-- 3. родукт
DROP TABLE IF EXISTS dim_product;
CREATE TABLE dim_product AS
SELECT DISTINCT
    sale_product_id AS product_id,
    product_name,
    product_category,
    product_price AS base_price,
    product_brand,
    product_material,
    product_color,
    product_size,
    product_weight,
    product_rating,
    product_reviews,
    product_description,
    toDate(product_release_date) AS release_date,
    toDate(product_expiry_date) AS expiry_date,
    multiIf(product_rating >= 4.5, 'Excellent',
            product_rating >= 4.0, 'Good',
            product_rating >= 3.0, 'Average',
            product_rating >= 2.0, 'Poor',
            'Very Poor') AS rating_category
FROM mock_data;

-- 4. агазин
DROP TABLE IF EXISTS dim_store;
CREATE TABLE dim_store AS
SELECT DISTINCT
    sale_seller_id AS store_id,
    seller_first_name,
    seller_last_name,
    concat(seller_first_name, ' ', seller_last_name) AS seller_full_name,
    seller_email,
    seller_country,
    seller_postal_code,
    store_name,
    store_location,
    store_city,
    store_state,
    store_country,
    store_phone,
    store_email
FROM mock_data;

-- 5. оставщик
DROP TABLE IF EXISTS dim_supplier;
CREATE TABLE dim_supplier AS
SELECT DISTINCT
    rowNumberInAllBlocks() AS supplier_id,
    supplier_name,
    supplier_contact,
    supplier_email,
    supplier_phone,
    supplier_address,
    supplier_city,
    supplier_country
FROM mock_data;

-- 6. акт продажи
DROP TABLE IF EXISTS fact_sales;
CREATE TABLE fact_sales AS
SELECT 
    sale_id,
    toYYYYMMDD(toDate(sale_date)) AS date_id,
    sale_customer_id AS customer_id,
    sale_product_id AS product_id,
    sale_seller_id AS store_id,
    1 AS supplier_id,
    sale_quantity AS quantity,
    sale_total_price AS total_price
FROM mock_data;

SELECT 'Star schema created successfully!' AS status;
