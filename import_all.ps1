$files = @(
    "MOCK_DATA_1.csv",
    "MOCK_DATA_2.csv",
    "MOCK_DATA_3.csv",
    "MOCK_DATA_4.csv",
    "MOCK_DATA_5.csv",
    "MOCK_DATA_6.csv",
    "MOCK_DATA_7.csv",
    "MOCK_DATA_8.csv",
    "MOCK_DATA_9.csv",
    "MOCK_DATA_10.csv"
)

$total = $files.Count
$current = 0

foreach ($file in $files) {
    $current++
    $filePath = "mock_data\$file"
    
    Write-Host "[$current/$total] Загружаю $file..." -ForegroundColor Yellow
    
    Get-Content $filePath | Select-Object -Skip 1 | docker exec -i bigdata_postgres psql -U student -d bigdata_lab -c "COPY raw_mock_data FROM STDIN WITH CSV"
    
    Write-Host " $file загружен" -ForegroundColor Green
}

Write-Host "`n=== Проверка ===" -ForegroundColor Cyan
docker exec bigdata_postgres psql -U student -d bigdata_lab -c "SELECT COUNT(*) as total_rows FROM raw_mock_data;"