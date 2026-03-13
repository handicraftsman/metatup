#! /bin/sh -e
# tup - A file-based build system
#
# Copyright (C) 2026  handicraftsman
#
# This program is free software; you can redistribute it and/or modify
# it under the terms of the GNU General Public License version 2 as
# published by the Free Software Foundation.

. ./tup.sh

mkdir -p src/deep
cat > Tupfile << HERE
: |> printf '%%s\n' \$(globs src/*.txt src/**/nested.txt) > %o |> list.txt
HERE

touch src/root.txt
touch src/deep/nested.txt

update
grep -qx "$PWD/src/root.txt" list.txt
grep -qx "$PWD/src/deep/nested.txt" list.txt

eotup
