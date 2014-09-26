echo "NOTE: needs to be run from the root dir of your copy of spark-hpc"
export SPARKHPC_HOME="$(pwd)"
echo "Setting SPARKHPC_HOME to: ${SPARKHPC_HOME}"
export PATH=${SPARKHPC_HOME}/bin:$PATH

if [[ -n "$1" ]]; then
	echo "Loading extra configuration from: $1"
	source $1
fi
