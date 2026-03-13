#! /bin/sh -e
# tup - A file-based build system
#
# Copyright (C) 2026  handicraftsman
#
# This program is free software; you can redistribute it and/or modify
# it under the terms of the GNU General Public License version 2 as
# published by the Free Software Foundation.

. ./tup.sh

cat > MetaTup.yaml << HERE
components:
  - name: app
    tupfile: ./Tupfile
HERE

mkdir build
cd build
! tup gen app > out.txt 2>&1
grep -q "component requires tupfile and function together" out.txt
cd ..

eotup
