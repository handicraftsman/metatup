#! /bin/sh -e
# tup - A file-based build system
#
# Copyright (C) 2026  handicraftsman
#
# This program is free software; you can redistribute it and/or modify
# it under the terms of the GNU General Public License version 2 as
# published by the Free Software Foundation.

. ./tup.sh

mkdir libs

cat > MetaTup.yaml << HERE
components:
  - name: pack
    dependencies:
      - name: //libs:left
      - name: //libs:right
HERE

cat > libs/Tupfile << HERE
function build_left {
  bind brdir := "brdir"
  : |> echo left > %o |> \$(brdir)/left.txt
}

function build_right {
  bind brdir := "brdir"
  : |> echo right > %o |> \$(brdir)/right.txt
}
HERE

cat > libs/MetaTup.yaml << HERE
components:
  - name: left
    tupfile: ./Tupfile
    function: build_left
  - name: right
    tupfile: ./Tupfile
    function: build_right
HERE

mkdir build
cd build
tup gen pack
grep -q '^  - name: pack$' TupBuild.yaml
grep -q '^    builddir: ./pack.build$' TupBuild.yaml
grep -q '^    depends:$' TupBuild.yaml
grep -q 'build: pack__libs_left' TupBuild.yaml
grep -q 'build: pack__libs_right' TupBuild.yaml
cd ..

update
check_exist build/pack__libs_left.build/libs/left.txt
check_exist build/pack__libs_right.build/libs/right.txt
check_exist build/pack.build/__tupbuild_pack.stamp
grep -qx "left" build/pack__libs_left.build/libs/left.txt
grep -qx "right" build/pack__libs_right.build/libs/right.txt

eotup
