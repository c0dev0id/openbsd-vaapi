#!/bin/sh -x
rsync -aHilpt --delete backup/xenocara/ /usr/xenocara
