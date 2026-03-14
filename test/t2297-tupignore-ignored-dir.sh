#! /bin/sh -e
# tup - A file-based build system
#
# Copyright (C) 2026  handicraftsman
#
# This program is free software; you can redistribute it and/or modify
# it under the terms of the GNU General Public License version 2 as
# published by the Free Software Foundation.

. ./tup.sh

mkdir ignored
cat > .tupignore << HERE
ignored
HERE

cat > Tupfile << HERE
: ignored/data.txt |> cp %f %o |> out.txt
HERE

cat > ignored/Tupfile << HERE
this is not valid tup syntax
HERE

echo ok > ignored/data.txt

update
check_exist out.txt
grep -qx "ok" out.txt

eotup
