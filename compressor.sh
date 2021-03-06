#!/bin/bash

source /etc/spark/conf/spark-env.sh

COMPRESSOR_TIME="compress.time"
DECOMPRESSOR_TIME="decompress.time"

COMPRESSOR_LOG="compress.log"
DECOMPRESSOR_LOG="decompress.log"

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
PARALLELISM=$2

if [ "${PARALLELISM}x" == "x" ]; then
    PARALLELISM=16
fi

MASTER="spark://hdn1001.local:7077"

FILENAME=`basename ${FILEPATH}`

hadoop fs -rm -r -skipTrash ./${FILENAME}.ec
hadoop fs -rm -r -skipTrash ./${FILENAME}.huff
hadoop fs -rm -r -skipTrash ./${FILENAME}.decompressed

echo "Starting Compressor..."

command time -v -o ${COMPRESSOR_TIME} $JAVA_HOME/bin/java -cp $CLASSPATH $CONFIG_OPTS edu.ttu.bigdata.huffman.Compressor ${MASTER} ${FILEPATH} ${PARALLELISM} > ${COMPRESSOR_LOG} 2>&1

echo "Compressor Done!"

echo "Waiting for 5 seconds..."
sleep 5s

echo "Starting Decompressor..."

command time -v -o ${DECOMPRESSOR_TIME} $JAVA_HOME/bin/java -cp $CLASSPATH $CONFIG_OPTS edu.ttu.bigdata.huffman.Decompressor ${MASTER} ${FILENAME} ${PARALLELISM} >${DECOMPRESSOR_LOG} 2>&1

echo "Decompressor Done!"


echo "============= Compress Time: ============="
echo
echo
cat ${COMPRESSOR_TIME}
echo
echo
echo "============= Decompress Time: ============="
echo
echo
cat ${DECOMPRESSOR_TIME}



compressed_size=`hadoop fs -ls ${FILENAME}.huff/part-* |grep -v "Found" |awk 'BEGIN{rst=0}{rst=rst+$5}END{printf("%d",rst/8)}'`

echo "The Size of the Compressed File is ${compressed_size} Bytes."

original_size=`hadoop fs -ls ${FILEPATH} | grep -v "Found" |awk '{printf("%d",$5)}'`

echo "The Size of the Original File is ${original_size} Bytes."

reduction_ratio=`echo "scale=3;(${original_size}-${compressed_size})/${original_size} * 100" | bc -l`

echo "The reduction_ratio is ${reduction_ratio}%"

decompressed_size=`hadoop fs -ls ${FILENAME}.decompressed/part-* |grep -v "Found" |awk 'BEGIN{rst=0}{rst=rst+$5}END{printf("%d",rst)}'`

echo "The Size of the Decompressed File is ${decompressed_size} Bytes."

