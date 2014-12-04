package org.vv.spark

/**
 * Created by zhangwei on 12/1/14.
 */
object CharTest {

	def main(args: Array[String]): Unit = {
		for (i <- 0 to 256) {
			val c = i.toChar;
			println(c);

		}


	}
}
