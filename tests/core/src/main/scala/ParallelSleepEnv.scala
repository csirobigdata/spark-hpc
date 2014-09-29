import org.apache.spark.SparkContext
import org.apache.spark.SparkContext._

object ParallelSleepEnv { 
    def main(args: Array[String]) {         
        // get MASTER from a variable
        val driverUrl = if (System.getenv("MASTER")!= null) System.getenv("MASTER") else "local" 
        val noOfTasks = if (args.length > 0) args(0).toInt else 5
    	val sc = new SparkContext(driverUrl, "ParallelSleep")
        val table = sc.parallelize(List.range(0,noOfTasks), noOfTasks) 
        val result = table.map{ i => 
          println("Starting task: " + i)
          Thread.sleep(10000)
          println("Finished task: " + i)
          i
        } 
        .toArray()
        println("Result: " + result.toList)
 } 
} 
