import org.apache.spark.SparkContext
import org.apache.spark.SparkContext._
import org.apache.spark.SparkConf

object WordCount { 
    def main(args: Array[String]) { 
        val inputPath = args(0)
        val sc = new SparkContext(new SparkConf())
        val file = sc.textFile(inputPath) 
        val result = file.flatMap(_.split(" ")) 
        .map(word => (word, 1)) 
        .reduceByKey(_ + _) 
        .toArray()
        println("Result: " + result.toList) 
        sc.stop()
 } 
} 
