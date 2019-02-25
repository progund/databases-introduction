#!/bin/bash

# Get the JSON-part
GET https://www.tv.nu/kanal/svt1|xmllint --html - 2>/dev/null| grep -A2 INITIAL > json1 

cat json1|cut -d ' ' -f3-|cut -d '<' -f1|jq . > svt1.json

#cat svt1.json | jq '."schedule"."broadcasts"[]'

echo "Star-stop-times:"
cat svt1.json | jq '[."schedule"."broadcasts"[].broadcast.startTime,."schedule"."broadcasts"[].broadcast.endTime]'
cat svt1.json | jq '[."schedule"."broadcasts"[]."title",."schedule"."broadcasts"[].broadcast.startTime,."schedule"."broadcasts"[].broadcast.endTime]'
