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
function inner {
  bind msg := "msg"
  : |> echo \$(msg) |> out.txt
}

function outer {
  bind msg := "msg"
  call inner({ "msg": "\$(msg)" })
}

call outer({ "msg": "hello" })
HERE

parse_fail_msg "Nested function calls must begin their argument map with '...'."

eotup
