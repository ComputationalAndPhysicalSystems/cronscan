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
EXP=$4				#. experiment name // reasiggnment from global optional

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

##____ELIMINATE
#init: one line /scanner, complete string of light orders
#ex 2scanners with TOGGLE -,+,3x5,8x5

# .track/setpy (regardless of ON/TOGGLE, ie no Toggle compare, since all previous state was off anyway)
# roll dice
# writes out calculations for this state
# 010000011111 (for example)
#_____________



#scan:
#scan right off the bat when launching START

#IF scan count = 0, treat as not a toggle (initiliaze)
#IF TOGGLE
#read /state (previous state, really)
#ELSE do nothing

# roll dice
# resolve.
# create a scan sequence, spliting by scanner #
#ex
# scanline+ 000000011111
# scanline+ 010000000000 <<< last scanner
# then combine with OR =
# state= 010000011111 > .track/state

#for each SI (scanner index) do
# send scanner line SI (turns off those lights)
# perform scan
# next SI

#~ROUTINES~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

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
  #:  option = 'on' 'off' 'scan' 'restore'
  #:  store w triggerarray for later action
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

#: if light index start is 0, this is the first run; make new LLIST
# $i1 will be zero for the final go, rest lights...

echo dishcnt $DISH_CNT
echo $PROG
echo lets scan scanner 1, so make next calc then turn off lights for scanner1
echo then replace .track/state with new state


[[ $i0 -eq 0 ]] && triggerlist || seekstate

echo ok, did that. Now turn off scannerX, switch remaining scanners to new state
echo report is: $report

prepscanner

#resolve
#mainloop
