#!/usr/bin/env bash

page=3

while [ $page -le 1000 ]; do
  printf -v p "%04d" $page
  echo Fetching page $page...
  curl -s -S -X 'GET' "https://openlibrary.org/search.json?q=dog&page=$page" -H 'accept: application/json' > dogs-$p.json
  page=$((page + 1))
  date
  sleep 1
done
