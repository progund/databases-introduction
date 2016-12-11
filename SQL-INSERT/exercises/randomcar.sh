#!/bin/bash

regnum(){
    alpha=$(cat /dev/urandom |tr -dc 'A-Z'| fold -w 3|head -1)
    num=$(cat /dev/urandom |tr -dc '0-9'| fold -w 3|head -1)
    echo -n "$alpha $num"
}
brand(){
    brands=( Volvo Mazda Honda Suzuki Ford Chevrolet Saab Simca Dodge )
    index=$((RANDOM%9))
    echo -n ${brands[$index]}
}
color(){
    colors=( Blue Red Green Yellow Black White Brown Silver )
    index=$((RANDOM%8))
    echo -n ${colors[$index]}
}
NUMBER=$1
for i in $(seq 1 $NUMBER)
do
    r=$(regnum)
    m=$(brand)
    c=$(color)
    echo "INSERT INTO \"cars\" VALUES('"$m"','"$c"','"$r"');"
done
