#!/bin/bash
#PBS -N spark_jnitest_env
#PBS -l nodes=2:ppn=1,vmem=6GB
#PBS -l walltime=0:30
#PBS -j oe
#PBS -o output/spark_jnitest_env.oe
#PBS -V 

set -e

export SPARKHPC_JAVA_CLASSPATH=${SPARKHPC_HOME}/tests/core/target/tests-core_2.10-1.0.jar:${SPARKHPC_HOME}/tests/jni/target/tests-jni-1.0.jar
export SPARKHPC_DRIVER_CLASSPATH=/home/szu004/dev/spark-hpc/tests/log4j 
export SPARKHPC_EXECUTOR_CLASSPATH=
export SPARKHPC_JAVA_LIBRARY_PATH=/home/szu004/dev/spark-hpc/tests/jni-native/target
export SPARKHPC_JAVA_OPTS="-Dspark.hpc.test="value""
export SPARKHPC_DRIVER_OPTS=""
export SPARKHPC_EXECUTOR_MEM="2G"
export SPARKHPC_DRIVER_MEM="2G"

${SPARKHPC_HOME}/bin/spark-hpc.sh --verbose JniTest /home/szu004/dev/spark-hpc/tests/data/lady_of_shalott.txt 

