val file = sc.textFile(inputPath)
val output = file.flatMap(_.split(" ")).map(word => (word, 1)).reduceByKey(_ + _)

val result =  output.toArray()
println("Result: " + result.toList)


