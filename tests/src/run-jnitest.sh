#!/bin/bash
#PBS -N spark_jnitest_env
#PBS -l nodes=2:ppn=1,vmem=6GB
#PBS -l walltime=0:30
#PBS -j oe
#PBS -o output/spark_jnitest_env.oe
#PBS -v SPARKHPC_ROOT

set -e

. ${SPARKHPC_ROOT}/load_spark.sh
. ${SPARKHPC_ROOT}/load_sparkhpc.sh


#PROVIDED LIBRARIES (that is installed on the cluster)

APP_JAR=${SPARKHPC_ROOT}/examples/core/target/tests-core_2.10-1.0.jar
APP_CLASSPATH=${SPARKHPC_ROOT}/examples/jni/target/tests-jni-1.0.jar

export SPARK_CLASSPATH=$APP_JAR:$APP_CLASSPATH:$OPENCV_JAR 
export SPARK_LIBRARY_PATH=${SPARKHPC_ROOT}/examples/jni-native/target
# SPARK_LIBRARY_PATH no longer works in spark 1.0.x. Need to pass LD_LIBRARY_PATH directly
export LD_LIBRARY_PATH=$SPARK_LIBRARY_PATH
export SPARK_JAVA_OPTS="-Dspark.hpc.test=value"
export SPARK_MEM="2048M"
export SPARKHPC_DRIVER_MEM="2048M"

spark-hpc.sh --url-env-var JniTestEnv ${SPARKHPC_ROOT}/examples/data/lady_of_shalott.txt


