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

  : |> printf 'tool\n' > %o |> \$(brdir)/bin/tool

  fbind dist := dist {
    at "\$(brdir)" as \$(abs \$(brdir)/bin/tool) => at "/bin" as tool
  }

  fbind dir := materialize "\$(dist)" "\$(brdir)/stage"

  : \$(dir)/bin/tool |> cp %f %o |> \$(brdir)/copy/tool
}
HERE

cat > TupBuild.yaml << HERE
builds:
  - name: pkg
    tupfile: ./defs/Tupfile
    function: build_pkg
    builddir: ./build/pkg
HERE

update
check_exist build/pkg/defs/bin/tool
check_exist build/pkg/defs/stage/bin/tool
check_exist build/pkg/defs/copy/tool
grep -qx 'tool' build/pkg/defs/stage/bin/tool
grep -qx 'tool' build/pkg/defs/copy/tool
check_not_exist defs/build

eotup
