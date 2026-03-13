#! /bin/sh -e
# tup - A file-based build system
#
# Copyright (C) 2026  handicraftsman
#
# This program is free software; you can redistribute it and/or modify
# it under the terms of the GNU General Public License version 2 as
# published by the Free Software Foundation.

. ./tup.sh

cat > Tupfile << HERE
function build_app {
  bind builddir := "builddir"
  bind mode := "mode"
  : |> echo \$(mode) > %o |> \$(builddir)/mode.txt
}
HERE

cat > MetaTup.yaml << 'HERE'
components:
  - name: app
    tupfile: ./Tupfile
    function: build_app
    binds:
      - to: "base"
        value: "$(flavor)"
      - to: "mode"
        value: "$(base)-checked"
HERE

mkdir build
cd build
tup gen app -B flavor=debug
grep -q '"base": "debug"' TupBuild.yaml
grep -q '"mode": "debug-checked"' TupBuild.yaml
cd ..

update
check_exist build/app.build/mode.txt
grep -qx "debug-checked" build/app.build/mode.txt

eotup
