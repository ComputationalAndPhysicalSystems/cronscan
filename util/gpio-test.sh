#!/bin/bash
#-c $DISH_CNT -i $zkey (which LED or 0 for all)

python $LABPATH/util/gpio-test.py -c $1 -i $2