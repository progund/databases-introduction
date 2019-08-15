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

FILE_DIR="literature_lists"
mkdir -p "$FILE_DIR"
# don't use variables with rm - what if the variable is empty?
rm -f literature_lists/*.*

for code in $(course_codes)
do
    echo "$code"
    PDF_URL=$(lit_list "$code")
    echo "Downloading $PDF_URL"
    wget -q "$PDF_URL" -P literature_lists/ ||
        echo "Couldn't find URL for $code" >&2
done

for PDF in $(find literature_lists -name '*.pdf')
do
    pdftotext "$PDF"
done

LIT_LIST_BASE="http://kursplaner.gu.se/svenska"
ADLIBRIS_BASE="https://www.adlibris.com/se/sok?q="
BOKUS_BASE="https://www.bokus.com/bok/"
HTML_FILE="lit_list.html"

rm -f $HTML_FILE
echo "<!DOCTYPE html>
<head><title>Literature lists</title></head>
<body>
<p>
" >> "$HTML_FILE"

for TXT in $(find "$FILE_DIR" -name '*.txt')
do
    ISBNs=$(cat "$TXT" | tr ' ' '\n' | grep -E '^[0-9-]{12}' | tr -d '.' | tr -d ',')    
    echo "<a href=\"$LIT_LIST_BASE/$(basename ${TXT%%.}).pdf\">$(basename ${TXT%%.}).pdf</a><br>" >> "$HTML_FILE"
    if [[ -z "$ISBNs" ]]
    then
        echo "&nbsp;* No ISBNs found<br>" >> "$HTML_FILE"
    fi
    for isbn in $ISBNs
    do
        short_isbn=$(echo $isbn | tr -d '-')        
        title=$(curl -s "https://www.googleapis.com/books/v1/volumes?q=isbn:$short_isbn"|jq '.items[0].volumeInfo.title')
        if [[ "$title" = "null" ]]
        then
            title=""
        fi
        echo "&nbsp;* <a href=\"${ADLIBRIS_BASE}$isbn\">Adlibris search for ISBN $isbn $title</a><br>"
        echo "&nbsp;* <a href=\"${BOKUS_BASE}$isbn\">Bokus search for ISBN $isbn $title</a><br>"
    done >> "$HTML_FILE"
done
echo "</p>
</body>
</html>" >> "$HTML_FILE"
google-chrome "$HTML_FILE" || echo "Could not open $HTML_FILE using google-chrome" >&2
