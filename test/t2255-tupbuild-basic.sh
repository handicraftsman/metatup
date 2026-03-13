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
function build_app {
  bind builddir := "builddir"
  bind msg := "msg" || "default"
  : |> echo \$(msg) > %o |> \$(builddir)/out.txt
}
HERE

cat > TupBuild.yaml << HERE
builds:
  - name: app
    tupfile: ./defs/Tupfile
    function: build_app
    builddir: ./build/app
    args:
      msg: hello
HERE

update
check_exist build/app/out.txt
grep -qx "hello" build/app/out.txt

eotup
