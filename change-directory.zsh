
source "${0:A:h}/functions/directory.zsh"
source "${0:A:h}/functions/rating.zsh"
source "${0:A:h}/functions/proposal.zsh"
source "${0:A:h}/debug.zsh"
source "${0:A:h}/init.zsh"

# initialize global vars, cd-alias and files for plugin
change-directory::init

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
  local help_flag list_flag abs_path set_option_value

  zmodload zsh/zutil
  zparseopts -D -F -K -- \
    {h,-help}=help_flag \
    {c,-config}:=configuration \
    -set-:=set_option_value \
    {l,-list}=list_flag \
    {v,-verbose}=verbose \
    L=logical \
    P=physical ||
    return 1

  # call help printer
  if [ -n "$help_flag" ]; then
    change-directory::show_help
    return 0
  fi

  # call options setter
  if [ -n "$set_option_value" ]; then
    # remove the flag
    set_option_value=${set_option_value#--set-}

    # if not using '=' to assign value
    if [[ "$set_option_value" != *"="* ]]; then
      change-directory::set_option ${set_option_value%%=*} $1
    else
      change-directory::set_option ${set_option_value%%=*} ${set_option_value#*=}
    fi
    return 0
  fi

  local tokens=$@

  # call history list printer
  if [ -n "$list_flag" ]; then
    directory::show_list $tokens
    return 0
  fi

  # it the first argument contains slashes, the input is considered a path. any other argument will be ignored
  if [[ "$1" == *"/"* ]]; then
    abs_path="$(directory::realpath $1)"

  # if there is a second argument, the inputs are considered tokens
  elif [ "$2" ]; then
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

#######################################
# change-directory::set_option
# Description:
#   Set the value for a specified option in the change-directory settings.
# Globals:
#   _cd_settings : Global array containing change-directory settings.
#   funcfiletrace : The file trace of the current function.
# Arguments:
#   $1 : option_name - The name of the option to set.
#   $2 : new_value - The new value for the specified option.
# Outputs:
#   Echoes the updated change-directory settings array.
# Returns:
#   0 - Successful execution.
#######################################
function change-directory::set_option() {
  local option_name=${1##[[:space:]]}
  local new_value=${2##[[:space:]]}

  if [[ -n $_cd_settings[$option_name] ]]; then

    # store in global var
    _cd_settings[$option_name]=$new_value

    # store in file
    sed -i "s/^$option_name=.*/$option_name=$new_value/" "$(dirname ${funcfiletrace[1]})/config"
  else
    echo "The option '$option_name' does not exist."
  fi

  echo ${_cd_settings[*]}
  return 0 # Success
}

#######################################
# change-directory::show_help
# Description:
#   Display help information for the change-directory function.
#######################################
function change-directory::show_help() {
  echo "Usage: change-directory [OPTIONS] [PATH]"
  echo "Change the current working directory based on specified options and arguments."

  echo -e "\nOptions:"
  echo "  -h, --help                   Show this help message."
  echo "  -L                           Change the logical working directory."
  echo "  -P                           Change the physical working directory."
  echo "  -P                           Change the physical working directory."
  echo "  --set-<option> <value>       Change an option."
  echo "  -c, --config CONFIG          Specify a configuration file (default: ~/.zshrc)."
  echo "  -l, --list                   Display a list of directories along with their rating and last access timestamp."
  echo "  -v, --verbose                Enable verbose mode."

  echo -e "\nArguments:"
  echo "  PATH                         If it is the onnly argument, it is considered a path."
  echo "                               If there are multiple arguments, they are considered as tokens for constructing a path."
}
