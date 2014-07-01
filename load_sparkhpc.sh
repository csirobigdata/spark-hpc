if [[ -z "$SPARKHPC_ROOT" ]]; then
    echo "SPARKHPC_ROOT undefined ... set-dev-env.sh or other means to set it"
    exit 1
fi
export SPARKHPC_HOME=${SPARKHPC_ROOT}
export PATH=${PATH}:${SPARKHPC_HOME}/bin

if [[ -r "${HOME}/.spark-hpc/load_openmpi.sh" ]]; then
        echo "Loading openmpi from: ${HOME}/.spark-hpc/load_openpmi.sh"
        source ${HOME}/.spark-hpc/load_openpmi.sh
else
	module load openmpi
fi

