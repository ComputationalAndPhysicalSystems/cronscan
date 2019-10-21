#!/bin/bash

#== This is the script for controlling NEOPIXEL lights via Arduino controller
#   See Arduino repository for Arduino programming


#.. input parms:
#.  $1 >  on/off  { lower case req }

#. hardcode path

#. random program assigns a one time random to the entire series
#. chaotic program assigns a random value to each light, every series

P=/home/caps/scripts/caps_cronscan/exp/

OPTION=$1
EXP=$2
EP="$P$2/$2" #: path prefix
LOG=$EP.log
LP=$EP.exp #: light program file
L=$EP.lights

source $LP #: read in ABS and REL variables


#. hard coded

DEVICE="/dev/ttyACM0" #- Arudino Leonardo signature;
OFF="#000000"

#. red green and blue

R="#FF0000"
G="#00FF00"
B="#0000FF"

randblue[0]=$OFF
randblue[1]=$B

ri=-1 #: set $ri to -1 to trigger test for random

i=0
while IFS= read -r line
do
    if [[ $line =~ chaotic ]]
    then
        ri=$(($RANDOM % 10))
        val=${randblue[$ri]}
        let buff=$ri
        mode="chaotic"
    fi     
    if [[ $line =~ random ]]
    then
        if [[ $ri -eq -1 ]] #: testing if a random has already been assigned for this series
        then
            prob=$((1 + RANDOM % 10))
            # echo random prob = $prob >> $LOG #--testing only
            if [[ $prob -le $PROB_ABS ]] #: probability light turns on
            then
                ri=1
            else
                ri=0                          
            fi
            val=${randblue[$ri]}
            let buff=$ri 
            mode="random"
        fi
    fi 
    if [[ $line =~ steady ]]
    then
        val=$B
        buff=1
        mode="steady"
    fi
    if [[ $line =~ ctrl ]]
    then
        val=$B
        buff=1
    fi
    if [[ $line =~ off ]]
    then
        val=$OFF
        buff=0
        #echo "$line" >>$LOG
    fi
    if [[ $1 = "off" ]]
    then
        val=$OFF
        buff=0
    fi
    eval LED[$i]=$val
    report=$report$buff
    ((i++))
done <$L

if [ ! -f "$LOG" ]
then
    echo "making a LOG file"
    echo "# log of light instructions" > $LOG
    echo $mode light experiment >> $LOG
    echo probability of an absolute switch = $PROB_ABS >> $LOG
    echo probability of a relative switch = $PROB_REL >> $LOG
fi
echo $report $(date +%s) >> $LOG
echo "turning lights $1"

if [ "$OPTION" == "on" ]; then
    for i in ${!LED[@]}; do
        echo "<+$i*${LED[$i]}>" > $DEVICE
        # echo "<+$i*${LED[$i]}>" 
    done
else
    for i in ${!LED[@]}; do
        echo "<+$i*$OFF>" > $DEVICE
        # echo "<+$i*$OFF>"
    done

fi
