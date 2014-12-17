#!/bin/bash

source ${SPARKHPC_HOME}/bin/spark-hpc-common.sh

#########################################
# Usage information

read -d '' USAGE << EOF
usage: ${0##*/} [options] <class> [args]
       ${0##*/} [options] --shell [spark_shell_args]

Runs a parallel Spark application implemented in
"class" with commandline arguments "args".

options:
    General

    -s|--shell      Run driver as REPL interactive shell, spark_shell_args
                    are arguments passed directly through to spark-shell
                    (see spark-shell usage information for valid arguements)

    --url-env-var   Pass driver url to application via MASTER environment
                    variable instead of first commandline argument (default
                    for --shell)

    -h|--help       This help message

    -v|--verbose    Turn on spark-hpc logging output to stderr

    --spark-hpc-log=file
                    Redirect spark-hpc logging to "file" (implies -v)

    Spark Properties

    --force-local-dir
                    Forces user overwrite of spark.local.dir java system
                    property set via SPARKHPC_LOCAL_DIR environment variable or
                    by adding "-Dspark.local.dir=value" in SPARK_JAVA_OPTS or
                    SPARK_EXECUTOR_OPTS.
EOF


############################################
# Check required env var SPARK_HOME

if [[ -z "$SPARK_HOME" ]]; then
    echoerr "ERROR: Required environment variable SPARK_HOME is not defined"
    exit 1
fi


############################################
# Check required env var SPARKHPC_HOME

if [[ -z "$SPARKHPC_HOME" ]]; then
    echoerr "ERROR: Required environment variable SPARKHPC_HOME is not defined"
    exit 1
fi
if [[ ! -d "$SPARKHPC_HOME" ]]; then
    echoerr "ERROR: Cannot find directory \"${SPARKHPC_HOME}\" defined in environment variable SPARKHPC_HOME"
    exit 1;
fi


############################################
# Load config files and modules to set the
# appropriate variables

# Load site config
if [[ -f "${SPARKHPC_HOME}/conf/set-env.sh" ]] ; then
  source ${SPARKHPC_HOME}/conf/set-env.sh
fi

# Save the admin/site version of SPARKHPC_LOCAL_DIR
# for later checking
SITE_SPARKHPC_LOCAL_DIR=$SPARKHPC_LOCAL_DIR

# Load users config
if [[ -f "${HOME}/.spark-hpc/set-env.sh" ]] ; then
  source ${HOME}/.spark-hpc/set-env.sh
fi

################################################
# Command line parsing

OPTS=`getopt -o "+shv" -l "shell,url-env-var,help,verbose,spark-hpc-log:,log4j-configuration:,force-local-dir" -- "$@"`
if [ $? -ne 0 ]; then
  echoerr "$USAGE"
  exit 1
fi
eval set -- "$OPTS"
while true; do
  case "$1" in
    -s|--shell)
      RUN_SHELL='TRUE'
      shift;;
    --url-env-var)
      DRIVER_URL_VIA_ENV='TRUE'
      shift;;
    -h|--help)
      echoerr "$USAGE"
      exit 0;;
    -v|--verbose)
      LOG_TO_FILE="--stderr"
      shift;;
    --spark-hpc-log)
      LOG_TO_FILE="-f ${2}"
      shift 2;;
    --log4j-configuration)
      LOG4J_CONF="${2}"
      shift 2;;
    --force-local-dir)
      FORCE_LOCAL_DIR='TRUE'
      shift;;
    --)
      shift
      break;;
  esac
done

# Set default for LOG_TO_FILE
export LOG_TO_FILE=${LOG_TO_FILE:-""}
LOG4J_CONF=${LOG4J_CONF:-""}

##################################################
# Error checking a usage warnings

# Check that a class has been specified in appropriate situations
if [[ "$RUN_SHELL" != "TRUE" && -z "$1" ]]; then
    echoerr "ERROR: application class <class> must be specified for non-interactive execution modes"
    echoerr ""
    echoerr "$USAGE"
    exit 1
