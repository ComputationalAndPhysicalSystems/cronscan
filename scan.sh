#!/bin/bash

# Webhook so the script can complain to us in real time
#! webhook established by Conrad; this might be the repo--I'm not sure
#! https://gist.github.com/andkirby/67a774513215d7ba06384186dd441d9e
export APP_SLACK_WEBHOOK=https://hooks.slack.com/services/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 #physarum channel


RESOLUTION=$1
LOCAL_DIR=$2
DELAY=4

ENUM=$(($(cat $LOCAL_DIR/count)+1))
EXPERIMENT_BASENAME=${LOCAL_DIR##*/}

export SANE_USB_WORKAROUND=1

echo "==Beginning Scan=="
date
echo "Scan count: $ENUM"
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

if [ "$SCANNER_COUNT" -lt "$(cat $LOCAL_DIR/scanners)" ]; then
	slack "[LAB ALERT]: Only detected $SCANNER_COUNT/$(cat $LOCAL_DIR/scanners) scanners. Seek scanner reset--may require physical inspection."
	export APP_SLACK_WEBHOOK=https://hooks.slack.com/services/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 #slime-report channel
    slack "[WARNING]: Only detected $SCANNER_COUNT/$(cat $LOCAL_DIR/scanners) scanners."
    slack "RIP Acquisition #$ENUM, ~$(date +%s)"
fi

for scanner in $SCANNER_LIST; do
    scanner_safename=${scanner//:/_}
    FILENAME=$scanner_safename.$(date +%s).png

    echo "Scanning $scanner to $FILENAME"

    scanimage -d $scanner --mode Color --format png --resolution $RESOLUTION > $LOCAL_DIR/$FILENAME
	echo "Delaying for $DELAY seconds"
	sleep $DELAY
done	

export APP_SLACK_WEBHOOK=https://hooks.slack.com/services/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 #slime-report channel

test -e $2/count && slack "[UPDATE} SCAN# $ENUM" || slack "[UPDATE] First scan for experiment $EXPERIMENT_BASENAME"
echo $ENUM > $LOCAL_DIR/count
rsync -ha --progress $2/LOG caps@129.101.130.89:/beta/data/CAPS/experiments/$EXPERIMENT_BASENAME
rsync -ha --progress $2/count caps@129.101.130.89:/beta/data/CAPS/experiments/$EXPERIMENT_BASENAME
rsync -ha --progress $2/xtab caps@129.101.130.89:/beta/data/CAPS/experiments/$EXPERIMENT_BASENAME
rsync -ha --progress $2/*.lights caps@129.101.130.89:/beta/data/CAPS/experiments/$EXPERIMENT_BASENAME
rsync -ha --progress $2/*.log caps@129.101.130.89:/beta/data/CAPS/experiments/$EXPERIMENT_BASENAME
