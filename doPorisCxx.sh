#!/bin/bash

if [ $# -eq 0 ]
  then
    echo "No arguments supplied"
    exit 1;
fi

FILE=./models/$1.ods
if test -f "$FILE"; then
    echo "Input $FILE exists, continuing"
else
    echo "Input $FILE does not exist, aborting"
    exit 1;
fi


if [ -z ${PORIS_SAFETY_OVERRIDE+x} ]; then 
    echo "PORIS_SAFETY_OVERRIDE is not set, checking repo is clean";
    if [ -z "$(git status --porcelain)" ]; then 
        echo "Welcome to doPorisCxx.sh"
    else 
        # Uncommitted changes
        echo "ERROR: YOUR REPOSITORY IS NOT CLEAN"
        echo "As executing this process can overwrite manual code"
        echo "you are encouraged to have commited/reverted any change"
        echo "in the repo so in case of loosing something you will have"
        echo "the opportunity to recover it (in case you commited it)"
        echo "or you will be the only responsible of having lost it "
        echo "(in case you reverted)."
        exit 1;
    fi
else
    echo "PORIS_SAFETY_OVERRIDE is set, skip checking repo is clean";
    echo "Welcome to doPorisCxx.sh"
fi

######### SAFETY AREA ############


########### USER CONFIGURATION AREA ##############

# Defining some environmental variables
# TODO: Convert them to arguments
# This will force the script to firstly clean every previous product
# PORIS_CLEAN=0

DEVBASE_PATH=`pwd`
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )"

########### INTERNAL VARIABLES CALCULATION AREA ##############

# Some "constants"
# The name of the device, get from the script first argument
DEVNAME=$1
# The path for the C++ base folder for the devices


# This is the folder for the PORIS tools path.
# Normally set to PORIS_TOOLS_CXX_PATH=${DEVBASE_CXX_PATH}/PORIS, but if you
# change DEVBASE_RELATIVE_PATH you might want to separate the link
# between the two variables
PORIS_TOOLS_PATH=${DEVBASE_PATH}/pyPORIS
PORIS_TOOLS_CXX_PATH=${SCRIPT_DIR}
echo "path"
echo ${PORIS_TOOLS_PATH}
echo ${PORIS_TOOLS_CXX_PATH}

# The path for the C++ base folder for the specific (user) custom code of the device
DEVBASE_USER_PATH=${DEVBASE_PATH}/output/cxx/${DEVNAME}_physical

########### WELCOME MESSAGE CALCULATION AREA ##############

echo "Welcome to C++ code generator por PORIS models"

######### CLEANING AREA ###############
# We will clean (or not) the products depending on PORIS_CLEAN variable
if [ -z ${PORIS_CLEAN+x} ]; then 
    echo "PORIS_CLEAN is not set, keeping already generated files";
    # We will have to preserve some files depending on PORISDEV_CLEAN variable
    echo "Preserve some previous files and removing the library directory";
    cp ${DEVBASE_PATH}/output/cxx/${DEVNAME}/${DEVNAME}PORIS.h .
    cp ${DEVBASE_PATH}/output/cxx/${DEVNAME}/${DEVNAME}PORIS.cpp .
    rm -rf ${DEVBASE_PATH}/output/cxx/${DEVNAME}
else
    echo "Cleaning previous generated products"
    rm -rf ${DEVBASE_PATH}/output/cxx/${DEVNAME}
fi

######### CREATING FOLDERS AREA ###############
# Let's create the product directories
mkdir -p ${DEVBASE_PATH}/output/cxx/${DEVNAME}

######### If no USER CUSTOM CODE FOLDER ADDED, COPY THE TEMPLATE ONE #############
echo "Checking the existence of ${DEVBASE_USER_PATH}"
if [ -d "$DEVBASE_USER_PATH" ]; then
  ### Take action if $DEVBASE_USER_PATH exists ###
  echo "${DEVBASE_USER_PATH} already present, nothing to do"
else
  ###  Control will jump here if $DEVBASE_USER_PATH does NOT exists ###
  echo "${DEVBASE_USER_PATH} not found. Copying template dir."
  cp -r ${PORIS_TOOLS_CXX_PATH}'/$S1_physical' ${DEVBASE_USER_PATH}

  mv ${DEVBASE_USER_PATH}'/$S1_physical.cpp' ${DEVBASE_USER_PATH}/${DEVNAME}_physical.cpp
  mv ${DEVBASE_USER_PATH}'/$S1_physical.h' ${DEVBASE_USER_PATH}/${DEVNAME}_physical.h

  sed -i "s/DEVICENAME/$1/g" ${DEVBASE_USER_PATH}/${DEVNAME}_physical.h
  sed -i "s/DEVICENAME/$1/g" ${DEVBASE_USER_PATH}/${DEVNAME}_physical.cpp
fi

######### PARSING THE MODEL AND GENERATING THE PORIS PRODUCTS ###############
cd ${DEVBASE_PATH}
if [ -z ${PORIS_CLEAN+x} ]; then 
    echo "PORIS_CLEAN is not set, bypassing poris2cxx.py";
    # We will have to recover the preserved files depending on PORISDEV_CLEAN variable
    mv _${DEVNAME}PORIS.h ${DEVBASE_PATH}/output/cxx/${DEVNAME}/
    mv ${DEVNAME}PORIS.cpp ${DEVBASE_PATH}/output/cxx/${DEVNAME}
else 
    echo "Generating the PORIS device products from $1.ods"
    python3 ${PORIS_TOOLS_PATH}/poris2xml.py models/$1.ods || { echo 'poris2cxx.py failed' ; exit 1; }
    echo "path"
    echo ${PORIS_TOOLS_CXX_PATH}
    python3 ${PORIS_TOOLS_CXX_PATH}/poris2cxx.py models/$1.ods || { echo 'poris2cxx.py failed' ; exit 1; }
fi

