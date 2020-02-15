#!/bin/bash
#
# This is a script which calls doxygen to produce xml output
# from blender dna header files.
# The xml files are then processed by org.cakelab.jdoxml
# to generate Java .Blend documentation files.
#
# -homac
#



################## CONFIG SECTION ##################

# BLENDER_VERSION
#
# Major and minor part of blender version string
BLENDER_VERSION=2.82

# ENV_PATH_BASE
#
# Path to blender source code directory
ENV_PATH_BASE="/home/homac/repos/git/blender.org/blender"

# REL_SRC_PATH
#
# Path to DNA structs relative to ENV_PATH_BASE.
REL_SRC_PATH="source/blender/makesdna"

# OUTPUT_PATH
# 
# This is the root path of the target Java.Blend documentation.
# The script will create a subdirectory $BLENDER_VERSION/dnasrc.
OUTPUT_PATH="/home/homac/repos/git/github/homacs/JavaBlendDocs/resources/dnadoc"

# ALL_COMMENTS
#
# Whether to convert all comments found in source code
# into doxygen conform documentation.
ALL_COMMENTS=true

# JDOXML_CLASSPATH
#
# Classpath to the JDOX Parser implementation.
JDOXML_CLASSPATH="/home/homac/repos/git/cakelab.org/playground/org.cakelab.jdoxml/bin"

# JSON_CLASSPATH
#
# Classpath to the JSON Codec implementation.
JSON_CLASSPATH="/home/homac/repos/git/cakelab.org/playground/org.cakelab.json/bin"

# DNADOC_CLASSPATH
#
# Classpath to the Java .Blend Documentation generator.
JAVA_BLEND_CLASSPATH="/home/homac/repos/git/cakelab.org/playground/org.cakelab.blender.io/bin"


################## CONFIG SECTION END ###############


ENV_INPUT="$ENV_PATH_BASE/$REL_SRC_PATH"
ENV_OUTPUT_DIR="/tmp/blender-$BLENDER_VERSION-xmldoc"


#
# This function preprocesses *.c *.cpp *.h *.hpp
# and replaces the following:
# - "/*" -> "/**"
#
function preprocess () {
	dir="$1"
	ftmp=`mktemp /tmp/preprocessing.XXXXXX`
	# enumerate all C source code files
	find $dir -regex ".*\.\(c\|h\)\(pp\)?$" | while read f ; do
		echo "$f ..."
		cat $f | awk '{ \
			s = $0 ; \
			s = gensub("[[:space:]]*DNA_DEPRECATED[[:space:]]*([,;][[:space:]]*)/\\*([^\\*!])", "\\1/**< \\\\deprecated\\2", "g", s); \
			s = gensub("(;[[:space:]]*)/\\*([^\\*!])", "\\1/**<\\2", "g", s); \
			s = gensub("[[:space:]]*DNA_DEPRECATED[[:space:]]*([,;][[:space:]]*)//([^/!])", "\\1///< \\\\deprecated\\2", "g", s); \
			s = gensub("(;[[:space:]]*)//([^/!])", "\\1///<\\2", "g", s); \
			s = gensub("//([^/!])", "///\\1", "g", s); \
			s = gensub("/\\*([^\\*!])", "/**\\1", "g", s); \
			s = gensub("/\\*$", "/**", "g", s); \
			s = gensub("[[:space:]]*DNA_DEPRECATED[[:space:]]*([,;][[:space:]]*)", "\\1/**< \\\\deprecated */ \\2", "G", s); \
			print s \
		}'	 > $ftmp
		mv $ftmp $f
	done
}	

if ! [ -d "$ENV_INPUT" ] ; then
	error_exit "can't find '$ENV_INPUT'"
fi


if $ALL_COMMENTS ; then
	# preprocess the source files and change every non-doxygen comment into a
	# doxygen conform comment (even // ).

	# make a clean copy
	tmp="/tmp/blender-$BLENDER_VERSION-preprocessed"
	rm -rf $tmp 
	mkdir -p $tmp/$REL_SRC_PATH/.
	cp -r $ENV_INPUT/* $tmp/$REL_SRC_PATH/.

	# run preprocessing over copy
	preprocess $tmp || error_exit "preprocessing failed"
	
	# update environment variables
	export ENV_PATH_BASE="$tmp"
	export ENV_INPUT="$ENV_PATH_BASE/$REL_SRC_PATH"
	export ENV_OUTPUT_DIR="/tmp/blender-$BLENDER_VERSION-xmldoc"
fi


# export environment variables to pass them to doxygen 
# (they are used in the doxygen config)
export ENV_PATH_BASE
export ENV_INPUT
export ENV_OUTPUT_DIR

# run doxygen
# config is in ./doxygen-dnasrcdoc-xml.doxygen
# result goes in $ENV_OUTPUT_DIR
rm -rf $ENV_OUTPUT_DIR
doxygen ./blender-dnasrc-xml.doxygen || error_exit "doxygen execution failed"

# extract documentation to dnadoc
CLASSPATH="$JDOXML_CLASSPATH:$JSON_CLASSPATH:$JAVA_BLEND_CLASSPATH"
java -cp $CLASSPATH org.cakelab.blender.doc.extract.dnadocs.Main -in "$ENV_OUTPUT_DIR" -out "$OUTPUT_PATH" -v "$BLENDER_VERSION" || error_exit "dnadox extraction failed"
