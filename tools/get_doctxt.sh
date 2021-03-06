#!/bin/bash
##
# Author: Johannes Zarl <isilmendil@gmx.net>
# This file is in the public domain.
##
output_dir=doctxt

grep_pre()
{
	sed -n '/^<pre>/,/^<\/pre>/ { /^<\/\?pre>/ d ; p }'
}

decode_entities()
{
	sed  's/&lt;/</g ; s/&gt;/>/g ; s/&quot;/"/g ; s/&nbsp;/ /g ; s/&amp;/\&/g'
}

mark_sections()
{ #add the version to the section headers so they are visible in the diff:
	sed 's/^\(Options\|Commands\|Standard CMake Modules\)$/\1 '$version'/' |\
		sed 's/^\(Properties\|Properties of Global Scope\|Properties on Directories\|Properties on Targets\|Properties on Tests\|Properties on Source Files\|Properties on Cache Entries\)$/\1 '$version'/' |\
		sed 's/^\(Policies\|Variables\|Variables That Change Behavior\|Variables That Describe the System\|Variables for Languages\|Variables that Control the Build\|Variables that Provide Information\)$/\1 '$version'/'
}

for version
do
	if ! echo "$version" |grep -q '^[1-9]\.[0-9]\.[0-9]*$'
	then
		echo "Version '$version' doesn't match pattern 'x.y.z'!" >&2
		echo "Usage: $0 <version1> [... <versionN>]" >&2
		echo "Downloads the documentation for a given cmake version from the cmake wiki."
		echo "E.g.: $0 2.8.7 2.8.8"
		exit 1
	fi

	outfile="$output_dir/cmake-$version.txt"
	if [ -f "$outfile" ]
	then
		echo "Documentation text for version $version is already available in file $outfile..." >&2
		continue
	fi
	echo "Downloading documentation for cmake version $version..." >&2
	wikiurl="http://www.cmake.org/Wiki/CMake_${version}_Docs"
	tmpfile=`mktemp`
	if ! wget -nv --progress=dot -O "$tmpfile"  "$wikiurl" 
	then
		echo "Something went wrong. Please check if the URL $wikiurl is correct!" >&2
		rm -f "$tmpfile"
		continue
	fi
	cat "$tmpfile" | grep_pre | decode_entities | mark_sections > "$outfile"
	rm "$tmpfile"
done
