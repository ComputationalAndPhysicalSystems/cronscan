#!/bin/bash

#--announce
echo
printf '~%.0s' {1..45}
echo -e "\nGLOBAL||r:$release git:$gitlog"
echo "<<scan.sh>> | resolution=$1"
printf '~%.0s' {1..29}
echo
#.. assignments



#. call movie.sh with $1=exp name $2=scanner count $3=release
