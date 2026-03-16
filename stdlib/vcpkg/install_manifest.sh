#!/bin/sh -e

if [ "$#" -lt 6 ]; then
  echo "usage: $0 <exe> <manifest_dir> <triplet> <prefix> <stamp> <outputs...>" >&2
  exit 1
fi

exe=$1
manifest_dir=$2
triplet=$3
prefix=$4
stamp=$5
shift 5

tmpdir=$(mktemp -d "${TMPDIR:-/tmp}/metatup-vcpkg.XXXXXX")
cleanup() {
  rm -rf "$tmpdir"
}
trap cleanup EXIT INT TERM

install_root="$tmpdir/install"

"$exe" install \
  --x-manifest-root="$manifest_dir" \
  --triplet="$triplet" \
  --x-install-root="$install_root"

for output in "$@"; do
  rel=${output#"$prefix"/}
  if [ "$rel" = "$output" ]; then
    echo "vcpkg helper error: output '$output' is outside prefix '$prefix'" >&2
    exit 1
  fi
  src="$install_root/$triplet/$rel"
  if [ ! -e "$src" ]; then
    echo "vcpkg helper error: expected installed file '$src' was not produced" >&2
    exit 1
  fi
  mkdir -p "$(dirname "$output")"
  if [ -d "$src" ]; then
    rm -rf "$output"
    cp -R "$src" "$output"
  else
    cp "$src" "$output"
  fi
done

mkdir -p "$(dirname "$stamp")"
printf '%s\n' "$triplet" > "$stamp"
