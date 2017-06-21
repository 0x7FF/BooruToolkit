# TMSU output module

options+="tmsu - Linux TMSU\n"

function output_tmsu {
	dependency_check tmsu important

	if [[ "$1" == "--delete" ]]; then
		 tmsu-fs-rm "$2"
	fi

	if [ "$cfg" == "1" ]; then
		while [ ! -d "$librarydir" ]; do read -p "Please enter full directory path to your library (without trailing slash): " librarydir ; done
	fi

	tags=$(xmllint --xpath "post/tags/text()" ./data/post/$md5.txt | recode html..UTF-8 | tr '/' '_'  | tr "\'" "_" | sed -e 's/[^A-Za-z0-9._ -()]/_/g' ) # "
	if [[ "$recursive" == 0 ]]; then
		tmsu tag --tags "$tags" $librarydir/"$fn" || true
	else
		tmsu tag --tags "$tags" "$fn" || true
	fi
}
