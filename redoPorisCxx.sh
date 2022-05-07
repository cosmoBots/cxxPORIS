#!/bin/bash

# Working directory clean
# Set the clean environment variable
export PORIS_CLEAN=1

# Execute the doPorisDev.sh
cxxPORIS/doPorisCxx.sh $1 || { echo 'doPorisDev.py failed' ; exit 1; }
