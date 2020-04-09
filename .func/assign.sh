#!bin/bash
#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
#..   $1, ($2)
#.    $EXP name, /cronscan/path,

#.. sources
source /usr/local/bin/caps_settings/labpath
source /usr/local/bin/caps_settings/config

#--announce
echo -e "\n~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~"
echo "<<assign.sh>> | $1 | ($2)"

#.. attr reassignment
#.  LABPATH override // may be needed for some testing environs
[[ ! -z "$1" ]] && EXP=$1
[[ ! -z "$2" ]] && LABPATH=$2 #:~ if for any reason we want a different root path

#.. assignments
#.  output files
ASSIGNED=$LABPATH/.func/assigned #: the output from this script

#.  local use for lazy
eroot=$LABPATH/exp
ebase=$eroot/$EXP

#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
#~~ output to file
#!  be careful for first entry >

echo \#!bin/bash > $ASSIGNED

echo SEG_XTABFILE=$SEG_XTABFILE >> $ASSIGNED
echo MOVIE_XTABFILE=$MOVIE_XTABFILE >> $ASSIGNED


echo -e "\n#~~~~~~~~~~~" >> $ASSIGNED
echo EXP=$EXP >> $ASSIGNED

echo -e "\n#.  global settings" >> $ASSIGNED
echo LABPATH=$LABPATH >> $ASSIGNED
echo CAPACITY=$CAPACITY >> $ASSIGNED
echo DEVICE=$DEVICE >> $ASSIGNED #- Arudino Leonardo signature;

echo -e "\n#.  slack" >> $ASSIGNED
echo SLACK_INTERVAL=$SLACK_INTERVAL >> $ASSIGNED
echo DEVHOOK=$DEVHOOK >> $ASSIGNED
echo PHYHOOK=$PHYHOOK >> $ASSIGNED
echo SLIMEHOOK=$SLIMEHOOK >> $ASSIGNED

echo -e "\n#.  pathing" >> $ASSIGNED
echo FUNCDIR=$LABPATH/.func >> $ASSIGNED
echo EP=$ebase >> $ASSIGNED             #: experiment path
echo TRACKDIR=$ebase/.track >> $ASSIGNED

echo -e "\n#.  output files" >> $ASSIGNED
echo STATUSFILE=$eroot/status.env >> $ASSIGNED
echo LASTFILE=$eroot/last.exp >> $ASSIGNED
echo SAVEFILE=$ebase/$EXP.tmp >> $ASSIGNED
echo EXPFILE=$ebase/$EXP.exp >> $ASSIGNED
#echo EXPREMOTE=
echo PROG=$ebase/$EXP.exp >> $ASSIGNED		          #: complete exp program file
echo XTABFILE=$ebase/xtab >> $ASSIGNED

echo LOGFILE=$ebase/LOG >> $ASSIGNED
echo LIGHTLOG=$ebase/light.log >> $ASSIGNED       #. log the light results
echo SETPY=$ebase/.track/setpy >> $ASSIGNED
echo STATETRACK=$ebase/.track/state >> $ASSIGNED
echo TOGTRACK=$ebase/.track/tog	>> $ASSIGNED	      #. special toggle track file
echo RESTORETRACK=$ebase/.track/restore >> $ASSIGNED
echo -n LLIST=$ebase/.track/llist >> $ASSIGNED     #: cheatsheet for lights, one string


echo -e "\n#.  scripts" >> $ASSIGNED
echo SETUPSH=$LABPATH/.func/setup.sh >> $ASSIGNED
