#!/bin/bash
URL='https://www.gu.se/omuniversitetet/aktuellt/lediga-jobb/?faculty=&category=Annan%2520undervisande%2520och%2520forskande%2520personal'

for url in $(lwp-request -m GET "$URL" |
                    grep Studentmedarbetare |
                    grep positionArray |
                    tr ':' '\n' |
                    grep detaljsida |
                    cut -d '"' -f2)
do
    lwp-request -m GET "https://www.gu.se${url}" |
        grep -A1 'LEDIGA ANST' |
        tail -1 |
        sed -e 's/^[[:space:]]*//g'
    lwp-request -m GET "https://www.gu.se${url}" |
        egrep 'fieldLabel|fieldText' |
        egrep -A3 'ansökningsdag|Placering|Diarienummer' |
        w3m -T text/html -dump
    echo "URL: https://www.gu.se${url}"
    echo
done
