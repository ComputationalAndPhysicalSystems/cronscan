
#!/bin/bash
echo "shot:"
read -s shot

echo "action"
echo "------"
echo "1 : segmovie"
echo "2 : archive seg files"
echo "3 : "

read -s -n 1 action

case $action in
	"1")			#: segmovie
		segmovie(${shot}_seg)
	;;
	*)
		;;
	esac


segmovie(){
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
	   echo $f
	   x=`printf %04d $x`
	   # mv "$f" "${f%??????????????}${type}"
	#  mv "$f" "${1}/${x}.${1}.${type}"
	   echo $x                                                                                                                  read -n 1                                                                                                                 (( x++ ))
	done
	r="20"
	f="image2"
	#s="1700x2354"
	s="2088x1408"
	vcodec="libx264"
	crf="25"
	pix_fmt="yuv420p"
	now=$(date)

	movie="${1}.mp4"
	#  ffmpeg -r $r -f $f -s $s -i ${1}/0/%04d.${1}.s${i}_0.${type} -vcodec $vcodec -crf $crf -pix_fmt $pix_fmt $movie < /dev$ffmpeg -r $r -f $f -s $s -i ${1}/%04d.${1}.${type} -vcodec $vcodec -vf "transpose=2" -crf $crf -pix_fmt $pix_fmt $movie <$
	echo "movie generated for $1, on $now." >> joblog
}

zipit(){
	echo "zipdir = ${1}"
	rm ${1} -R
}