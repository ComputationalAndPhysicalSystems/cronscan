#!/bin/bash
# $1=exp name $2=scanner count $3=release

#??? inteneded use:
# ssh -A caps@129.101.130.90 'cd ~/lab/movie; bash -s' < movie.sh test
#?- doesn't work: can't source this info during a ssh call to remote server, apparently
#?- wanted to source the exp record to get the EXP variable (although redundant), SCANNERCOUNT, and RELESASE

#?---------- makes the following procedure useless:
#x EXPFILE=$LABPATH/exp/$1/$1.exp
#x echo "sourcing job file: $EXPFILE"
#x source $EXPFILE
#----------------------

#? workaround: source info before starting and pass parameters to the script manually
#? add $2=scanner count, $3=release

#-------------
r="20"
f="image2"
s="1700x2354"
vcodec="libx264"
crf="25"
pix_fmt="yuv420p"
now=$(date)

for scanner in $2; do
  movie="${1}.s${scanner}.mp4"
  ffmpeg -r $r -f $f -s $s -i $1/%04d.$1.s$2.png -vcodec $vcodec -crf $crf -pix_fmt $pix_fmt $movie
done

echo "$2 movie(s) generated for #1, on $now. R $3" >> joblog