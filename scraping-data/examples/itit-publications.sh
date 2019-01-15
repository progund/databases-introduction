#!/bin/bash

URL_INST="https://ait.gu.se/om-institutionen/?selectedTab=2&itemsPerPage=-1"
URL_INFORMATIK="https://ait.gu.se/om-institutionen/avdelningen-for-informatik#tabContentAnchor2"
TMP_PAGE="/tmp/home_page$$.html"

fetch() {
    URL=$1
    echo "Publication information per employee"
    for HOME_PAGE in $(GET "$URL"| grep omdirigering|grep =\"person|cut -d '"' -f2|sort|uniq)
    do
        GET "${HOME_PAGE}&publicationsPerPage=500#tabContentAnchor2" > "${TMP_PAGE}"
        user_id=$(echo $HOME_PAGE |cut -d '?' -f2| tr '&' '\n' | grep userId|cut -d '=' -f2)
        name=$(cat "${TMP_PAGE}"|grep '<h1>'|sed -e 's/.*<h1>\([&;A-Za-z -]\+\)<\/h1>.*/\1/g')
        name=$(echo "$name"|w3m -dump -T text/html)
        last_pub_year=$(cat "${TMP_PAGE}"|egrep '<h3>[0-9]{4}</h3>'|head -1 | sed -e 's/.*\([0-9]\{4\}\).*/\1/g')
        first_pub_year=$(cat "${TMP_PAGE}"|egrep '<h3>[0-9]{4}</h3>'|tail -1 | sed -e 's/.*\([0-9]\{4\}\).*/\1/g')
        num_pub=$(cat "${TMP_PAGE}" | grep .| egrep "publicationGroup"|grep [a-z]|wc -l)
        name=$(echo "$name"|sed -e 's/\ \ /\ /g')
        num_sci_journal=$(cat "${TMP_PAGE}"|grep 'Artikel i vetenskaplig tidskrift'|wc -l)
        num_book_chapter=$(cat "${TMP_PAGE}"|grep 'Kapitel i bok'|wc -l)
        num_in_proceeding=$(cat "${TMP_PAGE}"|grep 'Paper i proceeding'|wc -l)
        num_encyclopedia=$(cat "${TMP_PAGE}"|grep 'Bidrag till encyklopedi'|wc -l)
        num_conference=$(cat "${TMP_PAGE}"|grep 'Konferensbidrag (offentliggjort, men ej förlagsutgivet)'|wc -l)
        num_collection=$(cat "${TMP_PAGE}"|grep 'Samlingsverk'|wc -l)
        pub_types=$(cat "${TMP_PAGE}"|grep publicationGroup|sed -e 's/.*>\([^<]*\)<\/span>/\1/g'|sort|uniq -c|sort -nr|sed -e 's/\ *//')
        if [[ -z "$name" ]]
        then
            echo $HOME_PAGE | tr '&' '\n' | grep userId
        fi
        echo -n "${name}: "
        num_single_pubs=$(cat "${TMP_PAGE}"  | grep "=$user_id&amp;"| grep 'sv"'| egrep -v ', '|tr '\t' ' '|sed -e 's/^\ */<br>/g'|w3m -dump -cols 260 -T text/html | wc -l)
        num_first_name=$(cat "${TMP_PAGE}" | grep "=$user_id&amp;" | grep 'sv"'|tr '\t' ' '|sed -e 's/^\ */<br>/g'|w3m -dump -cols 260 -T text/html |grep "^$name"| wc -l)
        num_not_first_name=$(cat "${TMP_PAGE}" | grep "=$user_id&amp;" | grep 'sv"' | egrep ', '|tr '\t' ' '|sed -e 's/^\ */<br>/g'|w3m -dump -cols 260 -T text/html |grep -v "^$name"| grep [a-z]|wc -l)
        echo "$num_single_pubs single author publications, $num_first_name first-name publications, and $num_not_first_name articles as co-author"
        echo "First publication published $first_pub_year, last publication published $last_pub_year"
        year=$(date +%Y)
        years_publishing=$((year-first_pub_year))
        years_publishing=$((years_publishing == 0 ? 1 : years_publishing))
        echo "Years active publishing: $years_publishing"
        avg_pubs_per_year=$(echo "$num_pub/$years_publishing"|bc -l)
        LC_NUMERIC=en_US.UTF-8 printf -v avg_pubs_per_year "%.2f" "$avg_pubs_per_year"
        echo "Number of publications: $num_pub. Average publications per year: $avg_pubs_per_year"
        echo -e "Publication types:\n$pub_types"
        echo "=================================="
        echo
        
    done
    rm "$TMP_PAGE"
}

echo "Informatik:"
fetch $URL_INFORMATIK
echo ===========================
echo "Institutionen för tillämpad IT:"
fetch $URL_INST
