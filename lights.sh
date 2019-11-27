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

source $LP #: read in ABS and REL variables
source $LAST

#! coding for REL or ABS for the time being is exclusive. One of these variables must be zero


[[ $SWITCH -eq "a" ]] && TOG=0 || TOG=1


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

# for i in {0..$(( DISH_CNT-1 ))}
for (( di=0; di<=$(( DISH_CNT-1 )); di++ ))
do
    # echo $di
    look=L$di
    thisdish="${!look}"

    case $thisdish in

    0)            #: NEG CONTROL OFF
        echo light off
        ;;
    10)             #: pos control ON
        echo light on
        ;;
    *)
        PROB=$di  
            # if [[ $PROGRAM =~ random ]]
            # then
            #     if [[ $ri -eq -1 ]] #: testing if a random has already been assigned for this series
            #     then
            #         prob=$((1 + RANDOM % 10))
            #         # echo random prob = $prob >> $LOG #--testing only
            #         echo prob: $prob
            #         echo PROB: $PROB
            #         if [[ $prob -le $PROB ]] #: compare the random value to the parameter
            #         then
            #             ri=1
            #         else
            #             ri=0                          
            #         fi
            #         if [[ $TOG -eq 1 ]] #: change results of $ri if the type of random is toggle
            #         then
            #             [[ $ri -eq 1 ]] && effect=" toggle state" || effect=" no change"
            #             ri=`echo $(( last - TOG * ri )) | sed 's/-//'`
            #         fi
            #         val=${randblue[$ri]}
            #         let buff=$ri 
            #         mode="random"
            #     fi
            # fi  
        echo $PROB
        ;;
    esac

    # if [[ $line =~ steady ]]
    # then
    #     val=$B
    #     buff=1
    #     mode="steady"
    # fi
    # if [[ $line =~ ctrl ]]
    # then
    #     val=$B
    #     buff=1
    # fi
    # if [[ $line =~ off ]]
    # then
    #     val=$OFF
    #     buff=0
    #     #echo "$line" >>$LOG
    # fi
    # if [[ $OPTION = "off" ]]
    # then
    #     val=$OFF
    #     buff=0
    # fi
    # eval LED[$i]=$val
    # report=$report$buff
    # ((i++))
done

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
    echo probability of an absolute switch = $PROB_ABS >> $LOG
    echo probability of a relative switch = $PROB_REL >> $LOG
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
