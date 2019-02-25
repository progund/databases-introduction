#!/bin/bash

name1="$1"
name2="$2"

if (( $# != 2))
then
    echo "Usage: ./$0 <firstname> <lastname>"
    exit 1
fi

URL='https://ait.gu.se/om-institutionen/?selectedTab=2&itemsPerPage=-1'
GET "$URL" |
    awk '/<tbody>/,/<\/tbody>/' |
    sed -e 's/^[[:blank:]]*//g' |
    grep -A1 userId |
    egrep -B1 "${name1}.*${name2}|${name2}.*${name1}" |
    tr '&' '\n' |
    grep userId |
    cut -d '=' -f3
