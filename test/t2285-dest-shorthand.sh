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
function build_pkg {
  bind brdir := "brdir"

  : |> printf 'payload\n' > %o |> \$(brdir)/dist.tar

  fbind dist := dest {
    at "\$(brdir)/dist.tar" => at "/dist.tar"
  }

  return { "dist": "\$(dist)" }
}
HERE

cat > TupBuild.yaml << HERE
builds:
  - name: pkg
    tupfile: ./defs/Tupfile
    function: build_pkg
    builddir: ./build/pkg
    dists:
      - from_return: dist
        path: ./release
HERE

update
check_exist build/pkg/defs/dist.tar
check_exist release/dist.tar
grep -qx 'payload' release/dist.tar

eotup
