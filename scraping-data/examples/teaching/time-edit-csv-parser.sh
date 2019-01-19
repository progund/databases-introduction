#!/bin/bash

TOTAL_HOURS=0
TOTAL_MINS=0
TOTAL_HOURS_SUPERVISION=0
TOTAL_MINS_SUPERVISION=0
TOTAL_HOURS_LECTURE=0
TOTAL_MINS_LECTURE=0
TOTAL_HOURS_WORKSHOP=0
TOTAL_MINS_WORKSHOP=0

declare -A TYPE_HOURS
declare -A TYPE_MINS

CAL_FILE=$1

OLDIFS="$IFS"
KURS=""
START_DATE=$(egrep ^[0-9]{4} "$CAL_FILE"|head -1|cut -d ',' -f1)
END_DATE=$(egrep ^[0-9]{4} "$CAL_FILE"|tail -1|cut -d ',' -f1)

while read line
do
    #echo $line
    IFS=","
    #echo $line
    while read date start x end course x type x x x x x x
    do
        #echo "date: $date start: $start end: $end type: $type kurs: $course"
        KURS=$course
        start_hour="${start:0:2}"
        if [[ "${start_hour:0:1}" -eq 0 ]]
        then
            start_hour=${start_hour:1:1}
        fi
        start_minute="${start:3:2}"
        
        if [[ "${start_minute:0:1}" -eq 0 ]]
        then
            start_minute=${start_minute:1:1}
        fi

        end_hour="${end:0:2}"
        if [[ "${end_hour:0:1}" -eq 0 ]]
        then
            end_hour=${end_hour:1:1}
        fi
        end_minute="${end:3:2}"
        if [[ "${end_minute:0:1}" -eq 0 ]]
        then
                end_minute=${end_minute:1:1}
        fi
        duration_mins=0
        duration_hours=0
        duration_hours=$((end_hour - start_hour))
        if ((duration_hours < 0))
        then
            #echo "start: $start end: $end"
            ((duration_hours += 24))
            #echo "duration hrs: $duration_hours"
        fi

        if ((start_minute != end_minute))
        then
            duration_mins=$((end_minute - start_minute))
            if ((duration_mins < 0))
            then
                duration_mins=$((60 + duration_mins))
                ((duration_hours--))
            fi
        fi
        if [[ -z "$type" ]]
        then
            IFS="$OLDIFS"
            #echo $line
            type=$(echo "$line"|tr ',' '\n'|egrep 'Förel|Works|Semin|Handl|Övnin|Inläm|Tenta|Anmäl|Projekt'|head -1)
            IFS=","
        fi
        if [[ -z "$type" ]]
        then
            type="Other/Unknown"
        fi
        #echo "Type: $type"
        thrs=${TYPE_HOURS[$type]}
        TYPE_HOURS["$type"]=$((thrs += duration_hours))
        tmins=${TYPE_MINS[$type]}
        TYPE_MINS["$type"]=$((tmins += duration_mins))
        ((TOTAL_HOURS += duration_hours))
        ((TOTAL_MINS += duration_mins))
        case "${type:0:5}" in
            Förel)
                ((TOTAL_HOURS_LECTURE += duration_hours))
                ((TOTAL_MINS_LECTURE += duration_mins))
                ;;
            Handl)
                ((TOTAL_HOURS_SUPERVISION += duration_hours))
                ((TOTAL_MINS_SUPTERVISION += duration_mins))
                ;;
            Works)
                ((TOTAL_HOURS_WORKSHOP += duration_hours))
                ((TOTAL_MINS_WORKSHOP += duration_mins))
                ;;                
            *)
                ;;
        esac
            #echo "type: $type"
            #echo "start: $start end: $end type: $type duration: $duration_hours hrs and $duration_mins mins"
    done < <(echo "$line")
    #echo "date: $date start: $start stop: $stop type: $type"
done < <(cat "$CAL_FILE" | sed -e 's/\([^"]*"\)\([^",]*\)\(,\)\(.*\)/\1\2;\4/g;s/"//g'|egrep ^[0-9]{4})

((TOTAL_HOURS += TOTAL_MINS/60))
TOTAL_MINS=$((TOTAL_MINS % 60))
((TOTAL_HOURS_LECTURE += TOTAL_MINS_LECTURE/60))
TOTAL_MINS_LECTURE=$((TOTAL_MINS_LECTURE % 60))
((TOTAL_HOURS_SUPERVISION += TOTAL_MINS_SUPERVISION/60))
TOTAL_MINS_SUPTERVISION=$((TOTAL_MINS_SUPERVISION % 60))
((TOTAL_HOURS_WORKSHOP += TOTAL_MINS_WORKSHOP/60))
TOTAL_MINS_WORKSHOP=$((TOTAL_MINS_WORKSHOP % 60))

#PERIOD=$(cat "$CAL_FILE"|egrep '(H|V)T?[0-9]{2}'|tr -d '\\'|tr ',' '\n'|sed -e 's/\ *//'|egrep '(H|V)T?[0-9]{2}')
PERIOD="$START_DATE - $END_DATE"
echo "$KURS $PERIOD"
echo "Total time: $TOTAL_HOURS hrs and $TOTAL_MINS mins"
#echo "Total lecture time: $TOTAL_HOURS_LECTURE hrs and $TOTAL_MINS_LECTURE mins"
#echo "Total supervision time: $TOTAL_HOURS_SUPERVISION hrs and $TOTAL_MINS_SUPERVISION mins"
#echo "Total worskhop time: $TOTAL_HOURS_WORKSHOP hrs and $TOTAL_MINS_WORKSHOP mins"
#ACTIVITIES=$(cat "$CAL_FILE"| grep SUMMARY | sed -e 's/\\//g;s/,\ /,/g' |cut -d ',' -f 2|grep -v SUMMARY|sort|uniq -c|sort -rnk1|sed -e 's/^\ *//g')
echo -e "Types and distribution of activities:\n$ACTIVITIES"
#echo $TYPE_HOURS
#echo $TYPE_MINS
for k in "${!TYPE_HOURS[@]}"
do
    TYPE_HOURS[$k]=$((TYPE_HOURS[$k] + TYPE_MINS[$k] / 60))
    TYPE_MINS[$k]=$((TYPE_MINS[$k] % 60))
    printf "%s\n" "$k: ${TYPE_HOURS[$k]} hrs and ${TYPE_MINS[$k]} mins."
done | sort -rnk2,5

echo -e "\nEnd of report.\n"
IFS=$OLDIFS
