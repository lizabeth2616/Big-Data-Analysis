import os
import psycopg2
from psycopg2 import sql
import glob

DB_CONFIG = {
    'host': 'localhost',
    'port': 5432,
    'database': 'bigdata_lab',
    'user': 'student',
    'password': 'student123'
}

def load_csv_files():
    """Загрузка всех CSV файлов в таблицу raw_mock_data"""
    
    csv_files = glob.glob('mock_data/MOCK_DATA_*.csv')
    csv_files.sort()
    
    print(f"Найдено файлов: {len(csv_files)}")
    
    conn = psycopg2.connect(**DB_CONFIG)
    cur = conn.cursor()
    
    total_rows = 0
    
    for csv_file in csv_files:
        print(f"Загружаю файл: {csv_file}")
        
        copy_sql = """
            COPY raw_mock_data FROM STDIN WITH 
            CSV HEADER 
            DELIMITER ',' 
            QUOTE '"'
            NULL ''
        """
        
        try:
            with open(csv_file, 'r', encoding='utf-8') as f:
                next(f)
                cur.copy_expert(sql=copy_sql, file=f)
                
            cur.execute("SELECT COUNT(*) FROM raw_mock_data")
            current_rows = cur.fetchone()[0]
            new_rows = current_rows - total_rows
            total_rows = current_rows
            
            print(f"Загружено {new_rows} строк из файла {csv_file}")
            print(f"Всего строк в таблице: {total_rows}")
            
        except Exception as e:
            print(f"Ошибка при загрузке файла {csv_file}: {e}")
            conn.rollback()
        else:
            conn.commit()
    
    cur.close()
    conn.close()
    
    print(f"\nЗагрузка завершена! Всего загружено {total_rows} строк")

if __name__ == "__main__":
    load_csv_files()