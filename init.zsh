change-directory::init() {
  typeset -r _directory_file="${HOME}/.cache/zsh-cd-history"
  if [ ! -f "$_directory_file" ]; then
    mkdir -p "$(dirname "$_directory_file")" && touch "$_directory_file"
  fi
}
