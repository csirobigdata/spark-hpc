#!/bin/bash
#PBS -N spark_wordcount
#PBS -l nodes=2:ppn=2,vmem=1GB
#PBS -l walltime=0:30
#PBS -j oe
#PBS -o output/spark_wordcount.oe
#PBS -v SPARKHPC_ROOT

set -e

. ${SPARKHPC_ROOT}/load_spark.sh
. ${SPARKHPC_ROOT}/load_sparkhpc.sh

export SPARK_CLASSPATH=${SPARKHPC_ROOT}/examples/core/target/tests-core_2.10-1.0.jar
spark-hpc.sh WordCount ${SPARKHPC_ROOT}/examples/data/lady_of_shalott.txt


