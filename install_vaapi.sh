#!/bin/sh -xe

# save dir so we can come back here
DIR=$PWD

# delete whatever is left from the last run
rm -rf $DIR/tmp
mkdir -p $DIR/tmp

# for a reproducible build, we backup xenocara on the first run
# on subsequent runs we restore it first and then run through the script.
[ -d backup/xenocara ] \
    && rsync -aHilpt --delete backup/xenocara/ /usr/xenocara \
    || rsync -aHilpt --delete /usr/xenocara/ backup/xenocara

export AUTOCONF_VERSION=2.69
export AUTOMAKE_VERSION=1.16

# Lets use git to version our efforts
echo "*.orig" > /usr/xenocara/.gitignore
echo "*.cache/" >> /usr/xenocara/.gitignore
cd /usr/xenocara && git init
cd /usr/xenocara && git add .
cd /usr/xenocara && git commit -m "Xenocara Initial Commit"

#### BOILERPLATE ABOVE ####

#
#
# ADD LIBVA TO XENOCARA
#

VA=2.19.0

### download, extract, copy
cd $DIR/tmp
ftp https://github.com/intel/libva/releases/download/$VA/libva-$VA.tar.bz2
tar xjvf libva-$VA.tar.bz2
cp -r libva-$VA /usr/xenocara/lib/libva

### prepare upstream code
cd /usr/xenocara/lib/libva
git add . && git commit -m "LibVA: Upstream Code"
autoupdate; autoreconf -i --force
git add . && git commit -m "LibVA: autoupdate, autoreconf -i --force (automake:$AUTOMAKE_VERSION autoconf:$AUTOCONF_VERSION)"

### Add patches for xenocara
cd /usr/xenocara
git apply $DIR/patch-libva.diff


#
#
# ADD VAINFO TO XENOCARA
#

VA_UTIL=2.19.0

### download, extract copy
cd $DIR/tmp
ftp https://github.com/intel/libva-utils/releases/download/$VA_UTIL/libva-utils-$VA_UTIL.tar.bz2
tar xjvf libva-utils-$VA_UTIL.tar.bz2
cp -r libva-utils-$VA_UTIL /usr/xenocara/app/vainfo

### prepare upstream code
cd /usr/xenocara/app/vainfo
git add . && git commit -m "vainfo: Upstream Code"
autoupdate; autoreconf -i --force
git add . && git commit -m "vainfo: autoupdate, autoreconf -i --force (automake:$AUTOMAKE_VERSION autoconf:$AUTOCONF_VERSION)"

### patches
cd /usr/xenocara
git apply $DIR/patch-vainfo.diff


#
#
# ADD INTEL VAAPI DRIVER TO XENOCARA
#

VA_DRV=2.4.1

### download, extract, copy
cd $DIR/tmp
ftp https://github.com/intel/intel-vaapi-driver/releases/download/$VA_DRV/intel-vaapi-driver-$VA_DRV.tar.bz2
tar xjvf intel-vaapi-driver-$VA_DRV.tar.bz2
cp -r intel-vaapi-driver-$VA_DRV /usr/xenocara/driver/intel-vaapi-driver

### prepare upstream code
cd /usr/xenocara/driver/intel-vaapi-driver
git add . && git commit -m "intel-vaapi-driver: Upstream Code"
autoupdate;  autoreconf -i --force
git add . && git commit -m "intel-vaapi-driver: autoupdate, autoreconf -i --force (automake:$AUTOMAKE_VERSION autoconf:$AUTOCONF_VERSION)"

### patch for xenocara
cd /usr/xenocara
git apply /home/sdk/vaapi/patch-intel-vaapi-driver.diff


#
#
# Create commits for patches
#
git add app/vainfo app/Makefile && git commit -m "vainfo: Patches..."
git add lib/libva lib/Makefile && git commit -m "LibVA: Patches..."
git add driver/intel-vaapi-driver driver/Makefile && git commit -m "intel-vaapi-driver: Patches..."

rm -rf /usr/X11R6/include/va
mkdir -p /usr/X11R6/include/va
chmod 777 /usr/X11R6/include/va

echo "now go and build xenocara"
