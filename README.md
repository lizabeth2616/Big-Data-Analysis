# Лабораторная работа №1

**Нормализация данных зоомагазина в аналитическую модель "Снежинка"**

---

##  Описание проекта

В рамках лабораторной работы выполнена трансформация исходных данных о продажах товаров для домашних питомцев из денормализованной структуры в аналитическую модель данных "Снежинка" (Snowflake Schema).

Модель позволяет эффективно анализировать продажи, поведение покупателей, популярность товаров и другие бизнес-метрики.

---

##  Модель данных "Снежинка"

```

    ┌──────────────────────┐
    │     DIM_DATE         │
    │──────────────────────│
    │ PK date_key          │
    │    full_date         │
    │    year              │
    │    quarter           │
    │    month             │
    │    month_name        │
    │    day               │
    │    day_of_week       │
    │    day_name          │
    └──────────┬───────────┘
               │
               │ FK
               │
    ┌──────────┴───────────┐         ┌──────────────────────┐         ┌──────────────────────┐
    │                      │         │     DIM_CUSTOMER     │         │     DIM_SELLER       │
    │                      │         │──────────────────────│         │──────────────────────│
    │                      │    ┌────│ PK customer_key      │         │ PK seller_key        │
    │                      │    │    │    customer_id       │         │    seller_id         │
    │                      │    │    │    first_name        │         │    first_name        │
    │                      │    │    │    last_name         │         │    last_name         │
    │     FACT_SALE        │    │    │    age               │         │    email             │
    │                      │    │    │    email             │         │    country           │
    │──────────────────────│    │    │    country           │         │    postal_code       │
    │ PK sale_id           │    │    │    postal_code       │         └──────────────────────┘
    │ FK date_key          │────┘    │ FK pet_key           │
    │ FK customer_key      │─────────│──────────────────────│
    │ FK seller_key        │─────────│──────────────────────│         ┌──────────────────────┐
    │ FK product_key       │    │    └──────────────────────┘         │     DIM_STORE        │
    │ FK store_key         │    │                                     │──────────────────────│
    │    sale_quantity     │    │    ┌──────────────────────┐         │ PK store_key         │
    │    sale_total_price  │    │    │     DIM_PET         │         │    store_name        │
    └──────────────────────┘    │    │──────────────────────│         │    store_location    │
                                │    │ PK pet_key           │         │    store_city        │
                                │    │    pet_type          │         │    store_state       │
                                │    │    pet_name          │         │    store_country     │
                                │    │    pet_breed         │         │    store_phone       │
                                │    └──────────────────────┘         │    store_email       │
                                │                                     └──────────────────────┘
                                │
                                │    ┌──────────────────────┐         ┌──────────────────────┐
                                │    │    DIM_PRODUCT      │         │   DIM_SUPPLIER      │
                                └────│──────────────────────│    ┌────│──────────────────────│
                                     │ PK product_key       │    │    │ PK supplier_key      │
                                     │    product_id        │    │    │    supplier_name     │
                                     │    product_name      │    │    │    supplier_contact  │
                                     │    product_category  │    │    │    supplier_email    │
                                     │    product_price     │    │    │    supplier_phone    │
                                     │    product_weight    │    │    │    supplier_address  │
                                     │    product_color     │    │    │    supplier_city     │
                                     │    product_size      │    │    │    supplier_country  │
                                     │    product_brand     │    │    └──────────────────────┘
                                     │    product_material  │    │
                                     │    product_description│   │
                                     │    product_rating    │    │
                                     │    product_reviews   │    │
                                     │    product_release   │    │
                                     │    product_expiry    │    │
                                     │    pet_category      │    │
                                     │ FK supplier_key      │────┘
                                     └──────────────────────┘
```

###  Связи между таблицами

| Родительская таблица | Дочерняя таблица | Тип связи |
|---------------------|-----------------|-----------|
| dim_date | fact_sale | 1:N (одна дата - много продаж) |
| dim_customer | fact_sale | 1:N (один покупатель - много покупок) |
| dim_seller | fact_sale | 1:N (один продавец - много продаж) |
| dim_product | fact_sale | 1:N (один товар - много продаж) |
| dim_store | fact_sale | 1:N (один магазин - много продаж) |
| dim_pet | dim_customer | 1:N (один питомец - у многих покупателей) |
| dim_supplier | dim_product | 1:N (один поставщик - много товаров) |

