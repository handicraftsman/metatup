#! /bin/sh -e
# tup - A file-based build system
#
# Copyright (C) 2026  handicraftsman
#
# This program is free software; you can redistribute it and/or modify
# it under the terms of the GNU General Public License version 2 as
# published by the Free Software Foundation.

. ./tup.sh

mkdir fakevcpkg manifest

cat > fakevcpkg/vcpkg << 'HERE'
#! /bin/sh -e

cmd=$1
shift

manifest_root=
triplet=
install_root=

for arg in "$@"; do
  case "$arg" in
    --x-manifest-root=*)
      manifest_root=${arg#--x-manifest-root=}
      ;;
    --triplet=*)
      triplet=${arg#--triplet=}
      ;;
    --x-install-root=*)
      install_root=${arg#--x-install-root=}
      ;;
  esac
done

test "$cmd" = install
test -n "$manifest_root"
test -n "$triplet"
test -n "$install_root"

name=$(sed -n 's/.*"name"[[:space:]]*:[[:space:]]*"\([^"]*\)".*/\1/p' "$manifest_root/vcpkg.json")
baseline=$(sed -n 's/.*"baseline"[[:space:]]*:[[:space:]]*"\([^"]*\)".*/\1/p' "$manifest_root/vcpkg-configuration.json")

mkdir -p "$install_root/$triplet/include" "$install_root/$triplet/lib" "$install_root/$triplet/bin"
printf '%s-%s-header\n' "$name" "$baseline" > "$install_root/$triplet/include/fake.h"
printf '%s-%s-lib\n' "$name" "$baseline" > "$install_root/$triplet/lib/libfake.a"
printf '%s-%s-tool\n' "$name" "$baseline" > "$install_root/$triplet/bin/fake-tool"
HERE
chmod +x fakevcpkg/vcpkg

cat > manifest/vcpkg.json << 'HERE'
{
  "name": "demo"
}
HERE

cat > manifest/vcpkg-configuration.json << 'HERE'
{
  "baseline": "one"
}
HERE

cat > Tupfile << 'HERE'
fbind {
  "prefix": prefix,
  "include_dir": include_dir,
  "lib_dir": lib_dir,
  "bin_dir": bin_dir,
  "stamp": stamp
} := call "@std//vcpkg" install_manifest({
  "brdir": "./build",
  "vcpkg/exe": "./fakevcpkg/vcpkg",
  "vcpkg/manifest_dir": "./manifest",
  "vcpkg/manifest_inputs": "./manifest/vcpkg.json ./manifest/vcpkg-configuration.json",
  "vcpkg/triplet": "x64-linux",
  "vcpkg/export_files": "include/fake.h lib/libfake.a bin/fake-tool"
})

: $(prefix)/include/fake.h $(prefix)/bin/fake-tool |> cat %f > %o |> app.txt
HERE

update
check_exist .metatup/repos/std/vcpkg/Tupfile
check_exist build/vcpkg_installed/x64-linux/include/fake.h
check_exist build/vcpkg_installed/x64-linux/lib/libfake.a
check_exist build/vcpkg_installed/x64-linux/bin/fake-tool
check_exist build/vcpkg_x64-linux.stamp
check_exist app.txt
grep -qx 'demo-one-header' build/vcpkg_installed/x64-linux/include/fake.h
grep -qx 'demo-one-lib' build/vcpkg_installed/x64-linux/lib/libfake.a
grep -qx 'demo-one-tool' build/vcpkg_installed/x64-linux/bin/fake-tool
printf 'demo-one-header\ndemo-one-tool\n' | diff - app.txt

cat > manifest/vcpkg-configuration.json << 'HERE'
{
  "baseline": "two"
}
HERE

update
grep -qx 'demo-two-header' build/vcpkg_installed/x64-linux/include/fake.h
grep -qx 'demo-two-lib' build/vcpkg_installed/x64-linux/lib/libfake.a
grep -qx 'demo-two-tool' build/vcpkg_installed/x64-linux/bin/fake-tool
printf 'demo-two-header\ndemo-two-tool\n' | diff - app.txt

eotup
