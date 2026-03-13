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
function build_root {
  bind brdir := "brdir"
  : |> printf '\$(brdir)' > %o |> \$(brdir)/root.txt
  call "./sub/Tupfile" build_sub_call({ ..., })
  spawn "./sub/Tupfile" build_sub_spawn({ ..., })
}
HERE

cat > defs/sub/Tupfile << HERE
function build_sub_call {
  bind brdir := "brdir"
  : |> printf '\$(brdir)' > %o |> \$(brdir)/sub-call.txt
}

function build_sub_spawn {
  bind brdir := "brdir"
  : |> printf '\$(brdir)' > %o |> \$(brdir)/sub-spawn.txt
}
HERE

cat > TupBuild.yaml << HERE
builds:
  - name: bad
    tupfile: ./defs/Tupfile
    function: build_root
    builddir: ./out//bad/
HERE

update
grep -qx 'out/bad/defs' out/bad/defs/root.txt
grep -qx 'out/bad/defs' out/bad/defs/sub-call.txt
grep -qx 'out/bad/defs/sub' out/bad/defs/sub/sub-spawn.txt

eotup
