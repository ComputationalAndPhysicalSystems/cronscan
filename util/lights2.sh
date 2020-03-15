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


##____ELIMINATE
#init: one line /scanner, complete string of light orders
#ex 2scanners with TOGGLE -,+,3x5,8x5

# .track/state (regardless of ON/TOGGLE, ie no Toggle compare, since all previous state was off anyway)
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
# ---rollrandom------------------<<
# ---resolve----------------->>
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



  if [[ $PROGRAM == "random.toggle" ]]
  then
    [[ ! $COUNT -eq 0 ]] && toggle #don't do toggle for first scan
  fi


  case $PROGRAM in
        "random.toggle")
          [[ $COUNT -eq 0 ]] && a=a #!! figure out how to flow to the random on case
          a=a
          ;;
        "steady")
          a=a
          ;;
        *)
          a=a # "random.on" or first random.toggle
          ;;
  esac

# ---mainloop-----------------<<
# ---newlist----------------->>
newlist(){
  #:: go through list of dishes and make triggerarray results
  #:  option = 'on' 'off' 'scan' 'restore'
  #:  store w triggerarray for later action
  for (( di=0; di<=$(( DishI)); di++ )) #: zero-index lights
  do
    found=-1 #?? what is it?
    look=L$di #: make a string L0..Ln, for looking at the dish probability variable in the .exp file
    thisdish="${!look}" #: assign $thisdish with the probability score for that dish
    [[ $thisdish == "ON" ]] && triggerarray+=(+)
    [[ $thisdish == "OFF" ]] && triggerarray+=(-)
    [ $thisdish == "ON" -o $thisdish == "OFF" ] && continue

    #: make grouparray based on unique group number assignments
    #. rollrandom and store result per group in the grouparray
    if [[ $OPTION == "on" ]]
    then
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
    fi
    triggerarray+=(${result})
    #-- trace
    echo finished dish loop
  done
  echo triggerarray
  read
}
# ---newlist-----------------<<

#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
#$ needed: $LLIST

#: if light index start is 0, this is the first run; make new LLIST
[[ $i0 -eq 0 ]] && newlist



resolve
mainloop
