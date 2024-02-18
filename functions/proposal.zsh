function proposal::get() {
  typeset -r _directory_file="${HOME}/.cache/zsh-cd-history"
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
  last_token="${tokens[-1]}[[:space:]]"
  shift -p tokens
  regex_without_last_token=$(
    IFS=\|
    echo "${tokens[*]}"
  )

  # get matches starting with $current location AND last token ending with a whitespace and sort by rating
  from_current_dir=$(grep -E "$current_location/.*(${regex_without_last_token}).*$last_token)" "${_directory_file}" | sort -k2 -nr | awk NF)
  if [[ -n ${from_current_dir[1]} ]]; then
    result=$(echo "$from_current_dir" | awk 'NR==1 {print $1}')
    echo $result
    return 0
  fi

  # get matches starting with $current location and sort by rating
  from_current_dir=$(grep -E "$current_location/(${regex})" "${_directory_file}" | sort -k2 -nr | awk NF)
  if [[ -n ${from_current_dir[1]} ]]; then
    result=$(echo "$from_current_dir" | awk 'NR==1 {print $1}')
    echo $result
    return 0
  fi

  # get matches starting of globally AND last token ending with a whitespace and sort by rating
  from_root_dir=$(grep -E "(${regex_without_last_token}).*$last_token" "${_directory_file}" | sort -k2 -nr | awk NF)
  if [[ -n ${from_root_dir[1]} ]]; then
    result=$(echo "$from_root_dir" | awk 'NR==1 {print $1}')
    echo $result
    return 0
  fi

  # get matches starting of globally and sort by rating
  from_root_dir=$(grep -E "${regex}" "${_directory_file}" | sort -k2 -nr | awk NF)
  if [[ -n ${from_root_dir[1]} ]]; then
    result=$(echo "$from_root_dir" | awk 'NR==1 {print $1}')
    echo $result
    return 0
  fi

  echo "no such file or directory: ${tokens[*]}"
  exit 1
  return 1
}
