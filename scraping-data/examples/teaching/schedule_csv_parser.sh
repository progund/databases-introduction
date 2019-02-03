#!/bin/bash

CSV=$1
FIELDS=$(cat "$CSV"|head -1)
# csvtool -t ',' col 9 -
# Startdatum,Starttid,Slutdatum,Sluttid,Kurs,"Grupp,Undergrupp,Basgrupp",Del av kurs,Lokal,Lärare,Undervisningstyp,Rubrik,Kommentar,Länk,Läsanvisningar,Persongrupp
NUM_COLS=$(cat "$CSV" | csvtool -t ',' width -)
START_DATE_COL=1
START_TIME_COL=2
STOP_DATE_COL=3
STOP_TIME_COL=4
COURSE_COL=5
TEACHER_COL=-1
TYPE_COL=-1
TOTAL_HOURS=0
TOTAL_MINS=0

COURSE=""
YEAR=""
declare -A TYPE_HOURS
declare -A TYPE_MINS
declare -A TEACHER_HOURS
declare -A TEACHER_MINS
declare -A TEACHER_TYPE_HOURS
declare -A TEACHER_TYPE_MINS

# csvtool drop 1 input.csv
for i in $(seq 5 "$NUM_COLS")
do
    COL=$(echo "$FIELDS" | csvtool -t ',' col "$i" -)
    case "$COL" in
        "Lärare")
            TEACHER_COL=$i
            ;;
        "Undervisningstyp")
            TYPE_COL=$i
            ;;
        *)
            continue
            ;;
    esac
done
if ((TEACHER_COL == -1 || TYPE_COL == -1))
then
    echo "Couldn't find teacher col or type col"
    exit 1
fi

#echo "START_DATE_COL: $START_DATE_COL START_TIME_COL: $START_TIME_COL STOP_DATE_COL: $STOP_DATE_COL STOP_TIME_COL: $STOP_TIME_COL TEACHER_COL: $TEACHER_COL TYPE_COL: $TYPE_COL"
OLD_IFS=$IFS
while read line
do
    IFS="|"
    read start end < <(echo "$line" | csvtool -t ',' -u '|' col ${START_TIME_COL},${STOP_TIME_COL} -)
    IFS='|'
    read teacher < <(echo "$line" | csvtool -t ',' -u '|' col ${TEACHER_COL} -|sed -e 's/^$/N\/A/')
    read type < <(echo "$line" | csvtool -t ',' -u '|' col ${TYPE_COL} -|sed -e 's/^$/N\/A/g')
    read COURSE < <(echo "$line" | csvtool -t ',' -u '|' col ${COURSE_COL} -|sed -e 's/^$/N\/A/g')
    if [[ -z "$YEAR" ]]
    then
        read start_date < <(echo "$line" | csvtool -t ',' -u '|' col ${START_DATE_COL} -|sed -e 's/^$/N\/A/g')
        YEAR=$(echo $start_date|cut -d '-' -f1)
    fi
    IFS=$OLD_IFS
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
        ((duration_hours += 24))
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
    #echo "Duration hours: $duration_hours duration minutes: $duration_mins"
    thrs=${TYPE_HOURS[$type]}
    TYPE_HOURS["$type"]=$((thrs += duration_hours))
    tmins=${TYPE_MINS[$type]}
    TYPE_MINS["$type"]=$((tmins += duration_mins))
    prof_hours=0
    prof_hours=${TEACHER_HOURS[$teacher]}
    if [[ -z prof_hours ]]
    then
        prof_hours=0
        prof_mins=0
    fi
    tth=0
    tth=${TEACHER_TYPE_HOURS["$teacher $type"]}
    ttm=0
    ttm=${TEACHER_TYPE_MINS["$teacher $type"]}
    #if [[ "$type" =~ ^[Ff]örel.* ]]
    #then
    TEACHER_TYPE_HOURS["$teacher $type"]=$((tth += duration_hours))
    TEACHER_TYPE_MINS["$teacher $type"]=$((ttm += duration_mins))
    #fi
    TEACHER_HOURS["$teacher"]=$((prof_hours += duration_hours))
    prof_mins=${TEACHER_MINS[$teacher]}
    TEACHER_MINS["$teacher"]=$((prof_mins += duration_mins))
    ((TOTAL_HOURS += duration_hours))
    ((TOTAL_MINS += duration_mins))    
done < <(cat "$CSV"|csvtool drop 1 -)

## Calculate the sum of hours and mins
((TOTAL_HOURS += TOTAL_MINS/60))
TOTAL_MINS=$((TOTAL_MINS % 60))
((TOTAL_HOURS_LECTURE += TOTAL_MINS_LECTURE/60))

echo "Teaching statistics for $COURSE $YEAR:"

for k in "${!TYPE_HOURS[@]}"
do
    TYPE_HOURS[$k]=$((TYPE_HOURS[$k] + TYPE_MINS[$k] / 60))
    TYPE_MINS[$k]=$((TYPE_MINS[$k] % 60))
    printf "%s\n" "$k: ${TYPE_HOURS[$k]} hrs and ${TYPE_MINS[$k]} mins."
done | sort -t ':' -k2nr -k5nr

echo
echo "Types and distribution of teacher involvement:"
for k in "${!TEACHER_HOURS[@]}"
do
    TEACHER_HOURS[$k]=$((TEACHER_HOURS[$k] + TEACHER_MINS[$k] / 60))
    TEACHER_MINS[$k]=$((TEACHER_MINS[$k] % 60))
    printf "%s\n" "$k: ${TEACHER_HOURS[$k]} hrs and ${TEACHER_MINS[$k]} mins."
done | sort -t ':' -k2nr -k5nr
echo
echo "Teacher type distribution:"
for k in "${!TEACHER_TYPE_HOURS[@]}"
do
    TEACHER_TYPE_HOURS[$k]=$((TEACHER_TYPE_HOURS[$k] + TEACHER_TYPE_MINS[$k] / 60))
    TEACHER_TYPE_MINS[$k]=$((TEACHER_TYPE_MINS[$k] % 60))
    printf "%s\n" "$k: ${TEACHER_TYPE_HOURS[$k]} hrs and ${TEACHER_TYPE_MINS[$k]} mins."
done | sort -t ':' -k2nr -k5nr

echo -e "\nEnd of report."
echo "=========================="
IFS="$OLD_IFS"
