SCRIPT_DIR="$(dirname "$(readlink -f "$0")")"

check_variables() {
    local error=0
    for var_name in "$@"; do
        if [ -z "${!var_name}" ]; then
            echo "Error: Variable '$var_name' is not set."
            error=1
        fi

    done
    if [ $error -eq 1 ]; then
        exit 1
    fi
}

check_host_exists() {
    if [[ ! -d "$SCRIPT_DIR/../NixDotfiles/hosts/${HOST_TO_INSTALL}" ]]
    then
        echo "ERROR: The specified host does not exist!"
        exit 1
    fi
}

check_root_pw() {
    if [ -z "$ROOT_PASSWORD" ]; then
        echo "Please set the ROOT_PASSWORD environment variable"
        exit 1
    fi
}

check_root_pw