#!/bin/bash
c=0
cat meals.txt|while read line
do
if [ $((++c)) -eq 1 ]
then
 echo "Breakfast: $line"
elif [ $((c)) -eq 2 ]
then
 echo "Lunch: $line"
elif [ $((c)) -eq 3 ]
then
 echo "Snack: $line"
elif [ $((c)) -eq 4 ]
then
 echo "Dinner: $line"
 c=0
fi
done
