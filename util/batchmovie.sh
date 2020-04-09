#!/bin/bash
#.. SOURCES
source /usr/local/bin/caps_settings/labpath
source $LABPATH/release
cd "${BASH_SOURCE%/*}"
gitlog=`git log --pretty=format:'%h' -n 1`

#--announce
echo
printf '~%.0s' {1..45}
echo -e "\nGLOBAL||r:$release git:$gitlog"
echo "<<batchmovie.sh>> "
printf '~%.0s' {1..29}
echo
#.. assignments
PATH="~/lab/movie"

#. first crop the latest file
# reqd $1: exp name $2: path  $3: number four padded
# optional $4: offset-x, $5: offset-y

#. find crop job files on the server

croparray=( ~/lab/movie/*.crop )
echo "found jobs: ${croparray[@]}"
echo "------------------------"
echo pause--
read
for c in "${croparray[@]}"
do
  basename "$c"
  act="$(basename -- $c)"
  act="${act%.*}"
  echo "crop file $act"
  IFS='.' read -r -a parms <<< $act
  echo result: ${parms[@]}
  . crop.sh ${parms[0]} $PATH ${parms[1]}
done




#. call movie.sh with $1=exp name $2=scanner count $3=release
