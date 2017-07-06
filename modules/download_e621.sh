# e621 post info downloader

function download {
  if [ ! -f ./data/post/$1.txt ]; then
    curl -A "BooruToolkit/$VERSION (+https://e621.net/forum/show/233498)" -s -S "$baseurl/post/show.xml?md5=$1" > ./data/post/$1.txt
    sleep $sleeprate || sleep 0.4 # rate limiter
  fi
}
