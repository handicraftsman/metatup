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
  rules {
    !cmd = |> echo inner |> inner.txt
  }
  : |> !cmd |>
}

function outer {
  rules {
    !cmd = |> echo outer |> outer.txt
  }
  call inner({ ..., })
}

call outer({})
HERE

parse
tup_object_exist . 'echo inner'
tup_object_no_exist . 'echo outer'

eotup
