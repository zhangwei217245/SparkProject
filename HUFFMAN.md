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