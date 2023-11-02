#!/bin/bash

# Script to add or remove an IP-hostname pair from /etc/hosts

# Ensure the script is run with superuser privileges
if [[ $EUID -ne 0 ]]; then
  echo "This script must be run as root" 1>&2
  exit 1
fi

# Ensure exactly three arguments are provided
if [ "$#" -ne 3 ]; then
  echo "Usage: $0 <ip-address> <hostname> <add|remove>" 1>&2
  exit 1
fi

IP_ADDRESS=$1
HOSTNAME=$2
COMMAND=$3
HOSTS_FILE="/etc/hosts"
ENTRY="$IP_ADDRESS $HOSTNAME"

# Function to add the IP-hostname pair
add_entry() {
  if grep -q "$ENTRY" "$HOSTS_FILE"; then
    echo "Entry '$ENTRY' already exists in $HOSTS_FILE"
  else
    echo "$ENTRY" >> "$HOSTS_FILE"
    echo "Entry '$ENTRY' added to $HOSTS_FILE"
  fi
}

# Function to remove the IP-hostname pair
remove_entry() {
  if grep -q "$ENTRY" "$HOSTS_FILE"; then
    sed -i "/$ENTRY/d" "$HOSTS_FILE"
    echo "Entry '$ENTRY' removed from $HOSTS_FILE"
  else
    echo "Entry '$ENTRY' does not exist in $HOSTS_FILE"
  fi
}

# Determine whether to add or remove the entry
case $COMMAND in
  add)
    add_entry
    ;;
  remove)
    remove_entry
    ;;
  *)
    echo "Invalid command: $COMMAND. Use 'add' or 'remove'." 1>&2
    exit 1
    ;;
esac

