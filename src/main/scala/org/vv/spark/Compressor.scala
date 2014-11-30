package org.vv.spark

import org.apache.spark.{SparkContext, SparkConf}

/**
 * Created by zhangwei on 11/29/14.
 *
 * NOTE: THIS IS ONLY FOR TEST, NOT FOR FINAL RELEASE.
 */
object Compressor {
	def main(args: Array[String]) {
		// There must be more than 3 command arguments passing to this program. Otherwise, exit the program.
		if (args.length < 3) {
			System.err.println(Console.RED + "usage : WordFind <sparkMaster> <dataFile> <keyWord>" + Console.RESET);
			System.exit(1);
		}
		// extract the arguments
		val sparkMaster = args(0)
		val dataFile = args(1)
		val keyWord = args(2)

		//set up spark config
		val conf = new SparkConf();
		// set spark master
		conf.setMaster(sparkMaster)
		// create spark context
		val sc = new SparkContext(sparkMaster, "org.vv.spark.WordFind" , conf)
		// load text text file from HDFS as RDD, and cache it. The the process of searching specified keyword can be
		// accelerated.
		val textFile = sc.textFile(dataFile).cache()

		// map the 4th column in each line of the file by traversing each item in the RDD, into a new RDD.
		var articleCount = textFile.map(line => line.split("\\t")(3)
			// eliminate some noise, such as XML tags, line feed characters, etc. so that the result of WordFinder
			// could be more accurate.
			.replaceAll("</?[^>]+>"," ")
			.replaceAll("\\\\n",""))
			// executing filter function on the new RDD created by map function, passing the filtering functions
			// to filter out all the data items containing specified keyword, and call count() function to see
			// how many "articles" contains the specified keyword.
			.filter(line => line.contains(keyWord)).count()

		printf("Found %d article(s) containing the keyword \"%s\"\n", articleCount, keyWord);
	}
}
