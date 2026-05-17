# Лабораторная работа №3: 

## Цель
Реализация потоковой обработки данных с помощью Apache Flink с использованием **DataStream API (Java)**:
чтение из Kafka, трансформация в модель "звезда" и запись в PostgreSQL.

## Структура проекта

```
flink-kafka-lab/
├── docker-compose.yml          # Docker-окружение (PostgreSQL, Kafka, Flink)
├── data/                       # Исходные CSV-файлы (10 файлов по 1000 строк)
│   ├── MOCK_DATA_1.csv
│   ├── MOCK_DATA_2.csv
│   └── ... (10 файлов)
├── kafka-producer/             # Приложение для отправки CSV в Kafka
│   ├── Dockerfile
│   ├── requirements.txt
│   └── producer.py
├── flink-job/                  # Flink DataStream API (Java проект)
│   ├── Dockerfile
│   ├── pom.xml
│   └── src/main/java/com/bigdata/flink/
│       ├── KafkaToStarSchema.java       # Основной класс
│       └── model/                       # Модели данных
│           ├── SaleEvent.java           # POJO для парсинга JSON из Kafka
│           ├── DimCustomer.java         # Измерение "Клиент"
│           ├── DimSeller.java           # Измерение "Продавец"
│           ├── DimProduct.java          # Измерение "Товар"
│           ├── DimDate.java             # Измерение "Дата"
│           └── FactSale.java            # Факт "Продажа"
├── sql/                        # SQL-скрипты для инициализации БД
│   └── init.sql
└── README.md                   # Документация
```

## Архитектура

```
CSV → Kafka Producer → Kafka Topic → Flink DataStream API → PostgreSQL (Star Schema)
```

## Модель данных (Star Schema)

| Таблица | Тип | Описание |
|---------|-----|----------|
| dim_customer | Измерение | Информация о покупателях и их питомцах |
| dim_seller | Измерение | Информация о продавцах |
| dim_product | Измерение | Информация о товарах |
| dim_date | Измерение | Измерение дат |
| fact_sales | Факт | Транзакции продаж |

## Предварительные требования

- Docker и Docker Compose
- Java 11+ и Maven (для сборки Java-проекта)
- 10 CSV-файлов `MOCK_DATA_*.csv` в папке `data/` (по 1000 строк каждый)

## Запуск проекта

### 1. Сборка Java-проекта

```powershell
cd flink-job
mvn clean package -DskipTests
cd ..
```

### 2. Сборка Docker-образов

```powershell
docker-compose build
```

### 3. Запуск всех сервисов

```powershell
docker-compose up -d
```

### 4. Ожидание отправки данных в Kafka

Producer автоматически запускается и отправляет все CSV-файлы в Kafka. Дождитесь завершения (около 2 минут):

```powershell
docker logs kafka-producer --tail 10
```

Повторяйте команду, пока не увидите `All files processed successfully!`

### 5. Запуск Flink Job (DataStream API)

```powershell
docker exec -it jobmanager /opt/flink/bin/flink run -c com.bigdata.flink.KafkaToStarSchema /opt/flink/usrlib/flink-kafka-lab.jar
```

> **Примечание:** Команда запускает Job в attached mode. Можно нажать `Ctrl+C` после появления `Job has been submitted` — Job продолжит работать на кластере.

### 6. Проверка результатов

```powershell
docker exec -it postgres psql -U bigdata_user -d bigdata_db -c "
SELECT 'dim_customer' as table_name, COUNT(*) FROM dim_customer
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
| fact_sales | 10000 |

## Реализация DataStream API

### Основные компоненты:

- **KafkaSource** — чтение JSON-сообщений из топика `sales_data`
- **MapFunction** — парсинг JSON в POJO `SaleEvent` с помощью Jackson
- **JdbcSink** — запись в PostgreSQL с UPSERT (`ON CONFLICT DO NOTHING`)
- **5 параллельных Sink'ов** — по одному на каждую таблицу

### Ключевые особенности:

- Аннотация `@JsonIgnoreProperties(ignoreUnknown = true)` для игнорирования лишних полей
- Обработка дат через `SimpleDateFormat("M/dd/yyyy")`
- Пакетная вставка: `withBatchSize(100)`
- Параллелизм: `env.setParallelism(1)`

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
- **PostgreSQL**: `localhost:5432`
  - Пользователь: `bigdata_user`
  - Пароль: `bigdata_pass`
  - База данных: `bigdata_db`

## Остановка

```powershell
# Остановка с сохранением данных
docker-compose stop

# Полная остановка с удалением данных
docker-compose down -v
```

## Перезапуск с нуля

```powershell
# Очистить всё
docker-compose down -v

# Пересобрать JAR (если были изменения в коде)
cd flink-job
mvn clean package -DskipTests
cd ..

# Запустить
docker-compose up -d
docker logs kafka-producer --tail 10
docker exec -it jobmanager /opt/flink/bin/flink run -c com.bigdata.flink.KafkaToStarSchema /opt/flink/usrlib/flink-kafka-lab.jar
```

## Технологии

- **Apache Flink 1.18.0** — потоковая обработка данных
- **Apache Kafka 7.5.0** — брокер сообщений
- **PostgreSQL 15** — хранение данных
- **Java 11** — язык реализации DataStream API
- **Maven** — сборка проекта
- **Docker & Docker Compose** — контейнеризация
