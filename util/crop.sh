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
# OFFX=$6
# OFFY=$7

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
  pLab+=("$2: $fetch=${!fetch}")
done

#.  constants
crops+=("696x696") #. crop[0] = image size
crops+=("900+79")
crops+=("900+868")
crops+=("900+1656")
crops+=("116+1656")
crops+=("116+868")
crops+=("116+79")
S=${crops[0]}


#--announce
echo
printf '~%.0s' {1..45}
echo -e "\n<<crop.sh>> | num=$1 | name=$2 | scanner=$3 | time=$4 | img=$5 " # (offsetx=$6) | (offsety=$7)
printf '~%.0s' {1..29}
echo -e "\nset path: $mp"
echo

#.  make directories if needed
for i in {1..6}
do
  [ -d ${mp}/$i ] || mkdir ${mp}/$i
done

# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
#. first crop
echo gonna crop em
for i in {1..6}
do
  convert ${fullimg} -crop $S+${crops[$i]} ${mp}/${i}/${movimg}_${i}.png
  echo "...plate $i cropped"
done



#. apply labels
# for i in {1..6}
# do
#   echo $i
#   echo ${label[$i]}
#   # read
#   convert $2/${i}/${1}_${i}.png -background black -splice 0x20 -gravity south \
#   -splice 0x20 -pointsize 18 -fill white -gravity north -annotate +150+84 \
#   "${label[$i]}" $2/${i}/${1}_${i}x.png
# done


# convert $2/2/${1}_2.png -background black -splice 0x20 -gravity south \
# -splice 0x20 -pointsize 18 -fill white -gravity north -annotate +150+84 \
# "$L1" $2/2/${1}_2.png
# convert $2/3/${1}_3.png -background black -splice 0x20 -gravity south \
# -splice 0x20 -pointsize 18 -fill white -gravity north -annotate +150+84 \
# "$L1" $2/3/${1}_3.png
# convert $2/4/${1}_4.png -background black -splice 0x20 -gravity south \
# -splice 0x20 -pointsize 18 -fill white -gravity north -annotate +150+84 \
# "$L1" $2/4/${1}_4.png
# convert $2/5/${1}_5.png -background black -splice 0x20 -gravity south \
# -splice 0x20 -pointsize 18 -fill white -gravity north -annotate +150+84 \
# "$L1" $2/5/${1}_5.png
# i=5
# l=${label[5]}
# y="boooo"





echo -e "\nAppend plate labels"

for i in {1..6}
do

  convert ${mp}/${i}/${movimg}_${i}.png -background black -fill white label:"${pLab[$i]}" \
    +swap -gravity west -append ${mp}/${i}/${movimg}_${i}.png
  echo "...plate $i appended"
done

echo -e "\nAppend date (( $dLab ))"

for i in {1..6}
do
  convert ${mp}/${i}/${movimg}_${i}.png -background black -fill white label:"${time}  ${dLab}" \
        -gravity west -append ${mp}/${i}/${movimg}_${i}.png
done

echo -e "\nAppend light/hood markers"

fetch=HOOD${3}
for i in {1..6}
do
  if grep -q "$i" <<< "${!fetch}"
  then
    echo "found it"
    col="teal"
  else
    col="black"
  fi
  echo col ${col}
  convert ${mp}/${i}/${movimg}_${i}.png -background "${col}" -gravity West -extent 716x716 \
    -background black -gravity East -extent 736x716 ${mp}/${i}/${movimg}_${i}.png
  echo "...plate $i appended"
done

rm -f $data
# for i in {1..6}
# do
#   convert ${mp}/${i}/${movimg}_${i}.png -fill white -draw "rectangle 676,0 696,696" \
#   -gravity west -append ${mp}/${i}/${movimg}_${i}.png
#   echo "...plate $i appended"
# done
#
#
# convert $2/1/${1}_1.png -fill white -draw "rectangle 350,0 696,20 rectangle 350,716 696,736" $2/1/${1}_1.png
# convert $2/2/${1}_2.png -fill white -draw "rectangle 350,0 696,20 rectangle 350,716 696,736" $2/2/${1}_2.png
# convert $2/3/${1}_3.png -fill white -draw "rectangle 350,0 696,20 rectangle 350,716 696,736" $2/3/${1}_3.png
# convert $2/4/${1}_4.png -fill white -draw "rectangle 350,0 696,20 rectangle 350,716 696,736" $2/4/${1}_4.png
# convert $2/5/${1}_5.png -fill white -draw "rectangle 350,0 696,20 rectangle 350,716 696,736" $2/5/${1}_5.png
# convert $2/6/${1}_6.png -fill white -draw "rectangle 350,0 696,20 rectangle 350,716 696,736" $2/6/${1}_6.png
