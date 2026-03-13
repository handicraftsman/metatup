#! /bin/sh -e
# tup - A file-based build system
#
# Copyright (C) 2026  handicraftsman
#
# This program is free software; you can redistribute it and/or modify
# it under the terms of the GNU General Public License version 2 as
# published by the Free Software Foundation.

. ./tup.sh

mkdir lib app build
cat > app/Tupfile << HERE
function app {
  fbind { "out": out } := call "//lib" gen({
    ...,
    "name": "app",
  })

  return { "out": "$(out)" }
}
HERE

cat > lib/Tupfile << HERE
function gen {
  bind name := "name"
  bind brdir := "brdir"

  : |> echo ok > %o |> $(brdir)/$(name).txt {out}

  return { "out": "$(groups {out})" }
}
HERE

cat > build/TupBuild.yaml << HERE
builds:
  - name: app
    tupfile: ../app/Tupfile
    function: app
    builddir: ./app.build
HERE

cd build
parse

eotup
