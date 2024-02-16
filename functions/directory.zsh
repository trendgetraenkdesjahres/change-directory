#######################################
# directory::update # Description:
#   Update the rating and timestamp of the specified directory in a file.
# Arguments:
#   $1 : directory - The directory to update information for.
# Returns:
#   None
#######################################

directory::update() {
  local directory=$1

  local file grep_result index rating last_cd
  file="../test_file"

  # look for the directory in the file
  grep_result=$(/usr/bin/grep -n "${directory}[[:space:]]" "$file")

  # if it has not found the directory in the file
  if [ ! "$grep_result" ]; then

    # add a new line of this directory with rating of 1 and current timestamp
    echo "$directory 1 $(date +%s)" >>"$file"
    return
  fi

  # Extracting the line number and directory from the row as array
  read -rA row <<<"$grep_result"
  index=${row[0]%%:*} # Extracts everything before the first ':'
  rating=${row[1]}
  last_cd=${row[2]}

  # calculating the new rating
  rating=$(rating::get_new "$rating" "$last_cd")

  # updating the row with new rating and timestamp
  sed -i "${index}c $directory $rating $(/usr/bin/date +%s)" "$file"
}
