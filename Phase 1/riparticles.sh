#!/usr/bin/env bash

cursor="*"
count=0
page=1

while [ $count -le 100000 ]; do
  printf -v p "%04d" $page
  echo Fetching page $page...
  curl -s -S -X 'GET' \
    "https://api.crossref.org/works?filter=type%3Ajournal-article&rows=1000&cursor=$cursor" \
    -H 'accept: application/json' > "articles-$p.json"
  count=$((count + 1000))
  page=$((page + 1))
  cursor=$(jq -r '.message."next-cursor"' "articles-$p.json")
  date
  sleep 1
done
