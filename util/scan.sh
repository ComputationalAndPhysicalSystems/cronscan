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
#DELAY=4

ENUM=$(($(cat $EP/count)+1))
EXP=${EP##*/}

export SANE_USB_WORKAROUND=1

now=$(date)
nows=$(date +%s)
echo "==Beginning Scan================================="
echo $now
echo $nows

[[ $LIGHTS == "on" ]] && . $LABPATH/util/lights.sh off $EXP >> $EP/LOG #. turn off lights if exp is using

echo "Scan count: $ENUM"
echo "Experiment \"$EXP\" will be stored in $EP"

# Create experiment direcotry if it doesn't already exist
if [ ! -d "$EP" ]; then
    echo "$EP not found, creating..."
    mkdir -p $EP
fi

SCANNER_LIST=$(scanimage -f "%d%n")
SCANNER_COUNT=$(echo "$SCANNER_LIST" | wc -l)

# Have we stored information about scanner count?
#if [ ! -f "$EP/scanners" ]; then
#    echo "$SCANNER_COUNT" > "$EP/scanners"
#fi

#echo "Found $SCANNER_COUNT/$(cat $EP/scanners) scanners:"
echo "Found $SCANNER_COUNT/$SCANNERS scanners:"
echo "$SCANNER_LIST"

if [ $SCANNER_COUNT -lt $SCANNERS ]
then
	slack "[LAB ALERT] <EXP: $EXP>: Only detected $SCANNER_COUNT/$(cat $EP/scanners) scanners. Scanners may require physical inspection."
	source /usr/local/bin/caps_settings/slimehook
    slack "[WARNING]: Only detected $SCANNER_COUNT/$(cat $EP/scanners) scanners."
    slack "RIP Acquisition #$ENUM, ~$(date +%s)"
fi
si=1
for scanner in $SCANNER_LIST; do
    scanner_safename=${scanner//:/_}
    FILENAME="$ENUM.$EXP.s$si.$nows.png"

    echo "Scanning $scanner to $FILENAME"

    scanimage -d $scanner --mode Color --format png --resolution $RESOLUTION > $EP/$FILENAME
    ((si++))
#	echo "Delaying for $DELAY seconds"
#	sleep $DELAY
done

#: sloppy code here; essentially reports to the slack channels, two channels of interest...
source /usr/local/bin/caps_settings/physarumhook
test -e $2/count && echo || slack "[LAUNCH] First scan for experiment $EXP"

source /usr/local/bin/caps_settings/slimehook

if [ $(( $ENUM % $SLACK_INTERVAL )) -eq 0 ]
then
    slack "[UPDATE] SCAN# $ENUM"
fi

[[ $LIGHTS == "on" ]] && . $LABPATH/util/lights.sh on $EXP >> $EP/LOG #. turn on lights if exp is using 

#[[ $LIGHTS == "on" ]] && `$LABPATH/util/lights.sh on $EP 2>&1 | tee -a $EP/LOG` #. turn of lights if exp is using

echo $ENUM > $EP/count
rsync $2/*.exp caps@129.101.130.89:/beta/data/CAPS/experiments/$EXP/
rsync $2/count caps@129.101.130.89:/beta/data/CAPS/experiments/$EXP/
rsync $2/xtab caps@129.101.130.89:/beta/data/CAPS/experiments/$EXP/
rsync $2/*.pylog caps@129.101.130.89:/beta/data/CAPS/experiments/$EXP/
rsync $2/*.log caps@129.101.130.89:/beta/data/CAPS/experiments/$EXP/
rsync $2/LOG caps@129.101.130.89:/beta/data/CAPS/experiments/$EXP/

[[ $XFER == "on" ]] `$LABPATH/util/transfer.sh \$ep 2>&1 | tee -a $EP/LOG`
