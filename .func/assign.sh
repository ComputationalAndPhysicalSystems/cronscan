#!bin/bash
#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
#..   $1, ($2)
#.    $EXP name, /cronscan/path,

#.. sources
source /usr/local/bin/caps_settings/labpath
source /usr/local/bin/caps_settings/config

#--announce
echo ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
echo "<<assign.sh>> | $1 | $2"

#.. attr reassignment
#.  LABPATH override // may be needed for some testing environs
EXP=$1
[[ ! -z "$2" ]] && LABPATH=$2

#.. assignments
#.  output files
ASSIGNED=$LABPATH/.func/assigned #: the output from this script

#.  local use for lazy
ep=$LABPATH/exp
EP=$ep/$EXP

#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
#~~ output to file
#!  be careful for first entry >
echo \#!bin/bash > $ASSIGNED

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
echo EP=$EP >> $ASSIGNED             #: experiment path
echo TRACKDIR=$EP/.track >> $ASSIGNED

echo -e "\n#.  output files" >> $ASSIGNED
echo STATUSFILE=$ep/status.env >> $ASSIGNED
echo LASTFILE=$ep/last.exp >> $ASSIGNED
echo SAVEFILE=$EP/$EXP.tmp >> $ASSIGNED
echo EXPFILE=$EP/$EXP.exp >> $ASSIGNED
echo PROG=$EP/$EXP.exp >> $ASSIGNED		          #: complete exp program file
echo XTABFILE=$EP/xtab >> $ASSIGNED
echo LOGFILE=$EP/LOG >> $ASSIGNED
echo LIGHTLOG=$EP/light.log >> $ASSIGNED       #. log the light results
echo PYTRACK=$EP/.track/py >> $ASSIGNED
echo TOGTRACK=$EP/.track/tog	>> $ASSIGNED	      #. special toggle track file
echo COUNTTRACK=$EP/.track/count >> $ASSIGNED
echo RESTORETRACK=$EP/.track/restore >> $ASSIGNED

echo -e "\n#.  scripts" >> $ASSIGNED
echo SETUPSH=$LABPATH/.func/setup.sh >> $ASSIGNED
