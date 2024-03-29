change-directory::init() {
  # define path for history file
  typeset -gr _cd_history_file="${HOME}/.cache/zsh-cd-history"

  # create file if not existing yet
  if [ ! -f "$_cd_history_file" ]; then
    mkdir -p "$(dirname "$_cd_history_file")" && touch "$_cd_history_file"
  fi

  # If settings array is not initialized yet
  if [ -z $_cd_settings ]; then
    typeset -gA _cd_settings
    local file=$(dirname ${funcfiletrace[1]})/config

    # Read lines from file into settings array
    while IFS= read -r line; do
      # Check if the line contains an equal sign
      if [[ "$line" != *"="* ]]; then
        echo "Error: Invalid line in config file."
        exit 1
      fi

      # Split line into key and value
      IFS='=' read -r key value <<<"$line"

      # Remove leading and trailing whitespace from key and value
      key=${key##[[:space:]]}
      key=${key%%[[:space:]]}
      value=${value##[[:space:]]}
      value=${value%%[[:space:]]}

      # Assign key-value pairs to the settings array
      _cd_settings[$key]=$value
    done <"$file"
  fi
}
