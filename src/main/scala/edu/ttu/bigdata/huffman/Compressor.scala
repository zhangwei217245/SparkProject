package edu.ttu.bigdata.huffman


import org.apache.spark.{SparkContext, SparkConf}
import org.apache.spark.SparkContext._

/**
 * Created by zhangwei on 12/1/14.
 *
 * Note:
 * 1. In scala, val denotes a immutable value, but var denote a variable whose value is mutable.
 * 2. In scala, semicolon at the end of a statement is optional
 */
object Compressor {

	def huffman_encoding(code:Int, c:Char): Tuple2[Int,String] ={

		var rst_code = code;


		//Generating "Amanda" code
		var huffman_code = rst_code.toBinaryString + "0"

		//validating whether the generated code follows our rule:
		//starts with 1, ends with 0, no 0s before 1s in between
		while (!huffman_code.matches("^1{1}1*0*0{1}$")) {
			// if the code doesn't match with the rule, jump over a natural number
			rst_code+=1;
			// generate the code again, until the code meets our needs
			huffman_code = code.toBinaryString + "0"
		}
		// natural number jumps over to the next
		rst_code+=1;
		return (rst_code,huffman_code)
	}
	/**
	 * Taking each character in str as an input, acquire the corresponding huffman code and accumulate
	 * it in a variable.
	 * @param str
	 * @param codings
	 * @return
	 */
	def huffman_replace(str:String, codings:Map[Char, String]) : String = {
		var rst:String = "";
		str.foreach(c => rst=rst+codings.getOrElse(c,""))
		return rst
	}

	/**
	 * main functions, taking 2 console parameters as input.
	 * the first one is for sparkMaster, the second one is for original file to be compressed.
	 * @param args
	 */
	def main(args: Array[String]) {
		// There must be more than 2 command arguments passing to this program. Otherwise, exit the program.
		if (args.length < 3) {
			System.err.println(Console.RED + "usage : WordFind <sparkMaster> <dataFile> <parallelism>" + Console.RESET);
			System.exit(1);
		}
		// extract the arguments
		val sparkMaster = args(0)
		val dataFile = args(1)
		val parallelism = args(2).toInt



		//set up spark config
		val conf = new SparkConf();
		// set spark master
		conf.setMaster(sparkMaster)
		// create spark context
		val sc = new SparkContext(sparkMaster, "edu.ttu.bigdata.huffman.Compressor", conf)
		// load text text file from HDFS as RDD, and cache it. The the process of searching specified keyword can be
		// accelerated.
		val textFile = sc.textFile(dataFile, parallelism/2).cache()

		// define the encoding_table for encoding operations
		var encoding_table: Map[Char, String] = Map();
		// define the decoding_table which will be persisted for the "Decompressor".
		var decoding_table: Map[String, Char] = Map();

		// define code which is actually the natural number for generating our "Amanda" code
		var code:Int = 1;

		// flat each line of the file into separated characters.
		var wordCount_arr = textFile.flatMap(line => line)
			//read each character while creating a tuple with number "1" denoting one time occurrence.
			.map(c => (c, 1))
			//reduce by summing up the occurrence of the same characters.
			.reduceByKey(_+_,parallelism)
			//change the order of elements in each tuple so that we can sort the RDD by occurrence
			.map(item => item.swap).sortByKey(false,parallelism)
			.foreach(item => {var rtn:Tuple2[Int, String]=huffman_encoding(code,item._2);code=rtn._1;
			encoding_table+=(item._2 , rtn._2.toString);decoding_table+(rtn._2.toString , item._2)})

		/**
		 * Due to the limitation of the design of Spark data processing, it's not feasible to store the decoding
		 * table together with the final compressed file, since Spark gonna generate two independent RDD which
		 * can only be stored under two different directories on HDFS.
		 *
		 * Though, a programmer should never fail to solve any simple problem such as merging files, operating binary
		 * file streams on HDFS, but doing this requires more Spark proficiency in terms of the low-level API, which
		 * may takes much more time for getting things done.
		 *
		 * So, currently, all we can do on Spark and HDFS is to carry out a simulation by storing the Huffman encoded
		 * file as a text file via the API provided by Spark. How does this simulation work?
		 *
		 * The size of the Huffman encoded file, which can be denoted by N, is the number of bytes of this file,
		 * or say, the number of 0s and 1s in this text file, which is equivalent to the number of 0-bits and 1-bits in
		 * the binary file in our ideal design. Namely, N is the number of bits in the binary file and we can calculate
		 * the size of such binary file by this function: B=N/8 (8 bits = 1 byte, as everyone knows), where B is the bytes
		 * of the binary file.
		 */


		/**
		 * All right, let's see how we can store both the decoding table and the huffman encoded file
		 *
		 * The file name should follow some rule so that the bash script can easily process it at the minimum effort.
		 *
		 * The rule is "Extracting the file name solely without any directory name in the file path, and add an extension
		 * directly to the end of the file name."
		 *
		 * FileName Example:
		 *
		 * Input:   /CS5331_Examples/Hamblablabla.txt
		 * Output:  Hamblablabla.txt.ec
		 *          Hamblablabla.txt.huff
		 */


		// Trivial.
		val filePathArr:Array[String] = dataFile.split("/");
		val fileName = filePathArr(filePathArr.length-1);

		//the function makeRDD[T](T=>value) here is to create a RDD in the context of Spark by scala collections such as
		//List, Map, Seq, etc.
		sc.makeRDD[(String, Char)](decoding_table.toSeq, 1)
			// if directly store such RDD as a text file, the content of each line will look like "(1000,c)" which is hard to parse.
			// so here we just simply convert it as a line with comma as the delimiter.
			.map(x => x._1 + "," +x._2)
			.saveAsTextFile(fileName + ".ec");

		//Go through each line of the original file and call the function huffman_replace
		//To see how scala anonymous function works, visit the link below:
		//http://www.tutorialspoint.com/scala/anonymous_functions.htm
		textFile.map(line => huffman_replace(line, encoding_table)).saveAsTextFile(fileName + ".huff")

	}
}
