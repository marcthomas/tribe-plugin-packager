# $1 path to plugin
# $2 destination folder name
# $3 version
# Usage: sh gitdeploy.sh /path/to/plugin/repo/folder my-plugin-name 1.0.1

CURRENTDIR=`pwd`

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
find "/tmp/$2" -name ".git*" -exec rm -rf {} \;
find "/tmp/$2" -name ".DS_Store" -exec rm -rf {} \;
find "/tmp/$2" -name ".svn*" -exec rm -rf {} \;
cd ../

# Zip the file
echo "-------- ZIP IT UP --------"
zip "$2.$3.zip" "$2"
rm -rf "/tmp/$2"

# Move back to initial directory
echo "-------- BRING IT HOME --------"
mv "$2.$3.zip" $CURRENTDIR
cd $CURRENTDIR
echo "$CURRENTDIR/$2.$3.zip"