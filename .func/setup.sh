#!bin/bash
#. Make a log file if none exists

#.  LIGHTLOG override // may be needed for some testing environs

[[ ! -z "$1" ]] && LIGHTLOG=$1

initlights(){
  #--announce
  echo -e "~~~~~~~~~~~~~~~~~~\n<<initlightlog.sh>> | $1 "
  echo -e "\nmaking a LOG file"
  echo "# log of light instructions for $EXP" > $LIGHTLOG
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
  echo "===========================" >> $LIGHTLOG
}
