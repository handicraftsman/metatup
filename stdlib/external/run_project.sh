#!/bin/sh -e

if [ "$#" -lt 11 ]; then
  echo "usage: $0 <srcdir> <brdir> <prefix> <stamp> <configure_script> <build_script> <install_script> <configure_cmd> <build_cmd> <install_cmd> <outputs...>" >&2
  exit 1
fi

srcdir=$1
brdir=$2
prefix=$3
stamp=$4
configure_script=$5
build_script=$6
install_script=$7
configure_cmd=$8
build_cmd=$9
install_cmd=${10}
shift 10

tmpdir=$(mktemp -d "${TMPDIR:-/tmp}/metatup-external.XXXXXX")
cleanup() {
  rm -rf "$tmpdir"
}
trap cleanup EXIT INT TERM

build_root="$tmpdir/build"
install_root="$tmpdir/install"
mkdir -p "$build_root" "$install_root"

if [ -n "$configure_script" ]; then
  SRC_DIR="$srcdir" BUILD_DIR="$build_root" PREFIX_DIR="$install_root" \
    sh "$configure_script"
elif [ -n "$configure_cmd" ]; then
  SRC_DIR="$srcdir" BUILD_DIR="$build_root" PREFIX_DIR="$install_root" \
    sh -ec "$configure_cmd"
fi

if [ -n "$build_script" ]; then
  SRC_DIR="$srcdir" BUILD_DIR="$build_root" PREFIX_DIR="$install_root" \
    sh "$build_script"
elif [ -n "$build_cmd" ]; then
  SRC_DIR="$srcdir" BUILD_DIR="$build_root" PREFIX_DIR="$install_root" \
    sh -ec "$build_cmd"
fi

if [ -n "$install_script" ]; then
  SRC_DIR="$srcdir" BUILD_DIR="$build_root" PREFIX_DIR="$install_root" \
    sh "$install_script"
else
  SRC_DIR="$srcdir" BUILD_DIR="$build_root" PREFIX_DIR="$install_root" \
    sh -ec "$install_cmd"
fi

for output in "$@"; do
  rel=${output#"$prefix"/}
  if [ "$rel" = "$output" ]; then
    echo "external helper error: output '$output' is outside prefix '$prefix'" >&2
    exit 1
  fi
  src="$install_root/$rel"
  if [ ! -e "$src" ]; then
    echo "external helper error: expected installed file '$src' was not produced" >&2
    exit 1
  fi
  mkdir -p "$(dirname "$output")"
  cp "$src" "$output"
done

mkdir -p "$(dirname "$stamp")"
printf '%s\n' "$srcdir" > "$stamp"
