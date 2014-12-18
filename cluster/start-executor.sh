#!/bin/bash

source ${SPARKHPC_HOME}/bin/spark-hpc-common.sh

echolog ${LOG_TO_FILE} "))))))))))))))))))))))))))))))))))))))))))"
echolog ${LOG_TO_FILE} "))))) Bootstraping executor at host: ${HOSTNAME} proc: $$"
echo

EXECUTOR_TAG="${HOSTNAME}:$$"

echolog ${LOG_TO_FILE} "TMPDIR: ${TMPDIR}"
echolog ${LOG_TO_FILE} "SPARKHPC_EXECUTOR_CLASSPATH: $SPARKHPC_EXECUTOR_CLASSPATH"
echolog ${LOG_TO_FILE} "SPARKHPC_COMMFILE: ${SPARKHPC_COMM_FILE}"
echolog ${LOG_TO_FILE} "SPARK_HOME ${SPARK_HOME}"
echolog ${LOG_TO_FILE} "))))))))))))))))))))))))))))))))))))))))))"

echolog ${LOG_TO_FILE} "))))) ${EXECUTOR_TAG}: Waiting for comfile: ${SPARKHPC_COMM_FILE}" 

for i in {1..20} ; do
    ls ${SPARKHPC_RUNDIR} > /dev/null #seems to be necessary to refesh -f checkt
    [[ -f "${SPARKHPC_COMM_FILE}" ]] && break
    DATE=`date`
    sleep 1
done

if  [[ ! -f "${SPARKHPC_COMM_FILE}" ]] ; then
    MSG="))))) ${EXECUTOR_TAG}: Timed out while waiting for the file: ${SPARKHPC_COMM_FILE}"
    echolog ${LOG_TO_FILE} ${MSG}
    echoerr ${MSG}
    exit 1
fi

export SPARK_EXECUTOR_OPTS="$SPARKHPC_JAVA_OPTS $SPARKHPC_EXECUTOR_OPTS"
export SPARK_CLASSPATH="$SPARKHPC_JAVA_CLASSPATH:$SPARKHPC_EXECUTOR_CLASSPATH"

#Setting up jvm heap size 
if [[ -n "${SPARKHPC_EXECUTOR_MEM}" ]]; then
  export SPARK_EXECUTOR_MEMORY="${SPARKHPC_EXECUTOR_MEM}"
fi

echolog ${LOG_TO_FILE} ")))))))))) SPARK EXECUTOR ENV: "
echolog ${LOG_TO_FILE} "SPARK_HOME: ${SPARK_HOME}"
echolog ${LOG_TO_FILE} "SPARK_CLASSPATH: ${SPARK_CLASSPATH}"
echolog ${LOG_TO_FILE} "SPARK_EXECUTOR_OPTS:  ${SPARK_EXECUTOR_OPTS}"
echolog ${LOG_TO_FILE} "))))))))))))))))))))))))))))))))))))))))))"


TMPVAR=`strings ${SPARKHPC_COMM_FILE} | head -n1`
DRIVER_URL=${TMPVAR:1}
CORES=1
if [[ -n "${PBS_NUM_PPN}" ]]; then 
  CORES=${PBS_NUM_PPN}
fi
CORES_AT_THIS_NODE=1
if [[ -n "${SPARKHPC_NODEFILE}" ]]; then
  CORES_AT_THIS_NODE=`grep ${HOSTNAME} ${SPARKHPC_NODEFILE} | wc -l`
  CORES=${CORES_AT_THIS_NODE}
fi
#
# TODO: This combines all the cores allocated on this host starst one executor for all cores.
# the better way would be to optionally allow to start muliple executors with allocated number of cores
#
NO_OF_EXECUTORS=${CORES_AT_THIS_NODE}
CORES=1
#NO_OF_EXECUTORS=$((${CORES_AT_THIS_NODE}/${CORES}))
echolog ${LOG_TO_FILE} "))))) ${EXECUTOR_TAG}: ${CORES_AT_THIS_NODE} cores at this node, starting ${NO_OF_EXECUTORS} executors (${CORES} cores  each)"

#CORES=${CORES_AT_THIS_NODE}
for i in $(seq 1 ${NO_OF_EXECUTORS} ); do 
    EXECUTOR_NAME="executor-${HOSTNAME}-$$-$i"
    echolog ${LOG_TO_FILE} "))))))) Starting executor: ${EXECUTOR_NAME} for: ${DRIVER_URL} with: ${CORES} cores"
    echolog ${LOG_TO_FILE} "))))))) CMD: org.apache.spark.executor.CoarseGrainedExecutorBackend ${DRIVER_URL} ${EXECUTOR_NAME} ${HOSTNAME} ${CORES}"
    ${SPARK_HOME}/bin/spark-class \
    org.apache.spark.executor.CoarseGrainedExecutorBackend ${DRIVER_URL} ${EXECUTOR_NAME} ${HOSTNAME} ${CORES} & 
done
