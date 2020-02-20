#!/bin/bash
set -ex

# disable proxies
unset http_proxy
unset HTTPS_PROXY
unset FTP_PROXY

# arguments
HTCONDOR_GIT_BRANCH=$1
ABI_TAG=$2
VER_APPEND=$3

# directories
SOURCE_DIR=$_CONDOR_SCRATCH_DIR/htcondor_source
BUILD_DIR=$_CONDOR_SCRATCH_DIR/htcondor_pypi_build

# derive tags & paths from ABI tag
PYTHON_TAG=${ABI_TAG:0:4}
PYTHON_VERSION_MAJOR=${ABI_TAG:2:1}
PYTHON_VERSION_MINOR=${ABI_TAG:3:1}
PYTHON_BASE_DIR=/opt/python/$PYTHON_TAG-$ABI_TAG

# get the htcondor source tarball from github
curl -k -L https://api.github.com/repos/htcondor/htcondor/tarball/$HTCONDOR_GIT_BRANCH > $HTCONDOR_GIT_BRANCH.tar.gz

# untar to source directory
mkdir -p $SOURCE_DIR
tar -xf $HTCONDOR_GIT_BRANCH.tar.gz --strip-components=1 -C $SOURCE_DIR
rm -f $HTCONDOR_GIT_BRANCH.tar.gz

# set up build environment
export PATH=$PYTHON_BASE_DIR/bin:$PATH
export PKG_CONFIG_PATH=$PYTHON_BASE_DIR/lib/pkgconfig:/usr/local/lib/pkgconfig:/usr/local/lib64/pkgconfig:/usr/lib64/pkgconfig
export PYTHON_INCLUDE_DIR=$(python -c "from distutils.sysconfig import get_python_inc; print(get_python_inc())")

# create build directory
mkdir -p $BUILD_DIR
cd $BUILD_DIR

# cmake
cmake $SOURCE_DIR \
       -DCMAKE_INSTALL_PREFIX:PATH=/usr/local \
       -DPROPER:BOOL=ON \
       -DHAVE_BOINC:BOOL=OFF \
       -DENABLE_JAVA_TESTS:BOOL=OFF \
       -DWITH_BLAHP:BOOL=OFF \
       -DWITH_CREAM:BOOL=OFF \
       -DWITH_BOINC:BOOL=OFF \
       -DWITH_SCITOKENS:BOOL=OFF \
       -DWANT_PYTHON_WHEELS:BOOL=ON \
       -DAPPEND_VERSION:STRING=$VER_APPEND \
       -DPYTHON_INCLUDE_DIR:PATH=$PYTHON_INCLUDE_DIR \
       -DBUILDID:STRING=UW_Python_Wheel_Build

# build targets
if [ -d "bindings/python" ]; then
    make python_bindings wheel_classad_module wheel_htcondor
    cd bindings/python
    curl -LO https://raw.githubusercontent.com/htcondor/htcondor/V8_8-branch/build/packaging/pypi/setup.cfg
else
    make
    cd build/packaging/pypi
    sed -i 's/ver_append = ""/ver_append = "'$VER_APPEND'"/' setup.py
fi

# put external libraries into path
for extlibdir in $(find $BUILD_DIR/bld_external -name lib -type d); do
    LD_LIBRARY_PATH=$LD_LIBRARY_PATH:$extlibdir
done
LD_LIBRARY_PATH=$LD_LIBRARY_PATH:$BUILD_DIR/src/condor_utils
LD_LIBRARY_PATH=$LD_LIBRARY_PATH:$BUILD_DIR/src/python-bindings
LD_LIBRARY_PATH=$LD_LIBRARY_PATH:$BUILD_DIR/src/classad/lib
LD_LIBRARY_PATH=$LD_LIBRARY_PATH:$BUILD_DIR/src/classad
export LD_LIBRARY_PATH

# build wheel
python setup.py bdist_wheel

# repair wheel
auditwheel repair dist/*.whl

# save result
cp wheelhouse/*.whl $_CONDOR_SCRATCH_DIR
