#! /bin/sh -e
# Try to use the nearest Tupfile.ini to automatically call init when 'tup' is run.

. ./tup.sh

tmpdir="/tmp/tup-t4160-$$"
cleanup()
{
	cd /tmp
	rm -rf $tmpdir
}

trap cleanup EXIT INT TERM
cleanup
mkdir -p $tmpdir/top/sub
cd $tmpdir/top
touch Tupfile.ini
cd sub
touch Tupfile.ini

output="$tupcurdir/$tuptestdir/output.txt"
# This should initialize in top/sub, not top.
metatup > $output

if ! grep "Initializing .metatup in.*/top/sub" $output > /dev/null; then
	echo "Error: Expecting tup to initialize in top/sub" 1>&2
	cat $output 1>&2
	exit 1
fi

if [ ! -d .metatup ]; then
	echo "Error: .metatup directory not found in top/sub" 1>&2
	exit 1
fi

if [ -d ../.metatup ]; then
	echo "Error: .metatup directory should not be in top" 1>&2
	exit 1
fi

# Now test that it stops even if a project exists higher up
cd $tmpdir/top
metatup init --no-sync
if [ ! -d .metatup ]; then
	echo "Error: Failed to manually init in top" 1>&2
	exit 1
fi

cd sub
rm -rf .metatup
# At this point:
# /tmp/tup-t4160/top/.metatup exists
# /tmp/tup-t4160/top/sub/Tupfile.ini exists
# Running 'metatup' in sub should now initialize /tmp/tup-t4160/top/sub/.metatup
# instead of using the parent project.

metatup > $output
if ! grep "Initializing .metatup in.*/top/sub" $output > /dev/null; then
	echo "Error: Expecting tup to initialize in top/sub even with parent project" 1>&2
	cat $output 1>&2
	exit 1
fi

if [ ! -d .metatup ]; then
	echo "Error: .metatup directory not found in top/sub (second run)" 1>&2
	exit 1
fi

# Now test that it still finds a parent Tupfile.ini if no closer one exists
rm -rf $tmpdir/top
mkdir -p $tmpdir/top/sub
cd $tmpdir/top
touch Tupfile.ini
cd sub
# At this point:
# /tmp/tup-t4160/top/Tupfile.ini exists
# No Tupfile.ini or .metatup in top/sub

metatup > $output
if ! grep "Initializing .metatup in.*/top" $output > /dev/null; then
	echo "Error: Expecting tup to initialize in top (parent dir search)" 1>&2
	cat $output 1>&2
	exit 1
fi

if [ ! -d ../.metatup ]; then
	echo "Error: .metatup directory not found in top" 1>&2
	exit 1
fi

eotup
