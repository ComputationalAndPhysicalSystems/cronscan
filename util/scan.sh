#!/bin/bash

# Webhook so the script can complain to us in real time
#! webhook established by Conrad; this might be the repo--I'm not sure
#! https://gist.github.com/andkirby/67a774513215d7ba06384186dd441d9e
#! Set up webhooks here: https://capsidaho.slack.com/services/BNASXK525
source /usr/local/bin/caps_settings/config
source /usr/local/bin/caps_settings/physarumhook
source /usr/local/bin/caps_settings/slimehook

RESOLUTION=$1
LOCAL_DIR=$2
#DELAY=4

SCANS=$(($(cat $LOCAL_DIR/count)+1))
EXPERIMENT_BASENAME=${LOCAL_DIR##*/}

export SANE_USB_WORKAROUND=1

echo "==Beginning Scan=="
date
echo "Scan count: $SCANS"
echo "Experiment \"$EXPERIMENT_BASENAME\" will be stored in $LOCAL_DIR"

# Create experiment direcotry if it doesn't already exist
if [ ! -d "$LOCAL_DIR" ]; then
    echo "$LOCAL_DIR not found, creating..."
    mkdir -p $LOCAL_DIR
fi

SCANNER_LIST=$(scanimage -f "%d%n")
SCANNER_COUNT=$(echo "$SCANNER_LIST" | wc -l)

# Have we stored information about scanner count?
if [ ! -f "$LOCAL_DIR/scanners" ]; then
    echo "$SCANNER_COUNT" > "$LOCAL_DIR/scanners"
fi

echo "Found $SCANNER_COUNT/$(cat $LOCAL_DIR/scanners) scanners:"
echo "$SCANNER_LIST"

if [ "$SCANNER_COUNT" -lt "$(cat $LOCAL_DIR/scanners)" ]
then
	slack "[LAB ALERT] <EXP: $EXPERIMENT_BASENAME>: Only detected $SCANNER_COUNT/$(cat $LOCAL_DIR/scanners) scanners. Scanners may require physical inspection."
	source /usr/local/bin/caps_settings/slimehook
    slack "[WARNING]: Only detected $SCANNER_COUNT/$(cat $LOCAL_DIR/scanners) scanners."
    slack "RIP Acquisition #$SCANS, ~$(date +%s)"
fi
si=1
for scanner in $SCANNER_LIST; do
    scanner_safename=${scanner//:/_}
    FILENAME="$SCANS.$EXPERIMENT_BASENAME.s$si.$(date +%s).png" #$scanner_safename.$(date +%s).png

    echo "Scanning $scanner to $FILENAME"

    scanimage -d $scanner --mode Color --format png --resolution $RESOLUTION > $LOCAL_DIR/$FILENAME
    ((si++))
#	echo "Delaying for $DELAY seconds"
#	sleep $DELAY
done

#: sloppy code here; essentially reports to the slack channels, two channels of interest...
source /usr/local/bin/caps_settings/physarumhook
test -e $2/count && echo || slack "[LAUNCH] First scan for experiment $EXPERIMENT_BASENAME"

source /usr/local/bin/caps_settings/slimehook

if [ $(( $SCANS % $SLACK_INTERVAL )) -eq 0 ]
then
    slack "[UPDATE] SCAN# $SCANS"
fi

echo $SCANS > $LOCAL_DIR/count
echo EXP=$EXP > $LABPATH/exp/status.env
echo DISH_CNT=$DISH_CNT >> $LABPATH/exp/status.env
echo SCANNERS=$SCANNERS >> $LABPATH/exp/status.env
echo SCANS=$SCANS >> $LABPATH/exp/status.env
echo STATUS=running >> $LABPATH/exp/status.env

rsync $2/LOG caps@129.101.130.89:/beta/data/CAPS/experiments/$EXPERIMENT_BASENAME/
rsync $2/count caps@129.101.130.89:/beta/data/CAPS/experiments/$EXPERIMENT_BASENAME/
rsync $2/xtab caps@129.101.130.89:/beta/data/CAPS/experiments/$EXPERIMENT_BASENAME/
rsync $2/*.exp caps@129.101.130.89:/beta/data/CAPS/experiments/$EXPERIMENT_BASENAME/
rsync $2/*.lights caps@129.101.130.89:/beta/data/CAPS/experiments/$EXPERIMENT_BASENAME/
rsync $2/*.log caps@129.101.130.89:/beta/data/CAPS/experiments/$EXPERIMENT_BASENAME/
