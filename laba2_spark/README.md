# Лабораторная работа №2

Анализ больших данных: Spark ETL-пайплайн из CSV в модель "Звезда" (PostgreSQL) и построение витрин данных в ClickHouse и MongoDB.

---

## Структура проекта

```
laba2_spark/
├── docker-compose.yml              # Контейнеры: PostgreSQL, Spark (Jupyter), ClickHouse, MongoDB
├── README.md                       # Этот файл
├── mock_data/                      # Исходные данные (10 CSV-файлов по 1000 строк)
│   ├── MOCK_DATA_1.csv
│   ├── ...
│   └── MOCK_DATA_10.csv
├── notebooks/                      # Jupyter ноутбуки с кодом
│   ├── 01_etl_postgres.ipynb       # ETL: CSV → Звезда PostgreSQL
│   ├── 02_etl_clickhouse.ipynb     # ETL: Звезда → Витрины ClickHouse
│   └── 03_etl_mongodb.ipynb        # ETL: Звезда → Коллекции MongoDB
├── jars/                           # JDBC драйверы
│   ├── postgresql-42.7.1.jar
│   └── clickhouse-jdbc-0.4.6-all.jar
└── sql/                            # SQL-скрипты 
```

---

## Модель данных "Звезда" (PostgreSQL)

```
dim_date
dim_customer ──┐
dim_seller ────┼── fact_sale ── dim_product ── dim_supplier
dim_store ─────┘
dim_pet ─────── dim_customer
```

### Измерения

| Таблица | Записей | Описание |
|---------|---------|----------|
| dim_date | 364 | Календарные даты |
| dim_pet | 8 126 | Виды питомцев |
| dim_customer | 1 000 | Покупатели |
| dim_seller | 1 000 | Продавцы |
| dim_product | 1 000 | Товары |
| dim_store | 383 | Магазины |
| dim_supplier | 383 | Поставщики |

### Факты

| Таблица | Записей | Описание |
|---------|---------|----------|
| fact_sale | 10 000 | Транзакции продаж |

---

## Витрины данных

### ClickHouse (БД `reports`)

| Витрина | Записей | Содержание |
|---------|---------|------------|
| product_sales_mart | 1 000 | Продажи по продуктам: выручка, рейтинг, отзывы |
| customer_sales_mart | 1 000 | Продажи по клиентам: суммы, средний чек |
| time_sales_mart | 12 | Продажи по месяцам: тренды, средний заказ |
| store_sales_mart | 383 | Продажи по магазинам: выручка, средний чек |
| supplier_sales_mart | 17 | Продажи по поставщикам: выручка, количество |
| product_quality_mart | 1 000 | Качество продукции: рейтинги, отзывы, продажи |

### MongoDB (БД `reports`)

| Коллекция | Документов | Содержание |
|-----------|------------|------------|
| product_sales | 1 000 | Продажи по продуктам |
| customer_sales | 1 000 | Продажи по клиентам |
| time_sales | 12 | Продажи по месяцам |
| store_sales | 383 | Продажи по магазинам |
| supplier_sales | 17 | Продажи по поставщикам |
| product_quality | 1 000 | Качество продукции |

---

## Быстрый старт

### Шаг 1: Клонирование репозитория

```bash
git clone https://github.com/lizabeth2616/Big-Data-Analysis.git
cd Big-Data-Analysis/laba2_spark
```

### Шаг 2: Скачивание JDBC драйверов

```powershell
# PostgreSQL JDBC Driver
Invoke-WebRequest -Uri "https://jdbc.postgresql.org/download/postgresql-42.7.1.jar" -OutFile "jars/postgresql-42.7.1.jar"

# ClickHouse JDBC Driver (fat jar)
Invoke-WebRequest -Uri "https://repo1.maven.org/maven2/com/clickhouse/clickhouse-jdbc/0.4.6/clickhouse-jdbc-0.4.6-all.jar" -OutFile "jars/clickhouse-jdbc-0.4.6-all.jar"
```

