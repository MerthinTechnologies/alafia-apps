#!/usr/bin/env bash

# Note to self 21-SEP-2023
# If this script needs to manage installs with any more complexity,
# it should be abandoned in favor of an actual installation system
# or package management tool. Look into https://makeself.io/

APP_DIR="./opt/alafia"
APP_PATTERN="alafia-*"

SERVICE_DIR="./etc/systemd/system"
SERVICE_PATTERN="alafia-*.service"

ICON_DIR="./usr/share/icons/hicolor"
ICON_PATTERN="alafia-*.png"

DESKTOP_DIR="./usr/share/applications"
DESKTOP_PATTERN="alafia-*.desktop"

BIN_DIR="./usr/bin"
BIN_PATTERN="alafia-*"

HOSTS_FILE="./etc/hosts"
HOSTS_PATTERN="\.alafia" # Gotta escape the dot for grep regex instead of glob expansion

check_root() {
  # Check if the script is run as root
  if [ "$EUID" -ne 0 ]; then
    echo "Error: This script must be run as root"
    exit 1
  fi
}

remove_line_with_pattern() {
  local FILE=$1
  local PATTERN=$2

  # Check if the file exists
  if [ ! -f "$FILE" ]; then
    echo "Error: File $FILE does not exist."
    return 1
  fi

  # Use grep to exclude lines that contain the pattern and save the result to a temporary file
  grep -v "$PATTERN" "$FILE" > "${FILE}.tmp"

  # Check if the temporary file is identical to the original file
  if cmp -s "$FILE" "${FILE}.tmp"; then
    echo "Pattern '$PATTERN' not found in $FILE."
    rm "${FILE}.tmp"  # Remove the temporary file as it is identical to the original
  else
    # Move the temporary file to overwrite the original file
    mv "${FILE}.tmp" "$FILE"
    echo "Lines containing pattern '$PATTERN' have been deleted from $FILE."
  fi
}

remove_pattern_from_dir() {
  local DIRECTORY=$1
  local PATTERN=$2
  local DEPTH=$3
  
  if [ -d "$DIRECTORY" ]; then
    local ITEMS=$(find $DIRECTORY -maxdepth $DEPTH -type f -name "$PATTERN" | sort)
    if [ -n "$ITEMS" ]; then
      for ITEM in $ITEMS; do
        echo "Removing $ITEM"
        #rm -f $unit
      done
    else
      echo "No files matching the pattern $PATTERN were found in $DIRECTORY. Nothing to remove."
    fi
  else
    echo "$SERVICE_DIR not found. Nothing to remove."
  fi
}



install_apps() {
  echo "Installing Alafia Apps"


SERVICE_DIR
SERVICE_PATTERN

ICON_DIR
ICON_PATTERN

DESKTOP_DIR
DESKTOP_PATTERN

BIN_DIR
BIN_PATTERN

$HOSTS_FILE
$HOSTS_PATTERN
  # Iterate through the items in the present directory
  # find apps in current directory that match PATTERN. Install them to DIR
  
 #TODO - this isn't finished yet

  local APP_DIRS=$(find ./* -maxdepth 1 -type d -name "$APP_PATTERN" | sort)

  for DIR in $APP_DIRS; do
  
    # Check if the item is a directory
    if [ -d "$DIR" ]; then
    
      # Get the base name of the directory and store path in a variable
      local APP_NAME="$(basename $DIR)"

      # Print or use the subdirectory variable as needed
      echo "  - $APP_NAME"
    fi
  done
}

uninstall_apps() {
  echo "Uninstalling Alafia Apps"
  
  if [ -d "$APP_DIR" ]; then
    echo "Removing entire app directory $APP_DIR"
    #rm -rf "$APP_DIR"
  else
    echo "App directory $APP_DIR not found. Nothing to remove."
  fi

  remove_pattern_from_dir $SERVICE_DIR $SERVICE_PATTERN 1
  remove_pattern_from_dir $ICON_DIR $ICON_PATTERN 3
  remove_pattern_from_dir $DESKTOP_DIR $DESKTOP_PATTERN 1
  remove_pattern_from_dir $BIN_DIR $BIN_PATTERN 1

  remove_line_with_pattern $HOSTS_FILE $HOSTS_PATTERN
}

# Initialize a variable to determine which function to run
run_install=true

check_root

# Iterate over the arguments
for arg in "$@"; do
  if [ "$arg" == "--uninstall" ]; then
    run_install=false
    break
  fi
done

# Check which function to run based on argument
if $run_install; then
  install_apps
else
  uninstall_apps
fi



