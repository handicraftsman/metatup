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
  rules {
    !gen = |> echo \$(name) |> \$(name).txt
  }
  : |> !gen |>
}

function build_greeter {
  bind whom := "whom"
  call gen({ ..., "name": "greeter_\$(whom)" })
}

call build_greeter({ "whom": "WORLD" })
call build_greeter({ "whom": "YOU" })
HERE

parse
tup_object_exist . 'echo greeter_WORLD'
tup_object_exist . 'echo greeter_YOU'

eotup
