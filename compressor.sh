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

echo "Starting Compressor..."

compress_time=`time $JAVA_HOME/bin/java -cp $CLASSPATH $CONFIG_OPTS edu.ttu.bigdata.huffman.Compressor ${MASTER} ${FILEPATH}  >/dev/null`

echo "Compressor Done!"

echo "Waiting for 5 seconds..."
sleep 5s

echo "Starting Decompressor..."

decompress_time=`time $JAVA_HOME/bin/java -cp $CLASSPATH $CONFIG_OPTS edu.ttu.bigdata.huffman.Decompressor ${MASTER} ${FILENAME}  >/dev/null`

echo "Decompressor Done!"

echo "Compress Time:"
echo ${compress_time}
echo "Decompress Time:"
echo ${decompress_time}


compressed_size=`hadoop fs -ls ${FILENAME}.huff/part-* |grep -v "Found" |awk 'BEGIN{rst=0}{rst=rst+$5}END{printf("%d",rst/8)}'`

echo "The Size of the Compressed File is ${compressed_size} Bytes."

original_size=`hadoop fs -ls ${FILEPATH} | grep -v "Found" |awk '{printf("%d",$5)}'`

echo "The Size of the Original File is ${original_size} Bytes."

reduction_ratio=`echo "(${original_size}-${compressed_size})/${original_size} * 100" | bc -l`

echo "The reduction_ratio is ${reduction_ratio}%"

decompressed_size=`hadoop fs -ls ${FILENAME}.decompressed/part-* |grep -v "Found" |awk 'BEGIN{rst=0}{rst=rst+$5}END{printf("%d",rst)}'`

echo "The Size of the Compressed File is ${decompressed_size} Bytes."

