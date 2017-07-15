# upload local files to e621 favorites

platform="e621fav"
options+="e621fav - favorite and upvote local images\n"

function output_e621fav {
  if [[ "$dbg" == "1" ]]; then echo "arg is $1"; fi
  if [[ "$1" == "--delete" ]]; then
		 echo "Not implemented."
     exit 1
	fi

  if [[ "$1" == "--selected" ]]; then
     return 0
  fi

  if [[ "$1" == "--init" ]]; then
		 database="processed-favs.txt"
     no_tags=0
     set +e
     btinit

     function xmllint-compat {
       xmllint --xpath "post/id/text()" ./data/post/$1.txt #"
     }

     # not particularly beautiful, I know
     if [ -z "$api_key" ]; then
       echo "No e621 login details found. Please log in."
       read -p "User name: " username
       echo "Go to https://e621.net/user/api_key and paste your API key below"
       read -p "API Key: " api_key
       apitest_result="$(curl -A "BooruToolkit/$VERSION (+https://e621.net/forum/show/233498)" -s "$baseurl/user/show.xml?login=$username&password_hash=$api_key")"
       if [[ "$dbg" == "1" ]]; then echo "echo "Test result: $apitest_result""; fi
       if echo $apitest_result | grep -q "$username"; then true; else echo >&2 'Unable to log in. Please make sure that your username and API key are correct.'; exit 1 ; fi
       read -p "Remember your credentials? [Y/n] " -n 1 -r
       if [[ $REPLY =~ ^[Yy]$ ]]; then echo -e "username=$username\napi_key=$api_key" >> ./settings.cfg ; fi
     fi
     if [[ $e621favcfg != 1 ]]; then
       if [ -z "$fav" ]; then
         read -p "Favorite all posts? [y/n] " -n 1 -r
         if [[ $REPLY =~ ^[Yy]$ ]]; then fav=1 ; else fav=0 ; fi
         echo

         read -p "Upvote all posts? [y/n] " -n 1 -r
         if [[ $REPLY =~ ^[Yy]$ ]]; then upvote=1 ; else upvote=0 ; fi
         echo

         e621favcfg=1
         read -p "Do you wish to save these settings? [y/n] " -n 1 -r
         if [[ $REPLY =~ ^[Yy]$ ]]; then echo -e "e621favcfg=$e621favcfg\nfav=$fav\nupvote=$upvote" >> ./settings.cfg ; fi
         echo
       fi
     fi

     return 0
	fi

  read id < <(xmllint-compat $1 2>&1)

  # sanity check
  if [[ $force_http == 1 ]] && [ ! -z "$api_key" ]; then echo "ERROR: Attempting to pass credentials over HTTP. Aborting."; exit 1 ; fi
  if [[ "$dbg" == "1" ]]; then echo "current id is $id, fav is $fav and upvote is $upvote"; fi
  if [[ $fav == 1 ]]; then curl -X POST -A "BooruToolkit/$VERSION (+https://e621.net/forum/show/233498)" -s "$baseurl/favorite/create.json?id=$id&login=$username&password_hash=$api_key" > /dev/null ; fi
  if [[ $upvote == 1 ]]; then curl -X POST -A "BooruToolkit/$VERSION (+https://e621.net/forum/show/233498)" -s "$baseurl/post/vote.xml?id=$id&score=1&login=$username&password_hash=$api_key" > /dev/null ; fi
  sleep $sleeprate || sleep 0.4 # rate limiter
}
