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
call "@std//" _build_marker({
  "brdir": ".",
})
HERE

update
check_exist _marker.txt .metatup/repos/std/Tupfile .metatup/repos/std/MetaTup.yaml
grep -qx "stdlib" _marker.txt

eotup
