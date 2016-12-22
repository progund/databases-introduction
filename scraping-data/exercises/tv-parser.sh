#!/bin/bash

count=0
title=""
start=""
end=""
desc=""
egrep 'data-title|data-start|data-end|data-text="' svt1 | cut -d '=' -f2-|cut -d '=' -f2|cut -d '"' -f2|while read line
do
if [ $((++count%4)) -eq 1 ]
then
    title="$line"
elif [ $((count%4)) -eq 2 ]
then
    start="$line"
elif [ $((count%4)) -eq 3 ]
then
    end="$line"
elif [ $((count%4)) -eq 0 ]
then
    desc="$line"
    echo "Title: $title start: $start end: $end desc: $desc"
    echo "---------------------"
fi
done
