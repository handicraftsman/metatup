#! /bin/sh -e
# tup - A file-based build system
#
# Copyright (C) 2026  handicraftsman
#
# This program is free software; you can redistribute it and/or modify
# it under the terms of the GNU General Public License version 2 as
# published by the Free Software Foundation.

. ./tup.sh

mkdir defs

cat > defs/Tupfile << HERE
function build_app {
  bind builddir := "builddir"
  : |> echo ok > %o |> \$(builddir)/out.txt
}
HERE

cat > MetaTup.yaml << HERE
extra_root:
  nested: true
components:
  - name: app
    extra_component:
      nested: true
    tupfile: ./defs/Tupfile
    function: build_app
HERE

mkdir build
cat > build/TupBuild.yaml << HERE
strict: true
unknown_root:
  keep:
    - this
builds:
  - name: stale
    builddir: ./stale.build
    unknown_build:
      child: value
HERE

cd build
tup gen app 2> warnings.txt

grep -q "ignoring unknown top-level key 'extra_root'" warnings.txt
grep -q "ignoring unknown component key 'extra_component'" warnings.txt
grep -q "ignoring unknown top-level key 'unknown_root'" warnings.txt
grep -q "ignoring unknown build key 'unknown_build'" warnings.txt
grep -q '^  - name: app$' TupBuild.yaml

cd ..

eotup
