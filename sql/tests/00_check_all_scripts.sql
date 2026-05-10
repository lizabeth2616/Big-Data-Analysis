-- Проверка всех скриптов лабораторной работы
SELECT '=== ПРОВЕРКА ВСЕХ СКРИПТОВ ===' as stage;

SELECT '1. raw_mock_data' as check_name, 
       COUNT(*) as row_count,
       CASE WHEN COUNT(*) = 10000 THEN 'OK' ELSE 'FAIL' END as status
FROM raw_mock_data;

SELECT '2. dim_date' as check_name, 
       COUNT(*) as row_count,
       CASE WHEN COUNT(*) >= 300 THEN 'OK' ELSE 'FAIL' END as status
FROM dim_date;

SELECT '3. dim_pet' as check_name, 
       COUNT(*) as row_count,
       CASE WHEN COUNT(*) >= 9000 THEN 'OK' ELSE 'FAIL' END as status
FROM dim_pet;

SELECT '4. dim_customer' as check_name, 
       COUNT(*) as row_count,
       CASE WHEN COUNT(*) = 1000 THEN 'OK' ELSE 'FAIL' END as status
FROM dim_customer;

SELECT '5. dim_seller' as check_name, 
       COUNT(*) as row_count,
       CASE WHEN COUNT(*) = 1000 THEN 'OK' ELSE 'FAIL' END as status
FROM dim_seller;

SELECT '6. dim_product' as check_name, 
       COUNT(*) as row_count,
       CASE WHEN COUNT(*) = 1000 THEN 'OK' ELSE 'FAIL' END as status
FROM dim_product;

SELECT '7. dim_store' as check_name, 
       COUNT(*) as row_count,
       CASE WHEN COUNT(*) >= 5000 THEN 'OK' ELSE 'FAIL' END as status
FROM dim_store;

SELECT '8. dim_supplier' as check_name, 
       COUNT(*) as row_count,
       CASE WHEN COUNT(*) = 10000 THEN 'OK' ELSE 'FAIL' END as status
FROM dim_supplier;

SELECT '9. fact_sale' as check_name, 
       COUNT(*) as row_count,
       CASE WHEN COUNT(*) = 10000 THEN 'OK' ELSE 'FAIL' END as status
FROM fact_sale;

SELECT '10. fact_sale связи' as check_name,
       COUNT(*) as row_count,
       CASE WHEN COUNT(*) = 10000 THEN 'OK' ELSE 'FAIL' END as status
FROM fact_sale 
WHERE date_key IS NOT NULL 
  AND customer_key IS NOT NULL 
  AND seller_key IS NOT NULL 
  AND product_key IS NOT NULL;

SELECT '11. customer_pet связи' as check_name,
       COUNT(*) as row_count,
       CASE WHEN COUNT(*) = 1000 THEN 'OK' ELSE 'FAIL' END as status
FROM dim_customer 
WHERE pet_key IS NOT NULL;

SELECT '12. product_supplier связи' as check_name,
       COUNT(*) as row_count,
       CASE WHEN COUNT(*) = 1000 THEN 'OK' ELSE 'FAIL' END as status
FROM dim_product 
WHERE supplier_key IS NOT NULL;

SELECT '13. аналитика продаж' as check_name,
       COUNT(DISTINCT d.year) as row_count,
       CASE WHEN COUNT(DISTINCT d.year) > 0 THEN 'OK' ELSE 'FAIL' END as status
FROM fact_sale f
JOIN dim_date d ON f.date_key = d.date_key;