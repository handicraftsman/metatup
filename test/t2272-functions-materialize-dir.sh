#! /bin/sh -e
# tup - A file-based build system
#
# Copyright (C) 2026  handicraftsman
#
# This program is free software; you can redistribute it and/or modify
# it under the terms of the GNU General Public License version 2 as
# published by the Free Software Foundation.

. ./tup.sh

mkdir -p src/bin src/include
printf 'tool\n' > src/bin/tool
printf 'header\n' > src/include/tool.h

cat > Tupfile << HERE
function gen {
  fbind bins := dist {
    at "." as src/bin/tool => at "/bin" as tool
  }

  fbind headers := dist {
    at "." as src/include/tool.h => at "/include" as tool.h
  }

  fbind dist := dist {
    mounts \$(bins) at "/"
    mounts \$(headers) at "/"
  }

  fbind dir := materialize "\$(dist)" "./stage"

  : \$(dir) |> printf '%%s\n' %f > %o |> local-dir.txt

  return { "dir": "\$(dir)" }
}

fbind { "dir": dir } := call gen({})

: \$(dir) |> printf '%%s\n' %f > %o |> root-dir.txt
: \$(dir)/bin/tool |> cp %f %o |> copy/bin/tool
: \$(dir)/include/tool.h |> cp %f %o |> copy/include/tool.h
HERE

update
check_exist stage/bin/tool
check_exist stage/include/tool.h
check_exist local-dir.txt
check_exist root-dir.txt
check_exist copy/bin/tool
check_exist copy/include/tool.h
grep -qx 'stage' local-dir.txt
grep -qx 'stage' root-dir.txt
grep -qx 'tool' copy/bin/tool
grep -qx 'header' copy/include/tool.h

eotup
