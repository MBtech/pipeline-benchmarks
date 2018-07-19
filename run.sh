#!/bin/bash
MASTER_IP=$1
CASSANDRA_IP=$2
MEMORY=$4
BENCHMARK=$3
/usr/local/spark/bin/spark-submit --executor-memory $MEMORY --packages com.datastax.spark:spark-cassandra-connector_2.11:2.3.0 --class "$BENCHMARK" --master spark://$MASTER_IP:7077 target/scala-2.11/simple-project_2.11-1.0.jar $MASTER_IP $CASSANDRA_IP
