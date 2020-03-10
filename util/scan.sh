#!/bin/bash
#WTF
# Webhook so the script can complain to us in real time
#! webhook established by Conrad; this might be the repo--I'm not sure
#! https://gist.github.com/andkirby/67a774513215d7ba06384186dd441d9e
#! Set up webhooks here: https://capsidaho.slack.com/services/BNASXK525
source /usr/local/bin/caps_settings/config
source /usr/local/bin/caps_settings/physarumhook
source /usr/local/bin/caps_settings/slimehook
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
echo "==Beginning Scan \"$EXP\"================================="
echo $now
echo $nows
echo "local directory: $EP"

if [[ $USELIGHTS == "on" ]]
then
  echo lights OFF for scan
  . $LABPATH/util/lights.sh off $EXP >> $EP/LOG #. turn off lights if exp is using
fi

echo "Scan count: $COUNT"

SCANNER_LIST=$(scanimage -f "%d%n")
SCANNER_COUNT=$(echo "$SCANNER_LIST" | wc -l)

echo "Found $SCANNER_COUNT/$SCANNERS scanners:"
echo "$SCANNER_LIST"

if [ $SCANNER_COUNT -lt $SCANNERS ]
then
	slack "[LAB ALERT] <EXP: $EXP>: Only detected $SCANNER_COUNT/$(cat $EP/scanners) scanners. Scanners may require physical inspection."
	source /usr/local/bin/caps_settings/slimehook
    slack "[WARNING]: Only detected $SCANNER_COUNT/$(cat $EP/scanners) scanners."
    slack "RIP Acquisition #$COUNT, ~$(date +%s)"
fi
si=1
for scanner in $SCANNER_LIST; do
    FILENAME="$COUNT.$EXP.s$si.$nows.png"

    echo "Scanning $scanner to $FILENAME"

    scanimage -d $scanner --mode Color --format png --resolution $RESOLUTION > $EP/$FILENAME
    ((si++))
done

#: sloppy code here; essentially reports to the slack channels, two channels of interest...
source /usr/local/bin/caps_settings/physarumhook
test -e $2/count && echo || slack "[LAUNCH] First scan for experiment $EXP"

source /usr/local/bin/caps_settings/slimehook

if [ $(( $COUNT % $SLACK_INTERVAL )) -eq 0 ]
then
    slack "[UPDATE] SCAN# $COUNT"
fi

if [[ $USELIGHTS == "on" ]]
then
  echo light program ON
  . $LABPATH/util/lights.sh on $EXP >> $EP/LOG #. turn on lights if exp is using
fi

#[[ $USELIGHTS == "on" ]] && `$LABPATH/util/lights.sh on $EP 2>&1 | tee -a $EP/LOG` #. turn of lights if exp is using

echo COUNT > $EP/.track/count
echo EXP=$EXP > $STATUSFILE
echo DISH_CNT=$DISH_CNT >> $STATUSFILE
echo SCANNERS=$SCANNERS >> $STATUSFILE
echo SCANS=$COUNT >> $STATUSFILE
echo USELIGHTS=$USELIGHTS >> $STATUSFILE
echo STATUS=running >> $STATUSFILE
rsync $2/*.exp caps@129.101.130.89:/beta/data/CAPS/experiments/$EXP/
rsync $STATUSFILE caps@129.101.130.89:/beta/data/CAPS/experiments/$EXP/
rsync $2/*.lights caps@129.101.130.89:/beta/data/CAPS/experiments/$EXP/
rsync $2/LOG caps@129.101.130.89:/beta/data/CAPS/experiments/$EXP/

[[ $XFER == "on" ]] && . $LABPATH/util/transfer.sh $EP >> $EP/LOG
