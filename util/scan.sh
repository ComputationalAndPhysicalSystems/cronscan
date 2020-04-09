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
source $LLIST  #. get $llist string

#.  announce data
source $LABPATH/release

#.  attr reassignment
RESOLUTION=$1

#!! maybe it worked once? CHECK THE GIT REPORT SEE if it works
cd "${BASH_SOURCE%/*}"
gitlog=`git log --pretty=format:'%h' -n 1`

#--announce
echo
printf '~%.0s' {1..45}
echo -e "\nGLOBAL||r:$release git:$gitlog"
echo "<<scan.sh>> | resolution=$1"
printf '~%.0s' {1..29}
echo
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
#if [ ! -d "NEED FULL PATH HERE $EXP" ]; then
#    echo "$EXP not found, creating..."
#    mkdir -p $EXP
#fi

#:  LOG file info
if [ "$gitlog" != "$gitlog_init" -a "$GITALERT" != "warned" ]
then
  echo -e "\n*** slack alert for gitlog change"
  slack "[WARNING]: The gitlog has changed, indiating a code update since the experiment began."
  GITALERT="warned"
fi
echo -e "\n==Beginning Scan \"$EXP\"=================================(#$COUNT)"
echo "$now || UNIX: $nows"

#:  check on scanners
echo -e "\nFound $SCANNER_COUNT/$SCANNERS scanners:"
echo -e "$SCANNER_LIST\n"

#:  slack alert for missing scanners
if [ $SCANNER_COUNT -lt $SCANNERS ]
then
  echo "*** slack alert for missing scanner"
	slack "[LAB ALERT] <EXP: $EXP>: Only detected $SCANNER_COUNT/$SCANNERS scanners. Scanners may require physical inspection."
  [[ $DIAGNOSTICS == "off" ]] && export APP_SLACK_WEBHOOK=$SLIMEHOOK
  slack "[WARNING]: Only detected $SCANNER_COUNT/$SCANNERS scanners."
  slack "RIP Acquisition #$COUNT, ~$(date +%s)"
fi

# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
#:  scan command loop
for scanner in $SCANNER_LIST
do
  pad=`printf %04d $COUNT`
  SCANFILE="$pad.$EXP.s$si.$nows.png"
  MPEGFILE="$pad.$EXP.s$si.png"

  #: turn off lights
  if [[ $USELIGHTS == "on" ]]
  then
    echo -e "\nScanning on scanner $si"
    i1=$((CAPACITY*si-1))
    i0=$((i1-CAPACITY+1))s
    echo "...turn $((i0+1)) to $((i1+1)) OFF for scan"
    r0=$i0
    r1=$i1
    . $LABPATH/util/lights.sh $nows $i0 $i1 >> $LOGFILE #. turn off lights if exp is using

#    . $LABPATH/util/lights.sh scan $EXP $nows $i0 $i1 >> $LOGFILE #. turn off lights if exp is using
  fi

  #: restore lights
  echo "-> Scanning $scanner to $SCANFILE"
  scanimage -d $scanner --mode Color --format png --resolution $RESOLUTION > $EP/$SCANFILE

  #. upload the crop files to phil

  # ssh caps@129.101.130.90 "echo llist=$llist touch > ~/lab/movie/$EXP/$SCANFILE.crop" #. ${s}.$pad.crop"
  # ssh caps@129.101.130.90 "echo =$llist touch >> ~/lab/movie/$EXP/$SCANFILE.crop" #. ${s}.$pad.crop"



  ((si++)) #! begins at 1
done


#: sloppy code here; essentially reports to the slack channels, two channels of interest...
[[ $DIAGNOSTICS == "off" ]] && export APP_SLACK_WEBHOOK=$PHYHOOK
if [ $COUNT -eq 1 ]
then
  echo "* slack report first scan"
  slack "[LAUNCH] First scan for experiment $EXP"
fi

[[ $DIAGNOSTICS == "off" ]] && export APP_SLACK_WEBHOOK=$SLIMEHOOK

if [ $(( $COUNT % $SLACK_INTERVAL )) -eq 0 ]
then
    echo "* slack scan frequency report "
    slack "[UPDATE $EXP] SCAN# $COUNT"
fi

if [[ $USELIGHTS == "on" ]]
then
  #restore lights for new state
  nows=$(date +%s)
  . $LABPATH/util/lights.sh $nows 0 "-1" >> $LOGFILE #. turn off lights if exp is using

  #. $LABPATH/util/lights.sh on $EXP $nows >> $LOGFILE #. turn on lights if exp is using
fi

echo "-----------------------------"
#..	update status file
source $FUNCDIR/status.sh; update

rsync $EXPFILE caps@129.101.130.89:/beta/data/CAPS/experiments/$EXP/
rsync $STATUSFILE caps@129.101.130.89:/beta/data/CAPS/experiments/$EXP/
[[ $USELIGHTS == "on" ]] && rsync $LIGHTLOG caps@129.101.130.89:/beta/data/CAPS/experiments/$EXP/
rsync $LOGFILE caps@129.101.130.89:/beta/data/CAPS/experiments/$EXP/

if [ $XFER == "on" ]
then
  echo "copy scan to Mnemosyne"
  rsync -za --quiet $EP/$SCANFILE caps@129.101.130.89:/beta/data/CAPS/experiments/$EXP/
  echo "copy scan to Repeller"
  rsync -za --quiet $EP/$SCANFILE caps@129.101.130.88:~/lab/segment/$EXP/

  echo "moving image to Phil for movie FFMPEG"

  #: note that it necesssary to move an existing file without name change to the leaf directory with rsync, because trying to sync a file to a leaf that doesn't yet exist will not work when SPECIFYING THE NAME of the file at destination. IT's very stupid.
  #: talk to phil, movie server
  rsync $EXPFILE caps@129.101.130.90:~/lab/movie/$EXP/
  rsync $STATUSFILE caps@129.101.130.90:~/lab/movie/$EXP/

  rsync -za --quiet --remove-source-files $EP/$SCANFILE caps@129.101.130.90:~/lab/movie/$EXP/$MPEGFILE

  #!! can't get this remote server copy command to work. not ssh, not cp, not scp, not rsync...
  #! ssh -A caps@129.101.130.89 rsync /beta/data/CAPS/experiments/$EXP/$SCANFILE /beta/data/CAPS/experiments/$EXP/$MPEGFILE

fi

rsync $STATUSFILE caps@129.101.130.89:/beta/data/CAPS/experiments/${HOSTNAME}_status
