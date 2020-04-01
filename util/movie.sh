#!/bin/bash
# $1=exp name
EXPFILE=$LABPATH/exp/$1/$1.exp
echo "sourcing job file: $EXPFILE"
source $EXPFILE
#source /usr/local/bin/cronscan/config

r="20"
f="image2"
s="1700x2354"
vcodec="libx264"
crf="25"
pix_fmt="yuv420p"
dir="~/lab"
now=$(date)


for scanner in $SCANNERS; do
  i2="${dir}/${1}/${i_pre}.${1}.s${scanner}.png"
  path="${dir}/${1}/"
  suf=".${1}.s${scanner}.png"
  movie="${1}.s${scanner}.mp4"
  ffmpeg -r $r -f $f -s $s -i $1/%04d.$1.s$SCANNERS.png -vcodec $vcodec -crf $crf -pix_fmt $pix_fmt $movie

done

echo "$EXP movie genrated $now. R $RELEASE" >> joblog

