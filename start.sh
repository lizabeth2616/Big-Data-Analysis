echo "Запуск PostgreSQL..."
docker-compose up -d

echo "Ожидание готовности PostgreSQL..."
until docker-compose exec -T postgres pg_isready -U student -d bigdata_lab; do
    echo "PostgreSQL еще не готов..."
    sleep 5
done

echo "PostgreSQL готов!"

echo "Создание таблицы raw_mock_data..."
docker-compose exec -T postgres psql -U student -d bigdata_lab -f /sql/01_create_raw_table.sql

echo "Загрузка данных из CSV файлов..."
python3 load_data.py

echo "Проверка загруженных данных..."
docker-compose exec -T postgres psql -U student -d bigdata_lab -c "SELECT COUNT(*) as total_rows FROM raw_mock_data;"

echo "Инфраструктура готова к работе!"