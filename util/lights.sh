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

#. attr reassignment
OPTION=$1 			#. on/off
EXP=$2 				#. exp name
i0=$3
i1=$4
echo "============="
echo "<<LIGHTS.SH>> $OPTION | $EXP | $i0 | $i1"

EP=$LABPATH/exp/$2 		#: experiment path
LIGHTLOG=$EP/$EXP.lights	#. log the light results
TOGFILE=$EP/.track/tog		#. special toggle track file
RESTOREFILE=$EP/.track/restore
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

  if [[ $OPTION == "restore" ]] #. build the restore array from restorefile
  then
    restarray=()
    while IFS= read -r restore
    do
      echo "heres restore aint it: $restore"
      [[ $restore -eq 1 ]] && restarray+=(1) || restarray+=(0)
      echo restore so far $restarray
    done <$RESTOREFILE
  fi

  #: go through list of dishes and make triggerarray results
  for (( di=0; di<=$(( DISH_CNT-1 )); di++ ))
  do
      if [[ $OPTION == "off" ]]
      then
          triggerarray+=(0)
      else                        #. option = 'on' or 'scan' or 'restore'
          found=-1
          if [[ $OPTION == "on" ]]
          then
            look=L$di #: make a string L0..Ln, for looking at the dish probability variable in the .exp file
            thisdish="${!look}" #: assign $thisdish with the probability score for that dish
          fi
          if [[ $OPTION == "scan" ]]
          then
            #: assign $thisdish with the probability score for that dish
            #[[ $di -lt $i1 && $di -gt $i2 ]] && thisdish="OFF" || thisdish="ON"
            [[ $di -ge $i0 && $di -le $i1 ]] && thisdish="OFF" || thisdish="ON"
            echo temporary scan session, light $di is $thisdish
          fi
          if [[ $OPTION == "restore" ]]
          then
            [[ ${restarray[$di]} -eq 1 ]] && thisdish="OFF" || thisdish="ON"
            echo restore light $di $thisdish
          fi
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
    if [ $TOG -eq 1 ] #. this is a toggle light program
    then
        [[ $OPTION == "on" ]] && togcalc #: use togcalc procedure to calcualte results
    else              #. not toggle program
        first="T"
        for t in ${triggerarray[@]}
        do
            [ $t == "T" -o $t == "+" ] && report+=1 || report+=0 #: summarize into one string for report purposes
            [ $t == "T" -o $t == "+" ] && resultarray+=($B) || resultarray+=($OFF)
            [ $t == "T" -o $t == "+" ] && pythonarray+=($PY_B) || pythonarray+=($PY_OFF)
            if [[ $first == "T" ]]
            then
              [$t == "T" -o $t == "+" ] && echo 1 > $RESTOREFILE || echo 0 > $RESTOREFILE
            else
              [$t == "T" -o $t == "+" ] && echo 1 >> $RESTOREFILE || echo 0 >> $RESTOREFILE
            fi
            first='F'

        done
    fi
}

togcalc(){
    #. compare previous results from TOG file to current trigger results to determine new state
    j=0
    rarray=() #. rountine temp array for writting to $TOGFILE (toggle result file)
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
    done <$TOGFILE
    first='T'
    for i in ${rarray[@]}
    do
        [[ $first == "T" ]] && echo $i > $TOGFILE || echo $i >> $TOGFILE #: first iteration overwrite TOG file
        [[ $first == "T" ]] && echo $i > $RESTOREFILE || echo $i >> $RESTOREFILE
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

    #. Resolve based on device
    if [ $CONTROLLER == 'gpio' ]    #. GPIO resolve
    then
        echo "launch python"
        sudo -E $LABPATH/util/gpio.sh $LABPATH #? pass the env variable cuz -E isn't working
        #sudo python $LABPATH/util/gpio.py -e $EXP -c $DISH_CNT
    else                            #. If using Arduino, send message to Device
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
