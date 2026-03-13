#! /bin/sh -e
# tup - A file-based build system
#
# Copyright (C) 2026  handicraftsman
#
# This program is free software; you can redistribute it and/or modify
# it under the terms of the GNU General Public License version 2 as
# published by the Free Software Foundation.

. ./tup.sh

mkdir -p defs/sub
cat > defs/Tupfile << HERE
function build_bad {
  bind builddir := "builddir"
  call "./sub/Tupfile" build_bad_sub({ ..., })
}
HERE

cat > defs/sub/Tupfile << HERE
function build_bad_sub {
  bind builddir := "builddir"
  bind brdir := "brdir"
  : |> echo good > %o |> \$(brdir)/good.txt
  : |> echo bad > %o |> \$(builddir)/bad.txt
}
HERE

cat > TupBuild.yaml << HERE
strict: true
builds:
  - name: bad
    tupfile: ./defs/Tupfile
    function: build_bad
    builddir: ./out//bad/
HERE

update_fail_msg "YAML strict mode forbids output './out//bad//bad.txt' outside builddir 'out/bad/defs/sub'"

eotup
