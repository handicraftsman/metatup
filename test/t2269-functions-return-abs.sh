#! /bin/sh -e
# tup - A file-based build system
#
# Copyright (C) 2026  handicraftsman
#
# This program is free software; you can redistribute it and/or modify
# it under the terms of the GNU General Public License version 2 as
# published by the Free Software Foundation.

. ./tup.sh
mkdir dir
printf "one" > foo.txt
printf "two" > dir/bar.txt

cat > Tupfile << HERE
function gen {
  bind brdir := "brdir"
  bind name := "name" || "prog"

  return {
    "files": "\$(abs foo.txt \$(brdir)/bin/\$(name) dir/../dir/bar.txt)"
  }
}

fbind { "files": files } := call gen({ "builddir": "out", "name": "tool" })

: \$(files) |> cat %f > %o |> out.txt
HERE

mkdir out
mkdir out/bin
printf "mid" > out/bin/tool

update
grep -qx 'onemidtwo' out.txt

eotup
