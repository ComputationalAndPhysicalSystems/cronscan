#!/bin/bash
#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
#== This is the script for controlling NEOPIXEL lights via
#=  RPI GPIO or Arduino controller
#=  See Arduino repository for Arduino programming
#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
#..   $1, ($2), ($3), ($4)
#.    $OPTION, $EXP, $i0, $i1
#.ex  $LABPATH/util/lights.sh scan $EXP $i0 $i1
#.. sources
#.  source golbal
source /usr/local/bin/caps_settings/labpath
source $LABPATH/.func/assigned

#--announce
echo -e "\n============="
echo "<<lights.sh>> $1 | $2 | $3 | $4"



#.  source exp program
source $PROG #: read in program and light variables

#.. assignments
#. attr reassignment
OPTION=$1     #. on/off/scan/restore/init
EXP=$2 				#. experiment name // reasiggnment from global optional
i0=$3         #. scan start range L0 index
i1=$4         #. scan end range L0 index

#. --hard coded--
#. red green and blue
R="#FF0000"
G="#00FF00"
B="#0000FF"
OFF="#000000"
PY_B="1" #"Color(0,0,255)"
PY_OFF="0" #"Color(0,0,0)"

#.  local vars
DishI=$((DISH_CNT-1)) #: get the dish index number for convenient use later

#. read and set if abs or relative [on/toggle]
IFS='.' read -r -a buffer <<< "$PROGRAM"
switch="${buffer[1]}"
[[ $switch == "on" ]] && TOG=0 || TOG=1

#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
initvars(){
  #.  arrays
  #? i=0 #?? unneeded?
  grouparray=()
  triggerarray=()
  resultarray=()
  pythonarray=()
  report=()
}

rollrandom(){
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

mainloop(){
  #--announce
  echo -e "~~~~~~~~~~\n<mainloop>"

  #.. assignments
  initvars

  #: build the restore array from RESTORETRACK
  if [[ $OPTION == "restore" ]]
  then
    #--trace
    echo "|option = $OPTION"
    restarray=()
    line=0
    while IFS= read -r restore
    do
      echo "Light $line restore value: $restore"
      [[ $restore -eq 1 ]] && restarray+=(1) || restarray+=(0)
      ((line++))
    done <$RESTORETRACK
    echo restore command array: ${restarray[@]}
  fi

  #:: go through list of dishes and make triggerarray results
  #:  option = 'on' 'off' 'scan' 'restore'
  #:  store w triggerarray for later action
  for (( di=0; di<=$(( DISH_CNT-1 )); di++ )) #: zero-index lights
  do
    case $OPTION in
  			  "off")
            triggerarray+=(0)
  			    ;;

  			  "on")
            found=-1 #?? what is it?
            look=L$di #: make a string L0..Ln, for looking at the dish probability variable in the .exp file
            thisdish="${!look}" #: assign $thisdish with the probability score for that dish
  			    ;;
          "scan")
            if [ -z "$i0" ] || [ -z "$i1" ] #: scan.sh needs to send all 4 attrs
            then
              echo "missing range attrs; EXIT"
              exit
            fi
            if [[ $di -ge $i0 && $di -le $i1 ]]
            then
              thisdish="OFF"
            else
              thisdish=`sed "$((${di}+1))q;d" $RESTORETRACK` #: +1 line number, 1-base index
              #--trace
              echo "previous setting from file $thisdish"
            fi

            echo temporary scan session, light $di is $thisdish
            ;;
          "restore")
            [[ ${restarray[$di]} -eq 1 ]] && thisdish="OFF" || thisdish="ON"
            echo restore light $di $thisdish
            ;;
          "init")
            echo initialize lighting
            echo $EXP
            echo $LIGHTLOG
            echo "# log of light instructions for \"$EXP\"" > $LIGHTLOG
            ;;

  			  *)
  			    ;;
  	esac
    [[ $thisdish == "ON" ]] && triggerarray+=(+)
    [[ $thisdish == "OFF" ]] && triggerarray+=(-)
    [ $thisdish == "ON" -o $thisdish == "OFF" ] && continue
    #[ $thisdish == "ON" -o $thisdish -eq 1 ] && triggerarray+=(+)
    #[ $thisdish == "OFF" -o $thisdish -eq 0 ] && triggerarray+=(-)
    #[ $thisdish == "ON" -o $thisdish == "OFF" -o \
    #  $thisdish -eq 0 -o $thisdish -eq 1 ] && continue
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
              [ $t == "T" -o $t == "+" ] && echo 1 > $RESTORETRACK || echo 0 > $RESTORETRACK
            else
              [ $t == "T" -o $t == "+" ] && echo 1 >> $RESTORETRACK || echo 0 >> $RESTORETRACK
            fi
            first='F'

        done
    fi
}

togcalc(){
    #. compare previous results from TOG file to current trigger results to determine new state
    j=0
    rarray=() #. rountine temp array for writting to $TOGTRACK (toggle result file)
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
        [[ $first == "T" ]] && echo $i > $TOGTRACK || echo $i >> $TOGTRACK #: first iteration overwrite TOG file
        [[ $first == "T" ]] && echo $i > $RESTORETRACK || echo $i >> $RESTORETRACK
        first='F'
    done

}

finish(){
  [[ ! -f "$LIGHTLOG" ]] && . $LABPATH/.func/initlightlog.sh $LIGHTLOG


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
        [[ $i -eq 0 ]] && printf "\n${pythonarray[$i]}" >> $PYTRACK || echo -n "${pythonarray[$i]}" >> $PYTRACK
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
