
#-------------assigning to array variable in a loop
label=()

for i in {1..6}
do
  resultarray+=($B)
  label+=("name, plate $i")
done
echo ${label[@]}
#-------------
