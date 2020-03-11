#!/bin/bash
#WTF
# Webhook so the script can complain to us in real time
#! webhook established by Conrad; this might be the repo--I'm not sure
#! https://gist.github.com/andkirby/67a774513215d7ba06384186dd441d9e
#! Set up webhooks here: https://capsidaho.slack.com/services/BNASXK525
source /usr/local/bin/caps_settings/config
export APP_SLACK_WEBHOOK=$DEVHOOK
RESOLUTION=$1
EP=$2

STATUSFILE=$LABPATH/exp/status.env

source $STATUSFILE

# Create experiment direcotry if it doesn't already exist
if [ ! -d "$EP" ]; then
    echo "$EP not found, creating..."
    mkdir -p $EP
fi

COUNT=$(($(cat $EP/.track/count)+1))
EXP=${EP##*/}

export SANE_USB_WORKAROUND=1

now=$(date)
nows=$(date +%s)
echo "==Beginning Scan \"$EXP\"=================================(#$COUNT)"
echo $now
echo $nows

SCANNER_LIST=$(scanimage -f "%d%n")
SCANNER_COUNT=$(echo "$SCANNER_LIST" | wc -l)

echo "Found $SCANNER_COUNT/$SCANNERS scanners:"
echo "$SCANNER_LIST"

if [ $SCANNER_COUNT -lt $SCANNERS ]
then
	slack "[LAB ALERT] <EXP: $EXP>: Only detected $SCANNER_COUNT/$(cat $EP/scanners) scanners. Scanners may require physical inspection."
  [[ $DIAGONSTICS == "off" ]] && export APP_SLACK_WEBHOOK=$SLIMEHOOK
  #source /usr/local/bin/caps_settings/slimehook
    slack "[WARNING]: Only detected $SCANNER_COUNT/$(cat $EP/scanners) scanners."
    slack "RIP Acquisition #$COUNT, ~$(date +%s)"
fi
si=1
for scanner in $SCANNER_LIST; do
  if [[ $USELIGHTS == "on" ]]
  then
    echo hey si = $si
    echo and capacity = $CAPACITY
    i1=$((CAPACITY*si-1))
    i0=$((i1-CAPACITY))
    echo lights $i0 to $i1 OFF for scan
    . $LABPATH/util/lights.sh scan $EXP $i0 $i1 >> $EP/LOG #. turn off lights if exp is using
    #. $LABPATH/util/lights.sh off $EXP >> $EP/LOG #. turn off lights if exp is using
  fi
  FILENAME="$COUNT.$EXP.s$si.$nows.png"

  echo "Scanning $scanner to $FILENAME"

  scanimage -d $scanner --mode Color --format png --resolution $RESOLUTION > $EP/$FILENAME
  ((si++))
done

#: sloppy code here; essentially reports to the slack channels, two channels of interest...
[[ $DIAGONSTICS == "off" ]] && export APP_SLACK_WEBHOOK=$PHYHOOK
test -e $2/.track/count && echo || slack "[LAUNCH] First scan for experiment $EXP"

[[ $DIAGONSTICS == "off" ]] && export APP_SLACK_WEBHOOK=$SLIMEHOOK

if [ $(( $COUNT % $SLACK_INTERVAL )) -eq 0 ]
then
    slack "[UPDATE $EXP] SCAN# $COUNT"
fi

if [[ $USELIGHTS == "on" ]]
then
  echo light program ON
  . $LABPATH/util/lights.sh on $EXP >> $EP/LOG #. turn on lights if exp is using
fi

#[[ $USELIGHTS == "on" ]] && `$LABPATH/util/lights.sh on $EP 2>&1 | tee -a $EP/LOG` #. turn of lights if exp is using

echo $COUNT > $EP/.track/count
echo EXP=$EXP > $STATUSFILE
echo SYSTEM=$SYSTEM >> $STATUSFILE
echo DISH_CNT=$DISH_CNT >> $STATUSFILE
echo SCANNERS=$SCANNERS >> $STATUSFILE
echo SCANS=$COUNT >> $STATUSFILE
echo USELIGHTS=$USELIGHTS >> $STATUSFILE
echo XFER=$XFER >> $STATUSFILE
echo STATUS=running >> $STATUSFILE
echo DIAGNOSTICS=$DIAGNOSTICS >> $STATUSFILE
rsync $2/*.exp caps@129.101.130.89:/beta/data/CAPS/experiments/$EXP/
rsync $STATUSFILE caps@129.101.130.89:/beta/data/CAPS/experiments/$EXP/
[[ $USELIGHTS == "on" ]] && rsync $2/*.lights caps@129.101.130.89:/beta/data/CAPS/experiments/$EXP/
rsync $2/LOG caps@129.101.130.89:/beta/data/CAPS/experiments/$EXP/

[[ $XFER == "on" ]] && . $LABPATH/util/transfer.sh $EP >> $EP/LOG
