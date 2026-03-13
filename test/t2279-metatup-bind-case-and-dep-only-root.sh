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
function build_wrapper {
  bind builddir := "builddir"
  bind mode := "mode"
  : |> echo \$(mode) > %o |> \$(builddir)/mode.txt
}
HERE

cat > MetaTup.yaml << HERE
components:
  - name: wrapper
    tupfile: ./Tupfile
    function: build_wrapper
    binds:
      - from: ["flavor"]
        to: "mode"
        case:
          - when: "a"
            then: "b"
          - when: "c"
            then: "d"
          - default: "e"
  - name: bundle
    dependencies:
      - name: //tools:tool
HERE

cat > tools/Tupfile << HERE
function build_tool {
  bind brdir := "brdir"
  : |> echo tool > %o |> \$(brdir)/tool.txt
}
HERE

cat > tools/MetaTup.yaml << HERE
components:
  - name: tool
    tupfile: ./Tupfile
    function: build_tool
HERE

mkdir build
cd build
tup gen wrapper -B flavor=a
grep -q '"mode": "b"' TupBuild.yaml
tup gen wrapper -B flavor=z
grep -q '"mode": "e"' TupBuild.yaml

tup gen bundle
grep -q '^  - name: bundle$' TupBuild.yaml
grep -q '^    function: build_tool$' TupBuild.yaml
grep -q '^    builddir: ./bundle.build$' TupBuild.yaml
cd ..

update
check_exist build/wrapper.build/mode.txt
check_exist build/bundle.build/tools/tool.txt
grep -qx "e" build/wrapper.build/mode.txt
grep -qx "tool" build/bundle.build/tools/tool.txt

eotup
