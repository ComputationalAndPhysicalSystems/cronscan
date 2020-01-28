#!/bin/bash
# https://www.youtube.com/watch?v=jeq161yD8tk
options=($(find ../exp -maxdepth 2 -iname '*.exp' -print0|xargs -0 )) 

echo "select file"
select opt in "${options[@]}" "Quit";
do
	if ((REPLY == 1 + ${#options[@]}))
	then
		exit
	elif (( REPLY <= ${#options[@]}))
	then
		display=$(basename $opt)
		echo $opt
		echo "File selected $display"
		break
	else
		echo "Not valid"
	fi
done

