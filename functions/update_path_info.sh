#######################################
# update_path_info
# Description:
#   Update the rating and timestamp of the specified path in a file.
# Arguments:
#   $1 : path - The path to update information for.
# Returns:
#   None
#######################################

export PATH="/usr/bin:/bin:$PATH"
update_path_info() {
    local path=$1

    local file grep_result index rating last_cd
    file="../test_file"

    # look for the path in the file
    grep_result=$(/usr/bin/grep -n "${path}[[:space:]]" "$file")

    # if it has not found the path in the file
    if [ ! "$grep_result" ]; then

        # add a new line of this path with rating of 1 and current timestamp
        echo "$path 1 $(date +%s)" >>"$file"
        return
    fi

    # Extracting the line number and path from the row as array
    read -ra row <<<"$grep_result"
    index=${row[0]%%:*} # Extracts everything before the first ':'
    rating=${row[1]}
    last_cd=${row[2]}

    # calculating the new rating
    rating=$(get_new_rating "$rating" "$last_cd")

    # updating the row with new rating and timestamp
    sed -i "${index}c $path $rating $(/usr/bin/date +%s)" "$file"
}
