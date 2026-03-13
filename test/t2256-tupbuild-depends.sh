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
function build_tools {
  bind builddir := "builddir"
  : |> echo tool > %o |> \$(builddir)/tool.txt
}

function build_app {
  bind builddir := "builddir"
  bind tools_dir := "tools_dir"
  : \$(tools_dir)/__tupbuild_tools.stamp |> echo tool > %o |> \$(builddir)/app.txt
}
HERE

cat > TupBuild.yaml << HERE
builds:
  - name: app
    tupfile: ./defs/Tupfile
    function: build_app
    builddir: ./out/app
    depends:
      - build: tools
        as: tools_dir
  - name: tools
    tupfile: ./defs/Tupfile
    function: build_tools
    builddir: ./out/tools
HERE

update
check_exist out/tools/tool.txt
check_exist out/app/app.txt
grep -qx "tool" out/app/app.txt

eotup
