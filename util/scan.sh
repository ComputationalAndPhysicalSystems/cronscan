#!/bin/bash
#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
#! Webhook so the script can complain to us in real time
#! webhook established by Conrad; this might be the repo--I'm not sure
#! https://gist.github.com/andkirby/67a774513215d7ba06384186dd441d9e
#! Set up webhooks here: https://capsidaho.slack.com/services/BNASXK525
#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

#.. SOURCES
#.  source golbal
source /usr/local/bin/caps_settings/labpath
source $LABPATH/.func/assigned

#.  status data
source $STATUSFILE

#.  announce data
source $LABPATH/release

#.  attr reassignment
RESOLUTION=$1

#!! maybe it worked once? CHECK THE GIT REPORT SEE if it works
#? cd "${BASH_SOURCE%/*}"
gitlog=`git log --pretty=format:'%h' -n 1`

#--announce
echo -e "\nGLOBAL||r:$release git:$gitlog"
echo "<<scan.sh>> | resolution=$1"

#.. assignments

#.  export env vars
export APP_SLACK_WEBHOOK=$DEVHOOK #: set as default, reprogram dynamically
export SANE_USB_WORKAROUND=1      #: Conrad's trick / dunno

#.  local vars
COUNT=$(($(cat $COUNTTRACK)+1))
now=$(date)
nows=$(date +%s)
SCANNER_LIST=$(scanimage -f "%d%n")
SCANNER_COUNT=$(echo "$SCANNER_LIST" | wc -l)
si=1  #: scan loop initialize

#:  Create experiment direcotry if it doesn't already exist
#/  likely never to happen ---
if [ ! -d "$EXP" ]; then
    echo "$EXP not found, creating..."
    mkdir -p $EXP
fi

#:  LOG file info
echo -e "\n==Beginning Scan \"$EXP\"=================================(#$COUNT)"
echo "$now || UNIX: $nows"

#:  check on scanners
echo -e "\nFound $SCANNER_COUNT/$SCANNERS scanners:"
echo -e "  $SCANNER_LIST \n"

#:  slack alert for missing scanners
if [ $SCANNER_COUNT -lt $SCANNERS ]
then
	slack "[LAB ALERT] <EXP: $EXP>: Only detected $SCANNER_COUNT/$(cat $EXP/scanners) scanners. Scanners may require physical inspection."
  [[ $DIAGNOSTICS == "off" ]] && export APP_SLACK_WEBHOOK=$SLIMEHOOK
  slack "[WARNING]: Only detected $SCANNER_COUNT/$(cat $EXP/scanners) scanners."
  slack "RIP Acquisition #$COUNT, ~$(date +%s)"
fi


for scanner in $SCANNER_LIST; do
  FILENAME="$COUNT.$EXP.s$si.$nows.png"

  #: turn off lights
  if [[ $USELIGHTS == "on" ]]
  then
    echo -e "\nlights off on scanner $si"
    i1=$((CAPACITY*si-1))
    i0=$((i1-CAPACITY+1))
    echo "...turn $((i0+1)) to $((i1+1)) OFF for scan"
    r0=$i0
    r1=$i1
    . $LABPATH/util/lights.sh off $EXP $nows >> $LOGFILE #. turn off lights if exp is using

#    . $LABPATH/util/lights.sh scan $EXP $nows $i0 $i1 >> $LOGFILE #. turn off lights if exp is using
  fi

  #: restore lights
  echo "-> Scanning $scanner to $FILENAME"
  scanimage -d $scanner --mode Color --format png --resolution $RESOLUTION > $EXP/$FILENAME

  if [[ $USELIGHTS == "on" ]]
  then
    nothing=nothing
    #!!echo restore lights $r0 to $r1
    #!!. $LABPATH/util/lights.sh restore $EXP $nows >> $LOGFILE #. turn off lights if exp is using
  fi
  ((si++)) #! begins at 1
done

#: sloppy code here; essentially reports to the slack channels, two channels of interest...
[[ $DIAGNOSTICS == "off" ]] && export APP_SLACK_WEBHOOK=$PHYHOOK
test -e $COUNTTRACK && echo || slack "[LAUNCH] First scan for experiment $EXP"

[[ $DIAGNOSTICS == "off" ]] && export APP_SLACK_WEBHOOK=$SLIMEHOOK

if [ $(( $COUNT % $SLACK_INTERVAL )) -eq 0 ]
then
    slack "[UPDATE $EXP] SCAN# $COUNT"
fi

if [[ $USELIGHTS == "on" ]]
then
  nows=$(date +%s)
  echo light program ON
  . $LABPATH/util/lights.sh on $EXP $nows >> $LOGFILE #. turn on lights if exp is using
fi

#[[ $USELIGHTS == "on" ]] && `$LABPATH/util/lights.sh on $EP 2>&1 | tee -a $LOGFILE` #. turn of lights if exp is using
#..	update status file
source $FUNCDIR/status.sh; update
rsync $EXPFILE caps@129.101.130.89:/beta/data/CAPS/experiments/$EXP/
rsync $STATUSFILE caps@129.101.130.89:/beta/data/CAPS/experiments/$EXP/
[[ $USELIGHTS == "on" ]] && rsync $LOGFILE caps@129.101.130.89:/beta/data/CAPS/experiments/$EXP/
rsync $LOGFILE caps@129.101.130.89:/beta/data/CAPS/experiments/$EXP/

[[ $XFER == "on" ]] && . $LABPATH/util/transfer.sh $EXP >> $LOGFILE
