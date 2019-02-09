#!/bin/bash

CODE=$1
wget -q "http://kursplaner.gu.se/pdf/kurs/sv/$CODE" -O "$CODE.pdf"
pdftotext "$CODE.pdf"
echo "${CODE}"
fmt -200 "$CODE.txt"|tr ' ' '\n'|egrep '[0-9]{4}-[0-9]{2}-[0-9]{2}' | sed -e 's/[.,]//g'
echo "Lärandemål"
cat "$CODE.txt" | grep '•'
