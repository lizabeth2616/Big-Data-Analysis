FROM flink:1.18.0-scala_2.12-java11
RUN mkdir -p /opt/flink/lib-ext
RUN wget -P /opt/flink/lib-ext/ \
    https://repo1.maven.org/maven2/org/apache/flink/flink-sql-connector-kafka/3.0.0-1.17/flink-sql-connector-kafka-3.0.0-1.17.jar && \
    wget -P /opt/flink/lib-ext/ \
    https://repo1.maven.org/maven2/org/apache/flink/flink-connector-jdbc/3.1.1-1.17/flink-connector-jdbc-3.1.1-1.17.jar && \
    wget -P /opt/flink/lib-ext/ \
    https://repo1.maven.org/maven2/org/postgresql/postgresql/42.7.1/postgresql-42.7.1.jar
RUN cp /opt/flink/lib-ext/*.jar /opt/flink/lib/
COPY target/flink-kafka-lab-1.0-SNAPSHOT.jar /opt/flink/usrlib/flink-kafka-lab.jar
