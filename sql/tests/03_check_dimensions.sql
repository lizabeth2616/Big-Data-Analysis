-- 3.1 Проверка DimSupplier (связан с DimProduct)
SELECT '=== Связь Товар-Поставщик ===' as test;
SELECT 
    'Товары без поставщика' as issue,
    COUNT(*) as count
FROM dim_product 
WHERE supplier_key IS NULL
UNION ALL
SELECT 
    'Товары с поставщиком',
    COUNT(*) 
FROM dim_product 
WHERE supplier_key IS NOT NULL;

-- 3.2 Проверка DimCustomer (связан с DimPet)
SELECT '=== Связь Покупатель-Питомец ===' as test;
SELECT 
    'Покупатели без питомца' as issue,
    COUNT(*) as count
FROM dim_customer 
WHERE pet_key IS NULL
UNION ALL
SELECT 
    'Покупатели с питомцем',
    COUNT(*) 
FROM dim_customer 
WHERE pet_key IS NOT NULL;

-- 3.3 Статистика по возрастам покупателей
SELECT '=== Статистика возрастов ===' as test;
SELECT 
    MIN(age) as min_age,
    MAX(age) as max_age,
    ROUND(AVG(age), 1) as avg_age,
    COUNT(*) as total_customers
FROM dim_customer;