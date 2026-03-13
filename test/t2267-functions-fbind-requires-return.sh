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
  : |> echo hi |> hi.txt
}

fbind { "msg": msg } := call gen({})
HERE

parse_fail_msg "fbind requires the invoked function to return values"

eotup
