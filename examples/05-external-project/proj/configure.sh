#! /bin/sh -e
name=$(cat "$SRC_DIR/meta/name.txt")
version=$(cat "$SRC_DIR/meta/version.txt")
printf 'NAME=%s\nVERSION=%s\n' "$name" "$version" > "$BUILD_DIR/config.mk"
