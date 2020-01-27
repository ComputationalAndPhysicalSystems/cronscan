#!/bin/bash
# https://www.youtube.com/watch?v=jeq161yD8tk


echo "select file"
options=($(find /home/caps/scripts/caps_cronscan/exp -maxdepth 2 -iname '*.exp' -print0|xargs -0))

select opt in "${options[@]}" "Quit";
do
	if (( REPLY == 1 + ${#options[@]}))
	then
		exit
	elif (( REPLY > 0 && REPLY <= ${options[@]}))
	then
		echo "File selected $opt"
		break
	else
		echo "Not valid"
	fi
done

