#!/bin/bash
count=0
egrep 'data-title|data-start|data-end|data-text="' svt1 | cut -d '=' -f2-|cut -d '=' -f2|cut -d '"' -f2|while read line
do
  if [ $((++count%4)) -eq 1 ]
  then
    echo "title: $line"
  elif [ $((count%4)) -eq 2 ]
  then
    echo "start: $(date -d $line +"%Y-%m-%d %H:%M:%S")"
  elif [ $((count%4)) -eq 3 ]
  then
    echo "end: $(date -d $line +"%Y-%m-%d %H:%M:%S")"
  elif [ $((count%4)) -eq 0 ]
  then
    echo "desc: $line"
  fi
done
