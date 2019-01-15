#!/bin/bash

URL_INST="https://ait.gu.se/om-institutionen/?selectedTab=2&itemsPerPage=-1"
URL_INFORMATIK="https://ait.gu.se/om-institutionen/avdelningen-for-informatik#tabContentAnchor2"
TMP_PAGE="/tmp/home_page$$.html"
TMP_PAPER_PAGE="/tmp/paper_page$$.html"
fetch() {
    TOTAL_PUBS=0
    TOTAL_FIRST_NAME_PUBS=0
    TOTAL_AUTHORS=0
    TOTAL_SCI_PUBS=0
    TOTAL_YEARS=0
    URL=$1
    echo "Publication information per employee"
    for HOME_PAGE in $(GET "$URL"| grep omdirigering|grep =\"person|cut -d '"' -f2|sort|uniq)
    do
        num_first_name=0
        num_sci_journal=0
        num_pub=0
        num_not_first_name=0
        curl -sL "${HOME_PAGE}&publicationsPerPage=500#tabContentAnchor2" |grep [a-z] > "${TMP_PAGE}"

        user_id=$(echo $HOME_PAGE |cut -d '?' -f2| tr '&' '\n' | grep userId|cut -d '=' -f2)
        name=$(cat "${TMP_PAGE}"|grep '<h1>'|sed -e 's/.*<h1>\([&;A-Za-z -]\+\)<\/h1>.*/\1/g')
        name=$(echo "$name"|w3m -dump -T text/html)
        echo -n "Analysing papers by $name "
        for PUB_URL in $(cat $TMP_PAGE |grep -A30000 'Visar 1 - '|
                                grep [a-z] |
                                tr '\t' ' ' |
                                sed -e 's/^\ *//g' |
                                grep 'class="publicationTitle"' |
                                cut -d '"' -f2)
        do
            echo "$PUB_URL" | grep -q https: || PUB_URL="https://www.gu.se$PUB_URL"
            
            IS_FIRST=false
            IS_SCI=false
            ((num_pub++))
            GET "$PUB_URL" > "$TMP_PAPER_PAGE" 
            cat "$TMP_PAPER_PAGE" |
                grep [a-z] |
                grep -A2 Författare|
                tail -1|
                sed -e 's/^\t*//g;s/^\ *//g'|
                grep -q $user_id && IS_FIRST=true
            if $IS_FIRST
            then
                ((num_first_name++));
                cat "$TMP_PAPER_PAGE" |
                    grep [a-z]|
                    grep -A1 publicationType|
                    tail -1|
                    sed -e 's/^\t*//g;s/^\ *//g'|
                    grep -q "Artikel i vete" && IS_SCI=true
                if $IS_SCI
                then                    
                    ((num_sci_journal++))
                    ((TOTAL_SCI_PUBS++)) 
                    echo -n "V"
                else
                    echo -n "F"
                fi
            else
                echo -n "."
            fi
        done
        echo "Done analysing papers."
        last_pub_year=$(cat "${TMP_PAGE}"|grep -A30000 'Visar 1 - ' |
                               egrep '<h3>[0-9]{4}</h3>' |
                               head -1 |
                               sed -e 's/.*\([0-9]\{4\}\).*/\1/g')
        first_pub_year=$(cat "${TMP_PAGE}"|grep -A30000 'Visar 1 - '|
                                egrep '<h3>[0-9]{4}</h3>'|
                                tail -1 |
                                sed -e 's/.*\([0-9]\{4\}\).*/\1/g')
        if ((num_pub != 0))
        then
            ((TOTAL_PUBS += num_pub))
            ((TOTAL_AUTHORS++))
        fi
        name=$(echo "$name"|sed -e 's/\ \ /\ /g')
        num_book_chapter=$(cat "${TMP_PAGE}"|grep -A30000 'Visar 1 - ' |
                                  grep 'Kapitel i bok'|wc -l)
        num_in_proceeding=$(cat "${TMP_PAGE}"|grep -A30000 'Visar 1 - ' |
                                   grep 'Paper i proceeding'|wc -l)
        num_encyclopedia=$(cat "${TMP_PAGE}"|grep -A30000 'Visar 1 - ' |
                                  grep 'Bidrag till encyklopedi'|wc -l)
        num_conference=$(cat "${TMP_PAGE}"|grep -A30000 'Visar 1 - ' |
                                grep 'Konferensbidrag (offentliggjort, men ej förlagsutgivet)'|wc -l)
        num_collection=$(cat "${TMP_PAGE}"|grep -A30000 'Visar 1 - ' |
                                grep 'Samlingsverk'|wc -l)
        pub_types=$(cat "${TMP_PAGE}"|grep -A30000 'Visar 1 - ' |
                           grep publicationGroup |
                           sed -e 's/.*>\([^<]*\)<\/span>/\1/g' |
                           sort | uniq -c | sort -nr |
                           sed -e 's/\ *//')
        if [[ -z "$name" ]]
        then
            echo $HOME_PAGE | tr '&' '\n' | grep userId
        fi
        echo -n "${name}: "
        num_single_pubs=$(cat "${TMP_PAGE}" | grep -A30000 'Visar 1 - ' |
                                 grep "=$user_id&amp;" |
                                 grep 'sv"' |
                                 egrep -v ', ' |
                                 tr '\t' ' ' |
                                 sed -e 's/^\ */<br>/g' |
                                 w3m -dump -cols 260 -T text/html | wc -l)
        num_not_first_name=$(cat "${TMP_PAGE}"|grep -A30000 'Visar 1 - ' |
                                    egrep "=$user_id&amp;" |
                                    grep 'sv"' | egrep ', ' |
                                    tr '\t' ' ' |
                                    sed -e 's/^\ */<br>/g' |
                                    w3m -dump -cols 260 -T text/html |
                                    grep -v "^$name" | grep [a-z] | wc -l)
        num_not_first_name_no_links=$(cat "${TMP_PAGE}" | grep -A30000 'Visar 1 - ' |
                                             grep -v "=$user_id&amp;" |
                                             egrep "et\ al\." |
                                             egrep ', ' |
                                             tr '\t' ' ' |
                                             sed -e 's/^\ */<br>/g' |
                                             w3m -dump -cols 260 -T text/html |
                                             grep -v "^$name"| grep [a-z]|wc -l)
        ((num_not_first_name += num_not_first_name_no_links))
        if (( (num_first_name) > 0 ))
        then
            (( TOTAL_FIRST_NAME_PUBS+=num_first_name ))
        fi
        echo -n "$num_single_pubs single author publications, "
        echo "$num_first_name first-name publications, and $num_not_first_name articles as co-author"
        echo "First publication published $first_pub_year, last publication published $last_pub_year"
        year=$(date +%Y)
        years_publishing=$((year-first_pub_year))
        years_publishing=$((years_publishing == 0 ? 1 : years_publishing))
        years_publishing=$((years_publishing == year ? 0 : years_publishing))
        echo "Years active publishing: $years_publishing"
        if ((years_publishing != 0))
        then
            avg_pubs_per_year=$(echo "$num_pub/$years_publishing"|bc -l)
            ((TOTAL_YEARS += years_publishing))
        else
            avg_pubs_per_year=0.0
        fi
        LC_NUMERIC=en_US.UTF-8 printf -v avg_pubs_per_year "%.2f" "$avg_pubs_per_year"
        echo -e "Number of publications: $num_pub.\nAverage publications per year: $avg_pubs_per_year"
        echo -e "Publication types:\n$pub_types"
        echo "Number of scientific journal publications as first name: $num_sci_journal"
        echo "=================================="
        echo

        #if ((TOTAL_AUTHORS == 5)) ; then break; fi
    done

    SCI_PUB_RATIO=0
    AVG_PUBS_PER_AUTHOR=0
    AVG_PUBS_PER_YEAR_PER_AUTHOR=0
    AVG_SCI_PUBS_PER_YEAR_PER_AUTHOR=0
    
    VAL=$(echo "$TOTAL_SCI_PUBS/$TOTAL_PUBS"|bc -l)
    SCI_PUB_RATIO=$(LC_NUMERIC=en_US.UTF-8 printf "%.2f" "$VAL")
    VAL=$(echo "$TOTAL_PUBS/$TOTAL_AUTHORS"|bc -l)
    AVG_PUBS_PER_AUTHOR=$(LC_NUMERIC=en_US.UTF-8 printf "%.2f" "$VAL")
    VAL=$(echo "$TOTAL_FIRST_NAME_PUBS/$TOTAL_YEARS/$TOTAL_AUTHORS"|bc -l)
    AVG_PUBS_PER_YEAR_PER_AUTHOR=$(LC_NUMERIC=en_US.UTF-8 printf "%.2f" "$VAL")
    echo "==========Summary for the department==============="
    echo "$TOTAL_PUBS (first-name) publications by $TOTAL_AUTHORS authors of which $TOTAL_SCI_PUBS were in sci. journals"
    echo "The ratio (scientific journal publication/publication) is $SCI_PUB_RATIO ."
    echo "An average of $AVG_PUBS_PER_AUTHOR publications per employee (counting only emp. who publishes)."
    echo "The total years of publishing (summing every authors active years publishing) is $TOTAL_YEARS"
    
    VAL=$(echo "$TOTAL_SCI_PUBS/$TOTAL_AUTHORS"|bc -l)
    AVG_SCI_PUB_PER_AUTHOR=$(LC_NUMERIC=en_US.UTF-8 printf "%.2f" "$VAL")
    echo "In average, each publishing empl has published $AVG_SCI_PUB_PER_AUTHOR scientific papers in a sci. journal."
    VAL=$(echo "$TOTAL_YEARS/$TOTAL_AUTHORS"|bc -l)
    AVG_YEAR_PER_AUTHOR=$(LC_NUMERIC=en_US.UTF-8 printf "%.2f" "$VAL")
    echo "In average, each publishing empl has published for $AVG_YEAR_PER_AUTHOR years."
    VAL=$(echo "$AVG_SCI_PUB_PER_AUTHOR/$AVG_YEAR_PER_AUTHOR"|bc -l)
    AVG_SCI_PUBS_PER_YEAR_PER_AUTHOR=$(LC_NUMERIC=en_US.UTF-8 printf "%.2f" "$VAL")
    echo "In average, each publishing empl has published $AVG_SCI_PUBS_PER_YEAR_PER_AUTHOR sci. papers in a sci. journal per year."
    rm "$TMP_PAGE"
    rm "$TMP_PAPER_PAGE"
}

# Avd. för interaktionsdesign, D&IT
# https://www.gu.se/omuniversitetet/enheter/?selectedTab=2&departmentId=107826&itemsPerPage=-1


if [[ ! -z "$1" ]]
then
    fetch "$1"
    exit
fi
echo "Informatik:"
fetch $URL_INFORMATIK
echo ===========================
echo "Institutionen för tillämpad IT:"
fetch $URL_INST
