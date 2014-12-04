# Log on the HPCC machine

```bash
$ ssh <username>@hadoop.hpcc.ttu.edu
$ ssh hdn1001
```

# Download the Project

```bash
$ git clone "https://github.com/zhangwei217245/SparkProject.git"
```

# Compile the Project

```bash
$ cd SparkProject
$ mvn clean package
```

# Run it

```bash
$ ./compressor.sh "/CS5331_Examples/Hamlet_by_William_Shakespeare"
```