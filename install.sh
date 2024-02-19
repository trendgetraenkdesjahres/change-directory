#!/bin/bash

if [ -n "$ZSH_CUSTOM" ]; then
  INSTALL_DIR="$ZSH_CUSTOM/plugins/change-directory"
elif [ -n "$ZSH" ]; then
  INSTALL_DIR="$ZSH/plugins/change-directory"
else
  echo "Uable to get zsh-directory from \$ZSH for cloning the plugin."
  return 1
fi

echo "Installing change-directory plugin..."

# Create the installation directory if it doesn't exist
mkdir -p "$INSTALL_DIR"

# Clone the repository
git clone -b main https://github.com/trendgetraenkdesjahres/change-directory.git "$INSTALL_DIR"

echo "Change-directory plugin installed successfully!"

# Manipulate the plugins variable in .zshrc
ZSHRC="$HOME/.zshrc"
PLUGIN_NAME="change-directory-plugin"

# Get the current plugins line
CURRENT_PLUGINS=$(grep -zoP 'plugins=\(((.|\n)*?)\)' "$ZSHRC")

# Check if the plugin is already present in the current plugins
if grep -q "$PLUGIN_NAME" <<<"$CURRENT_PLUGINS"; then
  echo "Plugin already present in .zshrc file"
else
  # Create an array from the current plugins line
  IFS=$'\n' read -rd '' -a plugins_array <<<"$CURRENT_PLUGINS"

  # Determine the separator used in the original line
  SEPARATOR=""
  if [[ "${plugins_array[0]}" == *$'\n'* ]]; then
    SEPARATOR=$'\n'
  else
    SEPARATOR=" "
  fi

  # Add the new plugin to the array
  plugins_array+=("$PLUGIN_NAME")

  # Join the array elements with the stored separator
  new_plugins_line=$(
    IFS="$SEPARATOR"
    echo "${plugins_array[*]}"
  )

  # Replace the old plugins line with the new one
  sed -i "s|$CURRENT_PLUGINS|$new_plugins_line|" "$ZSHRC"

  echo "Plugin added to .zshrc file"
fi
