#!/bin/bash

# Working directory clean
# Set the clean environment variable
export PORIS_CLEAN=1

SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )"

# Execute the doPorisCxx.sh
$SCRIPT_DIR/doPorisCxx.sh $1 || { echo 'doPorisCxx.sh failed' ; exit 1; }
