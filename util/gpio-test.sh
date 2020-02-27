#!/bin/bash
#-p GPIOPIN from config file -c $DISH_CNT -i $zkey (which LED or 0 for all)

SP=`pwd`
python $SP/util/gpio-test.py -c $2 -i $3