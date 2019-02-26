#!/bin/bash

# Get the JSON-part
GET https://www.tv.nu/kanal/svt1|xmllint --html - 2>/dev/null| grep -A2 INITIAL > json1 

cat json1|cut -d ' ' -f3-|cut -d '<' -f1|jq . > svt1.json

#cat svt1.json | jq '."schedule"."broadcasts"[]'

echo "Star-stop-times:"
cat svt1.json | jq '."schedule"."broadcasts"[]|"title:" + .title, "desc:" + .description, "start:" + (.broadcast.startTime / 100|tostring), "end:" + (.broadcast.endTime/100|tostring)'
echo parsing:
i=0
title=""
desc=""
start=""
end=""
while read line
do
    if ((i % 4 == 0))
    then
        title=$(echo $line  | cut -d ':' -f2 | cut -d '"' -f1)
    elif ((i % 4 == 1))
    then
        desc=$(echo $line  | cut -d ':' -f2 | cut -d '"' -f1)
    elif ((i % 4 == 2))
    then
        start=$(echo $line  | cut -d ':' -f2 | cut -d '"' -f1)
        start=$(date -d '@'"${start}")
    elif ((i % 4 == 3))
    then
        end=$(echo $line  | cut -d ':' -f2 | cut -d '"' -f1)
        end=$(date -d '@'"${end}")
        echo -n "INSERT INTO tv(title, desc, start, end) "
        echo "VALUES ('$title', '$desc', '$start', '$end');"
        echo
    fi
    ((i++))
done < <(cat svt1.json | jq '."schedule"."broadcasts"[]|"title:" + .title, "desc:" + .description, "start:" + (.broadcast.startTime / 1000|tostring), "end:" + (.broadcast.endTime/1000|tostring)')

