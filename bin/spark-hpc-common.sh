
#########################################
# Error printing and logging functions

echoerr() { echo "$@" 1>&2; }
echolog() {
    if [[ "$1" == "-f" && "$2" != "" ]]; then
        LOG_FILE=$2
        shift 2
        echo "$@" >> $LOG_FILE
    elif [[ "$1" == "--stderr" ]]; then
        shift
        echoerr "$@"
    else
        echo "$@" >> /dev/null
    fi
}

