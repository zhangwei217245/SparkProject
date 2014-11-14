This document is also available on <https://github.com/zhangwei217245/SparkProject>

# Compilation on Linux/Unix
## Compile and Package with sbt
* Make sure **scala** and **sbt** are installed on your Linux/Unix machine.

If not, download them from <http://www.scala-lang.org> and <http://www.scala-sbt.org>. Follow the document, and install them.

* Make sure the current working directory is the one containing this README.md file.
* Execute the command below in shell

```bash
$ sbt package
```

* Once succeed, the executable JAR file is generated under the **target** directory.

## Compile and Package with maven

* Make sure **scala** and **maven** are installed on your Linux/Unix machine.

If not, download them from <http://www.scala-lang.org> and <http://maven.apache.org>. Follow the document, and install them.

* Make sure the current working directory is the one containing this README.md file.
* Execute the command below in shell

```bash
$ mvn package
```

* Once succeed, the executable JAR file is generated under the **target** directory.

# Upload the executable JAR file onto HPCC cluster.

* Next, let's locate the JAR file.

    + If you're using **sbt** as a build tool, find the file **sparkproject_2.10-1.0.jar** under the **target/scala-2.10/** directory, and this is the executable file.

    + If you're using **maven** as a build tool, find the file **SparkProject-1.0.jar** under the **target/** directory, and this is the executable file.

* Execute the command below on your local Linux/UNIX machine:

```bash
$ sftp <your_user_name>@hadoop.hpcc.ttu.edu
```

* Enter the password, and execute the JAR file to your project directory.

```bash
$ mkdir <NAME_OF_YOUR_SPARK_WORKING_DIRECTORY>
$ put <ABSOLUTE_PATH_TO_YOUR_JAR_FILE_ON_YOUR_LOCAL_MACHINE>
```

* By doing this, the executable file is uploaded onto the HPCC machine.


# Run standalone program on Spark Cluster

## Run **WordFind** Program for Problem A

* By running our shell script, you can easily run **WordFind** program on JVM runtime.

Modify the value of JAR_NAME accordingly in file **wordfind.sh** , then execute the command below:

```bash
$ ./wordfind.sh "spark://hdn1001.local:7077" "/CS5331_Examples/Programming_Project_Dataset.txt" "Apple"
```

## Run **PageRank** Program for Problem B

Modify the value of JAR_NAME accordingly in file **pagerank.sh** , then execute the command below:

* By running our shell script, you can easily run **PageRank** program on JVM runtime.

```bash
$ ./pagerank.sh "spark://hdn1001.local:7077" "/CS5331_Examples/wiki-Vote.txt" "10"
```