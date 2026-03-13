#! /bin/sh -e
# tup - A file-based build system
#
# Copyright (C) 2026  handicraftsman
#
# This program is free software; you can redistribute it and/or modify
# it under the terms of the GNU General Public License version 2 as
# published by the Free Software Foundation.

. ./tup.sh

mkdir defs build
cat > defs/Tupfile << HERE
function build_pkg {
  bind brdir := "brdir"

  : |> printf 'marker\n' > %o |> \$(brdir)/marker.txt
  : |> printf 'payload\n' > %o |> \$(brdir)/bin/tool

  fbind dist := dist {
    at "\$(brdir)" as \$(abs \$(brdir)/bin/tool) => at "/bin" as tool
  }

  fbind dir := materialize "\$(dist)" "\$(brdir)/stage"

  : \$(dir) |> tar -cf %o \$(dir) |> \$(brdir)/stage.tar

  fbind tarball := dist {
    at "\$(brdir)/stage.tar" => at "/stage.tar"
  }

  return { "dist": "\$(tarball)" }
}
HERE

cat > build/TupBuild.yaml << HERE
builds:
  - name: pkg
    tupfile: ../defs/Tupfile
    function: build_pkg
    builddir: ./pkg
    dists:
      - from_return: dist
        path: ./release
HERE

update
check_exist build/pkg/defs/bin/tool
check_exist build/pkg/defs/marker.txt
check_exist build/pkg/defs/stage/bin/tool
check_exist build/pkg/defs/stage.tar
check_exist build/release/stage.tar
tar -tf build/release/stage.tar | grep -qx 'pkg/defs/stage/bin/tool'

eotup
