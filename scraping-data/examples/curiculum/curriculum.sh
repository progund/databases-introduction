#!/bin/bash

CODE=$1
wget -q "http://kursplaner.gu.se/pdf/kurs/sv/$CODE" -O "$CODE.pdf"
pdftotext "$CODE.pdf"
echo "=== ${CODE} ==="
echo "Date of creation and revisions:"
fmt -200 "$CODE.txt" |
    tr ' ' '\n' |
    egrep '[0-9]{4}-[0-9]{2}-[0-9]{2}' |
    sed -e 's/[.,]//g'
YEAR=$(fmt -200 "$CODE.txt" |
              tr ' ' '\n' |
              egrep '[0-9]{4}-[0-9]{2}-[0-9]{2}' |
              sed -e 's/[.,]//g' |
              head -1)
YEAR_OF_LAST_REV=$(fmt -200 "$CODE.txt" |
              tr ' ' '\n' |
              egrep '[0-9]{4}-[0-9]{2}-[0-9]{2}' |
              sed -e 's/[.,]//g' |
              tail -1)
which units &> /dev/null && echo "Course age: $(units $(date +%s)sec-$(date -d "$YEAR" +%s)sec 'yr;mo;d')"
which units &> /dev/null && echo "Course age since 'valid from date': $(units $(date +%s)sec-$(date -d "$YEAR_OF_LAST_REV" +%s)sec 'yr;mo;d')"
echo "Lärandemål"
cat "$CODE.txt" |
    grep .|
    grep -A 19 'Kunskap och' |
    egrep -A3 'Kunskap och|Färdigheter|Värderingsför|•' |
    egrep -v '^Innehåll|Kursen|^[0-9]|^Se '

