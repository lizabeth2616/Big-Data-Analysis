-- Очистка таблиц (в правильном порядке из-за внешних ключей)
TRUNCATE TABLE dim_customer CASCADE;
TRUNCATE TABLE dim_seller CASCADE;
TRUNCATE TABLE dim_product CASCADE;
TRUNCATE TABLE dim_store CASCADE;
TRUNCATE TABLE dim_supplier CASCADE;

-- Заполнение измерений с обработкой дубликатов

INSERT INTO dim_supplier (supplier_name, supplier_contact, supplier_email, supplier_phone, supplier_address, supplier_city, supplier_country)
SELECT DISTINCT ON (supplier_name, supplier_email)
    supplier_name,
    supplier_contact,
    supplier_email,
    supplier_phone,
    supplier_address,
    supplier_city,
    supplier_country
FROM raw_mock_data
WHERE supplier_name IS NOT NULL;

INSERT INTO dim_store (store_name, store_location, store_city, store_state, store_country, store_phone, store_email)
SELECT DISTINCT ON (store_name, store_location)
    store_name,
    store_location,
    store_city,
    store_state,
    store_country,
    store_phone,
    store_email
FROM raw_mock_data
WHERE store_name IS NOT NULL;

INSERT INTO dim_seller (seller_id, first_name, last_name, email, country, postal_code)
SELECT DISTINCT ON (sale_seller_id)
    sale_seller_id,
    seller_first_name,
    seller_last_name,
    seller_email,
    seller_country,
    seller_postal_code
FROM raw_mock_data
WHERE sale_seller_id IS NOT NULL
ORDER BY sale_seller_id;

INSERT INTO dim_product (product_id, product_name, product_category, product_price, product_weight, 
    product_color, product_size, product_brand, product_material, product_description, 
    product_rating, product_reviews, product_release_date, product_expiry_date, 
    pet_category, supplier_key)
SELECT DISTINCT ON (r.sale_product_id)
    r.sale_product_id,
    r.product_name,
    r.product_category,
    r.product_price,
    r.product_weight,
    r.product_color,
    r.product_size,
    r.product_brand,
    r.product_material,
    r.product_description,
    r.product_rating,
    r.product_reviews,
    NULLIF(r.product_release_date, '')::DATE,
    NULLIF(r.product_expiry_date, '')::DATE,
    r.pet_category,
    s.supplier_key
FROM raw_mock_data r
LEFT JOIN dim_supplier s ON r.supplier_name = s.supplier_name 
    AND r.supplier_email = s.supplier_email
WHERE r.sale_product_id IS NOT NULL
ORDER BY r.sale_product_id;

INSERT INTO dim_customer (customer_id, first_name, last_name, age, email, country, postal_code, pet_key)
SELECT DISTINCT ON (r.sale_customer_id)
    r.sale_customer_id,
    r.customer_first_name,
    r.customer_last_name,
    r.customer_age,
    r.customer_email,
    r.customer_country,
    r.customer_postal_code,
    p.pet_key
FROM raw_mock_data r
LEFT JOIN dim_pet p ON r.customer_pet_type = p.pet_type 
    AND r.customer_pet_name = p.pet_name 
    AND r.customer_pet_breed = p.pet_breed
WHERE r.sale_customer_id IS NOT NULL
ORDER BY r.sale_customer_id;

SELECT 'dim_date' as table_name, COUNT(*) as row_count FROM dim_date
UNION ALL
SELECT 'dim_pet', COUNT(*) FROM dim_pet
UNION ALL
SELECT 'dim_customer', COUNT(*) FROM dim_customer
UNION ALL
SELECT 'dim_seller', COUNT(*) FROM dim_seller
UNION ALL
SELECT 'dim_supplier', COUNT(*) FROM dim_supplier
UNION ALL
SELECT 'dim_store', COUNT(*) FROM dim_store
UNION ALL
SELECT 'dim_product', COUNT(*) FROM dim_product
ORDER BY table_name;
