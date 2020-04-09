
#-------------assigning to array variable in a loop
# label=()
#
# for i in {1..6}
# do
#   resultarray+=($B)
#   label+=("name, plate $i")
# done
# echo ${label[@]}
#-------------next..

croparray=( util/*.crop )
echo "found jobs: ${croparray[@]}"
echo "------------------------"

for c in "${croparray[@]}"
do
  basename "$c"
  act="$(basename -- $c)"
  act="${act%.*}"
  echo "crop file $act"
  IFS='.' read -r -a parms <<< $act
  echo result: ${parms[@]}
done
