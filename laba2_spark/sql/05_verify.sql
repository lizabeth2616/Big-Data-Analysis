SELECT '=== Количество записей ===' as info;

SELECT 'raw_mock_data' as table_name, COUNT(*) as row_count FROM raw_mock_data
UNION ALL
SELECT 'dim_date', COUNT(*) FROM dim_date
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
UNION ALL
SELECT 'fact_sale', COUNT(*) FROM fact_sale
ORDER BY table_name;

SELECT '=== Пример данных (первые 3 строки) ===' as info;

SELECT 
    f.sale_id,
    d.full_date as sale_date,
    c.first_name || ' ' || c.last_name as customer,
    s.first_name || ' ' || s.last_name as seller,
    p.product_name,
    st.store_name,
    f.sale_quantity,
    f.sale_total_price
FROM fact_sale f
JOIN dim_date d ON f.date_key = d.date_key
JOIN dim_customer c ON f.customer_key = c.customer_key
JOIN dim_seller s ON f.seller_key = s.seller_key
JOIN dim_product p ON f.product_key = p.product_key
LEFT JOIN dim_store st ON f.store_key = st.store_key
LIMIT 3;
