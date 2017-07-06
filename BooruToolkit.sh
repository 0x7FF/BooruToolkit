#!/bin/bash

# BooruToolkit, version 2.3
# This application is licensed under MIT, read LICENSE for more information
# Copyright 2017 Ray Volkov (hexl on e621)

cd "${BASH_SOURCE%/*}" || exit
if [[ "$1" == "-h" ]] || [[ "$1" == "--help" ]] || [[ "$1" == "-?" ]]; then
  echo -e "Usage: ./BooruToolkit.sh {argument}\n\n"
  echo -e "   --delete\n          delete a local file and properly untag it"
  echo -e "   --update\n          skip all prompts and update new files"
  echo -e "   --rescan\n          do a full re-tag of local library (CAUTION)\n"
  exit 0
fi

echo "[*] Initializing..."
set -e

# DO NOT MODIFY THESE VALUES, USE settings.cfg INSTEAD
VERSION=2.3
baseurl="https://e621.net"
database="processed.txt"
sleeprate=0.4
recursive=0
no_tags=0
dbg=0
if [[ "$1" == "--update" ]]; then update=1 ; fi
source ./settings.cfg >/dev/null 2>&1 || true

# Functions
function xmllint-compat {
  if [[ "$2" == "tags" ]]; then
    xmllint --xpath "post/tags/text()" ./data/post/$1.txt | tr " " "\n" | recode html..UTF-8 > ./data/post/$1-tags.txt #"
  else
    xmllint --xpath "post/$2/text()" ./data/post/$1.txt | recode html..UTF-8 #"
  fi
}

function sort_files {
  echo "[*] Sorting file lists..."
  sort -u -o ./data/processed_s.txt ./$database
  sort -u -o ./data/all_s.txt ./data/all.txt
  echo "[*] Searching for new files..."
  diff -u ./data/processed_s.txt ./data/all_s.txt | grep -E "^\+" | grep -v '+ ./data' | grep -v "(standard input)" | cut -c 2- > ./data/pending.txt
  echo "Found `cat ./data/pending.txt | wc -l` new files"
}

function proc {
	fn="$1" # fn - full name (image.jpg); in recursive mode this becomes the full path!
  if [[ "$dbg" == "1" ]]; then echo "DEBUG: proc started"; fi
	if [[ "$recursive" == 0 ]]; then
		fn=`basename $1`
	fi

	# check if the filename is already an MD5
	if [[ "$fn" == "[a-f0-9]{32}"* ]]; then
		md5=${fn:0:32}
	else
		if [[ "$recursive" == 0 ]]; then
			md5=`md5sum "$librarydir/$fn" | cut -c -32`
		else
			md5=`md5sum "$1" | cut -c -32`
		fi
	fi

	# check if we already have tags cached, otherwise download them
  # fun fact: you can use other imageboards by overriding this function
  download $md5

  # extract metadata from the file
  # takes an MD5 and what to extract (tags,id,whatever) as arguments
  xmllint-compat $md5 tags

	# final step: actually sort the files
  if [[ "$no_tags" != 1 ]]; then
  	if [ -s ./data/post/$md5-tags.txt ]; then
  		output_$platform $md5 $fn
  		echo "$fn"
  	else
  		echo >&2 "$fn did not return any tags, moving on..."
  	fi
  else
    output_$platform $md5 $fn
    echo "$fn"
  fi

	echo "$fn" >> ./$database
}

