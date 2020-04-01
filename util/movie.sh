#!/bin/bash
# $1=exp name $2=scanner counter
r="20"
f="image2"
s="1700x2354"
vcodec="libx264"
crf="25"
pix_fmt="yuv420p"
dir="~/lab"


for scanner in $2; do
  i2="${dir}/${1}/${i_pre}.${1}.s${scanner}.png"
  path="${dir}/${1}/"
  suf=".${1}.s${scanner}.png"
  movie="${1}.s${scanner}.mp4"
  ffmpeg -r $r -f $f -s $s -i $1/%04d.$1.s$2.png -vcodec $vcodec -crf $crf -pix_fmt $pix_fmt $movie

done

