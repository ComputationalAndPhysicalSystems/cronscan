#!bin/bash
#. Make a log file if none exists


update(){
  echo "~~~~~~~~~~~~~update function scans $SCANS"
  echo EXP=$EXP > $STATUSFILE
  echo SYSTEM=$SYSTEM >> $STATUSFILE
  echo PLATE_CNT=$PLATE_CNT >> $STATUSFILE
  echo SCANNERS=$SCANNERS >> $STATUSFILE
  echo SCANS=$SCANS >> $STATUSFILE
  echo USELIGHTS=$USELIGHTS >> $STATUSFILE
  echo XFER=$XFER >> $STATUSFILE
  echo STATUS=started >> $STATUSFILE
  echo DIAGNOSTICS=$DIAGNOSTICS >> $STATUSFILE
  echo GITALERT=$GITALERT >> $STATUSFILE
}
