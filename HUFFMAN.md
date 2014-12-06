# Log on the HPCC machine

```bash
$ ssh <username>@hadoop.hpcc.ttu.edu
```

# Download the Project

```bash
$ git clone "https://github.com/zhangwei217245/SparkProject.git"
```

# Log on the Data Node

```bash
$ ssh hdn1001
```


# Compile the Project

```bash
# change the directory to the one where you download the project.
$ cd SparkProject
$ mvn clean package
```

# Run it

```bash
$ ./compressor.sh "/CS5331_Examples/Hamlet_by_William_Shakespeare"
```

# What if the shell script doesn't run?

```bash
$ chmod +x ./compressor.sh
```

# What if the code is changed?

```bash
# exit to hadoop frame
$ exit
$ git pull
# log on to the Data Node again
$ ssh hdn1001
```

# More details on **Compressor** and **Decompressor**

* [Compressor.scala](/src/main/scala/edu/ttu/bigdata/huffman/Compressor.scala)

* [Decompressor.scala](/src/main/scala/edu/ttu/bigdata/huffman/Decompressor.scala)

# More details on Linux "time" command

```bash
$ man time
```
or visit:

* [time utility manual](http://man7.org/linux/man-pages/man7/time.7.html)

# About the benchmark result

In order to make comparison between traditional compression utilities (such as gunzip, zip) and spark, we wrote some bash script for convenience.

See the bash script for more information.

* A bash script for running data compression on Spark in a batch [batchCompressor.sh](/batchCompressor.sh)
* A bash script for running data compression via tar with gunzip in a batch [targz.sh](/tar_zip_report/targz.sh)
* A bash script for running data compression via zip utility in a batch [zip.sh](/tar_zip_report/zip.sh)
* For benchmark result, download: [CompressionOnHadoop.xlsx](/spark_report/CompressionOnHadoop.xlsx)


* Note: Due to the limited resource of current HPCC environment(in terms of CPU load and available memory), we failed to execute data compression against the 100MB file provided in programming project 1, though tar and zip command succeed in doing that. So, accordingly, we were not able to fetch the data about execution time and compressed file size of that 100MB file.


* The result of top command
The content below is the result of top command. It is easy to see the situation of the HPCC data node at the time the task was run.

```
top - 11:58:54 up 49 days, 23:21,  1 user,  load average: 12.37, 11.97, 11.80
Tasks: 519 total,   1 running, 518 sleeping,   0 stopped,   0 zombie
Cpu(s): 52.8%us,  0.5%sy,  0.0%ni, 46.6%id,  0.2%wa,  0.0%hi,  0.0%si,  0.0%st
Mem:  66078016k total, 58357296k used,  7720720k free,   657928k buffers
Swap:  1023992k total,        0k used,  1023992k free, 26219156k cached
```
