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
  : |> printf 'header\n' > %o |> \$(brdir)/include/tool.h

  fbind bins := dist {
    at "\$(brdir)" as \$(abs \$(brdir)/bin/tool) => at "/bin" as \$(realname \$(abs \$(brdir)/bin/tool))
  }

  fbind headers := dist {
    at "\$(brdir)" as \$(abs \$(brdir)/include/tool.h) => at "/include" as \$(realname \$(abs \$(brdir)/include/tool.h))
  }

  fbind dist := dist {
    mounts \$(bins) at "/"
    mounts \$(headers) at "/"
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
        path: ./release/root
HERE

update
check_exist build/pkg/defs/bin/tool
check_exist build/pkg/defs/include/tool.h
check_exist release/root/bin/tool
check_exist release/root/include/tool.h
grep -qx 'tool' release/root/bin/tool
grep -qx 'header' release/root/include/tool.h

eotup
