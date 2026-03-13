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
fbind {
  "outfile": outfile,
  "msg": msg
} := call "./sub/Tupfile" gen({
  "name": "world"
})

: |> echo "\$(msg)" > %o |> \$(outfile)
HERE

cat > sub/Tupfile << HERE
function gen {
  bind name := "name"

  return {
    "outfile": "hello.txt",
    "msg": "hello \$(name)"
  }
}
HERE

update
grep -qx 'hello world' hello.txt

eotup
