import org.apache.spark.SparkContext
import org.apache.spark.SparkContext._

object WordCountEnv { 
    def main(args: Array[String]) { 
        // get MASTER from a variable
        val driverUrl = if (System.getenv("MASTER")!= null) System.getenv("MASTER") else "local"        
        val inputPath = args(0)
        val sc = new SparkContext(driverUrl, "WordCount")
        val file = sc.textFile(inputPath) 
        val output = file.flatMap(_.split(" ")) 
        	.map(word => (word, 1)) 
        	.reduceByKey(_ + _)
        
        if (args.length > 1) {
        	val outputPath = args(1)
        	println("Saving result to :" + outputPath)
        	output.saveAsTextFile(outputPath)
        } else {
        	val result =  output.toArray()
        	println("Result: " + result.toList)
        }
    } 
} 
