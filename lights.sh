#!/bin/bash

#==	This is the script for controlling NEOPIXEL lights via Arduino controller
#  	See Arduino repository for Arduino programming


#..	input parms:
#.	$1 >  on/off  { lower case req }

#. hardcode path

P=/home/caps/scripts/caps_cronscan/exp/

OPTION=$1
EXP=$2
EP="$P$2/$2" #: path prefix
LOG=$EP.log
LP=$EP.lights #: light program file

#. hard coded

DEVICE="/dev/ttyACM0" #- Arudino Leonardo signature;
OFF="#000000"

#. red green and blue

R="#FF0000"
G="#00FF00"
B="#0000FF"

randblue[0]=$OFF
randblue[1]=$B

i=0
while IFS= read -r line; do
	echo $line
    if [[ $line =~ random ]]
    then
    	# echo $((1 + RANDOM % 2))
    	ri=$(($RANDOM % 2))
    	val=${randblue[$ri]}
    	let buff=$ri
    	mode="random"
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
done <$LP
echo report: $report 
for val in ${LED[@]}; do
   echo from the array: $val
done

if [ ! -f "$LOG" ]
then
    echo "making a LOG file"
	echo "# log of light instructions" > $LOG
	echo $mode light experiment >> $LOG
fi
echo $report $(date) >> $LOG


# source $2.lights #: in one commad, loads all variables
# echo and... $L0
# for i in $(cat $2.lights); do
# 	echo $i
# done




#. fixed program

# LED[0]="$OFF"
# LED[1]="$R"
# LED[2]="$R"
# LED[3]="#F0F0FF"
# LED[4]="#00FF00"
# LED[5]="#00FF00"
# LED[6]="#00FF00"
# LED[7]="#00FF00"
# LED[8]="#00FF00"
# LED[9]="#00FF00"
# LED[10]="#00FF00"
# LED[11]="#00FF00"
# #=======
# LED[0]="$B"
# LED[1]="$B"
# LED[2]="$B"
# LED[3]="$B"
# LED[4]="$B"


echo "turning lights $1"

if [ "$OPTION" == "on" ]; then
	for i in ${!LED[@]}; do
		# echo "<+$i*${LED[$i]}>" > $DEVICE
		echo "<+$i*${LED[$i]}>"
	done
else
	for i in ${!LED[@]}; do
		# echo "<+$i*$OFF>" > $DEVICE
		echo "<+$i*$OFF>"
	done

fi