# Function to initialize folders
function btinit {
	# rm -rf ./data/ 2>/dev/null || true # we reuse the post info if full re-scan is started, only remove the folder if necessary
	rm -f ./data/*.txt 2>/dev/null || true
	mkdir ./data 2>/dev/null || true
	mkdir ./data/post 2>/dev/null || true
  if [ ! -f ./$database ]; then >./$database ; fi
}

function rescan {
  >./$database
  echo '[*] Database cleared sucessfully.'
}

command_exists () {
    hash "$1" &> /dev/null ;
}

dependency_check () {
  if [[ $2 == "important" ]]; then
    command -v $1 >/dev/null 2>&1 || { echo >&2 "This feature requires $1 but it's not installed. Aborting."; exit 1; }
  else
    command -v $1 >/dev/null 2>&1 || { echo >&2 "I require $1 but it's not installed."; err=1; }
  fi
}

# Load extra functionality
for file in modules/* ; do
  if [ -f "$file" ] && [[ "$file" == *".sh" ]]; then
    . "$file"
    echo "[+] $file module loaded"
  fi
done

if [[ "$1" == "--delete" ]]; then
  if [ "$cfg" != "1" ] ; then echo >&2 "Please configure this script first by running without --delete" && exit 1; fi
  output_$platform --delete "$2" || true
fi

# Check for required software
dependency_check curl
dependency_check xmllint
dependency_check diff
dependency_check recode
dependency_check md5sum
dependency_check sed
if [ "$err" == 1 ]; then echo >&2 "One or more dependencies are missing.  Aborting." && exit 1; fi

btinit
if [ "$1" == "--update" ] && [ "$cfg" != "1" ] ; then echo >&2 "Please configure this script first by running without --update" && exit 1; fi
if [ "$1" == "--rescan" ] ; then rescan ; fi

# main menu
if [[ "$1" != "--update" ]]; then
  echo
  echo 'How would you like to tag your files?'
  echo -e "\n$options"
  read -p "Your choice: " platform

  if [ "$cfg" == "1" ]; then
    echo -e "\nYour settings are:\nPlatform=$platform\nLibrary path=$librarydir\nSorted path=$sorteddir"
    if [[ "$platform" == "windows"* ]]; then echo -e ""Windows library path="'$winlibrarydir'\n"Windows sorted path="'$winsorteddir'" ; fi
    echo && read -p "Do you wish to change these settings? [y/N] " -n 1 -r
    echo
    if [[ $REPLY =~ ^[Yy]$ ]]; then cfg=0 ; librarydir= ; fi
  fi
fi

# in case you need to disable configurator you can set cfg=1 at this step
output_$platform --selected || true

# if no configuration found, perform first time setup
if [ "$cfg" != "1" ]; then
  # set paths
	# note to self: file picker should be a function
 if [[ "$platform" == "windows"* ]]; then
	 echo 'Please use Linux paths for these settings (i.e. /mnt/c/path/to/whatever instead of C:\path\to\whatever)'
	 while [ ! -d "$librarydir" ]; do read -p "Please enter full directory path to your library (without trailing slash): " librarydir ; done
	 while [ ! -d "$sorteddir" ]; do read -p "Please enter full directory path where I should save SORTED files (without trailing slash): " sorteddir ; done
	 echo -e '\nNow use Windows paths for these settings (i.e. C:\path\to\whatever)'
	 while [ ! -d "$winlibrarydir" ]; do read -p "Please enter full directory path to your library (without trailing slash): " winlibrarydir ; done
	 while [ ! -d "$winsorteddir" ]; do read -p "Please enter full directory path where I should save SORTED files (without trailing slash): " winsorteddir ; done
 else
	  if command_exists zenity ; then
			librarydir=$(zenity --file-selection --directory --title="Choose your library directory" 2> /dev/null)
			if [[ "$platform" != "tmsu"* ]]; then sorteddir=$(zenity --file-selection --directory --title="Choose where to save sorted files" 2> /dev/null); fi
		else
			while [ ! -d "$librarydir" ]; do read -p "Please enter full directory path to your library (without trailing slash): " librarydir ; done
			if [[ "$platform" != "tmsu"* ]]; then
				while [ ! -d "$sorteddir" ]; do read -p "Please enter full directory path where I should save SORTED files (without trailing slash): " sorteddir ; done
			fi
		fi

    cfg=1
		echo -e "\nYour settings:\nPlatform=$platform\nLibrary path=$librarydir\nSorted path=$sorteddir"
		if [[ "$platform" == "windows"* ]]; then echo -e ""Windows library path="'$winlibrarydir'\n"Windows sorted path="'$winsorteddir'" ; fi
		echo && read -p "Do you wish to save these settings? [Y/n] " -n 1 -r
		echo
		if [[ $REPLY =~ ^[Yy]$ ]]
		then
			echo cfg=1 >> ./settings.cfg
			echo platform="$platform" >> ./settings.cfg
			echo librarydir="$librarydir" >> ./settings.cfg
			echo sorteddir="$sorteddir" >> ./settings.cfg
			if [[ "$platform" == "windows"* ]]; then echo winlibrarydir='$winlibrarydir' >> ./settings.cfg ; fi
			if [[ "$platform" == "windows"* ]]; then echo winsorteddir='$winsorteddir' >> ./settings.cfg ; fi
		fi
	fi
fi

# let modules do initial setup if they need to
if [[ "$1" == "--update" ]]; then
  output_$platform --init --update || true
else
  output_$platform --init || true
fi

if [[ "$no_sort" != 1 ]]; then
  cp ./$database ./$database.backup || true # backup processed file list in case something goes wrong
  if [[ "$recursive" == 0 ]]; then
  	find $librarydir -maxdepth 1 -type f > ./data/all.txt
  else
  	find $librarydir -type f > ./data/all.txt
  fi

  # Sort files and prep them for diff
  sort_files
fi

if [[ "$no_tags" != 1 ]]; then
  echo "[*] Processing files..."
  while read in; do proc "$in"; done < ./data/pending.txt
else
  output_$platform
fi

echo 'Program done!'
exit 0
