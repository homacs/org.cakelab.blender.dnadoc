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

JAVA_BLEND_TOOLING="../org.cakelab.blender.io.tooling"

source "$JAVA_BLEND_TOOLING/sh/config.sh"   || exit -1
include "utils/commons.sh"
include "blender/app/version.sh"
include "cakelab/doc.sh"



function main () {
	#
	# OUTPUT
	# This is the folder, where the Java Blend documentation system
	# stores documentation for DNA structs. The documentation is
	# used by the model generator to write it to generated classes.
	# Default: "$CAKELAB_REPO_HOME/resources/dnadoc"
	#
	local OUTPUT="${1:-$CAKELAB_DNADOC_HOME}"
	
	
	local version=$(blender_app_version_normalized_short)
	
	#
	# give feedback
	#
	
cat <<EOF
===============================================================================
	Importing Blenders python api documentation
	
	
	blender: ${BLENDER}
	version: $version
	output:  $OUTPUT
	
	
EOF
	
	proceed
	
	cakelab_docs_import_pyapi "$OUTPUT"
	
	EXTRACT_RESULT="$?"
	
	if [ $EXTRACT_RESULT -eq 0 ]
	then
		echo "successfully imported documentation in \"${OUTPUT}/${version}\""
	else
		echo "FAILED!"
	fi
	
	exit $EXTRACT_RESULT
}


main "$@"