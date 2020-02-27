#!/bin/bash
SP=`pwd`
#python $SP/utilgpio-test.py -c $DISH_CNT -i $zkey -p
python $SP/util/gpio-test.py -c $1 -i $2 -p $3
