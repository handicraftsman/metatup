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
fbind {
  "family": gcc_family,
  "os": gcc_os,
  "cc": gcc_cc,
  "cxx": gcc_cxx,
  "linker": gcc_linker,
  "ar": gcc_ar
} := call "@std//toolchains" gcc({
  "toolchain/os": "linux"
})

fbind {
  "family": clang_family,
  "os": clang_os,
  "cc": clang_cc,
  "cxx": clang_cxx,
  "linker": clang_linker,
  "ar": clang_ar
} := call "@std//toolchains" clang({
  "toolchain/os": "macos"
})

fbind {
  "family": msvc_family,
  "os": msvc_os,
  "cc": msvc_cc,
  "cxx": msvc_cxx,
  "linker": msvc_linker,
  "ar": msvc_ar
} := call "@std//toolchains" msvc({})

fbind {
  "family": host_family,
  "os": host_os,
  "cc": host_cc,
  "cxx": host_cxx,
  "linker": host_linker,
  "ar": host_ar
} := call "@std//toolchains" host({})

fbind {
  "c_flags": posix_c_flags,
  "link_flags": posix_link_flags
} := call "@std//toolchains" package_flags({
  "toolchain/family": "gcc",
  "package/include_dir": "/deps/include",
  "package/lib_dir": "/deps/lib",
  "package/posix_link_flags": "-lsqlite3"
})

fbind {
  "c_flags": msvc_pkg_c_flags,
  "link_flags": msvc_pkg_link_flags
} := call "@std//toolchains" package_flags({
  "toolchain/family": "msvc",
  "package/include_dir": "C:/deps/include",
  "package/lib_dir": "C:/deps/lib",
  "package/msvc_link_flags": "sqlite3.lib"
})

: |> echo $(gcc_family) $(gcc_os) $(gcc_cc) $(gcc_cxx) $(gcc_linker) $(gcc_ar) |> gcc.txt
: |> echo $(clang_family) $(clang_os) $(clang_cc) $(clang_cxx) $(clang_linker) $(clang_ar) |> clang.txt
: |> echo $(msvc_family) $(msvc_os) $(msvc_cc) $(msvc_cxx) $(msvc_linker) $(msvc_ar) |> msvc.txt
: |> echo $(host_family) $(host_os) $(host_cc) $(host_cxx) $(host_linker) $(host_ar) |> host.txt
: |> echo $(posix_c_flags) $(posix_link_flags) |> pkg-posix.txt
: |> echo $(msvc_pkg_c_flags) $(msvc_pkg_link_flags) |> pkg-msvc.txt
HERE

parse
tup_object_exist . 'echo gcc linux gcc g++ g++ ar'
tup_object_exist . 'echo clang macos clang clang++ clang++ ar'
tup_object_exist . 'echo msvc windows cl cl link lib'
tup_object_exist . 'echo -I/deps/include -L/deps/lib -lsqlite3'
tup_object_exist . 'echo /IC:/deps/include /LIBPATH:C:/deps/lib sqlite3.lib'

if uname -s | grep Linux > /dev/null; then
	tup_object_exist . 'echo gcc linux gcc g++ g++ ar'
fi

eotup
