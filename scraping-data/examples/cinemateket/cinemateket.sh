#!/bin/bash

cinema_file=/tmp/cinema.txt
w3m -cols 80 -dump 'https://www.filminstitutet.se/sv/se-och-samtala-om-film/Cinemateket-Goteborg/program/' > /tmp/cinema.txt
tuesday="$(date -d "next tuesday" "+%a %-e/%-m")"
saturday="$(date -d "next saturday" "+%a %-e/%-m")"
tuesday_title=$(egrep -B2 "$tuesday" $cinema_file|head -1)
saturday_title=$(egrep -B2 "$saturday" $cinema_file|head -1)
echo "Next tuesday: $tuesday_title"
grep -A8 "$tuesday_title" $cinema_file | grep -v '\['
echo "============================="
echo "Next saturday: $saturday_title"
grep -A8 "$saturday_title" $cinema_file | grep -v '\['

