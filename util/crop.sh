#/bin/bash
# test image offset
# $1: offset-x, $2: offset-y

#.. SOURCES
#.  source golbal
source /usr/local/bin/caps_settings/labpath

#.  announce data
source $LABPATH/release

#.  attr reassignment
OFFX=$3
OFFY=$4

#--announce
echo
printf '~%.0s' {1..45}
echo -e "\nGLOBAL||r:$release git:$gitlog"
echo "<<crop.sh>> | name=$1 | path=$2 | offsetx=$3 | offsety=$4"
printf '~%.0s' {1..29}
echo

#.  local vars
S=696x696 #: image dims
O1=900+79
O2=900+868
O3=900+1656
O4=116+1656
O5=116+868
O6=116+79

for i in {1..6}
do
  L${i}=$i
  echo $i
  echo $L${i}
done
echo here is L1 $L1

L1="${1}: plate 1"
L2="${1}: plate 2"
L3="${1}: plate 3"
L4="${1}: plate 4"
L5="${1}: plate 5"
L6="${1}: plate 6"

[ -d $2/1 ] || mkdir $2/1
[ -d $2/2 ] || mkdir $2/2
[ -d $2/3 ] || mkdir $2/3
[ -d $2/4 ] || mkdir $2/4
[ -d $2/5 ] || mkdir $2/5
[ -d $2/6 ] || mkdir $2/6



convert $2/${1}.png -crop $S+$O1 $2/1/${1}_1.png
convert $2/${1}.png -crop $S+$O2 $2/2/${1}_2.png
convert $2/${1}.png -crop $S+$O3 $2/3/${1}_3.png
convert $2/${1}.png -crop $S+$O4 $2/4/${1}_4.png
convert $2/${1}.png -crop $S+$O5 $2/5/${1}_5.png
convert $2/${1}.png -crop $S+$O6 $2/6/${1}_6.png

convert $2/1/${1}_1.png -background black -splice 0x20 -gravity south \
-splice 0x20 -pointsize 18 -fill white -gravity north -annotate +150+84 \
"$L1" $2/1/${1}_1.png
convert $2/2/${1}_2.png -background black -splice 0x20 -gravity south \
-splice 0x20 -pointsize 18 -fill white -gravity north -annotate +150+84 \
"$L1" $2/2/${1}_2.png
convert $2/3/${1}_3.png -background black -splice 0x20 -gravity south \
-splice 0x20 -pointsize 18 -fill white -gravity north -annotate +150+84 \
"$L1" $2/3/${1}_3.png
convert $2/4/${1}_4.png -background black -splice 0x20 -gravity south \
-splice 0x20 -pointsize 18 -fill white -gravity north -annotate +150+84 \
"$L1" $2/4/${1}_4.png
convert $2/5/${1}_5.png -background black -splice 0x20 -gravity south \
-splice 0x20 -pointsize 18 -fill white -gravity north -annotate +150+84 \
"$L1" $2/5/${1}_5.png
convert $2/6/${1}_6.png -background black -splice 0x20 -gravity south \
-splice 0x20 -pointsize 18 -fill white -gravity north -annotate +150+84 \
"$L1" $2/6/${1}_6.png


convert $2/1/${1}_1.png -fill white -draw "rectangle 350,0 696,20 rectangle 350,716 696,736" $2/1/${1}_1.png
convert $2/2/${1}_2.png -fill white -draw "rectangle 350,0 696,20 rectangle 350,716 696,736" $2/2/${1}_2.png
convert $2/3/${1}_3.png -fill white -draw "rectangle 350,0 696,20 rectangle 350,716 696,736" $2/3/${1}_3.png
convert $2/4/${1}_4.png -fill white -draw "rectangle 350,0 696,20 rectangle 350,716 696,736" $2/4/${1}_4.png
convert $2/5/${1}_5.png -fill white -draw "rectangle 350,0 696,20 rectangle 350,716 696,736" $2/5/${1}_5.png
convert $2/6/${1}_6.png -fill white -draw "rectangle 350,0 696,20 rectangle 350,716 696,736" $2/6/${1}_6.png
