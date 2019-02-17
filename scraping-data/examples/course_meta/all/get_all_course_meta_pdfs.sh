#!/bin/bash

PAGE_URL='http://wiki.juneday.se/mediawiki/index.php/Course_Meta_Documents'
for link in $(GET "$PAGE_URL" | grep '\.pdf' | tr '=' '\n' | grep mediawiki | cut -d '"' -f2)
do
    wget "http://wiki.juneday.se$link"
done
