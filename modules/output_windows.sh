# Windows mklink output module

options+="windows - Windows mklink\n"

function output_windows {
	if [ "$cfg" == "1" ]; then
		while [ ! -d "$librarydir" ]; do read -p "Please enter full LINUX directory path to your library (without trailing slash): " librarydir ; done
		while [ ! -d "$sorteddir" ]; do read -p "Please enter full LINUX directory path where I should save SORTED files (without trailing slash): " sorteddir ; done
		while [ ! -d "$winlibrarydir" ]; do read -p "Please enter full WINDOWS directory path to your library (without trailing slash): " winlibrarydir ; done
		while [ ! -d "$winsorteddir" ]; do read -p "Please enter full WINDOWS directory path where I should save SORTED files (without trailing slash): " winsorteddir ; done
	fi

	if [[ "$1" == "--delete" ]]; then
		echo 'Not implemented.'
		exit 1
	fi

	if [[ "$recursive" == 1 ]]; then
		# It's not supported yet because of possible regressions with forward and backward slashes.
		echo >&2 'Recursive mode is not supported on Windows yet. Recursive mode will be disabled!'
		recursive=0
	fi

	while read tag; do
		ctag=${echo $tag | sed -e 's/[^A-Za-z0-9._-]/_/g'}
		mkdir $sorteddir/"$ctag" 2>/dev/null || true
		echo 'mklink' "$winsorteddir"'\'"$ctag"'\'"$fn" "$winlibrarydir"'\'"$fn" >> ./hardlink.bat
	done < ./data/post/$md5-tags.txt
}
