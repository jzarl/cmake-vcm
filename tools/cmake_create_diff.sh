#!/bin/bash
##
# Author: Johannes Zarl <isilmendil@gmx.net>
# This file is in the public domain.
##
# How to use this:
# 1) Copy the textual documentation of all cmake-releases that you want to
#  compare into the $input_dir. The filenames should reflect the cmake-version,
#  and be sorted correctly. The textual documentation of cmake can be created by
#  running "cmake --help-full"; documentation for older releases of cmake can be
#  found at:  http://www.cmake.org/Wiki/CMake_Released_Versions
# 2) Run this script
#  You can get different kinds of output by setting diff_method to one of the
#  values "diff_long", "diff_short" or "diff_adv", e.g.:
#  diff_method=diff_short ./create_diffs.sh
# 3) View the output-diffs in $output_dir
##
input_dir=doctxt
output_dir=diffs
diff_method=${diff_method:-diff_adv}
version_file=cmake.versions
diff_flags=-ibwBEd

diff_long()
{ #plain text diff
	diff -u $diff_flags "$1" "$2"
}
diff_short()
{ #only diff features, not their content
	old="`tempfile -p old`"
	new="`tempfile -p new`"
	# "features" are on their own lines, with exactly 2 spaces before them
	grep '^\ \ [^ ]' "$1" >"$old"
	grep '^\ \ [^ ]' "$2" >"$new"
	diff --unified=0 $diff_flags --label "$1" "$old"  --label "$2" "$new"
	rm -f "$old" "$new"
}
diff_adv()
{ #like diff_long, but add a little bit of context, i.e. the last feature along with each change
	diff --unified=1 $diff_flags --show-function-line='^  [^ ]' "$1" "$2"
}

if [ ! -d "$output_dir" ]
then
	mkdir "$output_dir"
fi

#sort by version:
ls -1 "$input_dir" |sort -V >"$version_file"
mapfile -t cmake_versions < "$version_file"

let i=1
while [[ "$i" -lt "${#cmake_versions[*]}" ]]
do
	let old=i-1
	outfile="$output_dir/from_${cmake_versions[$old]}_to_${cmake_versions[$i]}.diff"
	echo "Creating diff between ${cmake_versions[$old]} and ${cmake_versions[$i]}"
	$diff_method "$input_dir/${cmake_versions[$old]}" "$input_dir/${cmake_versions[$i]}" >"$outfile"
	let i++
done
