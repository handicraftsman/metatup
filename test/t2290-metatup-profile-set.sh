#! /bin/sh -e
# tup - A file-based build system
#
# Copyright (C) 2026  handicraftsman
#
# This program is free software; you can redistribute it and/or modify
# it under the terms of the GNU General Public License version 2 as
# published by the Free Software Foundation.

. ./tup.sh

mkdir tools

cat > Tupfile << HERE
function build_app {
  bind builddir := "builddir"
  : |> echo root > %o |> \$(builddir)/app.txt
}
HERE

cat > MetaTup.yaml << HERE
profiles:
  - name: foo
    set:
      c/compiler: clang
components:
  - name: app
    tupfile: ./Tupfile
    function: build_app
    dependencies:
      - name: //tools:tool
HERE

cat > tools/Tupfile << HERE
function build_tool {
  bind brdir := "brdir"
  bind compiler := "compiler"
  : |> echo \$(compiler) > %o |> \$(brdir)/tool.txt
}
HERE

cat > tools/MetaTup.yaml << HERE
components:
  - name: tool
    tupfile: ./Tupfile
    function: build_tool
    binds:
      - from: [c/compiler]
        to: compiler
HERE

mkdir build
cd build
tup gen app -P foo
grep -q '^    profile: foo$' TupBuild.yaml
grep -q '^      "c/compiler": "clang"$' TupBuild.yaml
cd ..

update
check_exist build/app.build/app.txt
check_exist build/app__tools_tool.build/tools/tool.txt
grep -qx "root" build/app.build/app.txt
grep -qx "clang" build/app__tools_tool.build/tools/tool.txt

eotup
