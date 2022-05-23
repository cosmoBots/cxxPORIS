#!/bin/bash

# Working directory clean
# Set the clean environment variable
export PORIS_CLEAN=1

# Execute the doPorisCxx.sh
cxxPORIS/doPorisCxx.sh $1 || { echo 'doPorisCxx.sh failed' ; exit 1; }
