#!/bin/bash
#-------------assigning to array variable in a loop
# label=()
#
# for i in {1..6}
# do
#   resultarray+=($B)
#   label+=("name, plate $i")
# done
# echo ${label[@]}
#-------------next..

# croparray=( /home/caps/lab/movie/*.crop )
# echo "found jobs: ${croparray[@]}"
# echo "------------------------"
# echo pause--
# read
# for c in "${croparray[@]}"
# do
#   basename "$c"
#   act="$(basename -- $c)"
#   act="${act%.*}"
#   echo "crop file $act"
#   IFS='.' read -r -a parms <<< $act
#   echo ${parms[2]:1}
#   echo result: ${parms[@]}
# done


#-------------next..
# args+=("thing")
# args+=("boo")
#
# thing=1
# boo=2
#
# for arg in "${args[@]}"
# do
#    echo ${arg}=\"${!arg}\"
#    if grep -q "oo" <<< "$arg"
#    then
#      echo "found oo"
#    fi
# done

#------------.DYNAMIC VARIABLE
# suffix=bzz
# declare prefix_$suffix=mystr
# varname=prefix_$suffix
# echo ${!varname}

#------------.
# source $LABPATH/.func/assigned
# scanner=1
# cropfile=$TRACKDIR/s${scanner}.crop
# SCANFILE=0001.theoretical.s1.45464564.png
# rsync $cropfile caps@129.101.130.90:~/lab/movie/$SCANFILE.crop

#------------.rename directory of files, remove x characters
#
# for f in *png; do
#   mv "$f" "${f%??????????????}png"
#    #mv -- "$f" "${f:0:$position-1}${f:$position}"
# done

echo "shot:"
read shot

zipit()

zipit(){
  echo shot
}
