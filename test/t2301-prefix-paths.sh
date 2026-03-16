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
LIST = \$(prefix_paths build/out/ ; include/a.h lib/liba.a bin/tool)
: |> printf '%%s\n' \$(LIST) > %o |> out.txt
HERE

update
printf 'build/out/include/a.h\nbuild/out/lib/liba.a\nbuild/out/bin/tool\n' | diff - out.txt

eotup
