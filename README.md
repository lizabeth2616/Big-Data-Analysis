# Лабораторная работа №3: Streaming Processing с Apache Flink

## Цель
Реализация потоковой обработки данных с помощью Apache Flink: чтение из Kafka, трансформация в модель "звезда" и запись в PostgreSQL.

## Структура проекта

```
flink-kafka-lab/
├── docker-compose.yml          # Docker-окружение (PostgreSQL, Kafka, Flink)
├── data/                       # Исходные CSV-файлы
│   ├── MOCK_DATA_1.csv         # 1000 записей
│   ├── MOCK_DATA_2.csv         # 1000 записей
│   ├── MOCK_DATA_3.csv         # 1000 записей
│   ├── MOCK_DATA_4.csv         # 1000 записей
│   ├── MOCK_DATA_5.csv         # 1000 записей
│   ├── MOCK_DATA_6.csv         # 1000 записей
│   ├── MOCK_DATA_7.csv         # 1000 записей
│   ├── MOCK_DATA_8.csv         # 1000 записей
│   ├── MOCK_DATA_9.csv         # 1000 записей
│   └── MOCK_DATA_10.csv        # 1000 записей
├── kafka-producer/             # Приложение для отправки данных в Kafka
│   ├── Dockerfile
│   ├── requirements.txt
│   └── producer.py
├── flink-sql/                  # Flink SQL Job
│   ├── Dockerfile
│   └── job-final.sql           # Основной SQL-скрипт трансформации
├── sql/                        # SQL-скрипты для инициализации БД
│   └── init.sql
└── README.md                   # Документация
```

## Архитектура

```
CSV → Kafka Producer → Kafka Topic → Flink SQL (streaming) → PostgreSQL (Star Schema)
```

## Модель данных (Star Schema)

| Таблица | Тип | Описание |
|---------|-----|----------|
| dim_customer | Измерение | Информация о покупателях |
| dim_seller | Измерение | Информация о продавцах |
| dim_product | Измерение | Информация о товарах |
| dim_date | Измерение | Измерение дат |
| fact_sales | Факт | Транзакции продаж |

## Предварительные требования

- Docker и Docker Compose
- 10 CSV-файлов `MOCK_DATA_*.csv` в папке `data/` (по 1000 строк каждый)

## Запуск проекта

### 1. Запуск всех сервисов

```powershell
docker-compose up -d
```

### 2. Ожидание отправки данных в Kafka

Producer автоматически запускается и отправляет все CSV-файлы в Kafka. Дождитесь завершения (около 2 минут):

```powershell
docker-compose logs kafka-producer | Select-String "All files processed"
```

### 3. Запуск Flink SQL Job

```powershell
docker cp flink-sql/job-final.sql jobmanager:/opt/flink/job-final.sql
docker exec -it jobmanager /opt/flink/bin/sql-client.sh -D execution.runtime-mode=STREAMING -f /opt/flink/job-final.sql
```

### 4. Ожидание обработки данных

Job обрабатывает данные в режиме streaming. Дождитесь 3-5 минут.

### 5. Проверка результатов

```powershell
docker exec -it postgres psql -U bigdata_user -d bigdata_db -c "
SELECT 'dim_customer' as table_name, COUNT(*) as records FROM dim_customer
UNION ALL SELECT 'dim_seller', COUNT(*) FROM dim_seller
UNION ALL SELECT 'dim_product', COUNT(*) FROM dim_product
UNION ALL SELECT 'dim_date', COUNT(*) FROM dim_date
UNION ALL SELECT 'fact_sales', COUNT(*) FROM fact_sales;
"
```

## Ожидаемые результаты

| Таблица | Количество записей |
|---------|-------------------|
| dim_customer | 1000 |
| dim_seller | 1000 |
| dim_product | 1000 |
| dim_date | 364 |
| fact_sales | 1000 |

## Аналитические запросы

### Продажи по странам
```sql
SELECT dc.country, COUNT(*) as orders, SUM(fs.total_price) as revenue
FROM fact_sales fs
JOIN dim_customer dc ON fs.customer_id = dc.customer_id
GROUP BY dc.country
ORDER BY revenue DESC
LIMIT 10;
```

### Продажи по категориям товаров
```sql
SELECT dp.category, COUNT(*) as sales_count, SUM(fs.total_price) as revenue
FROM fact_sales fs
JOIN dim_product dp ON fs.product_id = dp.product_id
GROUP BY dp.category
ORDER BY revenue DESC;
```

## Мониторинг

- **Flink Dashboard**: http://localhost:8081
- **PostgreSQL**: `localhost:5432` (пользователь: `bigdata_user`, пароль: `bigdata_pass`, база: `bigdata_db`)

## Остановка

```powershell
# Остановка с сохранением данных
docker-compose stop

# Полная остановка с удалением данных
docker-compose down -v
```

## Перезапуск с нуля

```powershell
docker-compose down -v
docker-compose up -d
# Дождаться отправки данных
docker-compose logs kafka-producer | Select-String "All files processed"
# Запустить Flink Job
docker exec -it jobmanager /opt/flink/bin/sql-client.sh -D execution.runtime-mode=STREAMING -f /opt/flink/job-final.sql
