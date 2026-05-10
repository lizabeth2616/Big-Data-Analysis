-- Проверка, что все факты имеют связи с измерениями
SELECT '=== Проверка целостности связей ===' as test_name;

-- Факты без даты
SELECT 'Факты без даты' as issue, COUNT(*) as count
FROM fact_sale WHERE date_key IS NULL
UNION ALL
-- Факты без покупателя
SELECT 'Факты без покупателя', COUNT(*) 
FROM fact_sale WHERE customer_key IS NULL
UNION ALL
-- Факты без продавца
SELECT 'Факты без продавца', COUNT(*) 
FROM fact_sale WHERE seller_key IS NULL
UNION ALL
-- Факты без товара
SELECT 'Факты без товара', COUNT(*) 
FROM fact_sale WHERE product_key IS NULL
UNION ALL
-- Факты без магазина
SELECT 'Факты без магазина', COUNT(*) 
FROM fact_sale WHERE store_key IS NULL;