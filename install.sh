#!/bin/bash

# install.sh

# Exit immediately if a command exits with a non-zero status.
set -e

# Get the path to the current directory
DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

# Loop through each subdirectory in app-root
for d in "$DIR"/*/ ; do
    # Enter the directory
    cd "$d"
    echo "Entering directory $d"

    # Check if Makefile exists
    if [ -f Makefile ]; then
        # Run make and make install
        make
        make install
    else
        echo "No Makefile found in $d"
    fi

    # Go back to the app-root directory
    cd "$DIR"
done

echo "Installation complete."

