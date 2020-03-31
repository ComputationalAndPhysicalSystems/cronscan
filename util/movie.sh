#!/bin/bash
# $1=exp name $2=scanner counter
r="20"
f="image2"
s="1700x2354"
i_pre="printf %04d."
i_pre="%04d."
vcodec="libx264"
crf="25"
pix_fmt="yuv420p"
dir="~/lab"


for scanner in $2; do
  i2="${dir}/${1}/${i_pre}.${1}.s${scanner}.png"
  path="${dir}/${1}/"
  suf=".${1}.s${scanner}.png"
  i="~/lab/200328_shadow-pink-clock-12_1/`printf %.04d`.200328_shadow-pink-clock-12_1.s1.png"
  movie="${1}.s${scanner}.mp4"
  #ffmpeg -r $r -f $f -s $s -i ${path}${i_pre}${suf} -vcodec $vcodec -crf $crf -pix_fmt $pix_fmt $movie
  #ffmpeg -r $r -f $f -s $s -i ${i} -vcodec $vcodec -crf $crf -pix_fmt $pix_fmt $movie
  #ffmpeg -r $r -f $f -s $s -i hi/%04d.hi.s1.png -vcodec $vcodec -crf $crf -pix_fmt $pix_fmt $movie
  ffmpeg -r $r -f $f -s $s -i $1/%04d.$1.s$2.png -vcodec $vcodec -crf $crf -pix_fmt $pix_fmt $movie

done

