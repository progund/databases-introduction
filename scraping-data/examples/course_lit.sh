#!/bin/bash

course_codes()
{
    GET 'https://ait.gu.se/utbildning/program/systemvetenskap/om-programmet' |
        grep TIG |
        tr '(' '\n' |
        tr ')' '\n' |
        grep ^TIG
}

lit_list()
{
    CODE=$1
    curl -s -A 'Mozilla/5.0 (X11; Fedora; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/56.0.2924.76 Safari/537.36 Accept: text/html,application/xhtml+xml,application/xml;q=0.9,image/webp,*/*;q=0.8' -i -d "courseQuery=${CODE}&syllabiQuery=$CODE" https://utbildning.gu.se/kurser/hitta-kursplan/syllabisearchresultview/ | tr '=' '\n' | grep '>Litteratur' | cut -d '"' -f2
}

PROGRAM="Information Systems: IT, Users and Organizations"
HTML_FILE="lit_list.html"
FILE_DIR="literature_lists"
mkdir -p "$FILE_DIR"
# don't use variables with rm and * - what if the variable is empty?
rm -f literature_lists/*.*

rm -f $HTML_FILE # will fail on empty variable
echo "<!DOCTYPE html>
<head>
<title>Literature lists</title>
<style>html { font-family: sans-serif; }</style>
</head>
<html>
<body>
<h1>Course literature for $PROGRAM</h1>
<p>
" >> "$HTML_FILE"

for code in $(course_codes)
do
    echo "$code"
    PDF_URL=$(lit_list "$code")
    echo "Downloading $PDF_URL"
    wget -q "$PDF_URL" -P literature_lists/ ||
        echo "Couldn't find URL for $code <br>" >> "$HTML_FILE"
done

for PDF in $(find literature_lists -name '*.pdf')
do
    pdftotext "$PDF"
done

LIT_LIST_BASE="http://kursplaner.gu.se/svenska"
ADLIBRIS_BASE="https://www.adlibris.com/se/sok?q="
BOKUS_BASE="https://www.bokus.com/bok/"


for TXT in $(find "$FILE_DIR" -name '*.txt')
do
    ISBNs=$(cat "$TXT" | tr ' ' '\n' | grep -E '^[0-9-]{12}' | tr -d '.' | tr -d ',')
    echo "<h2>$(echo "$(basename $TXT)"|cut -d '_' -f1)</h2>" >> "$HTML_FILE"
    echo "<a href=\"$LIT_LIST_BASE/$(basename ${TXT%%.*}).pdf\">$(basename ${TXT%%.*}).pdf</a><br>" >> "$HTML_FILE"
    if [[ -z "$ISBNs" ]]
    then
        echo "&nbsp;* No ISBNs found<br>" >> "$HTML_FILE"
    fi
    for isbn in $ISBNs
    do
        short_isbn=$(echo $isbn | tr -d '-')
        echo -n "Looking up title for $isbn..." >&2
        title=$(curl -s "https://www.googleapis.com/books/v1/volumes?q=isbn:$short_isbn"|jq '.items[0].volumeInfo.title')
        if [[ "$title" = "null" ]]
        then
            title=""
            echo " Couldn't lookup title." >&2
        else
            echo "Done! $title" >&2
        fi
        lwp-request -m GET "${ADLIBRIS_BASE}$short_isbn" |
            grep -q 'inga tr&#228;ffar' &&
            echo "&nbsp;* $title $isbn - Not found on Adlibris<br>" ||
            echo "&nbsp;* <a href=\"${ADLIBRIS_BASE}$short_isbn\">Adlibris search for ISBN $isbn $title</a><br>"
        lwp-request -m GET "${BOKUS_BASE}$short_isbn" |
            grep -q 'Produkten kan inte hittas' &&
            echo "&nbsp;* $title $isbn - Not found on Bokus<br>" ||
            echo "&nbsp;* <a href=\"${BOKUS_BASE}$short_isbn\">Bokus search for ISBN $isbn $title</a><br>"
    done >> "$HTML_FILE"
done
echo "</p>
</body>
</html>" >> "$HTML_FILE"
google-chrome "$HTML_FILE" || echo "Could not open $HTML_FILE using google-chrome" >&2

# Don't use variables with rm without extra precaution
rm literature_lists/TIG*.{txt,pdf}
rmdir literature_lists