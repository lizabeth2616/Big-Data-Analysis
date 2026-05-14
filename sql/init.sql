CREATE TABLE IF NOT EXISTS dim_customer (
  customer_id INTEGER PRIMARY KEY,
  first_name VARCHAR(100), last_name VARCHAR(100), age INTEGER,
  email VARCHAR(100), country VARCHAR(50), postal_code VARCHAR(20),
  pet_type VARCHAR(20), pet_name VARCHAR(50), pet_breed VARCHAR(100),
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE IF NOT EXISTS dim_seller (
  seller_id INTEGER PRIMARY KEY,
  first_name VARCHAR(100), last_name VARCHAR(100), email VARCHAR(100),
  country VARCHAR(50), postal_code VARCHAR(20),
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE IF NOT EXISTS dim_product (
  product_id INTEGER PRIMARY KEY,
  product_name VARCHAR(200), category VARCHAR(50), price DOUBLE PRECISION,
  quantity INTEGER, brand VARCHAR(100), size VARCHAR(20),
  material VARCHAR(100), color VARCHAR(50), weight DOUBLE PRECISION,
  pet_category VARCHAR(20), rating DOUBLE PRECISION, reviews INTEGER,
  release_date DATE, expiry_date DATE,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE IF NOT EXISTS dim_date (
  date_key DATE PRIMARY KEY, year_num INTEGER, month_num INTEGER, day_num INTEGER,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE IF NOT EXISTS fact_sales (
  sale_id VARCHAR(100) PRIMARY KEY, date_key DATE,
  customer_id INTEGER, seller_id INTEGER, product_id INTEGER,
  quantity INTEGER, total_price DOUBLE PRECISION,
  processed_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);
