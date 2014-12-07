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


PARALLELISM=$1

if [ "${PARALLELISM}x" == "x" ]; then
    PARALLELISM=16
fi

MASTER="spark://hdn1001.local:7077"

REPORTDIR=./spark_report
HDFSBASE=./original


:> ${REPORTDIR}/report_time
:> ${REPORTDIR}/report_size


hadoop fs -ls ${HDFSBASE}/*.txt | grep -v "Found" | sort -k5 -n | awk '{print $NF}'|while read fname; do

	FILENAME=`basename ${fname}`
	hadoop fs -rm -r -skipTrash ${FILENAME}.huff/
	hadoop fs -rm -r -skipTrash ${FILENAME}.ec/
	hadoop fs -rm -r -skipTrash ${FILENAME}.decompressed/


	echo "======= Compressing ${fname} =========" >> ${REPORTDIR}/report_time 

	echo "" >> ${REPORTDIR}/report_time
	
	#rm -rf ${REPORTDIR}/${FILENAME}_compress.log
	#touch ${REPORTDIR}/${FILENAME}_compress.log

	command time -p -o ${REPORTDIR}/${FILENAME}_compress.time $JAVA_HOME/bin/java -cp $CLASSPATH $CONFIG_OPTS edu.ttu.bigdata.huffman.Compressor ${MASTER} ${fname} ${PARALLELISM}> ${REPORTDIR}/${FILENAME}_compress.log 2>&1

	cat ${REPORTDIR}/${FILENAME}_compress.time >> ${REPORTDIR}/report_time;

	echo "" >> ${REPORTDIR}/report_time

	echo "======= Decompressing ${fname} =========" >> ${REPORTDIR}/report_time

	echo "" >> ${REPORTDIR}/report_time

	#rm -rf ${REPORTDIR}/${FILENAME}_decompress.log
	#touch ${REPORTDIR}/${FILENAME}_decompress.log
	command time -p -o ${REPORTDIR}/${FILENAME}_decompress.time $JAVA_HOME/bin/java -cp $CLASSPATH $CONFIG_OPTS edu.ttu.bigdata.huffman.Decompressor ${MASTER} ${FILENAME} ${PARALLELISM}> ${REPORTDIR}/${FILENAME}_decompress.log 2>&1

	cat ${REPORTDIR}/${FILENAME}_decompress.time >> ${REPORTDIR}/report_time;

	echo "" >> ${REPORTDIR}/report_time


	echo "=========== ${fname} ============" >> ${REPORTDIR}/report_size

	echo "" >>${REPORTDIR}/report_size

	compressed_size=`hadoop fs -ls ${FILENAME}.huff/part-* |grep -v "Found" |awk 'BEGIN{rst=0}{rst=rst+$5}END{printf("%d",rst/8)}'`

	echo "The Size of the Compressed File is ${compressed_size} Bytes." >> ${REPORTDIR}/report_size

	original_size=`hadoop fs -ls ${fname} | grep -v "Found" |awk '{printf("%d",$5)}'`

	echo "The Size of the Original File is ${original_size} Bytes." >> ${REPORTDIR}/report_size

	reduction_ratio=`echo "scale=3;(${original_size}-${compressed_size})/${original_size} * 100" | bc -l`

	echo "The reduction_ratio is ${reduction_ratio}%" >> ${REPORTDIR}/report_size

	decompressed_size=`hadoop fs -ls ${FILENAME}.decompressed/part-* |grep -v "Found" |awk 'BEGIN{rst=0}{rst=rst+$5}END{printf("%d",rst)}'`

	echo "The Size of the Decompressed File is ${decompressed_size} Bytes." >> ${REPORTDIR}/report_size
	
	echo "" >> ${REPORTDIR}/report_size
done	
