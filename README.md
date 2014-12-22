## Overview 

This package runs SPARK applications on a Linux cluster through a PBS batch
system. It is based on, and uses the back end of, simr ([Spark in Map
Reduce](http://databricks.github.io/simr/))

It currently supports Spark 1.x and Scala(Java) application runnable with spark-class.

## Development

### Setting up development environment

Source the `set-dev-env.sh` with the file defining how to setup a specific environment as an argument in the spark-hpc root directory.
Sample environment definition files for CSIRO brag cluster are available in the `env` directory.

E.g.:

	source set-dev-env.sh env/bragg_1.8_1.1.0

The purpose of the environment definition files is to load desired version of spark-hpc dependencies including:

- openmpi
- jdk 
- spark
- maven3 (for development only)

### Testing 

Once the dev environment is set you can run the development version of SPARK-HPC with
$SPARKHPC_HOME/bin/sparkhpc-submit.

A few scripts useful for manual testsing are available in the `test` dir:

- submit-wordcount.sh - a simple word count application testing the basic submission interface
- submit-jnitest.sh - an application testing passing java options, classpath and java library path to both driver and executor.

Source code for the corresponding application is in the `test` dir as will and the applications need to be build with `mvn install` prior to testing.


### Building a distribution

Use the `make-dist.sh` script to build the distribution of SPARK HPC, e.g.:

	./make-dist.sh
	
The script reads the SPARK HPC version from the VERSION file (e.g. 0.1\_spark1.x) and produces the distribution tar.gz file in the `target/spark-hpc\_0.1\_<version>.tar.gz` file (e.g.: target/spark-hpc\_0.1\_spark-1.x.tar.gz).

The distribution includes:

- binaries (scripts) in `bin` directory
- sample configuration files in `conf` directory
- examples in `examples` directory
- and the README.md file from `docs` directory


## Contributions

Any third party contributions submitted to this software project are to be made
under the terms of the BSD 3-Clause License template, a copy is available at:
http://opensource.org/licenses/BSD-3-Clause

Please see the [LICENSE](./browse/LICENSE) file in the base directory of this
distrubtion for full details.

