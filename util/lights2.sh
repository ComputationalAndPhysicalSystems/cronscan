#!/bin/bash
#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
#== This is the script for controlling NEOPIXEL lights via
#=  RPI GPIO or Arduino controller
#=  See Arduino repository for Arduino programming
#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
# attrs: $nows $i0 $i1 ($EXP)
#------------------>

#.. sources
source /usr/local/bin/caps_settings/labpath
source $LABPATH/.func/assigned
source $PROG #: read in program and light variables || ../exp/$EXP/$EXP.exp

#--announce
echo -e "\n============="
echo "<<lights.sh>> $1 | $2 | $3 | ($4)"


#.. assignments
#. attr reassignment
#OPTION=$1     #. on/off/scan/restore/init
TIME=$1
i0=$2         #. scan start range L0 index
i1=$3         #. scan end range L0 index
[[ ! -z "$4" ]] && EXP=$4				#. experiment name // reasiggnment from global optional

#. --hard coded--
#. red green and blue for arduino serial code
R="#FF0000"
G="#00FF00"
B="#0000FF"
OFF="#000000"

#. python codes (needs GPIO shell scripts)
PY_B="1" #"Color(0,0,255)"
PY_OFF="0" #"Color(0,0,0)"

#.  local vars
DishI=$((DISH_CNT-1)) #: get the dish index number for convenient use later

#~ROUTINES~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

initvars(){
  #.  arrays
  #? i=0 #?? unneeded?
  grouparray=()
  triggerarray=()
  resultarray=()
  pythonarray=()
  report=()
}


# ---rollrandom----------------->>
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

group(){
    #: make grouparray based on unique group number assignments
    #. rollrandom and store result per group in the grouparray
    if [[ $di -eq 0 ]] #: first iteration, add thisdish to grouparray
    then
      rollrandom $thisdish
      echo result $result
      read
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
        echo grouparray $grouparray
      else
        rollrandom $thisdish
        grouparray+=(${thisdish}:${result})
      fi
    fi
    triggerarray+=(${result})
    #-- trace
    echo finished dish loop
  }
# ---rollrandom------------------<<
# ---rollrandom----------------->>

# ---resolve----------------->>
resolove(){
  :
}
# ---resolve-----------------<<

# ---toggle----------------->>
toggle(){
  :
}
# ---toggle-----------------<<

# ---mainloop----------------->>
mainloop(){
  #--announce
  echo -e "~~~~~~~~~~\n<mainloop>"



}
# ---mainloop-----------------<<


nextstate(){
  [[ ! -f "$LIGHTLOG" ]] && . $LABPATH/.func/initlightlog.sh $LIGHTLOG


    #. write results to light log file
    [[ $OPTION == "on" ]] && echo -n "+" >> $LIGHTLOG || echo -n "-" >> $LIGHTLOG #: '+' for ON, '-' for OFF

    echo -n ${report} $TIME >> $LIGHTLOG
    if [ $OPTION == "on" ]
    then
        echo "|| ${grouparray[@]} " >> $LIGHTLOG
    else
        echo "|| turn off for scan">> $LIGHTLOG
    fi

    #: write out nextstate file
    for i in ${!pythonarray[@]}
    do
        [[ $i -eq 0 ]] && printf "${pythonarray[$i]}" > $STATETRACK || echo -n "${pythonarray[$i]}" >> $STATETRACK
    done

    #: write out python data file

}

# ---newlist----------------->>
triggerlist(){
  #:: go through list of dishes and make triggerarray results
  #:  store w triggerarray for later action

  #!! this is the clumsy way of looking up the values from the EXP list.
  #!! let's look at the LLIST file, instad.
  for (( di=0; di<=$DishI; di++ )) #: zero-index lights
  do
    found=-1 #?? what is it?
    look=L$di #: make a string L0..Ln, for looking at the dish probability variable in the .exp file
    thisdish="${!look}" #: assign $thisdish with the probability score for that dish
    [[ $thisdish == "ON" ]] && triggerarray+=(+)
    [[ $thisdish == "OFF" ]] && triggerarray+=(-)
    [ $thisdish == "ON" -o $thisdish == "OFF" ] && continue
  done

  #:  evaluate triggererarray
  first="T"     #. first time thru flag
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
  OPTION=on #!!!!TEMP
  nextstate #:  write it out to .track/state file

}
# ---newlist-----------------<<

prepscanner(){

  #: write out python data file : si = state of i

  echo $i0, $i1
  for i in ${!pythonarray[@]}
  do
      #: range test to turn off light
      r=${pythonarray[$i]}

      [ $i -ge $i0 -a $i -le $i1 ] && r=0

      #: write one i at a time.
      [[ $i -eq 0 ]] && printf $r > $SETPY || echo -n $r >> $SETPY

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

seekstate(){
  n=()
  i=0
  while read -r -n1 n[i]
  do
    pythonarray+=(${n[i]})
    ((++i))
  done < $STATETRACK
}

#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
#$ needed: $LLIST

#--> if light index start is 0, this is the first run; make new LLIST <-- maybe use this if there's a per/dish scanners
#: curently checking if $i1 is '5', which means it's the first scanner, in a 6 dish configuration
# $i1 will be 0 for the final go, reset lights...

initvars

echo dishcnt $DISH_CNT
echo $PROG

#: hard code the 5 so we can move on for now...
[[ $i1 -eq 5 ]] && triggerlist || seekstate

echo report is: $report

prepscanner

#resolve
#mainloop
