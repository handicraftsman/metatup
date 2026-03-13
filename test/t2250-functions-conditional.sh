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
FLAG = n
function gen {
  rules {
    !gen = |> echo made |> out.txt
  }
  : |> !gen |>
}
ifeq (\$(FLAG),y)
call gen({})
endif
HERE

parse
tup_object_no_exist . 'echo made'

cat > Tupfile << HERE
FLAG = y
function gen {
  rules {
    !gen = |> echo made |> out.txt
  }
  : |> !gen |>
}
ifeq (\$(FLAG),y)
call gen({})
endif
HERE

parse
tup_object_exist . 'echo made'

eotup
