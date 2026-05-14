FROM flink:1.18.0-scala_2.12-java11
RUN apt-get update && apt-get install -y --no-install-recommends wget curl && rm -rf /var/lib/apt/lists/*
WORKDIR /tmp/jars
RUN wget -O flink-connector-kafka.jar https://repo1.maven.org/maven2/org/apache/flink/flink-connector-kafka/3.0.0-1.17/flink-connector-kafka-3.0.0-1.17.jar && \
    wget -O flink-connector-jdbc.jar https://repo1.maven.org/maven2/org/apache/flink/flink-connector-jdbc/3.1.1-1.17/flink-connector-jdbc-3.1.1-1.17.jar && \
    wget -O postgresql.jar https://repo1.maven.org/maven2/org/postgresql/postgresql/42.7.1/postgresql-42.7.1.jar && \
    wget -O kafka-clients.jar https://repo1.maven.org/maven2/org/apache/kafka/kafka-clients/3.6.0/kafka-clients-3.6.0.jar
RUN cp /tmp/jars/*.jar /opt/flink/lib/ && rm -rf /tmp/jars
WORKDIR /opt/flink
