#! /bin/sh -e
# tup - A file-based build system
#
# Copyright (C) 2026  handicraftsman
#
# This program is free software; you can redistribute it and/or modify
# it under the terms of the GNU General Public License version 2 as
# published by the Free Software Foundation.

. ./tup.sh

mkdir dep

cat > MetaTup.yaml << HERE
components:
  - name: app
    dependencies:
      - name: //dep:dep
        binds:
          - to: "mode"
            value: "release"
HERE

cat > dep/Tupfile << HERE
function build_dep {
  bind brdir := "brdir"
  bind mode := "mode"
  : |> echo \$(mode) > %o |> \$(brdir)/mode.txt
}
HERE

cat > dep/MetaTup.yaml << HERE
components:
  - name: dep
    tupfile: ./Tupfile
    function: build_dep
HERE

mkdir build
cd build
tup gen app
grep -q '^  - name: app$' TupBuild.yaml
grep -q '"mode": "release"' TupBuild.yaml
cd ..

update
check_exist build/app.build/dep/mode.txt
grep -qx "release" build/app.build/dep/mode.txt

eotup
