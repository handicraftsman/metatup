#! /bin/sh -e
# tup - A file-based build system
#
# Copyright (C) 2026  Mike Shal <marfey@gmail.com>
#
# This program is free software; you can redistribute it and/or modify
# it under the terms of the GNU General Public License version 2 as
# published by the Free Software Foundation.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License along
# with this program; if not, write to the Free Software Foundation, Inc.,
# 51 Franklin Street, Fifth Floor, Boston, MA 02110-1301 USA.

# Make sure 'tup compiledb' works with variants.

. ./tup.sh

cat > Tupfile << HERE
: foreach *.c |> ^j^ gcc -c %f -o %o |> %B.o
HERE
touch foo.c bar.c
touch foo.config bar.config
tup variant foo.config bar.config
compiledb

for j in build-foo build-bar; do
	for i in foo bar; do
		if ! grep "gcc -c $i\\.c -o $j/$i\\.o" $j/compile_commands.json > /dev/null; then
			echo "Error: Expected gcc command in $j/compile_commands.json" 1>&2
			exit 1
		fi
	done
	if cat $j/compile_commands.json | head -2 | tail -1 | grep ','; then
		echo "Error: $j/compile_commands.json has a ',' on line 2"
		exit 1
	fi
done

eotup
