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
!cmd = |> echo global |> global.txt
function gen {
  rules {
    !cmd = |> echo local |> local.txt
  }
  : |> !cmd |>
}
call gen({})
: |> !cmd |>
HERE

parse
tup_object_exist . 'echo local'
tup_object_exist . 'echo global'

eotup
