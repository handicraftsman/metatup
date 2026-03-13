#! /bin/sh -e
# tup - A file-based build system
#
# Copyright (C) 2026  handicraftsman
#
# This program is free software; you can redistribute it and/or modify
# it under the terms of the GNU General Public License version 2 as
# published by the Free Software Foundation.

. ./tup.sh

mkdir -p sub/deeper
cat > Tupfile << HERE
function call_root_fn {
  bind reldir := "reldir"
  : |> printf '\$(reldir)' > %o |> root-call.txt
  call "./sub/Tupfile" call_sub_fn({ ..., })
  spawn "./sub/Tupfile" spawn_sub_fn({ ..., })
}

call call_root_fn({})
HERE

cat > sub/Tupfile << HERE
function call_sub_fn {
  bind reldir := "reldir"
  : |> printf '\$(reldir)' > %o |> sub-call.txt
  call "./deeper/Tupfile" call_deeper_fn({ ..., })
}

function spawn_sub_fn {
  bind reldir := "reldir"
  : |> printf '\$(reldir)' > %o |> sub-spawn.txt
  spawn "./deeper/Tupfile" spawn_deeper_fn({ ..., })
}
HERE

cat > sub/deeper/Tupfile << HERE
function call_deeper_fn {
  bind reldir := "reldir"
  : |> printf '\$(reldir)' > %o |> deeper-call.txt
}

function spawn_deeper_fn {
  bind reldir := "reldir"
  : |> printf '\$(reldir)' > %o |> deeper-spawn.txt
}
HERE

update
grep -qx '\.' root-call.txt
grep -qx '\.' sub-call.txt
grep -qx '\.' deeper-call.txt
grep -qx 'sub' sub-spawn.txt
grep -qx 'sub/deeper' deeper-spawn.txt

eotup
