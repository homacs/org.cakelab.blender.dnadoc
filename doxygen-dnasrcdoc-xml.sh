#!/bin/bash
#
# This is a script which calls doxygen to produce xml output
# from blender dna header files.
# The xml files are then processed by org.cakelab.jdoxml
# to generate Java .Blend documentation files.
#
# -homac
#


JAVA_BLEND_TOOLING="../org.cakelab.blender.io.tooling"
source "$JAVA_BLEND_TOOLING/sh/config.sh"   || exit -1

include "cakelab/doc.sh"


################## CONFIG SECTION ##################


# ALL_COMMENTS
#
# Whether to convert all comments found in source code
# into doxygen conform documentation.
ALL_COMMENTS=true

# BLENDER_SOURCE_HOME
#
# Path to clone of blender repository
BLENDER_SOURCE_HOME="${1:-$BLENDER_REPO_WORK}"

# OUTPUT_PATH
# 
# This is the root path of the target Java.Blend documentation.
# The script will create a subdirectory <blender-version>/dnasrc.
OUTPUT_PATH="${2:-$CAKELAB_DNADOC_HOME}"


################## CONFIG SECTION END ###############





cakelab_doc_import_dnasrc "$ALL_COMMENTS" "$BLENDER_SOURCE_HOME" "$OUTPUT_PATH"







