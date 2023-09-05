#!/bin/sh -xe

#
# BOILERPLATE
#
DIR=$PWD
# backup / restore xenocara
if [ -d backup/xenocara ]
then
    rsync -aHilpt --delete backup/xenocara/ /usr/xenocara
else
    mkdir -p backup/xenocara
    rsync -aHilpt --delete /usr/xenocara/ backup/xenocara
fi
# delete whatever is left from the last run
rm -rf $DIR/tmp
mkdir -p $DIR/tmp
cd $DIR/tmp

export AUTOCONF_VERSION=2.69
export AUTOMAKE_VERSION=1.16
#
# /BOILERPLATE
#

#
# ADD LIBVA TO XENOCARA
#
VA=2.19.0
ftp https://github.com/intel/libva/releases/download/$VA/libva-$VA.tar.bz2
tar xjvf libva-$VA.tar.bz2
cp -r libva-$VA /usr/xenocara/lib/libva
cp $DIR/glue/Makefile.bsd-wrapper.libva /usr/xenocara/lib/libva/Makefile.bsd-wrapper
cd /usr/xenocara/lib && patch -p0 < $DIR/glue/patch-lib-Makefile.diff
cd /usr/xenocara/lib/libva && autoupdate && autoreconf -i --force
rm -rf /usr/X11R6/include/va
mkdir -p /usr/X11R6/include/va
chmod 777 /usr/X11R6/include/va

#
# ADD VAINFO TO XENOCARA
#
VA_UTIL=2.19.0
ftp https://github.com/intel/libva-utils/releases/download/$VA_UTIL/libva-utils-$VA_UTIL.tar.bz2
tar xjvf libva-utils-$VA_UTIL.tar.bz2
cp -r libva-utils-$VA_UTIL /usr/xenocara/app/vainfo
cp $DIR/glue/Makefile.bsd-wrapper.vainfo /usr/xenocara/app/vainfo/Makefile.bsd-wrapper
cd /usr/xenocara/app/vainfo && patch -p0 < $DIR/glue/patch-app-vainfo.diff
cd /usr/xenocara/app && patch -p0 < $DIR/glue/patch-app-Makefile.diff
cd /usr/xenocara/app/vainfo && autoupdate && autoreconf -i --force

#
# ADD INTEL VAAPI DRIVER TO XENOCARA
#
VA_DRV=2.4.1
ftp https://github.com/intel/intel-vaapi-driver/releases/download/$VA_DRV/intel-vaapi-driver-$VA_DRV.tar.bz2
tar xjvf intel-vaapi-driver-$VA_DRV.tar.bz2
cp -r intel-vaapi-driver-$VA_DRV /usr/xenocara/driver/intel-vaapi-driver
cp $DIR/glue/Makefile.bsd-wrapper.vaapi-driver /usr/xenocara/driver/intel-vaapi-driver/Makefile.bsd-wrapper
cd /usr/xenocara/driver/intel-vaapi-driver && patch -p0 < $DIR/glue/patch-driver-intel-vaapi-driver.diff
cd /usr/xenocara/driver && patch -p0 < $DIR/glue/patch-driver-Makefile.diff
cd /usr/xenocara/driver/intel-vaapi-driver && autoupdate && autoreconf -i --force


echo "no go and build xenocara"
