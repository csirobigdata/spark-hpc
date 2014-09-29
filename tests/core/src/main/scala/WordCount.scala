import org.apache.spark.SparkContext
import org.apache.spark.SparkContext._

object WordCount { 
    def main(args: Array[String]) { 
        val driverUrl = args(0)
        val inputPath = args(1)
        val sc = new SparkContext(driverUrl, "WordCount")
        val file = sc.textFile(inputPath) 
        val result = file.flatMap(_.split(" ")) 
        .map(word => (word, 1)) 
        .reduceByKey(_ + _) 
        .toArray()
        println("Result: " + result.toList) 
 } 
} 
