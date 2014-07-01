#!/bin/bash
#PBS -N spark_parallel_sleep
#PBS -l nodes=4:ppn=2,vmem=3GB
#PBS -l walltime=2:00
#PBS -j oe
#PBS -o output/run_parallel_sleep.oe
#PBS -v SPARKHPC_ROOT

set -e

. ${SPARKHPC_ROOT}/load_spark.sh
. ${SPARKHPC_ROOT}/load_sparkhpc.sh

export SPARK_CLASSPATH=${SPARKHPC_ROOT}/examples/core/target/tests-core_2.10-1.0.jar
spark-hpc.sh ParallelSleep 8

