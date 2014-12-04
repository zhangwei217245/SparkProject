package edu.ttu.bigdata.huffman

import scala.util.matching.Regex
import org.apache.spark.{SparkContext, SparkConf}

/**
 * Created by zhangwei on 11/29/14.
 *
 * Note:
 * 1. To see how to use the feature of Regular Expression in Java and Scala, visit:
 *      https://docs.oracle.com/javase/7/docs/api/java/util/regex/Pattern.html
 *      http://www.tutorialspoint.com/scala/scala_regular_expressions.htm
 * 2.
 *
 */
object Decompressor {

	/**
	 * Take a string in the huffman encoded file as input,
	 * acquire all the sequences that matches with our rule, into a list.
	 * concat the character decoded corresponding to the huffman code in the decoding map
	 * by traversing each element in the matching list
	 * @param str
	 * @param codings
	 * @return
	 */
	def huffman_replace2(str:String, codings:Map[String, String]) : String = {
		var rst:String = "";
		var pattern = new Regex("11*0*0");
		var matchingIterator = pattern.findAllIn(str);
		var codeList = matchingIterator.toList;
		codeList.foreach(x => rst=rst.concat(codings.getOrElse(x.trim,"")))
		return rst
	}

	/**
	 * Main function which takes 2 console arguments, one for sparkMaster and the other for "Huffman encoded file"
	 * @param args
	 */
	def main(args: Array[String]) {
		// There must be more than 2 command arguments passing to this program. Otherwise, exit the program.
		if (args.length < 2) {
			System.err.println(Console.RED + "usage : WordFind <sparkMaster> <dataFile>" + Console.RESET);
			System.exit(1);
		}
		// extract the arguments
		val sparkMaster = args(0)
		val dataFile = args(1)


		// set up spark config
		val conf = new SparkConf();
		// set spark master
		conf.setMaster(sparkMaster)
		// create spark context
		val sc = new SparkContext(sparkMaster, "edu.ttu.bigdata.huffman.Decompressor", conf)
		// load huffman encoded text file from HDFS as RDD, and cache it. The the process of searching specified keyword
		// can be accelerated.
		val textFile = sc.textFile(dataFile +".huff/part-*").cache()
		// load decoding talbe from HDFS as RDD and cache it.
		val encodings = sc.textFile(dataFile +".ec/part-*").cache()
			//map each line as a tuple via splitting the line by comma.
			.map(line => (line.split(",",2)(0), line.split(",",2)(1)))
			//the RDD is converted into a Seq of tuples by the statement below
			.collect
			//the Seq is converted into a Map of scala collections
			.toMap;


		/**
		 *
		 *
		 * File name example:
		 *
		 * Input:   Hamblablabla.txt.ec
		 *          Hamblablabla.txt.huff
		 *
		 * Output:  Hamblablabla.txt.decompressed
		 *
		 */

		//Trivial
		val filePathArr:Array[String] = dataFile.split("/");
		val fileName = filePathArr(filePathArr.length-1);

		//Decode the huffman encoded file, line by line.
		textFile.map(line => huffman_replace2(line, encodings))
			// save the result as a text file
			.saveAsTextFile(fileName + ".decompressed")

	}
}
