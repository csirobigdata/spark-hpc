#!/bin/bash
#PBS -N spark_wordcount
#PBS -l nodes=2:ppn=2,vmem=1GB
#PBS -l walltime=0:30
#PBS -j oe
#PBS -o output/spark_wordcount.oe
#PBS -V 

set -e
export SPARKHPC_JAVA_CLASSPATH=${SPARKHPC_HOME}/tests/core/target/tests-core_2.10-1.0.jar
export SPARKHPC_DRIVER_CLASSPATH= 
export SPARKHPC_EXECUTOR_CLASSPATH=
export SPARKHPC_JAVA_LIBRARY_PATH=
export SPARKHPC_JAVA_OPTS="-Dspark.logConf="true""
export SPARKHPC_DRIVER_OPTS=""
export SPARKHPC_EXECUTOR_MEM="1G"
export SPARKHPC_DRIVER_MEM="1G"

${SPARKHPC_HOME}/bin/spark-hpc.sh --verbose WordCount ${SPARKHPC_HOME}/tests/data/lady_of_shalott.txt 

