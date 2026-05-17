package com.bigdata.flink;

import com.bigdata.flink.model.SaleEvent;
import com.fasterxml.jackson.databind.ObjectMapper;
import org.apache.flink.api.common.eventtime.WatermarkStrategy;
import org.apache.flink.api.common.functions.MapFunction;
import org.apache.flink.connector.jdbc.JdbcConnectionOptions;
import org.apache.flink.connector.jdbc.JdbcExecutionOptions;
import org.apache.flink.connector.jdbc.JdbcSink;
import org.apache.flink.connector.kafka.source.KafkaSource;
import org.apache.flink.connector.kafka.source.enumerator.initializer.OffsetsInitializer;
import org.apache.flink.streaming.api.datastream.DataStream;
import org.apache.flink.streaming.api.environment.StreamExecutionEnvironment;

import java.text.SimpleDateFormat;

public class KafkaToStarSchema {

    public static void main(String[] args) throws Exception {
        final StreamExecutionEnvironment env = StreamExecutionEnvironment.getExecutionEnvironment();
        env.setParallelism(1);

        KafkaSource<String> source = KafkaSource.<String>builder()
                .setBootstrapServers("kafka:29092")
                .setTopics("sales_data")
                .setGroupId("flink-datastream-consumer")
                .setStartingOffsets(OffsetsInitializer.earliest())
                .setValueOnlyDeserializer(new org.apache.flink.api.common.serialization.SimpleStringSchema())
                .build();

        DataStream<String> kafkaStream = env.fromSource(source, WatermarkStrategy.noWatermarks(), "Kafka Source");

        DataStream<SaleEvent> saleEvents = kafkaStream.map(new MapFunction<String, SaleEvent>() {
            private transient ObjectMapper mapper;

            @Override
            public SaleEvent map(String value) throws Exception {
                if (mapper == null) {
                    mapper = new ObjectMapper();
                }
                return mapper.readValue(value, SaleEvent.class);
            }
        });

        saleEvents.addSink(JdbcSink.sink(
            "INSERT INTO dim_customer (customer_id, first_name, last_name, age, email, country, postal_code, pet_type, pet_name, pet_breed) " +
            "VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?) ON CONFLICT (customer_id) DO NOTHING",
            (statement, event) -> {
                statement.setInt(1, event.getSaleCustomerId());
                statement.setString(2, event.getCustomerFirstName());
                statement.setString(3, event.getCustomerLastName());
                statement.setInt(4, event.getCustomerAge() != null ? event.getCustomerAge() : 0);
                statement.setString(5, event.getCustomerEmail());
                statement.setString(6, event.getCustomerCountry());
                statement.setString(7, event.getCustomerPostalCode());
                statement.setString(8, event.getCustomerPetType());
                statement.setString(9, event.getCustomerPetName());
                statement.setString(10, event.getCustomerPetBreed());
            },
            JdbcExecutionOptions.builder().withBatchSize(100).build(),
            new JdbcConnectionOptions.JdbcConnectionOptionsBuilder()
                .withUrl("jdbc:postgresql://postgres:5432/bigdata_db")
                .withDriverName("org.postgresql.Driver")
                .withUsername("bigdata_user")
                .withPassword("bigdata_pass")
                .build()
        ));

        saleEvents.addSink(JdbcSink.sink(
            "INSERT INTO dim_seller (seller_id, first_name, last_name, email, country, postal_code) " +
            "VALUES (?, ?, ?, ?, ?, ?) ON CONFLICT (seller_id) DO NOTHING",
            (statement, event) -> {
                statement.setInt(1, event.getSaleSellerId());
                statement.setString(2, event.getSellerFirstName());
                statement.setString(3, event.getSellerLastName());
                statement.setString(4, event.getSellerEmail());
                statement.setString(5, event.getSellerCountry());
                statement.setString(6, event.getSellerPostalCode());
            },
            JdbcExecutionOptions.builder().withBatchSize(100).build(),
            new JdbcConnectionOptions.JdbcConnectionOptionsBuilder()
                .withUrl("jdbc:postgresql://postgres:5432/bigdata_db")
                .withDriverName("org.postgresql.Driver")
                .withUsername("bigdata_user")
                .withPassword("bigdata_pass")
                .build()
        ));

        saleEvents.addSink(JdbcSink.sink(
            "INSERT INTO dim_product (product_id, product_name, category, price, quantity, brand, size, material, color, weight, pet_category, rating, reviews) " +
            "VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?) ON CONFLICT (product_id) DO NOTHING",
            (statement, event) -> {
                statement.setInt(1, event.getSaleProductId());
                statement.setString(2, event.getProductName());
                statement.setString(3, event.getProductCategory());
                statement.setDouble(4, event.getProductPrice() != null ? event.getProductPrice() : 0.0);
                statement.setInt(5, event.getProductQuantity() != null ? event.getProductQuantity() : 0);
                statement.setString(6, event.getProductBrand());
                statement.setString(7, event.getProductSize());
                statement.setString(8, event.getProductMaterial());
                statement.setString(9, event.getProductColor());
                statement.setDouble(10, event.getProductWeight() != null ? event.getProductWeight() : 0.0);
                statement.setString(11, event.getPetCategory());
                statement.setDouble(12, event.getProductRating() != null ? event.getProductRating() : 0.0);
                statement.setInt(13, event.getProductReviews() != null ? event.getProductReviews() : 0);
            },
            JdbcExecutionOptions.builder().withBatchSize(100).build(),
            new JdbcConnectionOptions.JdbcConnectionOptionsBuilder()
                .withUrl("jdbc:postgresql://postgres:5432/bigdata_db")
                .withDriverName("org.postgresql.Driver")
                .withUsername("bigdata_user")
                .withPassword("bigdata_pass")
                .build()
        ));

        saleEvents.map(event -> {
            try {
                SimpleDateFormat sdf = new SimpleDateFormat("M/dd/yyyy");
                java.util.Date parsed = sdf.parse(event.getSaleDate());
                return new java.sql.Date(parsed.getTime());
            } catch (Exception e) {
                return null;
            }
        }).filter(date -> date != null).addSink(JdbcSink.sink(
            "INSERT INTO dim_date (date_key, year_num, month_num, day_num) VALUES (?, ?, ?, ?) ON CONFLICT (date_key) DO NOTHING",
            (statement, date) -> {
                statement.setDate(1, date);
                java.util.Calendar cal = java.util.Calendar.getInstance();
                cal.setTime(date);
                statement.setInt(2, cal.get(java.util.Calendar.YEAR));
                statement.setInt(3, cal.get(java.util.Calendar.MONTH) + 1);
                statement.setInt(4, cal.get(java.util.Calendar.DAY_OF_MONTH));
            },
            JdbcExecutionOptions.builder().withBatchSize(100).build(),
            new JdbcConnectionOptions.JdbcConnectionOptionsBuilder()
                .withUrl("jdbc:postgresql://postgres:5432/bigdata_db")
                .withDriverName("org.postgresql.Driver")
                .withUsername("bigdata_user")
                .withPassword("bigdata_pass")
                .build()
        ));

        saleEvents.addSink(JdbcSink.sink(
            "INSERT INTO fact_sales (sale_id, date_key, customer_id, seller_id, product_id, quantity, total_price) " +
            "VALUES (?, ?, ?, ?, ?, ?, ?) ON CONFLICT (sale_id) DO NOTHING",
            (statement, event) -> {
                try {
                    SimpleDateFormat sdf = new SimpleDateFormat("M/dd/yyyy");
                    java.util.Date parsed = sdf.parse(event.getSaleDate());
                    statement.setString(1, event.getId());
                    statement.setDate(2, new java.sql.Date(parsed.getTime()));
                    statement.setInt(3, event.getSaleCustomerId());
                    statement.setInt(4, event.getSaleSellerId());
                    statement.setInt(5, event.getSaleProductId());
                    statement.setInt(6, event.getSaleQuantity() != null ? event.getSaleQuantity() : 0);
                    statement.setDouble(7, event.getSaleTotalPrice() != null ? event.getSaleTotalPrice() : 0.0);
                } catch (Exception e) {
                    statement.setString(1, event.getId());
                    statement.setDate(2, null);
                    statement.setInt(3, event.getSaleCustomerId());
                    statement.setInt(4, event.getSaleSellerId());
                    statement.setInt(5, event.getSaleProductId());
                    statement.setInt(6, 0);
                    statement.setDouble(7, 0.0);
                }
            },
            JdbcExecutionOptions.builder().withBatchSize(100).build(),
            new JdbcConnectionOptions.JdbcConnectionOptionsBuilder()
                .withUrl("jdbc:postgresql://postgres:5432/bigdata_db")
                .withDriverName("org.postgresql.Driver")
                .withUsername("bigdata_user")
                .withPassword("bigdata_pass")
                .build()
        ));

        env.execute("Kafka to Star Schema - DataStream API");
    }
}
