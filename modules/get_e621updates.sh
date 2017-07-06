# download e621 updates for any combinations of tags

options+="dlu - download updates for queries\n"
dlucfglist="./trackedqueries.cfg"

function sort_files2 {
	echo "[*] Parsing file lists... "
	while [[ $query != 0 ]]; do
		xmllint --xpath '//post/file_url/text()' ./data/query$query.txt >> ./data/all.txt #'
		if [[ "$baseurl" == *https* ]]; then
			sed -i 's/https/\nhttps/g' ./data/all.txt
		else
			sed -i 's/http/\nhttp/g' ./data/all.txt
		fi
		((query--))
	done
	if [[ "$force_http" == "1" ]]; then sed -i 's/https/http/g' ./data/all.txt ; fi

	sort_files
}

function output_dlu {
	if [[ "$1" == "--delete" ]]; then
		 echo "DLU - Not applicable."
		 exit 1
	fi

	if [[ "$1" == "--selected" ]]; then
		 cfg=1
		 set +e
		 return 0
	fi

	if [[ "$1" == "--init" ]]; then
		 no_tags=1
		 no_sort=1
		 database="processed_e621updater.txt"
		 if [ "$dlucfg" != "1" ]; then
			 # set things to check
			 echo "Welcome to e621 updater. This module will download new images for your queries."
			 echo "WARNING: This module is in beta. Some special characters may not work."
			 if [ -d "$sorteddir" ]; then
				 if [[ "$2" != "--update" ]]; then
					 echo "[!] Files will be saved to $sorteddir"
					 read -p "Do you wish to continue with this path? [Y/n] " -n 1 -r
					 if [[ $REPLY =~ ^[Yy]$ ]]; then
						 length=${#sorteddir}
						 last_char=${sorteddir:length-1:1}
						 [[ $last_char != "/" ]] && sorteddir="$sorteddir/"; :
						 cont=1
						 dlucfg=1
					 else
						 unset sorteddir
						 echo
					 fi
				 else
					 cont=1
					 dlucfg=1
				 fi
			 fi
			 while [ "$cont" != 1 ]; do
				 while [ ! -d "$sorteddir" ]; do read -p "Please enter full directory path where I should save downloaded files (with trailing slash): " sorteddir ; mkdir "$sorteddir" ; done
				 echo "Your currently tracked queries:"
				 cat $dlucfglist 2>/dev/null || true
				 read -p "Enter a query to track (leave blank when done): " query
				 if [ ! -z "$query" ]; then
				 	echo "$query" >> $dlucfglist
			 	 else
				 	cont=1
			   fi
			 done
			 if [ "$dlucfg" != "1" ]; then
				 read -p "How many images to check for at once? (recommended: 20)" limit
				 dlucfg=1
				 read -p "Do you wish to save these settings? [Y/n] " -n 1 -r
		 		 echo
		 		 if [[ $REPLY =~ ^[Yy]$ ]]; then
					 echo dlucfg=$dlucfg >> ./settings.cfg
					 echo limit=$limit >> ./settings.cfg
					 echo sorteddir=$sorteddir >> ./settings.cfg
				 fi
			 fi
		 fi
		 return 0
	fi

	echo -e "\n[*] Downloading updates..."
	if [ ! -s $dlucfglist ]; then echo >&2 'Fatal error: trackedqueries.cfg not found. Aborting.' && exit 1 ; fi
	while read in; do
		((query++))
		echo "[*] Processing query $in"
		convquery=$(echo $in | recode UTF-8..html | tr ' ' '+')
	  curl -A "BooruToolkit/$VERSION (+https://e621.net/forum/show/233498)" -s -S "$baseurl/post/index.xml?limit=$limit&tags=$convquery" >> ./data/query$query.txt
	  sleep $sleeprate || sleep 0.4 # rate limiter
	done < $dlucfglist

	sort_files2

	echo "[*] Found `cat ./data/pending.txt | wc -l` new files."
	echo "[*] Downloading new images..."
	wget -nv --user-agent="BooruToolkit/$VERSION (+https://e621.net/forum/show/233498)" -nc -i ./data/pending.txt -P $sorteddir
	cat ./data/pending.txt >> $database
}
