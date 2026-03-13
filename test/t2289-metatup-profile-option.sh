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
  bind profile-name := "profile-name"
  : |> echo \$(profile-name) > %o |> \$(builddir)/app.txt
}
HERE

cat > MetaTup.yaml << HERE
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
  bind profile-name := "profile-name"
  : |> echo \$(profile-name) > %o |> \$(brdir)/tool.txt
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
tup gen app -P profile-name
grep -q '^    profile: profile-name$' TupBuild.yaml
grep -q '^  - name: app__tools_tool$' TupBuild.yaml
cd ..

update
check_exist build/app.build/app.txt
check_exist build/app__tools_tool.build/tools/tool.txt
grep -qx "true" build/app.build/app.txt
grep -qx "true" build/app__tools_tool.build/tools/tool.txt

eotup
