#!/bin/bash

htcondor_branch="master" # default to master branch
wheel_version_identifier="" # no version identifier by default
if [ $# -gt 0 ]; then
    htcondor_branch="$1"
    wheel_version_identifier="$2"
fi
dagfile=${htcondor_branch}${wheel_version_identifier}.dag

# Determine the latest docker image
docker_image="dockerreg.chtc.wisc.edu/htcondor/htcondor_manylinux1_x86_64:$(head -n 1 latest_tag)"

echo "JOB check_branch dummy.sub NOOP" > $dagfile
echo "SCRIPT PRE check_branch check_branch.sh $branch" >> $dagfile # check branch exists

# Create a temporary directory and node for each Python version in abi_tags.txt
while read python_version_tag; do
    nodename="${htcondor_branch}${wheel_version_identifier}_${abi_tag}"

    # Set up the temp directories
    tmpdir="tmp/$nodename"

    if [ -d "$tmpdir" ]; then
	# Start fresh if the directory exists
	rm -rf "$tmpdir"
    fi
    
    mkdir -p "$tmpdir"
    for f in *_python_wheel.submit *_python_wheel.sh *_python_wheel.py; do
	cp "$f" "$tmpdir"
    done

    # build the main dag
    echo
    echo "SUBDAG EXTERNAL $nodename $nodename.dag DIR $tmpdir"
    echo "PARENT check_branch CHILD $nodename"
    echo "RETRY $nodename 3"
    
    # build the subdags
    for jobtype in "build" "test"; do
	echo "JOB $jobtype ${jobtype}_python_wheel.submit"
    	if [ "$jobtype" == "test" ]; then
	    echo "VARS ALL_NODES manylinux_docker_image=\"$docker_images\""
	    echo "VARS ALL_NODES htcondor_branch=\"$htcondor_branch\"" 
	    echo "VARS ALL_NODES python_version_tag=\"$python_version_tag\""
	    echo "VARS ALL_NODES wheel_version_identifier=\"$wheel_version_identifier\""
	    echo "PARENT build CHILD test"
	    echo "SCRIPT POST test copy_python_wheel.sh"
	fi
    done > "$tmpdir/$nodename.dag"

done < abi_tags.txt >> $dagfile
