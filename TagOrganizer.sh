#!/bin/bash

# e621TagOrganizer, version 2.1
# This application is licensed under MIT, read LICENSE for more information
# Copyright 2017 Ray Volkov (hexl on e621)

set -e

# DO NOT MODIFY THESE VALUES, USE settings.cfg INSTEAD
baseurl="https://e621.net"
sleeprate=0.4
dbg=0
recursive=0

source ./settings.cfg >/dev/null 2>&1 || true

# Methods
function output_windows {
	if [[ "$dbg" == "1" ]]; then echo "Debug: output_windows called"; fi
	while read tag; do
		ctag=${echo $tag | sed -e 's/[^A-Za-z0-9._-]/_/g'}
		mkdir $sorteddir/"$ctag" 2>/dev/null || true
		echo 'mklink' "$winsorteddir"'\'"$ctag"'\'"$fn" "$winlibrarydir"'\'"$fn" >> ./hardlink.bat
	done < ./data/post/$md5-tags.txt
}

function output_linux {
	if [[ "$dbg" == "1" ]]; then echo "Debug: output_linux called"; fi
	while read tag; do
		ctag=$(echo $tag | sed -e 's/[^A-Za-z0-9._-]/_/g')
		mkdir $sorteddir/"$ctag" 2>/dev/null || true
		ln -s $librarydir/"$fn" $sorteddir/"$ctag"/"$fn" > /dev/null || true
	done < ./data/post/$md5-tags.txt
}

function output_tmsu {
	if [[ "$dbg" == "1" ]]; then echo "Debug: output_tmsu called"; fi
	tags=$(xmllint --xpath "post/tags/text()" ./data/post/$md5.txt | recode html..UTF-8 | tr '/' '_'  | tr "\'" "_" | sed -e 's/[^A-Za-z0-9._ -()]/_/g' ) # "
	tmsu tag --tags "$tags" $librarydir/"$fn" || true
}

function output_custom {
	# this is a template that you can use to implement your own tagging method.
	# for example, tracker
	# Please read MODIFY for more information.
	if [[ "$dbg" == "1" ]]; then echo "Debug: output_custom called"; fi
	echo "[Simulated] Linking $librarydir/"$fn" to $sorteddir/"$ctag"/"$fn""
}

# Main function
function proc {
	if [[ "$dbg" == "1" ]]; then echo "Debug: proc called"; fi
	fn="$1" # fn - full name (image.jpg)

	# check if the filename is already an MD5
	if [[ "$dbg" == "1" ]]; then echo "Debug: proc is checking MD5"; fi
	if [[ "$fn" == "[a-f0-9]{32}"* ]]; then
		md5=${fn:0:32}
	else
		md5=`md5sum "$librarydir/$fn" | awk '{ print $1 }'`
	fi

	# check if we already have tags available, otherwise download them
	if [ ! -f ./data/post/$md5-tags.txt ]; then
		if [[ "$dbg" == "1" ]]; then echo "Debug: downloading tags"; fi
		curl -A "TagOrganizer/2.0 (by hexl on e621 using curl)" -s "$baseurl/post/show.xml?md5=$md5" > ./data/post/$md5.txt
		xmllint --xpath "post/tags/text()" ./data/post/$md5.txt | tr " " "\n" | recode html..UTF-8 > ./data/post/$md5-tags.txt #"
		sleep $sleeprate # rate limiter
	fi

	# final step: actually sort the files
	if [ -s ./data/post/$md5-tags.txt ]; then
		if [[ "$platform" == "linux" ]]; then output_linux; fi
		if [[ "$platform" == "windows" ]]; then output_windows; fi
		if [[ "$platform" == "tmsu" ]]; then output_tmsu; fi
		if [[ "$platform" == "custom" ]]; then output_custom; fi
		echo "$fn"
	else
		echo "$fn did not return any tags, moving on..."
	fi

	echo "$fn" >> ./processed.txt
	if [[ "$dbg" == "1" ]]; then echo "Debug: proc end"; fi
}

