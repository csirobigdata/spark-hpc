SPARK HPC USER GUIDE
-------------------------------- 

This package runs SPARK applications on a Linux cluster through a PBS batch
system. It is based on, and uses the back end of, simr ([Spark in Map
Reduce](http://databricks.github.io/simr/))

It currently supports Spark 1.x.x and Scala(Java) application runnable with spark-class.

There are two ways to use spark-hpc

1. Submit spark jobs with sparkhpc-submit which mimics to large extend the spark-submit command.
2. Use spark-hpc.sh directly in PBS submission scripts. 

_Note: On CSIRO cluster you need to load appropriate spark-hpc module before submitting the jobs _ 

## <a name="devcons"></a> Develpment consideration 

Both `sparkhpc-submit` and  `spark-hpc.sh` pass the driver URL to the application
in the spark.master property of SparkConf, just as spark-submit does.

In order to avoid driver disassociation errors in the log and ensure clean 
termination of your application use `SparkContext.stop()` method to explicitly stop 
the the driver e.g.:

	val sc = new SparkContext(new SparkConf())
	// here goes your code
	sc.stop()  // finish working with the context

## Using sparkhpc-submit

With `sparkhpc-submit` you can submit spark jobs in a way similar to using `spark-submit`, e.g.:

	sparkhpc-submit --class WordCount -v lib/tests-core_2.10-1.0.jar ./data/lady_of_shalott.txt

(the application jar and data file are available in the `examples` dir of your SPARK HPC installation, i.e.:  `${SPARKHPC_HOME}/examples`)
		
The job will be submitted with `qsub`, and you can monitor its status with `qstat` e.g.:

	qstat -u bill # for user bill 	
		
Once the job has completed the joined PBS output is available in `./WordCount.oe` (this can be customized with `-o or --output` options).

To get more information about available command line options use:

	sparkhpc-submit --help
	
Here is an example a more advanced use that requests 32 executors each with 2G or RAM with walltime of 2h:

	sparkhpc-submit --class WordCount -v 
		--num-executors 32  --executor-memory 2 \
		--walltime 1:00:00	
		lib/tests-core_2.10-1.0.jar ./data/lady_of_shalott.txt
	
Here is the list of important differences between spark-submit and sparkhpc-submit

- the `--driver-memory` and `--executor-memory` take a number in GB rather then the java like mem specification that includes the unit, e.g: `--driver-memory 1` rather then `--driver-memory 1G`
- all shared paths (that includes application jar, additional jars, other classpath elements and file paths in argument) are assumed to be on a cluster shared posix filesystem. SPARH HPC will converts all the relative paths to the absolute paths on the submission node.   
- executor and driver jvm environment configuration options passed in SparkConf (e.g. spark.executor.extClassPath) are not supported. Executor environment is assumed to be the same as the driver environment  and is configured with the values of `--driver-java-options`, `--driver-class-path` and `driver-library-path`


`sparkhpc-submit` supports a few options useful for debugging:

- `--dry-run` :  Print out the pbs submission script but do not submit it to the cluster
- `-v, --verbose` : Print verbose info

## Using spark-hpc.sh

### <a name="config"></a> Runtime Configuration

When running Spark-HPC, `spark-hpc.sh` honors the following environment variables:

* `SPARKHPC_MEM` - the max java heap space
* `SPARKHPC_DRIVER_MEM` - the java heap space for the driver (defaults to $SPARKHPC_MEM)
* `SPARKHPC_EXECUTOR_MEM` - the max java heap space for the executor (defaults to $SPARKHPC_MEM)
* `SPARKHPC_JAVA_CLASSPATH` - 
* `SPARKHPC_DRIVER_CLASSPATH` - 
* `SPARKHPC_EXECUTOR_CLASSPATH` - 
* `SPARKHPC_JAVA_OPTS` - 
* `SPARKHPC_DRIVER_OPTS` - 
* `SPARKHPC_EXECUTOR_OPTS` - 
* `SPARKHPC_JAVA_LIBRARY_PATH` - 
* `SPARKHPC_DRIVER_LIBRARY_PATH` - 
* `SPARKHPC_DRIVER_LIBRARY_PATH` - 

See *examples/run-wordcout.sh* for a sample script using some of the options above.

### Non-interactive Batch Mode

To run in batch mode do the following in your PBS script.

Initialize the runtime environment so that it includes all required dependencies (e.g.: using env modules): openmpi, jre, spark, and spark-hpc

Configure `spark-hpc.sh` through environment variables. See the [Configuration](#config)
section for more information.

Then call `spark-hpc.sh` as follows:

    spark-hpc.sh <class-name> <args>

Where `<class-name>` contains the Spark driver program to run, and `<args>` are
the commandline arguments to the driver.

For example for a system with modules (e.g.: CSIRO clusters) a PBS submission script can look like that:

	#!/bin/bash
	#PBS -N WordCount
	#PBS -l nodes=1:ppn=1,vmem=2GB
	#PBS -l walltime=10:00
	#PBS -j oe
	#PBS -o output/WordCount.oe
	#PBS -V

	set -e

	export SPARKHPC_JAVA_CLASSPATH=${SPARKHPC_HOME}/examples/lib/tests-core_2.10-1.0.jar
	export SPARKHPC_JAVA_OPTS="-Dspark.logInfo=true"
	export SPARKHPC_EXECUTOR_MEM="1G"
	export SPARKHPC_DRIVER_MEM="1G"

	${SPARKHPC_HOME}/bin/spark-hpc.sh --verbose WordCount ${SPARKHPC_HOME}/examples/data/lady_of_shalott.txt	


### Interactive Mode

Initialize the runtime environment so that it includes all required dependencies (e.g.: using env modules): openmpi, jre, spark, and spark-hpc.
_Note: On CSIRO cluster you need to load appropriate spark-hpc module to initialize the runtime environment _ 

To run in interactive mode, first start an interactive PBS job:

    qsub -I -V <other pbs options> 

e.g:

    qsub -I -V -N sparkshell -l nodes=2:ppn=2,vmem=4GB,walltime=30:00

Then run Spark-HPC as follows:

    spark-hpc.sh --shell

The Spark interactive REPL will be started within the interactive shell
session, presenting you with a Scala prompt and pre loaded Spark context.

`spark-hpc.sh --shell` can be configured in the same way as the batch mode version.

### <a name="logging"></a> Logging

There are two types of logging information produced upon running `spark-hpc.sh`:

* Logging from `spark-hpc.sh` itself (*off* by default)
* log4j logging from Spark framework (*on* by default)

You can turn on `spark-hpc.sh` logging output using the `--verbose` or
`--spark-hpc-log=file` options (see `spark_hpc.sh --help` for more details).

To turn off or control the Spark framework's log4j logging, you can provide a
standard [log4j 1.2 configuration
file](http://logging.apache.org/log4j/1.2/manual.html#Configuration), and either:

1. specify the config file via `spark-hpc.sh --log4j-configuration=<path_to_file>`
2. set the `log4j.configuration` java system property to the *fully qualified
   URI* of your config file, via (for example) the `SPARK_JAVA_OPTS`
   environment variable.

For example, to keep the default log4j setting for Spark 0.9, but make the
output go to `spark.log` file. You could use the following configuration file,
and set `SPARKHPC_JAVA_OPTS` appropriately:

    > cat ${SPARKHPC_HOME}/examples/log4j/log4j.properties
    # Set everything to be logged to file spark.log
    log4j.rootCategory=INFO, file
    log4j.appender.file=org.apache.log4j.FileAppender
    log4j.appender.file.File=spark.log
    log4j.appender.file.Append=false
    log4j.appender.file.layout=org.apache.log4j.PatternLayout
    log4j.appender.file.layout.ConversionPattern=%d{yy/MM/dd HH:mm:ss} %p %c{1}: %m%n
    # Settings to quiet third party logs that are too verbose
    log4j.logger.org.eclipse.jetty=WARN
    log4j.logger.org.apache.spark.repl.SparkIMain$exprTyper=INFO
    log4j.logger.org.apache.spark.repl.SparkILoop$SparkILoopInterpreter=INFO
    > export SPARKHPC_JAVA_OPTS="${SPARKHPC_JAVA_OPTS}"\
    > " -Dlog4j.configuration=file:///${SPARKHPC_HOME}/examples/log4j/log4j.properties"


## Examples (needs to be reviewed)

Examples are available in the `examples` directory.
You will need to compile and package the examples before running with maven.
Please refer to [examples/README.md] for details.

### Non-Interactive Batch Examples

The example scripts in the base `examples` directory run applications in a
non-interactive batch mode. They include PBS directives for resource allocation
etc. Available example scripts are:

* submit-wordcount.sh - word count example with sparkhpc-submit
* run-wordcount.sh - word count example with spark-hpc

Please check your [Setup](#setup) before running the examples. 

In order to run sparkhpc-submit examples, just run the appropriate submit-xxx.sh script, e.g.:
	
	./submit-wordcount.sh
	
In order to run sparck-hpc examples use qsub to submit appropriate run-xxx.sh script, e.g.:

    qsub  run-wordcount.sh

The output is saved in the `output` directory.

### Interactive Examples

The `examples/repl` directory contains an example Scala script for
use in interactive mode. It is run by `:load`ing it at the Scala prompt.

To run the example, first launch `spark-hpc.sh` in interactive mode:

    qsub -I -v SPARKHPC_ROOT -l nodes=2:ppn=2,vmem=2GB,walltime=30:00
    . ${SPARKHPC_ROOT}/load_spark.sh
    . ${SPARKHPC_ROOT}/load_sparkhpc.sh`
    cd ${SPARKHPC_ROOT}/examples/repl
    spark-hpc.sh --shell

Once you have an interactive session, you can set the `inputPath` variable and
load the script via:

    val inputPath = "../../../data/lady_of_shalott.txt"
    :load WordCountREPL.scala

## Contributions

Any third party contributions submitted to this software project are to be made
under the terms of the BSD 3-Clause License template, a copy is available at:
http://opensource.org/licenses/BSD-3-Clause

Please see the [LICENSE](./browse/LICENSE) file in the base directory of this
distrubtion for full details.

