#!/bin/bash
source /etc/spark/conf/spark-env.sh

JAR_NAME="$HOME/spark_project/SparkProject-1.0.jar"

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


$JAVA_HOME/bin/java -cp $CLASSPATH $CONFIG_OPTS org.vv.spark.PageRank $1 $2 $3