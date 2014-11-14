package org.vv.spark

import org.apache.spark.{SparkContext ,SparkConf}
import org.apache.spark.SparkContext._

/**
 * Created by zhangwei on 11/14/14.
 */
object PageRank {
	def main(args: Array[String]) {
		// There must be more than 3 command arguments passing to this program. Otherwise, exit the program.
		if (args.length < 3) {
			System.err.println(Console.RED + "usage : PageRank <sparkMaster> <dataFile> <Iteration> <output>" + Console.RESET);
			System.exit(1);
		}
		// extract the arguments
		val sparkMaster = args(0)
		val dataFile = args(1)
		val iteration = args(2).toInt;

		//set up spark config
		val conf = new SparkConf();
		// set spark master
		conf.setMaster(sparkMaster)
		// create spark context
		val sc = new SparkContext(sparkMaster, "org.vv.spark.PageRank" , conf)
		// load text text file from HDFS as RDD, and cache it.
		val lines = sc.textFile(dataFile,1)

		// RDD of (user, neighbors) pairs
		val links = lines.map(s=>s.split("\\s+")).map(p=>(p(0), p(1))).distinct.groupByKey().cache()

		// RDD of (user, rank) pairs
		var ranks = links.mapValues(v=>1.0)

		//iteration
		for (i <- 1 to iteration) {
			var contribs = links.join(ranks).values.flatMap{
				case (urls, rank) => val size = urls.size;
				urls.map(url => (url, rank/size))
			}
			ranks = contribs.reduceByKey(_+_).mapValues(0.15 + 0.85 * _)
		}
		//sort by rank value and save the output
		ranks.map(k => k.swap).sortByKey(false).map(k => k.swap).map(p => p._1 + "\t" + p._2)
			.saveAsTextFile("page_rank_rst");
	}
}
