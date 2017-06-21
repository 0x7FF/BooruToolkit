# Linux ln -s output module

options+="linux - Linux ln -s\n"

function output_linux {
	if [ "$cfg" == "1" ]; then
		while [ ! -d "$librarydir" ]; do read -p "Please enter full directory path to your library (without trailing slash): " librarydir ; done
		while [ ! -d "$sorteddir" ]; do read -p "Please enter full directory path where I should save SORTED files (without trailing slash): " sorteddir ; done
	fi

	if [[ "$1" == "--delete" ]]; then
		echo 'Not implemented.'
		exit 1
	fi

	while read tag; do
		ctag=$(echo $tag | sed -e 's/[^A-Za-z0-9._-]/_/g')
		mkdir $sorteddir/"$ctag" 2>/dev/null || true
		if [[ "$recursive" == 0 ]]; then
			ln -s $librarydir/"$fn" $sorteddir/"$ctag"/"$fn" > /dev/null || true
		else
			basename="$(basename $fn)"
			if [ -f $sorteddir/"$ctag"/"$basename" ]; then echo >&2 "$basename already exists! Skipping..."; break ; fi
			ln -s "$fn" $sorteddir/"$ctag"/"$basename" > /dev/null || true
		fi
	done < ./data/post/$md5-tags.txt
}
