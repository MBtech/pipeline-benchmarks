#!/bin/bash
spark-submit --packages com.datastax.spark:spark-cassandra-connector_2.11:2.3.0 --class "$3" --master spark://$1:7077 target/scala-2.11/simple-project_2.11-1.0.jar $1 $2
