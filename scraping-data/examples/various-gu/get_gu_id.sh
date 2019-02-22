#!/bin/bash

name1="$1"
name2="$2"
URL='https://ait.gu.se/om-institutionen/?selectedTab=2&itemsPerPage=-1'
GET "$URL" |
    awk '/<tbody>/,/<\/tbody>/' |
    sed -e 's/^[[:blank:]]*//g' |
    grep -A1 userId |
    egrep -B1 "${name1}.*${name2}|${name2}.*${name1}" |
    tr '&' '\n' |
    grep userId |
    cut -d '=' -f3
