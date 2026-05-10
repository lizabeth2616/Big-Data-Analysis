-- 2.1 Продажи по годам и кварталам
SELECT '=== Продажи по кварталам ===' as report;
SELECT 
    d.year,
    d.quarter,
    COUNT(*) as total_sales,
    SUM(f.sale_total_price) as revenue,
    ROUND(AVG(f.sale_total_price), 2) as avg_check
FROM fact_sale f
JOIN dim_date d ON f.date_key = d.date_key
GROUP BY d.year, d.quarter
ORDER BY d.year, d.quarter;

-- 2.2 Топ-5 категорий товаров
SELECT '=== Топ-5 категорий товаров ===' as report;
SELECT 
    p.product_category,
    COUNT(*) as sales_count,
    SUM(f.sale_total_price) as revenue,
    ROUND(AVG(p.product_rating), 2) as avg_rating
FROM fact_sale f
JOIN dim_product p ON f.product_key = p.product_key
GROUP BY p.product_category
ORDER BY revenue DESC
LIMIT 5;

-- 2.3 Топ-5 покупателей
SELECT '=== Топ-5 покупателей ===' as report;
SELECT 
    c.first_name || ' ' || c.last_name as customer,
    COUNT(*) as purchases,
    SUM(f.sale_total_price) as total_spent,
    ROUND(AVG(f.sale_total_price), 2) as avg_purchase
FROM fact_sale f
JOIN dim_customer c ON f.customer_key = c.customer_key
GROUP BY c.first_name, c.last_name
ORDER BY total_spent DESC
LIMIT 5;

-- 2.4 Популярность товаров по питомцам
SELECT '=== Товары по типам питомцев ===' as report;
SELECT 
    p.pet_category,
    COUNT(*) as products_count,
    ROUND(AVG(p.product_rating), 2) as avg_rating,
    ROUND(AVG(p.product_price), 2) as avg_price
FROM dim_product p
GROUP BY p.pet_category
ORDER BY products_count DESC;

-- 2.5 География продаж
SELECT '=== Топ-5 стран покупателей ===' as report;
SELECT 
    c.country,
    COUNT(*) as customers,
    COUNT(f.sale_id) as purchases,
    SUM(f.sale_total_price) as revenue
FROM fact_sale f
JOIN dim_customer c ON f.customer_key = c.customer_key
GROUP BY c.country
ORDER BY revenue DESC
LIMIT 5;