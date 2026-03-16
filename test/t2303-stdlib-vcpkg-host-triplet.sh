#! /bin/sh -e
# tup - A file-based build system
#
# Copyright (C) 2026  handicraftsman
#
# This program is free software; you can redistribute it and/or modify
# it under the terms of the GNU General Public License version 2 as
# published by the Free Software Foundation.

. ./tup.sh

cat > Tupfile << 'HERE'
fbind { "triplet": triplet } := call "@std//vcpkg" host_triplet({
  "vcpkg/windows/linkage": "static"
})

: |> echo $(triplet) |> host-triplet.txt
HERE

parse

if uname -s | grep Linux > /dev/null; then
	tup_object_exist . 'echo x64-linux'
fi

varsetall TUP_PLATFORM=win32 TUP_ARCH=arm64
parse
tup_object_exist . 'echo arm64-windows-static'

eotup
