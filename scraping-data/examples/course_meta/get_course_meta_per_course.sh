#!/bin/bash

PAGE_URL='http://wiki.juneday.se/mediawiki/index.php/Course_Meta_Documents'
COURSES=$(GET "$PAGE_URL" | egrep '>TIG[0-9]{3}-[0-9]{4}</span></h2'|sed -e 's/\(^<h2>.*">\)\(TIG.*[0-9]\)\(<\/.*\)/\2/')
for course in $COURSES
do
    echo "$course:"
    GET "$PAGE_URL" | sed "/^<h2.*$course.*/,/^<h2.*/{//!b};d" |
        grep '\.pdf' | tr '=' '\n' | grep mediawiki | cut -d '"' -f2 |
        while read link
        do
            echo "http://wiki.juneday.se$link"
        done
done
exit
for link in $(GET "$PAGE_URL" | grep '\.pdf' | tr '=' '\n' | grep mediawiki | cut -d '"' -f2)
do
    wget "http://wiki.juneday.se$link"
done
