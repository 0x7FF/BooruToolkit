# upload local files to e621 favorites

platform="e621fav"

function output_e621fav {
  id=$(xmllint-compat $1 id) #"

  # not particularly beautiful, I know
  if [ ! -d "$api_key" ]; then
    echo "No e621 login details found in settings. Please log in."
    read -p "User name: " username
    echo "Go to https://e621.net/user/api_key and paste your API key below"
    read -p "API Key: " api_key
    apitest_result="$(curl -A "BooruToolkit/$VERSION (+https://e621.net/forum/show/233498)" -s "$baseurl/user/show.xml?login=$username&password_hash=$api_key")"
    if echo $apitest_result | grep -q "$username"; then true; else echo >&2 'Unable to log in. Please check that your username and API key are correct.'; exit 1 ; fi
  fi

  if [ ! -d "$fav" ]; then
    read -p "Favorite all posts? [y/n] " -n 1 -r
    if [[ $REPLY =~ ^[Yy]$ ]]; then fav=1 ; else fav=0 ; fi

    read -p "Upvote all posts? [y/n] " -n 1 -r
    if [[ $REPLY =~ ^[Yy]$ ]]; then upvote=1 ; else upvote=0 ; fi

    read -p "Do you wish to save these settings? [y/n] " -n 1 -r
    if [[ $REPLY =~ ^[Yy]$ ]]; then echo -e "fav=$fav\nupvote=$upvote" >> ./settings.cfg ; fi
  fi

  if [ $fav == 1 ]; then curl -X POST -A "BooruToolkit/$VERSION (+https://e621.net/forum/show/233498)" -s "$baseurl/favorite/create.json?id=$id&login=$username&password_hash=$api_key" ; fi
  if [ $upvote == 1 ]; then curl -X POST -A "BooruToolkit/$VERSION (+https://e621.net/forum/show/233498)" -s "$baseurl/favorite/create.json?id=$id&score=1&login=$username&password_hash=$api_key" ; fi
}

function output_e621fav {
	if [[ "$1" == "--delete" ]]; then
		 echo "Not implemented."
	fi

  if [[ "$1" == "--init" ]]; then
		 database="processed-favs.txt"
     no_tags=1
	fi
}
