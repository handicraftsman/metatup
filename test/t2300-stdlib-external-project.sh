#! /bin/sh -e
# tup - A file-based build system
#
# Copyright (C) 2026  handicraftsman
#
# This program is free software; you can redistribute it and/or modify
# it under the terms of the GNU General Public License version 2 as
# published by the Free Software Foundation.

. ./tup.sh

mkdir -p proj/meta

cat > proj/meta/name.txt << 'HERE'
demo
HERE

cat > proj/meta/version.txt << 'HERE'
one
HERE

cat > proj/configure.sh << 'HERE'
#! /bin/sh -e
name=$(cat "$SRC_DIR/meta/name.txt")
version=$(cat "$SRC_DIR/meta/version.txt")
printf 'NAME=%s\nVERSION=%s\n' "$name" "$version" > "$BUILD_DIR/config.mk"
HERE

cat > proj/build.sh << 'HERE'
#! /bin/sh -e
mkdir -p "$BUILD_DIR/out"
. "$BUILD_DIR/config.mk"
printf '%s-%s-header\n' "$NAME" "$VERSION" > "$BUILD_DIR/out/demo.h"
printf '%s-%s-tool\n' "$NAME" "$VERSION" > "$BUILD_DIR/out/demo-tool"
HERE

cat > proj/install.sh << 'HERE'
#! /bin/sh -e
mkdir -p "$PREFIX_DIR/include" "$PREFIX_DIR/bin"
cp "$BUILD_DIR/out/demo.h" "$PREFIX_DIR/include/demo.h"
cp "$BUILD_DIR/out/demo-tool" "$PREFIX_DIR/bin/demo-tool"
HERE

cat > Tupfile << 'HERE'
fbind {
  "prefix": prefix,
  "include_dir": include_dir,
  "bin_dir": bin_dir,
  "stamp": stamp
} := call "@std//external" project({
  "brdir": "./build/ext",
  "external/srcdir": "./proj",
  "external/inputs": "./proj/meta/name.txt ./proj/meta/version.txt ./proj/configure.sh ./proj/build.sh ./proj/install.sh",
  "external/configure_script": "./proj/configure.sh",
  "external/build_script": "./proj/build.sh",
  "external/install_script": "./proj/install.sh",
  "external/install_cmd": "",
  "external/export_files": "include/demo.h bin/demo-tool"
})

: $(prefix)/include/demo.h $(prefix)/bin/demo-tool |> cat %f > %o |> app.txt
HERE

update
check_exist build/ext/external_prefix/include/demo.h
check_exist build/ext/external_prefix/bin/demo-tool
check_exist build/ext/external_project.stamp
check_exist app.txt
grep -qx 'demo-one-header' build/ext/external_prefix/include/demo.h
grep -qx 'demo-one-tool' build/ext/external_prefix/bin/demo-tool
printf 'demo-one-header\ndemo-one-tool\n' | diff - app.txt

cat > proj/meta/version.txt << 'HERE'
two
HERE

update
grep -qx 'demo-two-header' build/ext/external_prefix/include/demo.h
grep -qx 'demo-two-tool' build/ext/external_prefix/bin/demo-tool
printf 'demo-two-header\ndemo-two-tool\n' | diff - app.txt

eotup
