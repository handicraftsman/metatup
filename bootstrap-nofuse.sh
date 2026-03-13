#! /bin/sh -e
# This is similar to bootstrap.sh, except it uses 'tup generate' to build a
# temporary shell script in case tup needs to be built in an environment that
# doesn't support FUSE. The resulting tup binary will still require FUSE to
# operate (on those platforms where it is used).

CFLAGS="-g" ./build.sh

if [ ! -d .metatup ]; then
	./build/metatup init
fi
./build/metatup generate --verbose build-nofuse.sh
./build-nofuse.sh
echo "Build complete. If ./metatup works, you can remove the 'build' directory."
