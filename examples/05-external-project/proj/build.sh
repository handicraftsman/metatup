#! /bin/sh -e
mkdir -p "$BUILD_DIR/out"
. "$BUILD_DIR/config.mk"
printf '%s-%s-header\n' "$NAME" "$VERSION" > "$BUILD_DIR/out/demo.h"
printf '%s-%s-tool\n' "$NAME" "$VERSION" > "$BUILD_DIR/out/demo-tool"
