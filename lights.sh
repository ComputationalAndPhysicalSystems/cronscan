#!/bin/bash

#== This is the script for controlling NEOPIXEL lights via Arduino controller
#   See Arduino repository for Arduino programming

#.. input parms:
#.  $1 >  on/off  { lower case req }
#.  $2 >  exp name

#. random program assigns a random result to all samples with a given probability setting

##### HARD CODED
#. red green and blue
R="#FF0000"
G="#00FF00"
B="#0000FF"
OFF="#000000"

DEVICE="/dev/ttyACM0" #- Arudino Leonardo signature;

#. hardcode path
P=/home/caps/scripts/caps_cronscan/exp/

OPTION=$1
EXP=$2
EP="$P$2/$2" #: path prefix
LOG=$EP.log
LAST=$P$2/tog
LP=$EP.exp #: light program file
L=$EP.lights

source $LP #: read in program and light variables

dishes=$((DISH_CNT*SCANNERS))

#. read and set if abs or relative [on/toggle]
IFS='.' read -r -a buffer <<< "$PROGRAM"
switch="${buffer[1]}"
[[ $switch == "on" ]] && TOG=0 || TOG=1

rollrandom (){
    #! coding for REL or ABS for the time being is exclusive. One of these variables must be zero
    prob=$((1 + RANDOM % 10))
    # echo random prob = $prob >> $LOG #--testing only
    if [[ $prob -le $1 ]] #: compare the random value to the parameter
    then
        result=T
    else
        result=F                       
    fi
    echo "rolled $prob for $10% = $result"
}

mainloop (){
i=0
grouparray=()
triggerarray=()
resultarray=()
report=()

#: go through list of dishes and make triggerarray results
for (( di=0; di<=$(( dishes-1 )); di++ ))
do
    if [[ $OPTION == "off" ]]
    then
        triggerarray+=(0)
    else
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
                        # echo found $thisdish at "${xi}"
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
    fi
done
}

resolve()
{
    echo grouparray: ${grouparray[@]}
    echo triggerarray: ${triggerarray[@]}
    echo TOG $TOG

    [[ $TOG -eq 1 ]] && togcalc #: use togcalc procedure to calcualte results

    for t in ${triggerarray[@]}
    do
        # echo t: $t
        # echo --report: ${report[@]}           

        [[ $t == "T" ]] && report+=1 || report+=0 #: summarize into one string for report purposes
        [[ $t == "T" ]] && resultarray+=($B) || resultarray+=($OFF)
    done
    echo resultarray: ${resultarray[@]}
    echo report: ${report}   
}

togcalc(){
    #. we must compare previous results to trigger results to determine new state
    echo heellllllo
    j=0
    while IFS= read -r line
    do
        if [ $line -eq 0 ]
        then
            echo j:$j
            echo ${triggerarray[$j]}
        fi
        ((j++))
    done <$LAST

    # for i in ${!resultarray[@]}

    # do
    # done

    #     [[ $result -eq 1 ]] && effect=" toggle state" || effect=" no change"
    #     result=`echo $(( last - TOG * result )) | sed 's/-//'`
    # fi
    # val=${light[$result]}
    # let buff=$result


    # # [[ $ri -eq 1 ]] && result="on" || result="off" #>! editing, dunno
    # # [[ $OPTION == "off" ]] && result="off" #: input paramter overrides result #>! editing, dunno
    # # if [ $TOG -eq 0 ]
    # # then
    # #     [[ $ri -eq 1 ]] && effect=" switch on" || effect=" switch off"
    # # fi    

    # #. Store results to TOG log file for toggle switch calculations
    # [[ $TOG -eq 1 ]] && echo last=$ri > $LAST
}

finish (){
    #. Make a log file if none exists
    if [ ! -f "$LOG" ]
    then
        echo "making a LOG file"
        echo "# log of light instructions" > $LOG
        echo $PROGRAM light experiment >> $LOG
        echo -n "probabilities:" >> $LOG
        for (( di=0; di<=$(( dishes-1 )); di++ ))
        do
            look=L$di #: make a string L0..Ln, for looking at the dish probability variable in the .exp file
            thisdish="${!look}0%" #: assign $thisdish with the probability score for that dish
            echo -n " D$((di+1)):$thisdish">> $LOG
        done
        echo >> $LOG
        echo "==============" >> $LOG
    fi


    #. write results to light log file
    [[ $OPTION == "on" ]] && echo -n "+" >> $LOG || echo -n "-" >> $LOG #: '+' for ON, '-' for OFF
    
    echo -n ${report} $(date +%s) >> $LOG
    if [ $OPTION == "on" ]
    then
        echo "|| ${grouparray[@]} " >> $LOG 
        # echo " = $effect" >> $LOG
    else
        echo "|| turn off for scan">> $LOG
    fi

    #. Send message to Device
    for i in ${!resultarray[@]}
    do
        echo "<+$i*${resultarray[$i]}>" > $DEVICE
        echo "<+$i*${resultarray[$i]}>"
    done
}

mainloop
resolve
finish