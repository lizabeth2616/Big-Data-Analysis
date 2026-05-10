-- DML: Заполнение таблицы фактов FactSale

INSERT INTO fact_sale (date_key, customer_key, seller_key, product_key, store_key, sale_quantity, sale_total_price)
SELECT 
    d.date_key,
    c.customer_key,
    s.seller_key,
    p.product_key,
    st.store_key,
    r.sale_quantity,
    r.sale_total_price
FROM raw_mock_data r
JOIN dim_date d ON r.sale_date::DATE = d.full_date
JOIN dim_customer c ON r.sale_customer_id = c.customer_id
JOIN dim_seller s ON r.sale_seller_id = s.seller_id
JOIN dim_product p ON r.sale_product_id = p.product_id
LEFT JOIN dim_store st ON r.store_name = st.store_name 
    AND r.store_location = st.store_location
WHERE r.sale_date IS NOT NULL;

SELECT 
    'fact_sale' as table_name,
    COUNT(*) as row_count 
FROM fact_sale;
