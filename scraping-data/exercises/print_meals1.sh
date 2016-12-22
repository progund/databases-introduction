#!/bin/bash

c=0
cat meals.txt|while read line
do
if [ $((++c%4)) -eq 1 ]
then
 echo "Breakfast: $line"
elif [ $((c%4)) -eq 2 ];
then
 echo "Lunch: $line"
elif [ $((c%4)) -eq 3 ]
then
 echo "Snack: $line"
elif [ $((c%4)) -eq 0 ]
then
 echo "Dinner: $line"
fi
done
