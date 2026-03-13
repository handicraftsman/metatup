#! /bin/sh -e
# tup - A file-based build system
#
# Copyright (C) 2026  handicraftsman
#
# This program is free software; you can redistribute it and/or modify
# it under the terms of the GNU General Public License version 2 as
# published by the Free Software Foundation.

. ./tup.sh

mkdir bundle
mkdir tools

cat > Tupfile << HERE
function build_app {
  bind builddir := "builddir"
  : |> echo app > %o |> \$(builddir)/base.txt
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
      - name: //bundle:bundle
        require_if:
          - profile_enabled: profile-name
HERE

cat > bundle/MetaTup.yaml << HERE
components:
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
tup gen app
grep -q '^  - name: app$' TupBuild.yaml
grep -qv 'app__tools_tool' TupBuild.yaml || true
if grep -q 'app__tools_tool' TupBuild.yaml; then
	echo "*** tool build should not be present without profile" 1>&2
	exit 1
fi

tup gen app -B profile-name=true
grep -q 'app__tools_tool' TupBuild.yaml
grep -q 'build: app__tools_tool' TupBuild.yaml
cd ..

update
check_exist build/app.build/base.txt
check_exist build/app__tools_tool.build/tools/tool.txt

eotup
