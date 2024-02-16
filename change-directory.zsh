alias cd='change-directory'
#######################################
# change-directory
# Description:
#   Change the current working directory based on specified options and arguments.
# Globals:
#   None
# Arguments:
#   Flags:
#     - -L : Change the logical working directory.
#     - -P : Change the physical working directory.
#   Other Arguments:
#     - $1 : If it contains slashes, it is considered a path.
#     - $2 and beyond: If present, considered as tokens for constructing a path.
# Outputs:
#   Echoes the current working directory after the change.
# Returns:
#   None
#######################################
function change-directory() {
    source functions/update_path_info.sh
    source functions/get_new_rating.sh

    local flags return_path

    # get the options
    while getopts "PL" opt; do
        case $opt in
        L) flags+=('logical') ;;
        P) flags+=('physical') ;;
        ?) echo "($0): Ein Fehler bei der Optionsangabe" ;;
        esac
    done

    # shift the arguments to remove the flags
    if [ "${flags[*]}" ]; then
        shift
    fi

    # it the first argument contains slashes, the input is considered a path. any other argument will be ignored
    if [[ "$1" == *"/"* ]]; then
        return_path="$1"

    # if there is a second argument, the inputs are considered tokens
    elif [ "$2" ]; then
        return_path=$(get_path "$@")

    # it the first argument is not in this directory, the input is considered a token
    elif [ ! -e "$1" ]; then
        return_path=$(get_path "$1")

    # default, run cd
    else
        return_path="$1"
    fi

    \cd "$return_path" && update_path_info "$return_path"

    echo "Now in: $(pwd)"
}
