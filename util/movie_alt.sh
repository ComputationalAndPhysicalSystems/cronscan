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
echo "what file type >> tiff/png [t,p]"
read -s -n 1 k
[[ $k = "t" ]] && type="tiff"
[[ $k = "p" ]] && type="png"
echo -e $type

echo "rename files for FFMPEG batch"

files=${1}/*.${type}
for f in $files
do
  echo $f
  mv "$f" "${f%??????????????}png"
done

echo "original scan, zero frame or plate  >> [s,0,p]"
read -s -n 1 source
[[ $source == "s" ]] && s="1700x2354"
[[ $source == "p" ]] && exit
[[ $source == "0" ]] && s="2088x1408"

r="20"
f="image2"
vcodec="libx264"
crf="25"
pix_fmt="yuv420p"
now=$(date)



for (( i=1; i<=$2; i++ ))
do
  echo "starting on $i of $2"
  if [ $source == "s" ] # origin scan
  then
  	movie="${1}.s${i}.mp4"
  	ffmpeg -r $r -f $f -s $s -i $1/%04d.$1.s$i.png -vcodec $vcodec -vf "transpose=2" -crf $crf -pix_fmt $pix_fmt $movie < /dev/null
  fi
  if [ $source == "0" ]
  then
  	movie="${1}.s${i}.X.mp4"
  	ffmpeg -r $r -f $f -s $s -i ${1}/0/%04d.${1}.s${i}_0.png -vcodec $vcodec -crf $crf -pix_fmt $pix_fmt $movie < /dev/null
  fi
done
echo "$2 movies generated for $1, on $now. R $3" >> joblog