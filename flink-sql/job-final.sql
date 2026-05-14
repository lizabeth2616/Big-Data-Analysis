SET 'execution.checkpointing.interval' = '10 s';
SET 'table.exec.mini-batch.enabled' = 'true';
SET 'table.exec.mini-batch.allow-latency' = '2 s';
SET 'table.exec.mini-batch.size' = '5000';

CREATE TABLE kafka_mock_data (
  id STRING, sale_customer_id STRING, sale_seller_id STRING, sale_product_id STRING,
  sale_date STRING, sale_quantity INT, sale_total_price DOUBLE,
  customer_first_name STRING, customer_last_name STRING, customer_age INT,
  customer_email STRING, customer_country STRING, customer_postal_code STRING,
  customer_pet_type STRING, customer_pet_name STRING, customer_pet_breed STRING,
  seller_first_name STRING, seller_last_name STRING, seller_email STRING,
  seller_country STRING, seller_postal_code STRING, product_name STRING,
  product_category STRING, product_price DOUBLE, product_quantity INT,
  product_brand STRING, product_size STRING, product_material STRING,
  product_color STRING, product_weight DOUBLE, pet_category STRING,
  product_rating DOUBLE, product_reviews INT, product_release_date STRING,
  product_expiry_date STRING, store_name STRING, store_location STRING,
  store_city STRING, store_state STRING, store_country STRING, store_phone STRING,
  store_email STRING, supplier_name STRING, supplier_contact STRING,
  supplier_email STRING, supplier_phone STRING, supplier_address STRING,
  supplier_city STRING, supplier_country STRING
) WITH (
  'connector' = 'kafka', 'topic' = 'sales_data',
  'properties.bootstrap.servers' = 'kafka:29092',
  'properties.group.id' = 'flink-star-etl',
  'scan.startup.mode' = 'earliest-offset', 'format' = 'json',
  'json.fail-on-missing-field' = 'false', 'json.ignore-parse-errors' = 'true'
);

CREATE TABLE dim_customer_sink (
  customer_id INTEGER, first_name STRING, last_name STRING, age INTEGER,
  email STRING, country STRING, postal_code STRING, pet_type STRING,
  pet_name STRING, pet_breed STRING, PRIMARY KEY (customer_id) NOT ENFORCED
) WITH (
  'connector' = 'jdbc', 'url' = 'jdbc:postgresql://postgres:5432/bigdata_db',
  'table-name' = 'dim_customer', 'driver' = 'org.postgresql.Driver',
  'username' = 'bigdata_user', 'password' = 'bigdata_pass'
);

CREATE TABLE dim_seller_sink (
  seller_id INTEGER, first_name STRING, last_name STRING, email STRING,
  country STRING, postal_code STRING, PRIMARY KEY (seller_id) NOT ENFORCED
) WITH (
  'connector' = 'jdbc', 'url' = 'jdbc:postgresql://postgres:5432/bigdata_db',
  'table-name' = 'dim_seller', 'driver' = 'org.postgresql.Driver',
  'username' = 'bigdata_user', 'password' = 'bigdata_pass'
);

CREATE TABLE dim_product_sink (
  product_id INTEGER, product_name STRING, category STRING, price DOUBLE,
  quantity INTEGER, brand STRING, size STRING, material STRING, color STRING,
  weight DOUBLE, pet_category STRING, rating DOUBLE, reviews INTEGER,
  release_date DATE, expiry_date DATE, PRIMARY KEY (product_id) NOT ENFORCED
) WITH (
  'connector' = 'jdbc', 'url' = 'jdbc:postgresql://postgres:5432/bigdata_db',
  'table-name' = 'dim_product', 'driver' = 'org.postgresql.Driver',
  'username' = 'bigdata_user', 'password' = 'bigdata_pass'
);

CREATE TABLE dim_date_sink (
  date_key DATE, year_num INTEGER, month_num INTEGER, day_num INTEGER,
  PRIMARY KEY (date_key) NOT ENFORCED
) WITH (
  'connector' = 'jdbc', 'url' = 'jdbc:postgresql://postgres:5432/bigdata_db',
  'table-name' = 'dim_date', 'driver' = 'org.postgresql.Driver',
  'username' = 'bigdata_user', 'password' = 'bigdata_pass'
);

