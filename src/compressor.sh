#!/bin/bash

source /etc/spark/conf/spark-env.sh

JAR_NAME="./target/SparkProject-1.0.jar"

# system jars:
CLASSPATH=/etc/hadoop/conf
CLASSPATH=$CLASSPATH:$HADOOP_HOME/*:$HADOOP_HOME/lib/*
CLASSPATH=$CLASSPATH:$HADOOP_HOME/../hadoop-mapreduce/*:$HADOOP_HOME/../hadoop-mapreduce/lib/*
CLASSPATH=$CLASSPATH:$HADOOP_HOME/../hadoop-yarn/*:$HADOOP_HOME/../hadoop-yarn/lib/*
CLASSPATH=$CLASSPATH:$HADOOP_HOME/../hadoop-hdfs/*:$HADOOP_HOME/../hadoop-hdfs/lib/*
CLASSPATH=$CLASSPATH:$SPARK_HOME/assembly/lib/*
CLASSPATH=$CLASSPATH:$SPARK_HOME/lib/*
CLASSPATH=$CLASSPATH:$SPARK_HOME/core/lib/*


# app jar:
CLASSPATH=$CLASSPATH:$JAR_NAME

CONFIG_OPTS="-Dspark.master=local -Dspark.jars=$JAR_NAME"

echo "$CLASSPATH"

FILEPATH=$1

MASTER="spark://hdn1001.local:7077"

FILENAME=`basename ${FILEPATH}`

hadoop fs -rm -r -skipTrash ./${FILENAME}.ec
hadoop fs -rm -r -skipTrash ./${FILENAME}.huff
hadoop fs -rm -r -skipTrash ./${FILENAME}.decompressed


$JAVA_HOME/bin/java -cp $CLASSPATH $CONFIG_OPTS edu.ttu.bigdata.huffman.Compressor ${MASTER} ${FILEPATH}
$JAVA_HOME/bin/java -cp $CLASSPATH $CONFIG_OPTS edu.ttu.bigdata.huffman.Decompressor ${MASTER} ${FILEPATH}


hadoop fs -ls ${FILENAME}.huff/part-* |grep -v "Found" |awk 'BEGIN{rst=0}{rst=rst+$5}END{printf("The Size of the Compressed File is %d Bytes\n",rst/8)}'

hadoop fs -ls ${FILEPATH} | grep -v "Found" |awk '{printf("The Size of the Original File is %d Bytes\n",$5)}'

hadoop fs -ls ${FILENAME}.decompressed/part-* |grep -v "Found" |awk 'BEGIN{rst=0}{rst=rst+$5}END{printf("The Size of the Compressed File is %d Bytes\n",rst)}'

