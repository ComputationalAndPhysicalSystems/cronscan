#!/bin/bash
LABPATH=$1
source $LABPATH/exp/status.env
python $LABPATH/util/gpio.py -e $EXP -c $DISH_CNT -v $DIAGNOSTICS
