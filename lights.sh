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
LAST=$P/$2/last
LP=$EP.exp #: light program file
L=$EP.lights

source $LP #: read in program and light variables
source $LAST

dishes=$((DISH_CNT*SCANNERS))

#! coding for REL or ABS for the time being is exclusive. One of these variables must be zero
IFS='.' read -r -a buffer <<< "$PROGRAM"
switch="${buffer[1]}"

[[ $switch == "on" ]] && TOG=0 || TOG=1



#. hard coded

DEVICE="/dev/ttyACM0" #- Arudino Leonardo signature;
OFF="#000000"

#. red green and blue

R="#FF0000"
G="#00FF00"
B="#0000FF"

randblue[0]=$OFF
randblue[1]=$B


rollrandom (){
    echo "rolling... "
    prob=$((1 + RANDOM % 10))
    # echo random prob = $prob >> $LOG #--testing only
    if [[ $prob -le $1 ]] #: compare the random value to the parameter
    then
        result=T
    else
        result=F                       
    fi

    # return $result
    # mode="random"
}


finish (){

    #! cut from elsewhere
    # if [[ $TOG -eq 1 ]] #: change results of $ri if the type of random is toggle
    # then
    #     [[ $result -eq 1 ]] && effect=" toggle state" || effect=" no change"
    #     result=`echo $(( last - TOG * result )) | sed 's/-//'`
    # fi
    # val=${randblue[$result]}
    # let buff=$result


    [[ $ri -eq 1 ]] && result="on" || result="off"
    [[ $OPTION == "off" ]] && result="off" #: input paramter overrides result
    if [ $TOG -eq 0 ]
    then
        [[ $ri -eq 1 ]] && effect=" switch on" || effect=" switch off"
    fi

    if [ ! -f "$LOG" ]
    then
        echo "making a LOG file"
        echo "# log of light instructions" > $LOG
        echo $mode light experiment >> $LOG
        # echo probability of an absolute switch = $PROB_ABS >> $LOG
        # echo probability of a relative switch = $PROB_REL >> $LOG
    fi
    echo last=$ri > $LAST
    if [ $OPTION == "on" ] 
    then
        echo -n +$report $(date +%s) >> $LOG
        echo -n "|| rolled a $prob" >> $LOG 
        echo " = $effect" >> $LOG
    else #: record what the probability roll was
        echo -n -$report $(date +%s) >> $LOG
        echo "|| turn off for scan">> $LOG
    fi


    echo "turning lights $result"


    if [ "$OPTION" == "on" ]
    then
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
}


mainloop (){
ri=-1 #: set $ri to -1 to trigger test for random

i=0
grouparray=()
triggerarray=()

#: go through list of dishes and make triggerarray results
for (( di=0; di<=$(( dishes-1 )); di++ ))
do
    found=-1
    look=L$di #: make a string L0..Ln, for looking at the dish probability variable in the .exp file
    thisdish="${!look}" #: assign $thisdish with the probability score for that dish

    #: make grouparray based on unique group number assignments
    #. rollrandom and store result per group in the grouparray
    if [[ $di -eq 0 ]] #: first iteration, add thisdish to grouparray
    then
        rollrandom $thisdish
        grouparray+=(${thisdish}:${result})
    else
        if printf '%s\n' ${grouparray[@]} | grep -q -P ${thisdish}
        then
            for xi in "${!grouparray[@]}"
            do
                if [[ "${grouparray[$xi]}" =~ ${thisdish} ]]
                then
                    echo found $thisdish at "${xi}"
                    found=${x1}
                    IFS=':' read -r -a buffer <<< "${grouparray[$xi]}"
                    result="${buffer[1]}"

                fi
            done
        else
            rollrandom $thisdish
            grouparray+=(${thisdish}:${result})
        fi  
    fi
    triggerarray+=(${result})
done
echo grouparray: ${grouparray[@]}
echo triggerarray: ${triggerarray[@]}

    # case $thisdish in

    # 0)          #: NEG CONTROL = OFF
    #     echo light off
    #     ;;
    # 10)         #: POS CONTRL = ON
    #     echo light on
    #     ;;
    # *)
    #     echo thisdish: $thisdish
    #     rollrandom
    #     ;;
    # esac

}

mainloop
