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

cat > dep/Tupfile << HERE
function build_dep {
  bind brdir := "brdir"

  : |> printf 'payload\n' > %o |> \$(brdir)/tool.txt

  return { "tool_path": "\$(abs \$(brdir)/tool.txt)" }
}
HERE

cat > dep/MetaTup.yaml << HERE
components:
  - name: dep
    tupfile: ./Tupfile
    function: build_dep
HERE

cat > Tupfile << HERE
function build_app {
  bind brdir := "brdir"
  bind dep_tool := "dep_tool"
  : \$(dep_tool) |> cp %f %o |> \$(brdir)/app.txt
}
HERE

cat > MetaTup.yaml << 'HERE'
components:
  - name: app
    tupfile: ./Tupfile
    function: build_app
    dependencies:
      - name: //dep:dep
    binds:
      - to: "dep_tool"
        value: "$(from \"//dep:dep\" \"tool_path\")"
HERE

mkdir build
cd build
tup gen app
grep -q '^  - name: app$' TupBuild.yaml
grep -q '^      - build: app__dep_dep$' TupBuild.yaml
grep -F -q '"dep_tool": "$(from \"app__dep_dep\" \"tool_path\")"' TupBuild.yaml
cd ..

update
check_exist build/app.build/app.txt
grep -qx "payload" build/app.build/app.txt

eotup
