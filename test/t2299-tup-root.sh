#! /bin/sh -e
# tup - A file-based build system
#
# Copyright (C) 2026  handicraftsman
#
# This program is free software; you can redistribute it and/or modify
# it under the terms of the GNU General Public License version 2 as
# published by the Free Software Foundation.

. ./tup.sh

mkdir -p foo/bar

cat > Tupfile << HERE
include foo/test1.metatup
root += \$(TUP_ROOT)
: |> echo \$(root) > %o |> out.txt
HERE

cat > foo/test1.metatup << HERE
include bar/test2.metatup
root += \$(TUP_ROOT)
HERE

cat > foo/bar/test2.metatup << HERE
root += \$(TUP_ROOT)
HERE

update
grep -qx '\.\./\.\. \.\. \.' out.txt

cat > foo/Tupfile << HERE
include bar/test1.metatup
root += \$(TUP_ROOT)
: |> echo \$(root) > %o |> out.txt
HERE

cat > foo/bar/test1.metatup << HERE
root += \$(TUP_ROOT)
HERE

update foo/out.txt
grep -qx '\.\./\.\. \.\.' foo/out.txt

eotup
