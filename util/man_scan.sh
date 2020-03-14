#!/bin/bash
RESOLUTION=$1

COUNT=manual
nows=$(date +%s)
SCANNER_LIST=$(scanimage -f "%d%n")
si=1  #: scan loop initialize


for scanner in $SCANNER_LIST; do
  FILENAME="$COUNT.$EXP.s$si.$nows.png"

  #: turn off lights // later feature
  if [[ $USELIGHTS == "on" ]]
  then
    #run clear
    a=a
#    . $LABPATH/util/lights.sh scan $EXP $nows $i0 $i1 >> $LOGFILE #. turn off lights if exp is using
  fi

  echo "-> Scanning $scanner to $FILENAME"
  scanimage -d $scanner --mode Color --format png --resolution $RESOLUTION > $EXP/$FILENAME

  #: restore lights // later feature
  if [[ $USELIGHTS == "on" ]]
  then
    nothing=nothing
    #!!echo restore lights $r0 to $r1
    #!!. $LABPATH/util/lights.sh restore $EXP $nows >> $LOGFILE #. turn off lights if exp is using
  fi
  ((si++)) #! begins at 1
done
