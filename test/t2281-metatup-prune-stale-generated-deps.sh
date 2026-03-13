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
  : |> echo app > %o |> \$(builddir)/app.txt
}
HERE

cat > MetaTup.yaml << HERE
defaults:
  profile-name: ""
components:
  - name: app
    tupfile: ./Tupfile
    function: build_app
    dependencies:
      - name: //tools:tool
        require_if:
          - profile_enabled: profile-name
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
tup gen app -B profile-name=true
grep -q '^  - name: app__tools_tool$' TupBuild.yaml

tup gen app
grep -q '^  - name: app$' TupBuild.yaml
grep -q '^  - name: app__tools_tool$' TupBuild.yaml
cd ..

update
check_exist build/app.build/app.txt
check_exist build/app__tools_tool.build/tools/tool.txt

eotup
