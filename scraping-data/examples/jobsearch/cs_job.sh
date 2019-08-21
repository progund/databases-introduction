#!/bin/bash

Q="$1"
CS_URL="https://csjobb.idg.se/s%C3%B6kjobb/?Keywords="
for url in $(GET "${CS_URL}${Q}" | grep jobb-info | sort | uniq)
do
    echo "https://csjobb.idg.se${url}"
    GET "http://csjobb.idg.se${url}" |
        w3m -T text/html -dump |
        awk '/computersweden.se/,/Dela/' |
        egrep -v '•|^Dela$|\[\]'
done

echo "Summary:"
for url in $(GET "${CS_URL}${Q}" | grep jobb-info | sort | uniq)
do
    echo "https://csjobb.idg.se${url}"
done

echo "You searched for $Q"
echo "These phrases matched:"

for url in $(GET "${CS_URL}${Q}" | grep jobb-info | sort | uniq)
do
    echo "DEBUG: $url"
    echo "phrase search:"
    GET "http://csjobb.idg.se${url}" |
        w3m -T text/html -dump |
        awk '/• Ansök/,/Dela/' |
        egrep -v '•|^Dela$|\[\]' | grep -C2 -i "$Q"
    echo "================"
    GET "http://csjobb.idg.se${url}" |
        w3m -T text/html -dump |
        awk '/computersweden.se/,/Dela/' |
        egrep -v '•|^Dela$|\[\]' | grep -C2 -i "$Q"
done
