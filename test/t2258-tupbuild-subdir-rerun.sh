#! /bin/sh -e
# tup - A file-based build system
#
# Copyright (C) 2026  handicraftsman
#
# This program is free software; you can redistribute it and/or modify
# it under the terms of the GNU General Public License version 2 as
# published by the Free Software Foundation.

. ./tup.sh

projdir=/tmp/t2258-tupbuild-subdir-rerun-$$
rm -rf "$projdir"
mkdir "$projdir"
cd "$projdir"

cat > Tupfile.ini << HERE
# auto-init marker
HERE

cat > Tupfile << HERE
function build_greeter {
  bind whom := "greeter/whom"

  : foreach *.c |> gcc -c %f -DWHOM="\"\$(whom)\"" -o %o |> %B_\$(whom).o {objs}
  : {objs} |> gcc %f -o %o |> ../greeter_\$(whom)
}
HERE

cat > greeter.h << HERE
#ifndef GREETER_H
#define GREETER_H

const char *greeter(void);

#endif
HERE

cat > greeter.c << HERE
#include "greeter.h"

const char *greeter(void)
{
	return WHOM;
}
HERE

cat > main.c << HERE
#include <stdio.h>
#include "greeter.h"

int main(void)
{
	puts(greeter());
	return 0;
}
HERE

mkdir build
cat > build/TupBuild.yaml << HERE
builds:
  - name: foo
    tupfile: ../Tupfile
    function: build_greeter
    builddir: ./greeter_foo
    args:
      "greeter/whom": "foo"
  - name: bar
    tupfile: ../Tupfile
    function: build_greeter
    builddir: ./greeter_bar
    args:
      "greeter/whom": "bar"
HERE

rm -rf .metatup .gitignore

cd build
if ! metatup > ../run1.txt 2>&1; then
	cat ../run1.txt
	exit 1
fi
if ! metatup > ../run2.txt 2>&1; then
	cat ../run2.txt
	exit 1
fi
if ! metatup > ../run3.txt 2>&1; then
	cat ../run3.txt
	exit 1
fi
cd ..

check_exist greeter_foo
check_exist greeter_bar
check_exist build/greeter_foo/__tupbuild_foo.stamp
check_exist build/greeter_bar/__tupbuild_bar.stamp
check_exist build/main_foo.o
check_exist build/main_bar.o

grep -qx "foo" << EOF
`./greeter_foo`
EOF
grep -qx "bar" << EOF
`./greeter_bar`
EOF

if grep ".metatup/mnt" run2.txt > /dev/null; then
	cat run2.txt
	exit 1
fi
if grep ".metatup/mnt" run3.txt > /dev/null; then
	cat run3.txt
	exit 1
fi

cd "$tupcurdir/$tuptestdir"
rm -rf "$projdir"

eotup