###  Статистика данных

| Таблица | Тип | Количество записей |
|---------|-----|-------------------|
| raw_mock_data | Исходные данные | 10,000 |
| dim_date | Измерение | 364 |
| dim_pet | Измерение | 9,321 |
| dim_customer | Измерение | 1,000 |
| dim_seller | Измерение | 1,000 |
| dim_product | Измерение | 1,000 |
| dim_store | Измерение | 9,688 |
| dim_supplier | Измерение | 10,000 |
| fact_sale | Факт | 10,000 |

---

##  Структура проекта

```
bigdata-snowflake/
├── docker-compose.yml              # Docker конфигурация PostgreSQL
├── mock_data/                      # Исходные CSV файлы
│   ├── MOCK_DATA_1.csv
│   ├── MOCK_DATA_2.csv
│   ├── MOCK_DATA_3.csv
│   ├── MOCK_DATA_4.csv
│   ├── MOCK_DATA_5.csv
│   ├── MOCK_DATA_6.csv
│   ├── MOCK_DATA_7.csv
│   ├── MOCK_DATA_8.csv
│   ├── MOCK_DATA_9.csv
│   └── MOCK_DATA_10.csv
├── sql/                            # SQL скрипты
│   ├── 01_create_raw_table.sql     # Создание сырой таблицы
│   ├── 02_create_dimensions.sql    # DDL таблиц измерений и фактов
│   ├── 03_fill_dimensions_v2.sql   # DML заполнение измерений
│   ├── 04_fill_fact.sql            # DML заполнение фактов
│   ├── 05_verify.sql               # Проверка результатов
│   └── tests/                      # Тестовые запросы
│       ├── 00_check_all_scripts.sql
│       ├── 01_test_relationships.sql
│       ├── 02_analytical_queries.sql
│       └── 03_check_dimensions.sql
└── README.md                       # Документация проекта
```

---

##  Быстрый старт

### Шаг 1: Запуск PostgreSQL

```bash
docker-compose up -d
```

### Шаг 2: Создание таблиц

```bash
docker exec -i bigdata_postgres psql -U student -d bigdata_lab -f /sql/01_create_raw_table.sql
```

### Шаг 3: Загрузка данных из CSV

```powershell
2..10 | ForEach-Object { 
    $file = "mock_data\MOCK_DATA_$_.csv"
    Get-Content $file | Select-Object -Skip 1 | 
    docker exec -i bigdata_postgres psql -U student -d bigdata_lab -c "COPY raw_mock_data FROM STDIN WITH CSV"
}
```

### Шаг 4: Создание схемы "Снежинка"

```bash
docker exec -i bigdata_postgres psql -U student -d bigdata_lab -f /sql/02_create_dimensions.sql
```

### Шаг 5: Заполнение измерений и фактов

```bash
docker exec -i bigdata_postgres psql -U student -d bigdata_lab -f /sql/03_fill_dimensions_v2.sql
docker exec -i bigdata_postgres psql -U student -d bigdata_lab -f /sql/04_fill_fact.sql
```

### Шаг 6: Проверка результата

```bash
docker exec -i bigdata_postgres psql -U student -d bigdata_lab -f /sql/05_verify.sql
docker exec -i bigdata_postgres psql -U student -d bigdata_lab -f /sql/tests/00_check_all_scripts.sql
```

---

##  Примеры аналитических запросов

### 1. Продажи по кварталам

```sql
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
```

### 2. Топ-5 категорий товаров

```sql
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
```

### 3. Топ-5 покупателей

```sql
SELECT 
    c.first_name || ' ' || c.last_name as customer,
    COUNT(*) as purchases,
    SUM(f.sale_total_price) as total_spent
FROM fact_sale f
JOIN dim_customer c ON f.customer_key = c.customer_key
GROUP BY c.first_name, c.last_name
ORDER BY total_spent DESC
LIMIT 5;
```
