#! /bin/sh -e
# tup - A file-based build system
#
# Copyright (C) 2026  handicraftsman
#
# This program is free software; you can redistribute it and/or modify
# it under the terms of the GNU General Public License version 2 as
# published by the Free Software Foundation.

. ./tup.sh
mkdir sub
cat > Tupfile << HERE
call "./sub/Tupfile" gen({ "msg": "cross" })
HERE
cat > sub/Tupfile << HERE
function gen {
  rules {
    !gen = |> echo \$(msg) |> out.txt
  }
  bind msg := "msg" || "default"
  : |> !gen |>
}
HERE

parse
tup_object_exist . 'echo cross'

eotup
