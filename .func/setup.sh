#!bin/bash
#. Make a log file if none exists

#.  LIGHTLOG override // may be needed for some testing environs

[[ ! -z "$1" ]] && LIGHTLOG=$1

#. init vars
listarray=()

initlights(){
  #--announce
  echo -e "~~~~~~~~~~~~~~~~~~\n<<setup.sh {initlights} >> | $1 " >> $LOGFILE
  echo -e "\nmaking a LOG file" >> $LOGFILE
  echo LIGHTLOG file: $LIGHTLOG >> $LOGFILE
  echo "# log of light instructions for \"$EXP\"" > $LIGHTLOG
  echo $PROGRAM light experiment >> $LIGHTLOG
  echo -n "probabilities:" >> $LIGHTLOG
  for (( di=0; di<=$(( PLATE_CNT-1 )); di++ ))
  do
    look=L$di #: make a string L0..Ln, for looking at the plate probability variable in the .exp file
    thisplate="${!look}" #: assign $thisplate with the probability score for that plate

    #: lout to make $LPROG
    lout=$thisplate                      #:
    [ $thisplate == "ON" ] && lout="+"
    [ $thisplate == "OFF" ] && lout="-"
    listarray+=$lout

    #: make the human readable report line 0
    [ $thisplate != "ON" -a $thisplate != "OFF" ] && thisplate+="0%"
    echo -n " D$((di+1)):$thisplate">> $LIGHTLOG
    echo -n


  done
  echo llist=$listarray > $LLIST
  echo >> $LIGHTLOG
  echo "===========================" >> $LIGHTLOG
}