CREATE TABLE fact_sales_sink (
  sale_id STRING, date_key DATE, customer_id INTEGER, seller_id INTEGER,
  product_id INTEGER, quantity INTEGER, total_price DOUBLE,
  PRIMARY KEY (sale_id) NOT ENFORCED
) WITH (
  'connector' = 'jdbc', 'url' = 'jdbc:postgresql://postgres:5432/bigdata_db',
  'table-name' = 'fact_sales', 'driver' = 'org.postgresql.Driver',
  'username' = 'bigdata_user', 'password' = 'bigdata_pass'
);

EXECUTE STATEMENT SET
BEGIN
  INSERT INTO dim_customer_sink
  SELECT CAST(sale_customer_id AS INTEGER), MAX(customer_first_name), MAX(customer_last_name),
    MAX(customer_age), MAX(customer_email), MAX(customer_country), MAX(customer_postal_code),
    MAX(customer_pet_type), MAX(customer_pet_name), MAX(customer_pet_breed)
  FROM kafka_mock_data WHERE sale_customer_id IS NOT NULL GROUP BY sale_customer_id;

  INSERT INTO dim_seller_sink
  SELECT CAST(sale_seller_id AS INTEGER), MAX(seller_first_name), MAX(seller_last_name),
    MAX(seller_email), MAX(seller_country), MAX(seller_postal_code)
  FROM kafka_mock_data WHERE sale_seller_id IS NOT NULL GROUP BY sale_seller_id;

  INSERT INTO dim_product_sink
  SELECT CAST(sale_product_id AS INTEGER), MAX(product_name), MAX(product_category),
    MAX(product_price), MAX(product_quantity), MAX(product_brand), MAX(product_size),
    MAX(product_material), MAX(product_color), MAX(product_weight), MAX(pet_category),
    MAX(product_rating), MAX(product_reviews),
    CASE WHEN MAX(product_release_date) IS NOT NULL AND TRIM(MAX(product_release_date)) <> ''
      THEN CAST(TO_TIMESTAMP(MAX(product_release_date), 'M/d/yyyy') AS DATE) ELSE NULL END,
    CASE WHEN MAX(product_expiry_date) IS NOT NULL AND TRIM(MAX(product_expiry_date)) <> ''
      THEN CAST(TO_TIMESTAMP(MAX(product_expiry_date), 'M/d/yyyy') AS DATE) ELSE NULL END
  FROM kafka_mock_data WHERE sale_product_id IS NOT NULL GROUP BY sale_product_id;

  INSERT INTO dim_date_sink
  SELECT CAST(TO_TIMESTAMP(sale_date, 'M/d/yyyy') AS DATE),
    CAST(EXTRACT(YEAR FROM CAST(TO_TIMESTAMP(sale_date, 'M/d/yyyy') AS DATE)) AS INTEGER),
    CAST(EXTRACT(MONTH FROM CAST(TO_TIMESTAMP(sale_date, 'M/d/yyyy') AS DATE)) AS INTEGER),
    CAST(EXTRACT(DAY FROM CAST(TO_TIMESTAMP(sale_date, 'M/d/yyyy') AS DATE)) AS INTEGER)
  FROM kafka_mock_data WHERE sale_date IS NOT NULL AND TRIM(sale_date) <> ''
  GROUP BY CAST(TO_TIMESTAMP(sale_date, 'M/d/yyyy') AS DATE);

  INSERT INTO fact_sales_sink
  SELECT id, CAST(TO_TIMESTAMP(sale_date, 'M/d/yyyy') AS DATE),
    CAST(sale_customer_id AS INTEGER), CAST(sale_seller_id AS INTEGER),
    CAST(sale_product_id AS INTEGER), sale_quantity, sale_total_price
  FROM kafka_mock_data WHERE id IS NOT NULL AND sale_date IS NOT NULL AND TRIM(sale_date) <> '';
END;
