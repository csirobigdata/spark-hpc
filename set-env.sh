#!/bin/bash
# SPARK-HPC system wide config file
#
# This file should be modified by system admins to set default SPARKHPC_*
# environment variables, and can contain arbitrary bash code.
#
# This script is sourced by SPARK-HPC prior to the users configuration script,
# which can overwrite environment variables set here


# Set spark.local.dir, i.e. the location spark executors will use for spill and
# RDD files FOR THE JOB SOURCING THIS FILE!
# NOTE: Often node local for performance, can/should be a value specific to
#       the job (e.g. assigned by cluster manager)
export SPARKHPC_LOCAL_DIR=${LOCALDIR}

# Set scratch directory for SPARK-HPC to use.
# NOTE: Does not have to be job specific, SPARK_HPC will create additional job
#       specific subdirectories in scratch space
export SPARKHPC_SCRDIR=${FLUSHDIR}

# Set classpath required to run SPARK-HPC
#export SPARKHPC_CLASSPATH=

# Set classpath required to run driver application
#export SPARKHPC_DRIVER_CLASSPATH=


