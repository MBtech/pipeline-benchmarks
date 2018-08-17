#!/bin/bash
# Licensed to the Apache Software Foundation (ASF) under one or more
# contributor license agreements.  See the NOTICE file distributed with
# this work for additional information regarding copyright ownership.
# The ASF licenses this file to You under the Apache License, Version 2.0
# (the "License"); you may not use this file except in compliance with
# the License.  You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
source rf.conf

MEMORY=6G
MASTER_IP=$HDFS_MASTER
CASSANDRA_PRIV=172.31.46.157
CASSANDRA_IP=172.31.46.157
OPTION="--numTrees $NUM_TREES_RF \
        --numClasses $NUM_CLASSES_RF \
        --featureSubsetStrategy $FEATURE_SUBSET_STRATEGY_RF \
        --impurity $IMPURITY_RF \
        --maxDepth $MAX_DEPTH_RF \
        --maxBins $MAX_BINS_RF"
#run_spark_job com.intel.hibench.sparkbench.ml.RandomForestClassification $OPTION $INPUT_HDFS

ssh -t ubuntu@$CASSANDRA_IP "cqlsh $CASSANDRA_PRIV -e \"DROP TABLE IF EXISTS test.rf;\""
ssh -t ubuntu@$CASSANDRA_IP "cqlsh $CASSANDRA_PRIV -e \"CREATE KEYSPACE IF NOT EXISTS test WITH REPLICATION = {'class' : 'SimpleStrategy','replication_factor' : 1};\""
ssh -t ubuntu@$CASSANDRA_IP "cqlsh $CASSANDRA_PRIV -e \"CREATE TABLE IF NOT EXISTS test.rf (label float, prediction float, id bigint, PRIMARY KEY (id) );\""

/usr/local/spark/bin/spark-submit --jars scopt_2.11-3.7.0.jar --executor-memory $MEMORY --packages com.datastax.spark:spark-cassandra-connector_2.11:2.3.0 --class RandomForestClassification --master spark://$MASTER_IP:7077 target/scala-2.11/simple-project_2.11-1.0.jar $OPTION $INPUT_HDFS
