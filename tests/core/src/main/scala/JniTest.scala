import org.apache.spark.SparkContext
import org.apache.spark.SparkContext._
import org.apache.spark.SparkConf

/**
 * A bit dumb example but
 * Calculates an average of each images pixels value (from an image sequence)
 * It is expected to test:
 * - dependency on a provided system library (<opencv-install>/share/OpenCV/java/opencv-java-2.4.9.jar)
 * - dependency on a JNI library (<opencv-install>/share/OpenCV/java)
 * - dependency on a bundled library (lib/img-filters-0.0.1-SNAPSHOT.jar)
 * - passing of java properties
 * - passing of memory options
 * Options to run with
 * java opts: -Dspark.hpc.test=driver -Xmx2048M
 * 
 */

object JniTest {

  System.loadLibrary("tests_jni");

  class Tests(in: String) {
    def testSysProperty() = {
      if (!"value".equals(System.getProperty("spark.hpc.test"))) {
        throw new AssertionError("spark.hpc.test is not 'value' in:  " + in)
      }
    }
    
    def testMemory() = {
      List.range(0, 900).map(i => new Array[Byte](2 * 1024 * 1024)).toArray
    }
    
    def testJar() {
      new JniTransformer()
    }
    
    testSysProperty()
    testMemory()
    testJar()
    
  }
  
    def main(args: Array[String]) {

    new Tests("driver")
    lazy val testsInExecutor = new Tests("executor")
    // get MASTER from a variable

    val inputPath = args(0)
    val sc = new SparkContext(new SparkConf())
    val lines = sc.textFile(inputPath)

    val transforms = lines.map { l =>
      testsInExecutor.getClass()
      new JniTransformer().transform(l)
    }
    transforms.toArray().foreach(println(_))
    sc.stop()
  }
} 
