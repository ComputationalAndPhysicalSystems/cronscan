#!/bin/bash

#== This is the script for controlling NEOPIXEL lights via Arduino controller
#   See Arduino repository for Arduino programming

#.. input parms:
#.  $1 >  on/off  { lower case req }
#.  $2 >  exp name

#. random program assigns a random result to all samples with a given probability setting

##### Source Configs

source /usr/local/bin/caps_settings/config

##### HARD CODED
#. red green and blue
R="#FF0000"
G="#00FF00"
B="#0000FF"
OFF="#000000"
PY_B="1" #"Color(0,0,255)"
PY_OFF="0" #"Color(0,0,0)"

DEVICE="/dev/ttyACM0" #- Arudino Leonardo signature;

echo LABPATH = $LABPATH
#. attr reassignment
OPTION=$1 			#. on/off
EXP=$2 				#. exp name

EP=$LABPATH/exp/$2 		#: experiment path
LIGHTLOG=$EP/$EXP.lights	#. log the light results
TOGTRACK=$EP/.track/tog		#. special toggle track file
PROG=$EP/$EXP.exp 		#: complete exp program file
PYLOG=$EP/.track/pylog

source $PROG #: read in program and light variables

DishI=$((DISH_CNT-1)) #: get the dish index number for convenient use later


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
    # echo "rolled $prob for $10% = $result"
}

mainloop (){
i=0
grouparray=()
triggerarray=()
resultarray=()
pythonarray=()
report=()

#: go through list of dishes and make triggerarray results
for (( di=0; di<=$(( DISH_CNT-1 )); di++ ))
do
    if [[ $OPTION == "off" ]]
    then
        triggerarray+=(0)
    else
        found=-1
        look=L$di #: make a string L0..Ln, for looking at the dish probability variable in the .exp file
        thisdish="${!look}" #: assign $thisdish with the probability score for that dish
        [[ $thisdish == "ON" ]] && triggerarray+=(+)
        [[ $thisdish == "OFF" ]] && triggerarray+=(-)
        [ $thisdish == "ON" -o $thisdish == "OFF" ] && continue
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
    if [ $TOG -eq 1 ]
    then
        [[ $OPTION == "on" ]] && togcalc #: use togcalc procedure to calcualte results
    else
        for t in ${triggerarray[@]}
        do
            [ $t == "T" -o $t == "+" ] && report+=1 || report+=0 #: summarize into one string for report purposes
            [ $t == "T" -o $t == "+" ] && resultarray+=($B) || resultarray+=($OFF)
            [ $t == "T" -o $t == "+" ] && pythonarray+=($PY_B) || pythonarray+=($PY_OFF)

        done
    fi
}

togcalc(){
    #. compare previous results from TOG file to current trigger results to determine new state
    j=0
    rarray=() #. rountine temp array for writting to $LAST (toggle result file)
    while IFS= read -r last
    do
        case $last in
          -)
            report+=0
            rarray+=(-)
            resultarray+=($OFF)
            pythonarray+=($PY_OFF)
            ;;
          +)
            report+=1
            rarray+=(+)
            resultarray+=($B)
            pythonarray+=($PY_B)
            ;;
          *)
            [[ ${triggerarray[$j]} == "T" ]] && trigger=1 || trigger=0
            tresult=`echo $(( last - TOG * trigger )) | sed 's/-//'`
            [[ $tresult -eq 1 ]] && resultarray+=($B) || resultarray+=($OFF)
            [[ $tresult -eq 1 ]] && pythonarray+=($PY_B) || pythonarray+=($PY_OFF)
            [[ $tresult -eq 1 ]] && report+=1 || report+=0
            [[ $tresult -eq 1 ]] && rarray+=(1) || rarray+=(0) #. temp buffer for tog result file
            ;;
        esac

        ((j++))
    done <$TOGTRACK
    first='T'
    for i in ${rarray[@]}
    do
        if [[ $first == "T" ]]
        then
          echo init TOGTRACK 
          echo $i > $TOGTRACK
        else
          echo $i >> $TOGTRACK #: first iteration overwright TOG file
        fi
        first='F'
    done
}

finish(){
    #. Make a log file if none exists
    if [ ! -f "$LIGHTLOG" ]
    then
        echo "making a LOG file"
        echo "# log of light instructions" > $LIGHTLOG
        echo $PROGRAM light experiment >> $LIGHTLOG
        echo -n "probabilities:" >> $LIGHTLOG
        for (( di=0; di<=$(( DISH_CNT-1 )); di++ ))
        do
            look=L$di #: make a string L0..Ln, for looking at the dish probability variable in the .exp file
            thisdish="${!look}" #: assign $thisdish with the probability score for that dish
            [ $thisdish != "ON" -a $thisdish != "OFF" ] && thisdish+="0%"
            echo -n " D$((di+1)):$thisdish">> $LIGHTLOG
        done
        echo >> $LIGHTLOG
        echo "==============" >> $LIGHTLOG
    fi

    #. write results to light log file
    [[ $OPTION == "on" ]] && echo -n "+" >> $LIGHTLOG || echo -n "-" >> $LIGHTLOG #: '+' for ON, '-' for OFF

    echo -n ${report} $(date +%s) >> $LIGHTLOG
    if [ $OPTION == "on" ]
    then
        echo "|| ${grouparray[@]} " >> $LIGHTLOG
    else
        echo "|| turn off for scan">> $LIGHTLOG
    fi

    #: write out python data file
    for i in ${!pythonarray[@]}
    do
        [[ $i -eq 0 ]] && printf "\n${pythonarray[$i]}" >> $PYLOG || echo -n "${pythonarray[$i]}" >> $PYLOG
    done

    #. If using Arduino, send message to Device
    if [ $CONTROLLER == 'gpio' ]
    then
        echo "launch python"
        sudo python $LABPATH/util/gpio.py -e $EXP -c $DISH_CNT
    else
        for i in ${!resultarray[@]}
        do
            echo "<+$i*${resultarray[$i]}>" > $DEVICE
            echo "<+$i*${resultarray[$i]}>"
        done
    fi
}

mainloop
resolve
finish
