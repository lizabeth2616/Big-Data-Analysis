import csv
import json
import os
import time
import logging
from kafka import KafkaProducer
from kafka.errors import NoBrokersAvailable

logging.basicConfig(level=logging.INFO)
logger = logging.getLogger(__name__)

class CSVProducer:
    def __init__(self, bootstrap_servers, topic, data_dir):
        self.topic = topic
        self.data_dir = data_dir
        self.producer = None
        self.connect_to_kafka(bootstrap_servers)
    
    def connect_to_kafka(self, bootstrap_servers):
        max_retries = 30
        retry_delay = 10
        for attempt in range(max_retries):
            try:
                self.producer = KafkaProducer(
                    bootstrap_servers=bootstrap_servers.split(','),
                    value_serializer=lambda v: json.dumps(v).encode('utf-8'),
                    key_serializer=lambda k: str(k).encode('utf-8') if k else None,
                    acks='all', retries=3, max_block_ms=60000
                )
                logger.info("Successfully connected to Kafka")
                return
            except NoBrokersAvailable:
                logger.warning(f"Kafka not available. Attempt {attempt + 1}/{max_retries}")
                time.sleep(retry_delay)
        raise Exception("Could not connect to Kafka")
    
    def convert_csv_to_json(self, csv_file):
        messages = []
        with open(csv_file, 'r', encoding='utf-8') as file:
            reader = csv.DictReader(file)
            for row in reader:
                message = {}
                for key, value in row.items():
                    if value is None or value.strip() == '':
                        message[key] = None
                    else:
                        try:
                            if any(kw in key.lower() for kw in ['id', 'age', 'quantity', 'reviews']):
                                message[key] = int(float(value))
                            elif any(kw in key.lower() for kw in ['price', 'rating', 'total']):
                                message[key] = float(value)
                            else:
                                message[key] = value.strip()
                        except (ValueError, TypeError):
                            message[key] = value.strip()
                messages.append(message)
        return messages
    
    def send_to_kafka(self, messages, file_name):
        for i, message in enumerate(messages):
            key = message.get('id', str(i))
            self.producer.send(self.topic, key=key, value=message)
            if i % 100 == 0:
                logger.info(f"Sent {i+1}/{len(messages)} from {file_name}")
                time.sleep(0.05)
        self.producer.flush()
        logger.info(f"Completed {file_name}: {len(messages)} messages")
    
    def run(self):
        logger.info("Starting CSV to Kafka streaming...")
        csv_files = sorted([f for f in os.listdir(self.data_dir) if f.endswith('.csv')])
        if not csv_files:
            logger.error(f"No CSV files found in {self.data_dir}")
            return
        logger.info(f"Found {len(csv_files)} CSV files")
        for csv_file in csv_files:
            file_path = os.path.join(self.data_dir, csv_file)
            messages = self.convert_csv_to_json(file_path)
            self.send_to_kafka(messages, csv_file)
            time.sleep(2)
        logger.info("All files processed successfully!")
        self.producer.close()

if __name__ == "__main__":
    producer = CSVProducer(
        os.getenv("KAFKA_BOOTSTRAP_SERVERS", "kafka:29092"),
        os.getenv("KAFKA_TOPIC", "sales_data"),
        os.getenv("DATA_DIR", "./data")
    )
    producer.run()
