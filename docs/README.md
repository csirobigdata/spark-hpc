## Overview 

This package runs SPARK applications on a Linux cluster through a PBS batch
system. It is based on, and uses the back end of, simr ([Spark in Map
Reduce](http://databricks.github.io/simr/))

It currently supports Spark 1.0.x and Scala(Java) application runnable with spark-class.

WARNING: THIS IS A FIRST VERSION TESTED WITH SPARK 1.0.x.
IT APPEARS TO BE WORKING FOR THE MOST PART BUT IT GENERATES A NUMBER OF DEPRECATION 
WARNINGS AND SOME FEATURES MAY NOW WORK.
TREAT IT AS WORK IN PROGRESS.

There are two ways to use spark-hpc

1. Submit spark jobs with sparkhpc-submit which mimics to large extend the spark-sumit command.
2. Use spark-hpc.sh direclty in PBS submission scrips. 


## Spark integration

Spark applications run via `spark-hpc.sh` need to construct a spark context and
need to accept the driver url either:

1. via their first command line argument
2. the `MASTER` environment variable

These two usage conventions are mutually exclusive, i.e. use one or the other
for each Spark application. See [Usage section](#usage) for details on telling
`spark-hpc.sh` which driver convention you are using.

## <a name="intall"></a> Installation

### <a name="depend"></a>Dependencies

Spark-HPC requires the following software and environment variables to be setup
on the system:

* Spark 1.0.x
    - `SPARK_HOME` environment variable must be set to the Spark installation
      directory
    - The `bin` directory of the Spark installation must be added to the `PATH`
      environment variable
* MPI
    - The `mpirun` script/program must be visible via the `PATH`
      ENVironment variable. If your MPI distribution use a different name to
      `mpirun`, please set up an alias or symbolic link named `mpirun`.

### <a name="setup"></a> Setup

1. Copy the Spark-HPC project directory to the desired location.
2. Set the `SPARKHPC_HOME` and `SPARKHPC_ROOT` environment variables to the
   base location used above.
3. Add `${SPARKHPC_HOME}/bin` to the system `PATH`.

### <a name="env"></a> Dynamic Environment Setup Scripts
If it is inappropriate to set the installation environment variables described
above permanently, then they must be set in each shell session prior to calling
`spark-hpc.sh`.

Spark-HPC provides the `load_spark.sh` and `load_sparkhpc.sh` in the
`SPARK_HOME` directory to centralise and simplify on demand configuration of
the Spark and Spark-HPC installations.

The scripts can be used by sourcing them in your own script or shell sessions:

    . ${SPARKHPC_ROOT}/load_spark.sh
    . ${SPARKHPC_ROOT}/load_sparkhpc.sh

By default the scripts try to load the packages via appropriate [Environment
Models](http://modules.sourceforge.net/).

Users can specify their own configuration by placing identically named scripts
into their `~/.spark-hpc/` directory, which contain appropriate shell commands.
These will automatically be chosen over the defaults if present.

## <a name="config"></a> Runtime Configuration

When running Spark-HPC, `spark-hpc.sh` honors all general and executor specific
Spark [environment
variables](http://spark.apache.org/docs/0.9.0/configuration.html#environment-variables)
and [java system
properties](http://spark.apache.org/docs/0.9.0/configuration.html#spark-properties),
used to control Spark job behaviour.

Noteworthy Spark environment variables:

* `SPARK_CLASSPATH` - additional classpath
* `SPARK_JAVA_OPTS` - jvm options (e.g. -Dxxxx=yyy)
* `SPARK_LIBRARY_PATH` - path to native java libraries (JAVA_LIBRARY_PATH)
* `SPARK_MEM` - the max java heap space for both driver and executors (e.g. 2048m)

See *examples/run-jnitest-env.sh* for a sample script using all of the options above.

In addition `spark-hpc.sh` can be configured using the following environment variables:

* `SPARKHPC_LOCAL_DIR` - the location spark executors will use for spill and RDD files
* `SPARKHPC_DRIVER_MEM` - the java heap space for the driver (defaults to $SPARK_MEM)
* `SPARKHPC_EXECUTOR_MEM` - the max java heap space for the executor (defaults to $SPARK_MEM)

The following special handling rules apply:

* `spark.local.dir` is checked and handled with respect to admin set site conventions
* `SPARKHPC_LOCAL_DIR` is synonymous with, and overwritten by, `-Dspark.local.dir`


### <a name="site_conf"></a> Site Wide Runtime Config

Site wide runtime configuration options can be set by system administrators in
the `set-env.sh` script in the `SPARKHPC_HOME` directory. Please see comments in
this script for a description of the available environment variables.

Values in this file are overwritten by values in the [User Config](#user_conf)
file. On some sites, usage policies or conventions dictate that certain
`SPARKHPC_*` or `SPARK_*` variables be tightly controlled to avoid a user
adversely affecting other users on the system.

Currently, the `SPARKHPC_LOCAL_DIR` environment variable can not be overwritten
by the user without an error message being displayed. This is due to the
implications of users writing to unsuitable locations in node local storage,
and filling file systems.

### <a name="user_conf"></a> User Config

User configuration of `SPARKHPC_*`, `SPARK_*`, and any other environment
variables specific to your applications can be set in a
`~/.spark-hpc/set-env.sh` file.

Note that it is not advisable to overwrite some site wide configuration
settings (see [Site Wide Config](#site_conf)). Options for forcing overwrite
are outlined in `spark-hpc.sh --help`.

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
and set `SPARK_JAVA_OPTS` appropriately:

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
    > export SPARK_JAVA_OPTS="${SPARK_JAVA_OPTS}"\
    > " -Dlog4j.configuration=file:///${SPARKHPC_HOME}/examples/log4j/log4j.properties"

## <a name="usage"></a> Usage

### Non-interactive Batch Mode

To run in batch mode do the following in your PBS script.

If required (see [Dynamic Environment Setup Scripts](#env)), source the
`load_sparkhpc.sh` and/or `load_spark.sh` scripts *prior* to calling
`spark-hpc.sh. e.g.:

    #PBS -v SPARKHPC_ROOT
    . ${SPARKHPC_ROOT}/load_spark.sh
    . ${SPARKHPC_ROOT}/load_sparkhpc.sh

Then call `spark-hpc.sh` as follows:

    spark-hpc.sh <class-name> <args>

Where `<class-name>` contains the Spark driver program to run, and `<args>` are
the commandline arguments to the driver.

See the [Driver Calling Convention](#callconv) section for information on
different approaches to passing the driver URL to the program named in
`<class-name>`. See `spark-hpc.sh --help` for an extended usage description.

Additional options e.g.: (classpath, jvm options) can be passed to
`spark-hpc.sh` through environment variables. See the [Configuration](#config)
section for more information.

### Interactive Mode

To run in interactive mode, first start an interactive PBS job:

    qsub -I -v SPARKHPC_ROOT <other pbs options> 

e.g:

    qsub -I -v SPARKHPC_ROOT -N sparkshell -l nodes=2:ppn=2,vmem=4GB,walltime=30:00

Once the job starts and you have an interactive shell session, source the
[Dynamic Environment Setup Scripts](#env) if required, e.g.:

    . ${SPARKHPC_ROOT}/load_spark.sh
    . ${SPARKHPC_ROOT}/load_sparkhpc.sh

Then run Spark-HPC as follows:

    spark-hpc.sh --shell

The Spark interactive REPL will be started within the interactive shell
session, presenting you with a Scala prompt and pre loaded Spark context.

`spark-hpc.sh --shell` can be configured in the same way as the batch mode version.
See the [Configuration](#config) section for more information.

### <a name="callconv"></a> Driver Calling Convention

By default `spark-hpc.sh` passes the driver URL to `<class-name>` via its first
commandline argument, with `<args>` starting from the *second* argument. Use
the `--url-env-var` option to alternatively pass the driver URL to
`<class-name>` via environment variable `MASTER`, with `<args>` starting at the
*first* commandline argument.

Interactive mode *always* passes the driver URL via environment variable.
i.e. `spark-hpc.sh --shell` is a synonym for `spark-hpc.sh --shell
--url-env-var`.

## Examples

Examples are available in the `examples` directory.
You will need to compile and package the examples before running with maven.
Please refer to [examples/README.md] for details.

### Non-Interactive Batch Examples

The example scripts in the base `examples` directory run applications in a
non-interactive batch mode. They include PBS directives for resource allocation
etc. Available example scripts are:

* run-workcount.sh - word count example (Driver URL passed via commandline)
* run-workcount-env.sh - word count example (Driver URL passed via environment
  variable)
* run-parallel-sleep.sh - parallel sleep example
* run-jnitest.sh - an example of calling a native function from java (and setting requried Spark options)

Please check your [Setup](#setup) before running the examples. In order to run:

    qsub <example script>

e.g.:

    qsub  run-wordcount.sh

The output is saved in the `output` directory.

*NOTE:* These examples and scripts should also work when run directly from
the Linux from shell (without qsub)

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

