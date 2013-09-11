# Script to package plugins for public release.
#
# @author Peter Chester of Modern Tribe
#
# This script is designed to be run from outside of the plugin-packager folder. It will copy
# the plugin to /tmp, process it and zip it and return it as a zip to the plugins directory
#
# Parameters:
# $1 path to plugin
# $2 destination folder name
# $3 version
#
# Usage: sh plugin-packager/gitdeploy.sh /path/to/plugin/repo/folder my-plugin-name 1.0.1

CURRENTDIR=`pwd`

# Uses ANT for YUI compressor
# `sudo port install apache-ant`
YUICOMPRESSOR_PATH="$CURRENTDIR/plugin-packager/vendor/yuicompressor-2.4.8.jar"
CLOSURE_PATH="$CURRENTDIR/plugin-packager/vendor/closure-compiler.jar"


# Git Pull
cd "$1"
echo "-------- GIT PULL --------"
git checkout master
git pull
echo "-------- GIT SUBMODULES --------"
git submodule foreach git pull
cd $CURRENTDIR

# Copy plugin to /tmp
echo "-------- COPY TO /TMP --------"
cp -rfp "$1" "/tmp/$2"
cd "/tmp/$2"

# Clean up hidden files
echo "-------- CLEAN FILES --------"
find "/tmp/$2" -name ".idea*" -exec rm -rf {} \;
find "/tmp/$2" -name ".git*" -exec rm -rf {} \;
find "/tmp/$2" -name ".DS_Store" -exec rm -rf {} \;
find "/tmp/$2" -name ".svn*" -exec rm -rf {} \;
#rm -rf "/tmp/$2/test"
find "/tmp/$2" -name "tests" -exec rm -rf {} \;

# Compress JS files
echo "-------- COMPRESSING JS FILES --------"
compress_js () {
	SOURCE=${1}
	DESTINATION=${SOURCE/\./.min\.} #replace .js with .min.js
	echo $SOURCE
	java -jar $CLOSURE_PATH --compilation_level SIMPLE_OPTIMIZATIONS --define=''tribe_debug=false'' --jscomp_off=unknownDefines --js_output_file $DESTINATION $SOURCE
	echo $DESTINATION
}
find "/tmp/$2" \( -iname "*.js" ! -iname "*.min.js" \) | while read file
	do compress_js "$file"
done

# Compress CSS files
echo "-------- COMPRESSING CSS FILES --------"
compress_css () {
	SOURCE=${1}
	DESTINATION=${SOURCE/\./.min\.} #replace .css with .min.css
	echo $SOURCE
	java -jar $YUICOMPRESSOR_PATH $SOURCE -o $DESTINATION
	echo $DESTINATION
}
find "/tmp/$2" \( -iname "*.css" ! -iname "*.min.css" \) | while read file
	do compress_css "$file"
done

# Zip the file
cd "/tmp"
echo "-------- ZIP IT UP --------"
echo "zip -r /tmp/$2.$3.zip $2"
zip -r "/tmp/$2.$3.zip" $2

# Move back to initial directory
echo "-------- BRING IT HOME --------"
mv "/tmp/$2.$3.zip" $CURRENTDIR
rm -rf "/tmp/$2"
cd $CURRENTDIR
echo "$CURRENTDIR/$2.$3.zip"