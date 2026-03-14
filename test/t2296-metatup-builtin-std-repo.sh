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
    dependencies:
      - name: "@std//:_stdlib_marker"
HERE

mkdir build
cd build
tup gen app
grep -q '^  - name: app$' TupBuild.yaml
grep -q '^    tupfile: \.\./\.metatup/repos/std/\./Tupfile$' TupBuild.yaml
grep -q '^    function: _build_marker$' TupBuild.yaml
cd ..

update
check_exist .metatup/repos/std/Tupfile .metatup/repos/std/MetaTup.yaml
check_exist build/app.build/build/_marker.txt
grep -qx "stdlib" build/app.build/build/_marker.txt

eotup
