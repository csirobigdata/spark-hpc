#!/bin/bash
#PBS -N spark_wordcount_env
#PBS -l nodes=2:ppn=2,vmem=5GB
#PBS -l walltime=0:30
#PBS -o output/spark_wordcount_env.o
#PBS -e output/spark_wordcount_env.e
#PBS -v SPARKHPC_ROOT

set -e

. ${SPARKHPC_ROOT}/load_spark.sh
. ${SPARKHPC_ROOT}/load_sparkhpc.sh

export SPARK_CLASSPATH=${SPARKHPC_ROOT}/examples/core/target/tests-core_2.10-1.0.jar
spark-hpc.sh --url-env-var WordCountEnv ${SPARKHPC_ROOT}/examples/data/lady_of_shalott.txt