fi

# Check whether user set spark.local.dir in SPARK_JAVA_OPTS or SPARK_EXECUTOR_OPTS
# NOTE: we only check these two env vars, as spark-hpc does not YET invoke paths
#       through spark-class that utilise other options
# 1) First see if any -Dspark.local.dir is gobbled by matching "s
LOCAL_DIR_IN_JAVA_OPTS=$(echo "${SPARK_JAVA_OPTS} ${SPARK_EXECUTOR_OPTS}" | sed 's/"[^"]*"/""/g' | grep '\-Dspark\.local\.dir')
if [[ -n "$LOCAL_DIR_IN_JAVA_OPTS" ]]; then
    # 2) if not get the full -Dspark.local.dir=value string
    LOCAL_DIR_IN_JAVA_OPTS=$(echo "${SPARK_JAVA_OPTS} ${SPARK_EXECUTOR_OPTS}" | sed -n 's/.*\(-Dspark\.local\.dir=\)\("[^"]*"\|[^"][^" ]*\).*/\1\2/gp')
fi


# If the user has not confirmed overwrite of spark.local.dir with
# --force-local-dir, then run check for the attempt and warn them
if [[ -z "$FORCE_LOCAL_DIR" ]]; then

    # If the user has set a value for SPARKHPC_LOCAL_DIR or
    # spark.local.dir anywhere, warn them of ramifications
    if [[ -n "$LOCAL_DIR_IN_JAVA_OPTS" || "$SITE_SPARKHPC_LOCAL_DIR" != "$SPARKHPC_LOCAL_DIR" ]]; then
        if [[ -n "$LOCAL_DIR_IN_JAVA_OPTS" ]]; then
            SPECIFIED_WHERE="SPARK_JAVA_OPTS or SPARK_EXECUTOR_OPTS"
            SPECIFIED_AS=$LOCAL_DIR_IN_JAVA_OPTS
        fi
        SPECIFIED_WHERE=${SPECIFIED_WHERE:-SPARKHPC_LOCAL_DIR}
        SPECIFIED_AS=${SPECIFIED_AS:-$SPARKHPC_LOCAL_DIR}

        echoerr "ERROR: User has overwritten spark.local.dir site default to ${SPECIFIED_AS} in ${SPECIFIED_WHERE}"
        echoerr "       Site policies or conventions could be in place for jobs' usage of  node local storage on cluster."
        echoerr "       Misuse of node local storage can adversely effect nodes."
        echoerr ""
        echoerr "       Use the spark-hpc.sh --force-local-dir option to force user overwrite of spark.local.dir value"

        exit 1

    fi
fi

######################################################
# Start preparing SPARK-HPC working files and env vars

# If -Dspark.local.dir is not already defined in
# SPARK_JAVA_OPTS or SPARK_EXECUTOR_OPTS then add it
if [[ ! -n "$LOCAL_DIR_IN_JAVA_OPTS" ]]; then
    # Set the path of spark.local.dir to that defined by
    # SPARKHPC_LOCAL_DIR, otherwise default to ${LOCALDIR}
    SPARKHPC_LOCAL_DIR=${SPARKHPC_LOCAL_DIR:-$LOCALDIR}
    SPARK_JAVA_OPTS="${SPARK_JAVA_OPTS} -Dspark.local.dir=${SPARKHPC_LOCAL_DIR}"
fi

