#!/bin/bash

echo "Ten pages with most revisions (edits):"
w3m -dump 'http://wiki.juneday.se/mediawiki/index.php?title=Special:MostRevisions&limit=500&offset=0'|grep 'revisions)'|head -10

echo 
echo "Total number of edits, and average edits on this wiki:"
w3m -dump 'http://wiki.juneday.se/mediawiki/index.php/Special:Statistics'|grep edits

echo

echo "Number of wiki pages on this wiki (including talk pages, redirects, etc):"
w3m -dump 'http://wiki.juneday.se/mediawiki/index.php/Special:Statistics'|grep Pages

echo

echo "The fifteen longest pages:"
w3m -dump http://wiki.juneday.se/mediawiki/index.php/Special:LongPages|grep bytes|head -15

echo

echo "The total number of bytes of the 400 longest pages:"
$ echo $(w3m -dump -cols 200 'http://wiki.juneday.se/mediawiki/index.php?title=Special:LongPages&limit=500&offset=0'|grep bytes|head -400|tr -d ','|cut -d '[' -f2|cut -d ' ' -f1|while read bytes;do echo -n "$bytes +";done;echo 0)|bc -l|numfmt --to=si --suffix=B --padding=6
