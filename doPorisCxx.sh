#!/bin/bash

if [ -z ${PORIS_SAFETY_OVERRIDE+x} ]; then 
    echo "PORIS_SAFETY_OVERRIDE is not set, checking repo is clean";
    if [ -z "$(git status --porcelain)" ]; then 
        echo "Welcome to doPorisDev.sh"
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
    echo "Welcome to doPorisDev.sh"
fi

######### SAFETY AREA ############


########### USER CONFIGURATION AREA ##############

# Defining some environmental variables
# TODO: Convert them to arguments
# This will force the script to firstly clean every previous product
# PORIS_CLEAN=0
# If set, the Interface Repository is not in the localhost, so it will
# avoid executing the cs -t ir.restart; cs -t ir.load process
# and will warn the user to do it in the IR host
# TODO: Try to avoid this definition by getting the value from the ${GCS_OPT_FILE}
# that will be defined below
# This is the relative path from ${WORKING_GCS_PATH}/src_src/ to
# the folder where the $1.ods file is located.  It also will be used
# to build the ${DEVBASE_JAVA_PATH}/$1 folder where the Java panels
# will be created.
# You could check this diagram: http://ll-sb1:3000/cosmosys/gcs/hie_gv.svg
# Normally set to the DEVBASE_RELATIVE_PATH=gtc/DSL/CK/DevLib, but you
# should change it when the final device location is defined.
DEVBASE_PATH=`pwd`

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
PORIS_TOOLS_CXX_PATH=${DEVBASE_PATH}/cxxPORIS
echo "path"
echo ${PORIS_TOOLS_PATH}
echo ${PORIS_TOOLS_CXX_PATH}

# The path for the C++ base folder for the specific (user) custom code of the device
DEVBASE_USER_PATH=${DEVBASE_PATH}/${DEVNAME}.user

########### WELCOME MESSAGE CALCULATION AREA ##############

echo "Welcome to C++ code generator por PORIS models"

######### CLEANING AREA ###############
# We will clean (or not) the products depending on PORIS_CLEAN variable
if [ -z ${PORIS_CLEAN+x} ]; then 
    echo "PORIS_CLEAN is not set, keeping already generated files";
    # We will have to preserve some files depending on PORISDEV_CLEAN variable
    echo "Preserve some previous files and removing the library directory";
    cp ${DEVBASE_PATH}/${DEVNAME}/${DEVNAME}PORIS.h .
    cp ${DEVBASE_PATH}/${DEVNAME}/${DEVNAME}PORIS.cpp .
    rm -rf ${DEVBASE_PATH}/${DEVNAME}
else
    echo "Cleaning previous generated products"
    rm -rf ${DEVBASE_PATH}/${DEVNAME}
fi

######### CREATING FOLDERS AREA ###############
# Let's create the product directories
mkdir -p ${DEVBASE_PATH}/${DEVNAME}

######### If no USER CUSTOM CODE FOLDER ADDED, COPY THE TEMPLATE ONE #############
echo "Checking the existence of ${DEVBASE_CXX_USER_PATH}"
if [ -d "$DEVBASE_USER_PATH" ]; then
  ### Take action if $DEVBASE_USER_PATH exists ###
  echo "${DEVBASE_USER_PATH} already present, nothing to do"
else
  ###  Control will jump here if $DEVBASE_CXX_USER_PATH does NOT exists ###
  echo "${DEVBASE_USER_PATH} not found. Copying template dir."
  cp -r ${PORIS_TOOLS_CXX_PATH}'/$S1.user' ${DEVBASE_USER_PATH}
  mv ${DEVBASE_USER_PATH}'/$S1_user.cpp' ${DEVBASE_USER_PATH}/${DEVNAME}_user.cpp
  mv ${DEVBASE_USER_PATH}'/$S1_user.h' ${DEVBASE_USER_PATH}/${DEVNAME}_user.h
  sed -i "s/DEVICENAME/$1/" ${DEVBASE_USER_PATH}/${DEVNAME}_user.h
  sed -i "s/DEVICENAME/$1/" ${DEVBASE_USER_PATH}/${DEVNAME}_user.h
  sed -i "s/DEVICENAME/$1/" ${DEVBASE_USER_PATH}/${DEVNAME}_user.h
  sed -i "s/DEVICENAME/$1/" ${DEVBASE_USER_PATH}/${DEVNAME}_user.cpp
  sed -i "s/DEVICENAME/$1/" ${DEVBASE_USER_PATH}/${DEVNAME}_user.cpp
  sed -i "s/DEVICENAME/$1/" ${DEVBASE_USER_PATH}/${DEVNAME}_user.cpp
fi

######### PARSING THE MODEL AND GENERATING THE PORIS PRODUCTS ###############
cd ${DEVBASE_PATH}
if [ -z ${PORIS_CLEAN+x} ]; then 
    echo "PORIS_CLEAN is not set, bypassing poris2Cxx.py";
    # We will have to recover the preserved files depending on PORISDEV_CLEAN variable
    mv _${DEVNAME}PORIS.h ${DEVBASE_PATH}/${DEVNAME}/
    mv ${DEVNAME}PORIS.cpp ${DEVBASE_PATH}/${DEVNAME}
else 
    echo "Generating the PORIS device products from $1.ods"
    python3 ${PORIS_TOOLS_PATH}/poris2xml.py models/$1.ods || { echo 'poris2Cxx.py failed' ; exit 1; }
    echo "path"
    echo ${PORIS_TOOLS_CXX_PATH}
    python3 ${PORIS_TOOLS_CXX_PATH}/poris2cxx.py models/$1.ods || { echo 'poris2Cxx.py failed' ; exit 1; }
fi
