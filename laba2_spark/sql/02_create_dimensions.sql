-- DDL: Создание таблиц измерений 

CREATE TABLE IF NOT EXISTS dim_date (
    date_key SERIAL PRIMARY KEY,
    full_date DATE NOT NULL,
    year INTEGER NOT NULL,
    quarter INTEGER NOT NULL,
    month INTEGER NOT NULL,
    month_name VARCHAR(20) NOT NULL,
    day INTEGER NOT NULL,
    day_of_week INTEGER NOT NULL,
    day_name VARCHAR(20) NOT NULL,
    UNIQUE(full_date)
);

CREATE TABLE IF NOT EXISTS dim_pet (
    pet_key SERIAL PRIMARY KEY,
    pet_type VARCHAR(50) NOT NULL,
    pet_name VARCHAR(100) NOT NULL,
    pet_breed VARCHAR(100) NOT NULL,
    UNIQUE(pet_type, pet_name, pet_breed)
);

CREATE TABLE IF NOT EXISTS dim_customer (
    customer_key SERIAL PRIMARY KEY,
    customer_id INTEGER NOT NULL,
    first_name VARCHAR(100),
    last_name VARCHAR(100),
    age INTEGER,
    email VARCHAR(100),
    country VARCHAR(100),
    postal_code VARCHAR(50),
    pet_key INTEGER REFERENCES dim_pet(pet_key),
    UNIQUE(customer_id)
);

CREATE TABLE IF NOT EXISTS dim_seller (
    seller_key SERIAL PRIMARY KEY,
    seller_id INTEGER NOT NULL,
    first_name VARCHAR(100),
    last_name VARCHAR(100),
    email VARCHAR(100),
    country VARCHAR(100),
    postal_code VARCHAR(50),
    UNIQUE(seller_id)
);

CREATE TABLE IF NOT EXISTS dim_supplier (
    supplier_key SERIAL PRIMARY KEY,
    supplier_name VARCHAR(200),
    supplier_contact VARCHAR(100),
    supplier_email VARCHAR(100),
    supplier_phone VARCHAR(50),
    supplier_address VARCHAR(200),
    supplier_city VARCHAR(100),
    supplier_country VARCHAR(100)
);

CREATE TABLE IF NOT EXISTS dim_product (
    product_key SERIAL PRIMARY KEY,
    product_id INTEGER NOT NULL,
    product_name VARCHAR(200),
    product_category VARCHAR(100),
    product_price DECIMAL(10,2),
    product_weight DECIMAL(10,2),
    product_color VARCHAR(50),
    product_size VARCHAR(50),
    product_brand VARCHAR(100),
    product_material VARCHAR(100),
    product_description TEXT,
    product_rating DECIMAL(3,1),
    product_reviews INTEGER,
    product_release_date DATE,
    product_expiry_date DATE,
    pet_category VARCHAR(50),
    supplier_key INTEGER REFERENCES dim_supplier(supplier_key),
    UNIQUE(product_id)
);

CREATE TABLE IF NOT EXISTS dim_store (
    store_key SERIAL PRIMARY KEY,
    store_name VARCHAR(200),
    store_location VARCHAR(200),
    store_city VARCHAR(100),
    store_state VARCHAR(50),
    store_country VARCHAR(100),
    store_phone VARCHAR(50),
    store_email VARCHAR(100)
);


CREATE TABLE IF NOT EXISTS fact_sale (
    sale_id SERIAL PRIMARY KEY,
    date_key INTEGER REFERENCES dim_date(date_key),
    customer_key INTEGER REFERENCES dim_customer(customer_key),
    seller_key INTEGER REFERENCES dim_seller(seller_key),
    product_key INTEGER REFERENCES dim_product(product_key),
    store_key INTEGER REFERENCES dim_store(store_key),
    sale_quantity INTEGER NOT NULL,
    sale_total_price DECIMAL(10,2) NOT NULL
);

CREATE INDEX IF NOT EXISTS idx_fact_sale_date ON fact_sale(date_key);
CREATE INDEX IF NOT EXISTS idx_fact_sale_customer ON fact_sale(customer_key);
CREATE INDEX IF NOT EXISTS idx_fact_sale_product ON fact_sale(product_key);
CREATE INDEX IF NOT EXISTS idx_fact_sale_store ON fact_sale(store_key);
