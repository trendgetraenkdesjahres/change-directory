alias cd='change-directory'
source "${0:A:h}/functions/directory.zsh"
source "${0:A:h}/functions/rating.zsh"
source "${0:A:h}/functions/proposal.zsh"
source "${0:A:h}/init.zsh"
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

# TODO was passiert hier?
# tower22win:plugins (version2*) $ cd fabian .cache
# cd: no such file or directory: /home/.cache/.oh-my-zsh-custom/plugins
# TODO was passiert hier?
# tower22win:/var $ cd home fabian
# cd: string not in pwd: home
# TODO wenn als plugin geladen geht die pfad nicht
# TODO wieso gab es einen leeren pfad in der datei?
# TODO logik bei nur einem token - wann automatik, wann fehler?

function change-directory() {
  change-directory::init
  local flags abs_path

  # get the options
  while getopts "hPL" opt; do
    case $opt in
    h) change-directory::show_help && return 0 ;;
    L) flags+=('logical') ;;
    P) flags+=('physical') ;;
    ?) echo "($0): Invalid Option.\n" $(change-directory::show_help) ;;
    esac
  done

  # shift the arguments to remove the flags
  if [ "${flags[*]}" ]; then
    shift
  fi

  # it the first argument contains slashes, the input is considered a path. any other argument will be ignored
  if [[ "$1" == *"/"* ]]; then
    abs_path="$(directory::realpath $1)"

  # if there is a second argument, the inputs are considered tokens
  elif [ "$2" ]; then
    local tokens=$@
    abs_path=$(proposal::get $tokens)

  # it the first argument is not in this directory, the input is considered a token ???
  elif [ ! -e "$1" ]; then
    abs_path=$(proposal::get "$1")

  # default
  else
    abs_path="$(directory::realpath $1)"
  fi
  # execute build-in cd with calculated path and update the information about the path or forget the info about the path on fail
  \cd "$abs_path" && directory::update "$abs_path" || directory::forget "$abs_path"

  echo "Now in: $(pwd)"
}

function change-directory::show_help() {
  echo "Usage: change-directory [OPTIONS] [PATH]"
  echo "Change the current working directory based on specified options and arguments."
  echo "Options:"
  echo "  -h, --help    Show this help message."
  echo "  -L            Change the logical working directory."
  echo "  -P            Change the physical working directory."
  echo "Arguments:"
  echo "  PATH          If it contains slashes, it is considered a path. If not, it is considered as token."
  echo "                If there are multiple arguments, they are considered as tokens for constructing a path."
}