### Шаг 3: Запуск контейнеров

```powershell
docker-compose up -d
```

Проверка статуса:
```powershell
docker ps
```

Должны быть запущены четыре контейнера:
- `spark_postgres` (PostgreSQL)
- `spark_jupyter` (Spark + Jupyter)
- `spark_clickhouse` (ClickHouse)
- `spark_mongodb` (MongoDB)

### Шаг 4: Установка pymongo в Spark

```powershell
docker exec -it spark_jupyter pip install pymongo
```

### Шаг 5: Запуск ETL-пайплайнов

1. Откройте Jupyter Notebook: [http://localhost:8888](http://localhost:8888)
   - Токен: `spark123`
2. Откройте папку `notebooks`
3. Запустите ноутбуки по порядку:
   - `01_etl_postgres.ipynb` — CSV → Звезда PostgreSQL
   - `02_etl_clickhouse.ipynb` — Звезда → Витрины ClickHouse
   - `03_etl_mongodb.ipynb` — Звезда → Коллекции MongoDB

### Шаг 6: Проверка результатов

#### PostgreSQL

```powershell
docker exec spark_postgres psql -U student -d bigdata_lab -c "
SELECT 'raw_mock_data' AS tbl, COUNT(*) FROM raw_mock_data
UNION ALL SELECT 'dim_date', COUNT(*) FROM dim_date
UNION ALL SELECT 'dim_pet', COUNT(*) FROM dim_pet
UNION ALL SELECT 'dim_customer', COUNT(*) FROM dim_customer
UNION ALL SELECT 'dim_seller', COUNT(*) FROM dim_seller
UNION ALL SELECT 'dim_product', COUNT(*) FROM dim_product
UNION ALL SELECT 'dim_store', COUNT(*) FROM dim_store
UNION ALL SELECT 'dim_supplier', COUNT(*) FROM dim_supplier
UNION ALL SELECT 'fact_sale', COUNT(*) FROM fact_sale
ORDER BY tbl;"
```

#### ClickHouse

```powershell
docker exec spark_clickhouse clickhouse-client -u student --password student123 -q "
SELECT 'product_sales_mart', count() FROM reports.product_sales_mart
UNION ALL SELECT 'customer_sales_mart', count() FROM reports.customer_sales_mart
UNION ALL SELECT 'time_sales_mart', count() FROM reports.time_sales_mart
UNION ALL SELECT 'store_sales_mart', count() FROM reports.store_sales_mart
UNION ALL SELECT 'supplier_sales_mart', count() FROM reports.supplier_sales_mart
UNION ALL SELECT 'product_quality_mart', count() FROM reports.product_quality_mart
FORMAT PrettyCompact"
```

#### MongoDB

```powershell
docker exec spark_mongodb mongosh --eval "
use reports;
db.getCollectionNames().forEach(function(name) {
    print(name + ': ' + db[name].countDocuments() + ' документов');
});
"
```

---

## Подключение через DBeaver и MongoDB Compass

### PostgreSQL

| Параметр | Значение |
|----------|----------|
| Host | localhost |
| Port | 5432 |
| Database | bigdata_lab |
| User | student |
| Password | student123 |

### ClickHouse

| Параметр | Значение |
|----------|----------|
| Host | localhost |
| Port | 8123 (HTTP) |
| Database | reports |
| User | student |
| Password | student123 |

### MongoDB

| Параметр | Значение |
|----------|----------|
| Connection string | mongodb://localhost:27017 |
| Database | reports |

---

## Порты сервисов

| Сервис | Порт | URL |
|--------|------|-----|
| Jupyter Notebook | 8888 | http://localhost:8888 |
| Spark UI | 4040 | http://localhost:4040 |
| PostgreSQL | 5432 | jdbc:postgresql://localhost:5432/bigdata_lab |
| ClickHouse HTTP | 8123 | http://localhost:8123 |
| ClickHouse Native | 9000 | clickhouse://localhost:9000 |
| MongoDB | 27017 | mongodb://localhost:27017 |

