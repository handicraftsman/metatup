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
function build_tool {
  bind builddir := "builddir"
  : |> echo tool > %o |> \$(builddir)/tool.txt
  return { "tool_path": "\$(abs \$(builddir)/tool.txt)" }
}

function build_app {
  bind builddir := "builddir"
  bind tool_path := "tool_path"
  : \$(tool_path) |> cp %f %o |> \$(builddir)/app.txt
}
HERE

cat > TupBuild.yaml << HERE
builds:
  - name: app
    tupfile: ./defs/Tupfile
    function: build_app
    builddir: ./out/app
    args:
      "tool_path": "\$(from \"tools\" \"tool_path\")"
    depends:
      - build: tools
        as: tools_dir
  - name: tools
    tupfile: ./defs/Tupfile
    function: build_tool
    builddir: ./out/tools
HERE

update
check_exist out/tools/tool.txt
check_exist out/app/app.txt
grep -qx "tool" out/app/app.txt

eotup
