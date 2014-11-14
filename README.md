This document is also available on <http://github.com/>

# Compilation on Linux/Unix
*     Make sure **scala** and **sbt** are installed on your Linux/Unix machine.
>  If not, download them from <http://www.scala-lang.org> and <http://www.scala-sbt.org>. Follow the document, and install them.
*     Make sure the current working directory is the one containing this README.md file.
*     Execute the command below in shell
>       sbt package
*     Once succeed, the executable JAR file is generated under the **target** directory.

# Upload the executable JAR file onto HPCC cluster.

*     Next, find the file **sparkproject_2.10-1.0.jar** under the **target** directory, and this is the executable file.
*     Execute the command below on your local Linux/UNIX machine:
>       sftp <your_user_name>@hadoop.hpcc.ttu.edu
*     Enter the password, and execute the JAR file to your project directory.
>       mkdir <NAME_OF_YOUR_SPARK_WORKING_DIRECTORY>
>       put <ABSOLUTE_PATH_TO_YOUR_JAR_FILE_ON_YOUR_LOCAL_MACHINE>
*     By doing this, the executable file is uploaded onto the HPCC machine.


# Run standalone program on Spark Cluster
## Run **WordFind** Program for Problem A



## Run **PageRank** Program for Problem B

