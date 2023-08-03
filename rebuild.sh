#!/bin/sh -xe

# build xenocara
cd /usr/xenocara
doas make -j1 build
