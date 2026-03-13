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
  bind name := "name"
  : |> printf "\$(name)_1" > %o |> \$(name)_1.txt {objs}
  : |> printf "\$(name)_2" > %o |> \$(name)_2.txt {objs}
  : {objs} |> cat %f > %o |> \$(name).txt
}

call gen({ "name": "a" })
call gen({ "name": "b" })
HERE

update

[ "$(cat a.txt)" = "a_1a_2" ]
[ "$(cat b.txt)" = "b_1b_2" ]

eotup