# If a log4j config file was specified and exists
if [[ -f "$LOG4J_CONF" ]]; then
    # Append the current working directory path if it
    # is not already an absolute path
    if [[ "$LOG4J_CONF" != /* ]]; then
        LOG4J_CONF="${PWD}/${LOG4J_CONF}"
    fi
    SPARK_JAVA_OPTS="${SPARK_JAVA_OPTS} -Dlog4j.configuration=file://${LOG4J_CONF}"
fi
export SPARK_JAVA_OPTS


#JAVA mem
export SPARKHPC_DRIVER_MEM=${SPARKHPC_DRIVER_MEM:-$SPARK_MEM}
export SPARKHPC_EXECUTOR_MEM=${SPARKHPC_EXECUTOR_MEM:-$SPARK_MEM}

#Create a global scratch directory for this job, default to FLUSHDIR if
# appropriate env vars not set
SPARKHPC_SCRDIR=${SPARKHPC_SCRDIR:-${FLUSHDIR}}/.sparkhpc
if [[ ! -d ${SPARKHPC_SCRDIR} ]]; then
    mkdir ${SPARKHPC_SCRDIR}
fi
export SPARKHPC_RUNDIR=$(mktemp -d --tmpdir=${SPARKHPC_SCRDIR} job.${PBS_JOBID:-$$}.XXXXXX)

# If a PBS_NODEFILE has been specified, copy it
# to the scratch directory
if [[ -n "${PBS_NODEFILE}" ]] ; then
  export SPARKHPC_NODEFILE=${SPARKHPC_RUNDIR}/nodefile
  cp ${PBS_NODEFILE}  ${SPARKHPC_NODEFILE}
fi

# Construct SIMR communications file and drive URL
export SPARKHPC_COMM_FILE=${SPARKHPC_RUNDIR}/commfile
SPARKHPC_DRIVER_URL="simr://${SPARKHPC_COMM_FILE}"

####################################################
# Start launching Executors

echolog ${LOG_TO_FILE} ">>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>"

echolog ${LOG_TO_FILE} "DRIVER_URL: ${SPARKHPC_DRIVER_URL}"

echolog ${LOG_TO_FILE} "Starting executors"

mpirun --pernode ${SPARKHPC_HOME}/cluster/start-executor.sh &

####################################################
export SPARK_SUBMIT_CLASSPATH=$SPARKHPC_DRIVER_CLASSPATH

echolog ${LOG_TO_FILE} ">>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>"
echolog ${LOG_TO_FILE} ">>  SPARKHPC_DRIVER_CLASSPATH: ${SPARKHPC_DRIVER_CLASSPATH}"
echolog ${LOG_TO_FILE} ">>  PWD: ${PWD}"


# Launching Driver
if [[ -n "${SPARKHPC_DRIVER_MEM}" ]]; then
  export SPARK_DRIVER_MEMORY="${SPARKHPC_DRIVER_MEM}"
fi

if [[ "$RUN_SHELL" == "TRUE" ]]; then
  # Code for running spark driver as an interactive
  # shell 
  export MASTER=${SPARKHPC_DRIVER_URL}
  export CLASSNAME=org.apache.spark.repl.Main
  SPARK_JAVA_OPTS="${SPARK_JAVA_OPTS} -Dspark.master=${SPARKHPC_DRIVER_URL} -Dspark.app.name=${PBS_JOBNAME}-Spark"
  export SPARK_JAVA_OPTS
  ${SPARK_HOME}/bin/spark-class org.apache.spark.repl.Main 
elif [[ "$DRIVER_URL_VIA_ENV" == "TRUE" ]]; then
  # Code for running spark driver where driver URL
  # is read from environment variable
  export MASTER=${SPARKHPC_DRIVER_URL}
  SPARK_JAVA_OPTS="${SPARK_JAVA_OPTS} -Dspark.master=${SPARKHPC_DRIVER_URL} -Dspark.app.name=${PBS_JOBNAME}-Spark"
  export SPARK_JAVA_OPTS
  ${SPARK_HOME}/bin/spark-class $@
else
  CLASSNAME=$1
  shift
  ${SPARK_HOME}/bin/spark-class $CLASSNAME $SPARKHPC_DRIVER_URL $@
fi

rm -rf ${SPARKHPC_RUNDIR}
echolog ${LOG_TO_FILE} "<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<"

