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
function build_app {
  : foreach *.c |> ^j^ gcc -c %f -o %o |> %B.o
}
HERE

touch foo.c

cat > MetaTup.yaml << HERE
auto_compiledb: true
components:
  - name: app
    tupfile: ./Tupfile
    function: build_app
HERE

tup gen app

grep -q '^auto_compiledb: true$' TupBuild.yaml
if [ -e compile_commands.json ]; then
	echo "Error: compile_commands.json should not be generated during tup gen" 1>&2
	exit 1
fi

update
check_exist compile_commands.json
grep 'gcc -c foo\.c -o foo\.o' compile_commands.json > /dev/null

cat > MetaTup.yaml << HERE
components:
  - name: app
    tupfile: ./Tupfile
    function: build_app
HERE

rm -f compile_commands.json
tup gen app

grep -q '^auto_compiledb: true$' TupBuild.yaml
if [ -e compile_commands.json ]; then
	echo "Error: compile_commands.json should not be generated during tup gen" 1>&2
	exit 1
fi

update
check_exist compile_commands.json
grep 'gcc -c foo\.c -o foo\.o' compile_commands.json > /dev/null

eotup
