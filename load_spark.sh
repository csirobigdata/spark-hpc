#!/bin/bash

if [[ -r "${HOME}/.spark-hpc/load_spark.sh" ]]; then
 	echo "Loading spark from: ${HOME}/.spark-hpc/load_spark.sh"
	source ${HOME}/.spark-hpc/load_spark.sh
else
	module load jdk
	module load spark
fi

echo "JAVA_HOME: ${JAVA_HOME}"
echo "SPARK_HOME: ${SPARK_HOME}"
