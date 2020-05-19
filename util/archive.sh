#!/bin/bash

zipit(){
		# zip -9 -r -m RQIKPEMF-0_scan.zip 200328_shadow-pink-clock-12_1
		# ssh caps@129.101.130.90 'cd ~/lab/movie; bash -s' < util/movie.sh $EXP $SCANNERS $release
		echo "zipdir = ${1}"
		echo "zip -9 -r -m ${1}.zip ${shot}"
}


movie(){
	echo "shotdir = ${1}"
	echo "what file type >> tiff/png [t,p]"
	read -s -n 1 k
	[[ $k = "t" ]] && type="tiff"
	[[ $k = "p" ]] && type="png"
	echo -e $type
	echo "rename files for FFMPEG batch"
	x=0
	files=${1}/*.${type}
	for f in $files
	do
		a=a
	  echo $f
	  x=$(printf %04d $x)
		echo $x
	done
	r="20"
	f="image2"
	s="2088x1408"
	vcodec="libx264"
	crf="25"
	pix_fmt="yuv420p"
	now=$(date)

	movie="${1}.mp4"
	#  ffmpeg -r $r -f $f -s $s -i ${1}/0/%04d.${1}.s${i}_0.${type} -vcodec $vcodec -crf $crf -pix_fmt $pix_fmt $movie < /dev$ffmpeg -r $r -f $f -s $s -i ${1}/%04d.${1}.${type} -vcodec $vcodec -vf "transpose=2" -crf $crf -pix_fmt $pix_fmt $movie <$
	echo "movie generated for $1, on $now." >> joblog
}

echo "shot:"
read shot

echo -e "\nLevel: master or plate?"
echo "--------"
echo "0 : master"
echo "1-6 : plate"
read -s -n 1 level

echo -e "\nwhich"
echo "------"
echo "1 : scans"
echo "2 : segments"
read -s -n 1 ask
[[ $ask -eq 1 ]] && which="_scan" || which="_seg"

echo -e "\naction"
echo "------"
echo "1 : movie"
echo "2 : archive files"

read -s -n 1 action

case $action in
	1)			#: segmovie
		movie "${shot}${level}"
	;;
	2)			#: segmovie
		zipit "${shot}-${level}"
	;;

	*)
	;;
	esac
