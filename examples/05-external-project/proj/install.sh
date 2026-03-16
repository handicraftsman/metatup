#! /bin/sh -e
mkdir -p "$PREFIX_DIR/include" "$PREFIX_DIR/bin"
cp "$BUILD_DIR/out/demo.h" "$PREFIX_DIR/include/demo.h"
cp "$BUILD_DIR/out/demo-tool" "$PREFIX_DIR/bin/demo-tool"
