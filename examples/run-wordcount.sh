#!/bin/bash
#PBS -N WordCount
#PBS -l nodes=1:ppn=1,vmem=2GB
#PBS -l walltime=10:00
#PBS -j oe
#PBS -o output/WordCount.oe
#PBS -V

set -e

export SPARKHPC_JAVA_CLASSPATH=${SPARKHPC_HOME}/examples/lib/tests-core_2.10-1.0.jar
export SPARKHPC_DRIVER_CLASSPATH= 
export SPARKHPC_EXECUTOR_CLASSPATH=
export SPARKHPC_JAVA_LIBRARY_PATH=
export SPARKHPC_JAVA_OPTS=""
export SPARKHPC_DRIVER_OPTS=""
export SPARKHPC_EXECUTOR_MEM="1G"
export SPARKHPC_DRIVER_MEM="1G"

${SPARKHPC_HOME}/bin/spark-hpc.sh --verbose WordCount ${SPARKHPC_HOME}/examples/data/lady_of_shalott.txt 

