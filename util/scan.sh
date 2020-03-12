#!/bin/bash

#! Webhook so the script can complain to us in real time
#! webhook established by Conrad; this might be the repo--I'm not sure
#! https://gist.github.com/andkirby/67a774513215d7ba06384186dd441d9e
#! Set up webhooks here: https://capsidaho.slack.com/services/BNASXK525

#.. sources
#.  source golbal
source $LABPATH/.func/assigned
#.  announce data
source $LABPATH/release
gitlog=`git log --pretty=format:'%h' -n 1`
#.  status data
source $STATUSFILE

#--announce
echo "GLOBAL||r:$release git:$gitlog"
echo "<<scan.sh>> | $1 | $2 "

#.. assignments
#.  attr reassignment
RESOLUTION=$1
cron_EP=$2

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
if [ ! -d "$cron_EP" ]; then
    echo "$cron_EP not found, creating..."
    mkdir -p $cron_EP
fi

#:  LOG file info
echo "==Beginning Scan \"$EXP\"=================================(#$COUNT)"
echo "$now || UNIX: $nows"
echo
echo "Found $SCANNER_COUNT/$SCANNERS scanners:"
echo "  $SCANNER_LIST"

#:  slack alert for missing scanners
if [ $SCANNER_COUNT -lt $SCANNERS ]
then
	slack "[LAB ALERT] <EXP: $EXP>: Only detected $SCANNER_COUNT/$(cat $cron_EP/scanners) scanners. Scanners may require physical inspection."
  [[ $DIAGNOSTICS == "off" ]] && export APP_SLACK_WEBHOOK=$SLIMEHOOK
  slack "[WARNING]: Only detected $SCANNER_COUNT/$(cat $cron_EP/scanners) scanners."
  slack "RIP Acquisition #$COUNT, ~$(date +%s)"
fi
for scanner in $SCANNER_LIST; do
  if [[ $USELIGHTS == "on" ]]
  then
    i1=$((CAPACITY*si-1))
    i0=$((i1-CAPACITY+1))
    echo lights $i0 to $i1 OFF for scan
    r0=$i0
    r1=$i1
    . $LABPATH/util/lights.sh scan $EXP $i0 $i1 >> $LOGFILE #. turn off lights if exp is using
  fi
  FILENAME="$COUNT.$EXP.s$si.$nows.png"
  echo "Scanning $scanner to $FILENAME"
  scanimage -d $scanner --mode Color --format png --resolution $RESOLUTION > $cron_EP/$FILENAME
  if [[ $USELIGHTS == "on" ]]
  then
    echo restore lights $r0 to $r1
    . $LABPATH/util/lights.sh restore $EXP >> $LOGFILE #. turn off lights if exp is using
  fi
  ((si++)) #! begins at 1
done

#: sloppy code here; essentially reports to the slack channels, two channels of interest...
[[ $DIAGNOSTICS == "off" ]] && export APP_SLACK_WEBHOOK=$PHYHOOK
test -e $2/.track/count && echo || slack "[LAUNCH] First scan for experiment $EXP"

[[ $DIAGNOSTICS == "off" ]] && export APP_SLACK_WEBHOOK=$SLIMEHOOK

if [ $(( $COUNT % $SLACK_INTERVAL )) -eq 0 ]
then
    slack "[UPDATE $EXP] SCAN# $COUNT"
fi

if [[ $USELIGHTS == "on" ]]
then
  echo light program ON
  . $LABPATH/util/lights.sh on $EXP >> $LOGFILE #. turn on lights if exp is using
fi

#[[ $USELIGHTS == "on" ]] && `$LABPATH/util/lights.sh on $EP 2>&1 | tee -a $LOGFILE` #. turn of lights if exp is using
source $FUNCDIR/update.sh; update
rsync $2/*.exp caps@129.101.130.89:/beta/data/CAPS/experiments/$EXP/
rsync $STATUSFILE caps@129.101.130.89:/beta/data/CAPS/experiments/$EXP/
[[ $USELIGHTS == "on" ]] && rsync $2/*.lights caps@129.101.130.89:/beta/data/CAPS/experiments/$EXP/
rsync $2/LOG caps@129.101.130.89:/beta/data/CAPS/experiments/$EXP/

[[ $XFER == "on" ]] && . $LABPATH/util/transfer.sh $cron_EP >> $LOGFILE
