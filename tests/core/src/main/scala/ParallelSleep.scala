import org.apache.spark.SparkContext
import org.apache.spark.SparkContext._

object ParallelSleep { 
    def main(args: Array[String]) {         
    	val noOfTasks = if (args.length > 0) args(0).toInt else 5
        val sc = new SparkContext(new SparkConf())
        val table = sc.parallelize(List.range(0,noOfTasks), noOfTasks) 
        val result = table.map{ i => 
          println("Starting task: " + i)
          Thread.sleep(10000)
          println("Finished task: " + i)
          i
        } 
        .toArray()
        println("Result: " + result.toList)
        sc.stop()
 } 
} 
