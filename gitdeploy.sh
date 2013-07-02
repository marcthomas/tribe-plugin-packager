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
YUICOMPRESSOR_PATH="$CURRENTDIR/plugin-packager/vendor/yuicompressor/build/yuicompressor-2.4.8.jar"


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
find "/tmp/$2" -name "test" -exec rm -rf {} \;

# Compress JS files
compressjs () {
	SOURCE=${1}
	DESTINATION=${SOURCE/\./.min\.} #replace .js with .min.js
	java -jar $YUICOMPRESSOR_PATH $SOURCE -o $DESTINATION
}
find "/tmp/$2" \( -iname "*.js" ! -iname "*.min.js" \) | while read file
	do compressjs "$file"
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