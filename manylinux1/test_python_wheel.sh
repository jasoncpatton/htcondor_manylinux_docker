#!/bin/bash
set -e

# arguments
FULL_PYTHON_VERSION_TAG=$1
WHEEL_FILE=$2

# do not test Python 2 "cp__m" versions
if [ "$FULL_PYTHON_VERSION_TAG" == "cp27m" ];
   echo "Not testing wheel for $FULL_PYTHON_VERSION_TAG"
   exit 0
fi

# derive tags & paths from python version tag
PYTHON_VERSION_MAJOR=${FULL_PYTHON_VERSION_TAG:2:1}
PYTHON_VERSION_MINOR=${FULL_PYTHON_VERSION_TAG:3:1}

# install miniconda and create environment
export HOME=$_CONDOR_SCRATCH_DIR
bash Miniconda3-latest-Linux-x86_64.sh -b -p $HOME/miniconda3
source $HOME/miniconda3/bin/activate
conda create -y -n wheeltest python=${PYTHON_VERSION_MAJOR}.${PYTHON_VERSION_MINOR}
conda activate wheeltest

# install htcondor and run test script
pip install $WHEEL_FILE
python test_wheel.py
exit $?