# Fuction to initialize folders
function tagorginit {
	# rm -rf ./data/ 2>/dev/null || true # we reuse the post info if full re-scan is started, only remove the folder if absolutely necessary
	rm -f ./data/*.txt 2>/dev/null || true
	mkdir ./data 2>/dev/null || true
	mkdir ./data/post 2>/dev/null || true
	if [ ! -f ./processed.txt ]; then
		>./processed.txt
	fi
}

# License agreement
function liccheck {
	echo "[*] Reading license agreement..."
	if [ -f ./LICENSE ]; then
		cat ./LICENSE
		echo
		read -p "Do you accept the license agreement? [Y/n] " -n 1 -r
		echo
		if [[ $REPLY =~ ^[Yy]$ ]]
		then
			licenseaccepted=y
			echo licenseaccepted="$licenseaccepted" >> ./settings.cfg
		else
			exit 1
		fi
	else
		read -p "I couldn't find the LICENSE file, so we'll just assume that you've read it already. Press ENTER if you accept the license agreement or Ctrl+C if you don't."
		licenseaccepted=y
		echo licenseaccepted="$licenseaccepted" >> ./settings.cfg
	fi
}

command_exists () {
    hash "$1" &> /dev/null ;
}
# functions end

# Check for required software
command -v curl >/dev/null 2>&1 || { echo >&2 "I require curl but it's not installed."; err=1; }
command -v xmllint >/dev/null 2>&1 || { echo >&2 "I require xmllint but it's not installed."; err=1; }
command -v diff >/dev/null 2>&1 || { echo >&2 "I require diff but it's not installed."; err=1; }
command -v recode >/dev/null 2>&1 || { echo >&2 "I require recode but it's not installed."; err=1; }
command -v md5sum >/dev/null 2>&1 || { echo >&2 "I require md5sum but it's not installed."; err=1; }
command -v sed >/dev/null 2>&1 || { echo >&2 "I require sed but it's not installed."; err=1; }
if [ "$err" == 1 ]; then echo "One or more dependencies are missing.  Aborting." && exit 1; fi

# Initialize folders, variables etc.
echo "[*] Initializing..."
tagorginit

# Display the license if it hasn't been read before
if [ "$licenseaccepted" != y ]; then liccheck; fi

# if no configuration found, ask user
if [ "$cfg" != "1" ]
then
	echo -e "No configuration file found, running first-time setup.\n"

	PS3='How would you like to tag your files? '
	options=("Windows mklink" "Linux ln" "Linux TMSU" "Custom")
	select opt in "${options[@]}"
	do
	    case $opt in
	        "Windows mklink")
	            platform="windows"
							break
	            ;;
	        "Linux ln")
	            platform="linux"
							break
	            ;;
						"Linux TMSU")
			        platform="tmsu"
							command -v tmsu >/dev/null 2>&1 || { echo >&2 "This feature requires TMSU but it's not installed. Aborting."; exit 1; }
							echo -e "\nDo not forget to tmsu init ~ if you haven't done it already!"
			   			break
		         ;;
	        "Custom")
	            platform="custom"
							break
	            ;;
	        *) echo invalid option;;
	    esac
 done

  # set paths
 if [[ "$platform" == "windows" ]]; then
	 echo 'Please use Linux paths for these settings (i.e. /mnt/c/path/to/whatever instead of C:\path\to\whatever)'
	 while [ ! -d "$librarydir" ]; do read -p "Please enter full directory path to your library (without trailing slash): " librarydir ; done
	 while [ ! -d "$sorteddir" ]; do read -p "Please enter full directory path where I should save SORTED files (without trailing slash): " sorteddir ; done
	 echo -e '\nNow use Windows paths for these settings (i.e. C:\path\to\whatever)'
	 while [ ! -d "$winlibrarydir" ]; do read -p "Please enter full directory path to your library (without trailing slash): " winlibrarydir ; done
	 while [ ! -d "$winsorteddir" ]; do read -p "Please enter full directory path where I should save SORTED files (without trailing slash): " winsorteddir ; done
 else
	  if command_exists zenity ; then
			librarydir=$(zenity --file-selection --directory --title="Choose your library directory" 2> /dev/null)
			if [[ "$platform" != "tmsu" ]]; then sorteddir=$(zenity --file-selection --directory --title="Choose where to save sorted files" 2> /dev/null); fi
		else
			while [ ! -d "$librarydir" ]; do read -p "Please enter full directory path to your library (without trailing slash): " librarydir ; done
			if [[ "$platform" != "tmsu" ]]; then
				while [ ! -d "$sorteddir" ]; do read -p "Please enter full directory path where I should save SORTED files (without trailing slash): " sorteddir ; done
			fi
		fi

		echo -e "\nYour settings:\nPlatform=$platform\nLibrary path=$librarydir\nSorted path=$sorteddir"
		if [[ "$platform" == "windows" ]]; then echo -e ""Windows library path="'$winlibrarydir'\n"Windows sorted path="'$winsorteddir'" ; fi
		echo && read -p "Do you wish to save these settings? [Y/n] " -n 1 -r
		echo
		if [[ $REPLY =~ ^[Yy]$ ]]
		then
			cfg=1
			echo cfg="$cfg" >> ./settings.cfg
			echo platform="$platform" >> ./settings.cfg
			echo librarydir="$librarydir" >> ./settings.cfg
			echo sorteddir="$sorteddir" >> ./settings.cfg
			if [[ "$platform" == "windows" ]]; then echo winlibrarydir='$winlibrarydir' >> ./settings.cfg ; fi
			if [[ "$platform" == "windows" ]]; then echo winsorteddir='$winsorteddir' >> ./settings.cfg ; fi
		fi
	fi
fi

cp ./processed.txt ./processed.txt.backup || true # backup processed file list in case something goes wrong
if [[ "$recursive" == 0 ]]; then
	find $librarydir -maxdepth 1 -type f | while read line ; do basename "$line" ; done > ./data/all.txt
else
	find $librarydir -type f | while read line ; do basename "$line" ; done > ./data/all.txt
fi

# Sort files and prep them for diff
echo "[*] Sorting file lists..."
sort -u -o ./data/processed_s.txt ./processed.txt
sort -u -o ./data/all_s.txt ./data/all.txt
echo "[*] Searching for new files to tag..."
diff -u ./data/processed_s.txt ./data/all_s.txt | grep -E "^\+" | grep -v "/data" | cut -c 2- > ./data/pending.txt
echo "Found `cat ./data/pending.txt | wc -l` new files"

echo "[*] Processing files..."
while read in; do proc "$in"; done < ./data/pending.txt

tagorginit
echo 'Program done!' && exit 0
