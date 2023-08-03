#!/bin/sh -xe
DIR=$PWD

# restore xenocara from backup (only works if ./backup_xenocara.sh has been run)
./restore_xenocara.sh

# delete whatever is left from the last run
rm -rf $DIR/tmp
mkdir -p $DIR/tmp
cd $DIR/tmp

# versions... so we can upgrade easily
#VA=2.17.0
VA=2.19.0
#VA_UTIL=2.17.1
VA_UTIL=2.19.0
VA_DRV=2.4.1

# download required archives
ftp https://github.com/intel/libva/releases/download/$VA/libva-$VA.tar.bz2
ftp https://github.com/intel/libva-utils/releases/download/$VA_UTIL/libva-utils-$VA_UTIL.tar.bz2
ftp https://github.com/intel/intel-vaapi-driver/releases/download/$VA_DRV/intel-vaapi-driver-$VA_DRV.tar.bz2

# extract archives
tar xjvf libva-$VA.tar.bz2
tar xjvf libva-utils-$VA_UTIL.tar.bz2
tar xjvf intel-vaapi-driver-$VA_DRV.tar.bz2

# copy dirs to xenocara
cp -r libva-utils-$VA_UTIL       /usr/xenocara/app/vainfo
cp -r libva-$VA                  /usr/xenocara/lib/libva
cp -r intel-vaapi-driver-$VA_DRV /usr/xenocara/driver/intel-vaapi-driver

# copy glue bsd.wrappers
cp ../glue/Makefile.bsd-wrapper.vainfo       /usr/xenocara/app/vainfo/Makefile.bsd-wrapper
cp ../glue/Makefile.bsd-wrapper.libva        /usr/xenocara/lib/libva/Makefile.bsd-wrapper
cp ../glue/Makefile.bsd-wrapper.vaapi-driver /usr/xenocara/driver/intel-vaapi-driver/Makefile.bsd-wrapper

# include new directories into Makefiles
cd /usr/xenocara/app    && patch -p0 < $DIR/glue/patch-app-Makefile.diff
cd /usr/xenocara/driver && patch -p0 < $DIR/glue/patch-driver-Makefile.diff
cd /usr/xenocara/lib    && patch -p0 < $DIR/glue/patch-lib-Makefile.diff

# patch vainfo
cd /usr/xenocara/app/vainfo && patch -p0 < $DIR/glue/patch-app-vainfo.diff

# patch libva
# not needed (upstream) cd /usr/xenocara/lib/libva && patch -p0 < $DIR/glue/patch-lib-libva-va-va-c.diff
# not needed (upstream) cd /usr/xenocara/lib/libva && patch -p0 < $DIR/glue/patch-lib-libva-va-va_trace-c.diff

# patch intel-vaapi-driver
cd /usr/xenocara/driver/intel-vaapi-driver && patch -p0 < $DIR/glue/patch-driver-intel-vaapi-driver.diff
# not needed cd /usr/xenocara/driver/intel-vaapi-driver && patch -p0 < $DIR/glue/patch-driver-intel-vaapi-driver-src_i965_encoder_utils_c.diff

# patch mesa
# not needed cd /usr/xenocara/lib/mesa && patch -p0 < $DIR/glue/patch-lib-mesa-meson_build.diff
# not needed cd /usr/xenocara/lib/mesa && patch -p0 < $DIR/glue/patch-lib-mesa-src-meson_build.diff

# this won't work for you
chown -R sdk /usr/xenocara

# build xenocara
cd /usr/xenocara
doas make bootstrap
doas make obj
doas make -j8 build
#doas make install

