#! /bin/sh -e
# tup - A file-based build system
#
# Copyright (C) 2026  handicraftsman
#
# This program is free software; you can redistribute it and/or modify
# it under the terms of the GNU General Public License version 2 as
# published by the Free Software Foundation.

. ./tup.sh

mkdir -p sub shared
cat > Tupfile << HERE
call root_fn({})

function root_fn {
  call "./sub/Tupfile" sub_fn({})
}
HERE

cat > sub/Tupfile << HERE
function sub_fn {
  call "//shared" call_gen({})
  spawn "//shared" spawn_gen({})
}
HERE

cat > shared/Tupfile << HERE
function call_gen {
  : |> echo bazel-call |> call.txt
}

function spawn_gen {
  : |> echo bazel-spawn |> spawn.txt
}
HERE

parse
tup_object_exist sub 'echo bazel-call'
tup_object_exist shared 'echo bazel-spawn'

eotup
