#!/bin/bash

#
# This is a script which calls blender with a blender standard
# python script to receive all docs from blender python API.
# Those are related to RNA, but RNA is kind of derived from
# DNA.
#
# The output of the script is fed to the class:
#     org.cakelab.blender.doc.extract.ExtractPyAPIDoc
# as input to generate a Java Blend documentation file (JSON).
#
# -homac
#

# Some default variables (maybe overridden by the user in config section below)
# using standard installation.
BLENDER_SYSTEM_SCRIPTS="/usr/share/blender/scripts"
BLENDER=~/opt/blender-2.78a-linux-glibc211-x86_64/blender




################# CONFIGURATION SECTION ################

# BLENDER_BUILD_ENV
#
# This variable controls whether the script uses the standard
# installation or a custom built installation in a different
# directory.
BLENDER_BUILD_ENV=false

# BLENDER_SOURCE
#
# Required only if BLENDER_BUILD_ENV is set to true.
# Path to blender source code. 
BLENDER_SOURCE="/home/homac/repos/git/blender.org/blender"

# BLENDER_BUILD
#
# Required only if BLENDER_BUILD_ENV is set to true.
# Specifies the blender build directory.
# This directory has to contain the following directories
# - bin: containing the blender executable
# - lib: containing all custom build third-party libraries
BLENDER_BUILD="$BLENDER_SOURCE/build"


# JSON_CLASSPATH
# 
# classpath for dependency org.cakelab.json
JSON_CLASSPATH="/home/homac/repos/svn/cakelab.org/playground/org.cakelab.json/bin"

# JAVA_BLEND_CLASSPATH
# 
# Java .Blend SDK class path
JAVA_BLEND_CLASSPATH="/home/homac/repos/svn/cakelab.org/playground/org.cakelab.blender.io/bin"

#
# SCRIPT
# This the path to the python script called rna_info.py. It
# Reads the runtime API documentation and dumps it on stdout.
# We use the standard path on linux distros here. If it is not
# there then use the following command to locate it:
# > updatedb && locate rna_info.py
#
SCRIPT="$BLENDER_SYSTEM_SCRIPTS/modules/rna_info.py"

#
# OUTPUT
# This is the folder, where the Java Blend documentation system
# stores documentation for DNA structs. The documentation is
# used by the model generator to write it to generated classes.
# Default: "resources/dnadoc"
#
OUTPUT="resources/dnadoc"

#
# VERSION
#
# Default: <empty>
#
# This is the version of Blender executable used to receive 
# python api documentation. If left empty, the script will determine
# the version on its own using `blender -v`.
#
# This version information is used to create a subfolder in the
# documentation system. 
#
VERSION=

#
# TMP
# Temp directory to store temporary files.
#
TMP=/tmp


################# END OF CONFIGURATION SECTION ################

if $BLENDER_BUILD_ENV ; then
	# preparing to run the custom build blender executable

	export BLENDER_SYSTEM_DATAFILES="$BLENDER_SOURCE/release/datafiles"
	export BLENDER_SYSTEM_SCRIPTS="$BLENDER_SOURCE/release/scripts"
	export LD_LIBRARY_PATH="$BLENDER_BUILD/lib"

	# BLENDER
	#
	# The blender executable.
	BLENDER="$BLENDER_BUILD/bin/blender"
fi


if [ -z "$VERSION" ] ; then
	echo "retrieving blender version string"
	VERSION=`$BLENDER -v | grep "Blender" | head -n 1 | awk '{print $2}'`
fi


echo "extracting blenders python api documentation."
echo "blender executable: ${BLENDER}"
echo "blender version: ${VERSION}"
echo "running python script: ${SCRIPT}"



SCRIPT_OUTPUT=$TMP/pyapi-${VERSION}.txt
CONVERTER_INPUT=$TMP/pyapi-${VERSION}-clean.txt

rm -f $SCRIPT_OUTPUT
$BLENDER --background -noaudio --python $SCRIPT 2> $SCRIPT_OUTPUT >/dev/null

echo "removing debug output"
cat $SCRIPT_OUTPUT | while read line && [ "$line" != "EOF" ] ; do 
	#
	# filter debug output
	#
	if expr "$line" : "^[^\\.\\:]*:" >/dev/null; then 
		continue ;
	fi
	echo "$line"	
done > $CONVERTER_INPUT



echo "calling converter class: org.cakelab.blender.doc.extract.ExtractPyAPIDoc"

CLASSPATH="$JSON_CLASSPATH:$JAVA_BLEND_CLASSPATH"
#CLASSPATH=${CLASSPATH}`find lib -name "*.jar" | while read jar ; do 
	#	echo -n ":$jar"
#done`
echo "CLASSPATH=$CLASSPATH"
java -cp ${CLASSPATH} org.cakelab.blender.doc.extract.rnadocs.ExtractPyAPIDoc -v ${VERSION} -in $CONVERTER_INPUT -out ${OUTPUT}


rm -f $SCRIPT_OUTPUT
rm -f $CONVERTER_INPUT
echo "done."