#/bin/bash
# test image offset
# reqd $1: exp name $2: scanner number  $3: number four padded
# optional  offset-x, offset-y

#.. SOURCES
#.  source golbal
source /usr/local/bin/caps_settings/labpath

#.  announce data
source $LABPATH/release

#.  attr reassignment
time=$4
img=$5


#.. local vars
#. dynamic vars
pLab=()
crops=()
root="/home/caps/lab/movie/"
mp="${root}${2}"
fullimg=${mp}/${img}
movimg=${1}.${2}.s${3}
data=${root}${img}.crop
echo load data from $data
source $data

dLab=`date -d @$time`
pLab+=("dummy") #. fill the zero index
for i in {1..6}
do
  fetch=PLATE${3}_${i}
  pLab+=("$fetch=${!fetch}")
done


#.  constants
PAD=6
RES=684
IMAGE=$((RES+PAD+PAD))
COL1=$((900+OFFX-PAD))
COL2=$((116+OFFX-PAD))
ROW1=$((79+OFFY-PAD))
ROW2=$((868+OFFY-PAD))
ROW3=$((1656+OFFY-PAD))

M1x=$((PAD))
M1y=$((60))
M1u=$((M1x+13))
M1v=$((M1y+13))
#-draw "rectangle 0,63 13,76" -fill "${col2}" -draw "rectangle 683,646 696,659" \
MARK1="$M1x,$M1y $M1u,$M1v"

Lx=$((PAD+9))
Ly=$((IMAGE-26))
#-draw "text 20,666 '"${pLab[$i]}"" \
LABEL="$Lx,$Ly"

M2x=$((IMAGE-13-PAD))
M2u=$((IMAGE-PAD))
M2v=$((IMAGE-M1y))
M2y=$((M2v-13))

MARK2="$M2x,$M2y $M2u,$M2v"
crops+=("${IMAGE}x${IMAGE}") #. crop[0] = image size
crops+=("$COL1+$ROW1")
crops+=("$COL1+$ROW2")
crops+=("$COL1+$ROW3")
crops+=("$COL2+$ROW3")
crops+=("$COL2+$ROW2")
crops+=("$COL2+$ROW1")
S=${crops[0]}


#--announce
echo
printf '~%.0s' {1..45}
echo -e "\n<<crop2.sh>> | num=$1 | name=$2 | scanner=$3 | time=$4 | img=$5 " # (offsetx=$6) | (offsety=$7)
printf '~%.0s' {1..29}
echo -e "\nset path: $mp"
echo

#.  make directories if needed
for i in {0..6}
do
  [ -d ${mp}/$i ] || mkdir ${mp}/$i
done
[ -d ${mp}/track ] || mkdir ${mp}/track

# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
#. first crop
echo gonna crop em
for i in {1..6}
do
  convert ${fullimg} -crop $S+${crops[$i]} ${mp}/${i}/${movimg}_${i}.png
  # echo "...plate $i cropped"
done

echo -e "\nAppend light/hood markers"
#-font helvetica -pointsize 9 -draw "text 167,554 'userName'"
fetch=HOOD${3}
col1=red
for i in {1..6}
do
  if grep -q "$i" <<< "${!fetch}"
  then
    col2=black
  else
    col2=green
  fi
  convert ${mp}/${i}/${movimg}_${i}.png +repage \
  -pointsize 12 -stroke black -strokewidth 1 \
  -draw "text ${LABEL} '"${pLab[$i]}"" \
  -fill "${col1}" -stroke black -strokewidth 2 \
  -draw "rectangle ${MARK1}" -fill "${col2}" -draw "rectangle ${MARK2}" \
  ${mp}/${i}/${movimg}_${i}.png

done

echo -e "\n assemble summary"

montage ${mp}/1/${movimg}_1.png ${mp}/2/${movimg}_2.png ${mp}/3/${movimg}_3.png \
  ${mp}/4/${movimg}_4.png ${mp}/5/${movimg}_5.png ${mp}/6/${movimg}_6.png \
  -geometry +0+0 -border 0 -tile 3x2 -background black ${mp}/0/${movimg}_0.png

echo -e "\nAppend date (( $dLab ))"

for i in {0..6}
do
  convert ${mp}/${i}/${movimg}_${i}.png -font Times-New-Roman -pointsize 14 \
  -background black -fill white label:"${time}  ${dLab}" \
  -gravity west -append ${mp}/${i}/${movimg}_${i}.png
done




mv -f $data ${mp}/track/
