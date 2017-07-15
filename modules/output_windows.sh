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

	if [[ "$1" == "--init" ]]; then
		echo -e 'This feature works best with Windows 10 Creators Update or newer\nand Developer mode enabled (Settings -> Updates -> For developers)'
		read -p "Are you using Windows 10 Creators update or newer? [Y/n] " -n 1 -r
		if [[ $REPLY =~ ^[Yy]$ ]]; then compatibility=0 ; else compatibility=1 ; fi
		if [[ $compatibility == 0 ]]; then
			read -p "Is your device in Developer Mode? [Y/n] " -n 1 -r
			if [[ $REPLY =~ ^[Yy]$ ]]; then compatibility=0 ; else compatibility=1 ; fi
		fi
		if [[ $compatibility == 1 ]]; then echo "[*] Using compatibility mode." ; fi
	fi

	if [[ "$recursive" == 1 ]] && [[ $compatibility == 1 ]]; then
		# It's not supported yet because of possible regressions with forward and backward slashes.
		echo >&2 'Recursive mode is not supported in compatibility mode. Recursive mode will be disabled!'
		recursive=0
	fi

	if [[ $compatibility == 0 ]]; then
		while read tag; do
			ctag=${echo $tag | sed -e 's/[^A-Za-z0-9._-]/_/g'}
			if [[ "$recursive" != 1 ]]; then
				cmd.exe /c "mklink "$winsorteddir\\$ctag\\$fn" "$winlibrarydir\\$fn"" || true
			else
				cmd.exe /c "mklink "$winsorteddir\\$ctag\\$(basename $fn)" "$winlibrarydir\\$(basename $fn)"" || true
			fi
		done < ./data/post/$md5-tags.txt
	else
		while read tag; do
			ctag=${echo $tag | sed -e 's/[^A-Za-z0-9._-]/_/g'}
			mkdir $sorteddir/"$ctag" 2>/dev/null || true
			echo 'mklink' "$winsorteddir"'\'"$ctag"'\'"$fn" "$winlibrarydir"'\'"$fn" >> ./link.bat
		done < ./data/post/$md5-tags.txt
	fi
}
