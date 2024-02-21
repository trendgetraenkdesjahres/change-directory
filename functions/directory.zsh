#######################################
# directory::update # Description:
#   Update the rating and timestamp of the specified directory in a file.
# Globals:
#   _cd_history_file : The file containing directory information.
# Arguments:
#   $1 : directory - The directory to update information for.
# Returns:
#   None
#######################################
directory::update() {
    typeset -r _cd_history_file="${HOME}/.cache/zsh-cd-history"
    # declaring readonlys for the desired directory
    typeset -r directory="$1"

    # look for the directory in the file
    local grep_result=$(grep -n "${directory}[[:space:]]" "${_cd_history_file}")

    # if it has not found the directory in the file
    # add a new line of this directory with rating of 1 and current timestamp and exit the function
    if [ -z "$grep_result" ]; then
        print "path not found in file\n"
        echo "$directory 1 $(date +%s)" >>"${_cd_history_file}"
        return
    fi

    # Extracting the line number and directory from the row as array
    read -rA row <<<"$grep_result"
    typeset -ri index="${row[1]%%:*}" # Extracts everything before the first ':'
    typeset -ri last_cd="${row[3]}"
    typeset -i rating="${row[2]}"

    # calculating the new rating
    rating=$(rating::get_new "$rating" "$last_cd")

    # updating the row with new rating and timestamp
    sed -i "${index}c $directory $rating $(date +%s)" "${_cd_history_file}"
}

#######################################
# directory::forget
# Description:
#   Delete information about the specified directory from a file.
# Globals:
#   _cd_history_file : The file containing directory information.
# Arguments:
#   $1 : directory - The directory to forget.
# Outputs:
#   None
# Returns:
#   None
#######################################
directory::forget() {
    typeset -r _cd_history_file="${HOME}/.cache/zsh-cd-history"
    # declaring readonlys for the desired directory
    typeset -r directory="$1"

    # delete that line
    sed -i "\|${directory}|d" "${_cd_history_file}"
}

#######################################
# directory::realpath
# Description:
#   Get the canonicalized absolute pathname of the specified directory.
# Globals:
#   None
# Arguments:
#   $1 : directory - The directory to get the realpath for.
# Outputs:
#   Echoes the canonicalized absolute pathname of the directory.
#######################################
directory::realpath() {
    typeset -r directory="$(readlink -f "$1")"
    echo $directory
}

#######################################
# directory::show_list
# Description:
#   Display a list of directories along with their rating and last access timestamp.
# Globals:
#   HOME : The user's home directory.
#   _cd_history_file : The file containing directory information.
# Arguments:
#   $1 : tokens - Tokens to filter directories in the list (optional).
# Outputs:
#   Echoes a formatted list of directories, their rating, and last access timestamp.
# Returns:
#   0 - Successful execution.
#######################################
directory::show_list() {
    typeset -r _cd_history_file="${HOME}/.cache/zsh-cd-history"
    # get the tokens param
    local tokens=()
    read -r -A tokens <<<"$1"

    # current working dir
    local current_location=$(pwd)

    # regex
    regex=$(
        IFS=\|
        echo "${tokens[*]}"
    )

    # when argument, show whole file
    if [[ -z $tokens ]]; then
        list=$(sort -k2 -nr "$_cd_history_file")
    else
        list=$(grep -E --color=always "($regex)" "${_cd_history_file}")
    fi
    echo $list | sort -k2 -nr | awk 'BEGIN {print "Directory Rating Date"} {print $1, $2, strftime("%Y-%m-%d %H:%M:%S", $3)}' | column -t -s ' '
    return 0
}
