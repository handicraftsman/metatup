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

# Try calling lua functions with missing parameters.

. ./tup.sh

cat > Tupfile.lua << HERE
print(tup.getrelativedir())
HERE
parse_fail_msg "tup.getrelativedir() called with a nil path"

cat > Tupfile.lua << HERE
tup.include()
HERE
parse_fail_msg "tup.include() must be passed a filename as an argument."

cat > Tupfile.lua << HERE
tup.glob()
HERE
parse_fail_msg "tup.glob() must be passed a glob pattern as an argument."

cat > Tupfile.lua << HERE
tup.export()
HERE
parse_fail_msg "tup.export() must be passed an environment variable name as an argument."

cat > Tupfile.lua << HERE
tup.import()
HERE
parse_fail_msg "tup.import() must be passed an environment variable name as an argument."

cat > Tupfile.lua << HERE
tup.nodevariable()
HERE
parse_fail_msg "tup.nodevariable() must be passed a string referring to a node"

cat > Tupfile.lua << HERE
tup.definerule()
HERE
parse_fail_msg "tup.definerule() must be passed a table containing parameters"

cat > Tupfile.lua << HERE
tup.getconfig()
HERE
parse_fail_msg "tup.getconfig() must be passed a config variable name as an argument"

cat > Tupfile.lua << HERE
tup.handle_fileread()
HERE
parse_fail_msg "chdir() must be passed a filename for Windows dependencies"

cat > Tupfile.lua << HERE
tup.run()
HERE
parse_fail_msg "tup.run() must be passed a string for the command-line to run"

eotup
