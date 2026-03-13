#! /bin/sh -e
# tup - A file-based build system
#
# Copyright (C) 2026  handicraftsman
#
# This program is free software; you can redistribute it and/or modify
# it under the terms of the GNU General Public License version 2 as
# published by the Free Software Foundation.

. ./tup.sh

mkdir -p lib build
cat > lib/Tupfile << HERE
function build {
  bind brdir := "brdir"
  bind name := "name"
  : |> printf '\$(abs \$(brdir)/bin/\$(name))' > %o |> \$(brdir)/out.txt
}
HERE

cat > build/TupBuild.yaml << HERE
builds:
  - name: foo
    tupfile: ../lib/Tupfile
    function: build
    builddir: ./greeter_foo
    args:
      "name": "greeter_foo"
HERE

update
grep -qx "$PWD/build/greeter_foo/lib/bin/greeter_foo" build/greeter_foo/lib/out.txt

eotup
