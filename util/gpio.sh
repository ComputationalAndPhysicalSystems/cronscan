#!/bin/bash
LABPATH=$1
source $LABPATH/exp/status.env
python $LABPATH/util/gpio.py -e $EXP -c $PLATE_CNT -v $DIAGNOSTICS
