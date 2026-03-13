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
  bind msg := "msg" || "default"
  inspect "inspect says \$(msg)"
  : |> printf 'ok\n' > %o |> out.txt
}

call gen({ "msg": "hello" })
HERE

if ! tup >stdout.txt 2>stderr.txt; then
	echo "*** Expected tup to succeed" 1>&2
	exit 1
fi

check_exist out.txt
grep -qx 'inspect says hello' stderr.txt

eotup
