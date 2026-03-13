#! /bin/sh -e
# tup - A file-based build system
#
# Copyright (C) 2026  handicraftsman
#
# This program is free software; you can redistribute it and/or modify
# it under the terms of the GNU General Public License version 2 as
# published by the Free Software Foundation.

. ./tup.sh
cat > Tupfile << HERE
function gen {
  : |> printf "one" > %o |> one.txt {grp1}
  : |> printf "two" > %o |> two.txt {grp2}

  return {
    "files": "\$(groups {grp1} {grp2})"
  }
}

fbind { "files": files } := call gen({})

: \$(files) |> cat %f > %o |> out.txt
HERE

update
grep -qx 'onetwo' out.txt

eotup
