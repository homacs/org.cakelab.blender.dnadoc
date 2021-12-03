#!/bin/bash


# blender-utils.sh
#
# Utility functions for blender.
#
# Supposed to be included by other scripts like this:
#
#     source blender-utils.sh
#

CAKELAB_REPO_HOME=/home/homac/repos/git/cakelab.org/playground

BLENDER_REPO_HOME=/home/homac/repos/git/blender.org

# BLENDER_HOME
# Base directory of the blender installation.
# This may be overridden when using a custom build environment
# to be configured further below.
BLENDER_HOME=/home/homac/opt/blender/blender-latest

# BLENDER
# Path to blender executable. Used to determine blender 
# version by executing: 
# > blender -v
# This variable may be overridden, when using a custom build
# environment, as to be configured further below.
BLENDER=${BLENDER_HOME}/blender



function error_exit () {
	echo "error: $1" 1>&2
	exit -1
}

function abort ()
{
	error_exit "aborted."
}

function proceed ()
{
 	while [ -z "$answer" ] 
 	do  
 		read -p "proceed (y/n)? " answer
 	done
 	
 	if [ "$answer" == "y" ]
 	then
 		return 0
 	else
 		return -1
 	fi
}

# Determine blender version using blender -v
function blender-version () {
	# parse output of 
	#    blender -v
	# and extract the major and minor version (only!)
	#    -> X.XX
	
	# supports older version of blender too
	$BLENDER -v | awk ' /^Blender [0-9]+\.[0-9]+\.[0-9]$/ \
						{                                 \
							gsub(/\.[0-9]+$/,"",$2);      \
							print $2 ;                    \
							exit 0;                       \
						}                                 \
						/^Blender [0-9]+\.[0-9]+$/        \
						{                                 \
							print $2 ;                    \
							exit 0;                       \
						}                                 \
					  '
}
