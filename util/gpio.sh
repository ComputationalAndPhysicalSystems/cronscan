#!/bin/bash

source $LABPATH/exp/status.env
python $LABPATH/util/gpio.py -e $EXP -c $DISH_CNT

