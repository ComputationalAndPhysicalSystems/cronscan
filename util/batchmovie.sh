#!/bin/bash
#.. SOURCES
source /usr/local/bin/caps_settings/labpath
source $LABPATH/release
cd "${BASH_SOURCE%/*}"
gitlog=`git log --pretty=format:'%h' -n 1`

#--announce
echo
echo -e "\nGLOBAL||r:$release git:$gitlog"
printf '=%.0s' {1..45}

echo
echo "<<batchmovie.sh>> "
printf '~%.0s' {1..29}
echo -e "\n"
#.. assignments


#. first crop the latest file


#. find crop job files on the server

croparray=( ~/lab/movie/*.crop )
for job in $croparray
do
  echo "found job: $(basename -- $job)"
done

for c in "${croparray[@]}"
do
  source $c
  basename "$c"
  act="$(basename -- $c)"
  act="${act%.*}"
  echo "crop file $act"
  IFS='.' read -r -a parms <<< $act
  echo result: ${parms[@]}
  # crop.sh ~ [reqd] $1: exp name $2: scanner number $3: number (four padded) $4 full image name
  # optional $4: offset-x, $5: offset-y
  . crop.sh ${parms[0]} ${parms[1]} ${parms[2]:1} ${parms[3]} ${act} $llist
done




#. call movie.sh with $1=exp name $2=scanner count $3=release
