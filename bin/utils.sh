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
