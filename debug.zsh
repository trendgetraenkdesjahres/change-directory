#######################################
# debug::echo
# Description:
#   Echo a verbose message with function and file information if verbose or debugging is enabled.
# Globals:
#   verbose : Indicates whether verbose mode is enabled.
#   debug : Indicates whether debugging is enabled.
#   funcstack : The function call stack.
#   funcfiletrace : The file trace of the current function.
# Arguments:
#   $1 : message - The verbose message to echo.
# Outputs:
#   Echoes the verbose message if verbose or debugging is enabled.
# Returns:
#   None
#######################################
debug::echo() {
  local message=$1
  if [ -n "$verbose" || -n "$debug" ]; then
    print "v: '$message' [ by ${funcstack[-1]}() in '${funcfiletrace[1]}' ]"
  fi
}

#######################################
# debug::log
# Description:
#   Log a debug message with timestamp, function, and file information in the same directory as the calling function.
# Globals:
#   debug : Indicates whether debugging is enabled.
#   funcstack : The function call stack.
#   funcfiletrace : The file trace of the current function.
# Arguments:
#   $1 : message - The debug message to log.
# Outputs:
#   Appends the debug message to a debug log file if debugging is enabled.
# Returns:
#   None
#######################################
debug::log() {
  local message=$1
  if [ -n "$debug" ]; then
    print "$(date +%d.%m.%y-%H:%M:%S)\t'$message' [ by ${funcstack[-1]}() in '${funcfiletrace[1]}' ]" >>"$(dirname "${funcfiletrace[1]}")/debug.log"
  fi
}
