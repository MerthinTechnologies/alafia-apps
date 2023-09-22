#!/usr/bin/env bash

# Define the URL and IP variables

#TODO: Needs to update variable names and get values of variables from args

check_root() {
  # Check if the script is run as root
  if [ "$EUID" -ne 0 ]; then
    echo "Error: This script must be run as root"
    exit 1
  fi
}

# Call the function to check if the user is root
check_root

# Check if the URL exists in /etc/hosts
if grep -q "$URL" /etc/hosts; then
    echo "$URL exists in /etc/hosts, deleting the old entry."
    # If the URL exists, delete the line containing the URL
    sed -i.bak "/$URL/d" /etc/hosts
else
    echo "URL does not exist in /etc/hosts."
fi

# Append the URL and IP to the end of /etc/hosts
echo "Appending new entry to /etc/hosts."
echo "$IP $URL" | tee -a /etc/hosts

echo "Done."

