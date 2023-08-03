#!/bin/sh -x
mkdir -p backup/xenocara
rsync -aHilpt --delete /usr/xenocara/ backup/xenocara
