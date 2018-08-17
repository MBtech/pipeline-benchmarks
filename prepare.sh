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
/usr/local/spark/bin/spark-submit --executor-memory $MEMORY --packages com.datastax.spark:spark-cassandra-connector_2.11:2.3.0 --class RandomForestDataGenerator --master spark://$MASTER_IP:7077 target/scala-2.11/simple-project_2.11-1.0.jar $INPUT_HDFS $NUM_EXAMPLES_RF $NUM_FEATURES_RF
#./run.sh RandomForestDataGenerator $INPUT_HDFS $NUM_EXAMPLES_RF $NUM_FEATURES_RF

