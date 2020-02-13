#!/bin/bash
#: largs - light value array

SP="/home/caps/scripts/caps_cronscan"
CAPACITY=6 #. hard code 6 DISH_CNT per scanner
#!! WTF, need to redeclare CAPACITY again during saveit()

SFILE="./exp/last.exp"

### DECLARE VARIABLES
##. Color codes for UI
#. Reset
NC='\033[0m'       # Text Reset

#. Regular Colors
Black='\033[0;30m'        # Black
Red='\033[0;31m'          # Red
Green='\033[0;32m'        # Green
Yellow='\033[0;33m'       # Yellow
Blue='\033[0;34m'         # Blue
LtBlue='\033[1;34m'
Purple='\033[0;35m'       # Purple
Cyan='\033[0;36m'         # Cyan
White='\033[0;37m'        # White

#. Underline
UCyan='\033[4;36m'

#. Bold Colors
BBlack='\033[1;30m'       # Black
BRed='\033[1;31m'         # Red
BGreen='\033[1;32m'       # Green
BYellow='\033[1;33m'      # Yellow
BBlue='\033[1;34m'        # Blue
BPurple='\033[1;35m'      # Purple
BCyan='\033[1;36m'        # Cyan
BWhite='\033[1;37m'       # White

#... random..
IYellow='\033[0;93m'
On_IYellow='\033[47m' 
BPurple='\033[1;35m'
UBlack='\033[4;30m'

On_IBlack='\033[0;100m'

Inv='\e[7m'

BIWhite='\033[1;95m'
BIPurple='\033[1;95m'

Italic='\033[3m'
##. Arrays
declare -a args
declare -a blurbs
declare -a subs
declare -a keys
declare -a cols
declare -a subblurbs
declare -a func
declare -a opts
declare -a optslist
declare -a subvals #: the value to store in the associated EXP ARG, if different than user input
declare -a trueopts
# declare -a lprog

keys=(e s i r z x l a f o c)
mkeys=(T Z F S Q)

opts+=("*/...")
opts+=("C/1..9")
opts+=("I/minutes")
opts+=("C/1/3/6")
opts+=("T")
opts+=("T")
opts+=("T")
opts+=("*/...")
opts+=("*/...")
opts+=("*/...")
opts+=("*/...")

optslist+=("")
optslist+=("1.to.9")
optslist+=("")
optslist+=("100.DPI/300.DPI/600.DPI")
optslist+=("")
optslist+=("")
optslist+=("")
optslist+=("")
optslist+=("")
optslist+=("")
optslist+=("")

subvals+=("")
subvals+=("C/^")
subvals+=("")
subvals+=("C/100/300/600")
subvals+=("")
subvals+=("")
subvals+=("")
subvals+=("")
subvals+=("")
subvals+=("")
subvals+=("")

trueopts+=("")
trueopts+=("C/123456789")
trueopts+=("I/1234567890")
trueopts+=("C/1/3/6")
trueopts+=("")
trueopts+=("")
trueopts+=("")
trueopts+=("")
trueopts+=("")
trueopts+=("")
trueopts+=("")

args+=("EXP")
args+=("SCANNERS")
args+=("INT")
args+=("RES")
args+=("REF")
args+=("XFER")
args+=("LIGHTS")
args+=("SPECIES")
args+=("FOODS")
args+=("OTHER")
args+=("SYSTEM")

blurbs+=("Exp Name")
blurbs+=("Scanner Count")
blurbs+=("Scan Interval Time")
blurbs+=("Scan resolution")
blurbs+=("* REF scan every frame")
blurbs+=("* server file transfer")
blurbs+=("* use lights")
blurbs+=("test animals")
blurbs+=("food sources")
blurbs+=("note other setup")
blurbs+=("Computer system name")

#: menu blurbs
mblurbs+=("Test NeoPixels")
mblurbs+=("STOP experiment")
mblurbs+=("LOAD from file")
mblurbs+=("SAVE program")
mblurbs+=("QUIT")

#: subsections
subs+=("_exp")
subs+=("_exp")
subs+=("_exp")
subs+=("_exp")
subs+=("_exp")
subs+=("_exp")
subs+=("_exp")
subs+=("_exp")
subs+=("_exp")
subs+=("_exp")
subs+=("_sys")
# subs+=("_menu")
# subs+=("_menu")

subblurbs+=("${Inv}_____Experiment Parameters_____${NC} [${Red} WARNING${NC} | ${LtBlue}LAST EXP${NC} | ${Green}new value${NC} ]")
subblurbs+=("${On_IBlack}________ System Setup__________${NC}")
subblurbs+=("${On_IBlack}___________Dish Setup__________${NC}")

##. flow booleans
stay_TF=true


#=> tips from https://www.youtube.com/watch?v=jeq161yD8tk

sfile(){

options=($(find exp/ -maxdepth 2 -iname '*.exp' -print0|xargs -0 )) 
echo
echo "Load prior EXP"
select opt in "${options[@]}" "CANCEL";
do
	if ((REPLY == 1 + ${#options[@]}))
	then
		return
	elif (( REPLY <= ${#options[@]}))
	then
		SFILE=$opt
		#display=$(basename $opt)
		echo $SFILE
		#echo "File selected $display"
		load_parms
		return
	else
		echo "Not valid"
	fi
done
}


insert(){
    local i
    [[ $1 = -h ]] && { echo "$h" >/dev/stderr; return 1; }
    declare -n __arr__=$1   # reference to the array variable
    i=$2                    # index to insert at
    el="$3"                 # element to insert
    # handle errors
    [[ ! "$i" =~ ^[0-9]+$ ]] && { echo "E: insert: index must be a valid integer" >/dev/stderr; return 1; }

    #? the following line throws errors sporatically, when ingesting special characters in the 0th index
    # (( "$1" < 0 )) && { echo "E: insert: index can not be negative" >/dev/stderr; return 1; }
    # Now insert $el at $i
    __arr__=("${__arr__[@]:0:$i}" "$el" "${__arr__[@]:$i}")
}

spacer (){ #: helps with UI building
	echo
	echo -e "${subblurbs[$isub]}"

}

opts_list (){
	local -a optsreturn=(${optslist[$i]//// })
	echo ${optsreturn[*]}
}

eatinput (){
	# echo eatinput function
	local -a thisopt
	thisopt=(${trueopts[$i]//// }) #: store options into array, incl type marker
	local op=${opts[$i]:0:1} #: the type marker, kind of hotkey, choice, toggle, etc
	local limit=1
	local -a uinput
	local secret=1
	local subz=0
	local q uvalue k
	# echo "options for this argument thisopt = ( ${thisopt[@]} )" #-- TRACER
	case $op in
		"C")			#: CHOICE
			IFS="/"
			subz=1
			set -- "${subvals[$i]}" 
			local -a svals=($*) #: setting svals array for substituting in final args
			unset IFS
			# read -p "pause"
			;;
		"T")			#: TOGGLE
			a=a

			;;
		"I")			#: TOGGLE
			secret=0
			;;
		"*")
			limit=30 #: arbitray high limit for string entry
			secret=0
			;;
		*)
			;;
	esac

	while [ ${#uinput[@]} -lt $limit ]
	do
		#echo while limit loop #-- TRACER
		if [[ $secret -eq 1 ]] #: single key trigger with readout substitution; suppress user key printout
		then
			#echo secret loop, read single key #-- TRACER
			read -s -n 1 k
			if [[ $k = "" ]]
			then
				echo -e ${Yellow}${Italic}no change${NC}
				xcolor=${cols[$i]}
				return
			fi
			#: VALID KEY SECTION ----------------------
			for q in "${!thisopt[@]}"
			do
				if [[ ${thisopt[$q]} = *$k* ]] #: if key occurs in the valid set
				then
					uvalue=${svals[$q]} #: user; index matching key stroke
					if [[ ${uvalue: -1} = ^ ]] #: add the key pressed to the final ARG string (exp-groupX)
					then
						uvalue=${uvalue::-1}$k
					fi
					echo $uvalue
					limit=-1
				else
					#reject input, don't leave
					a=a
				fi
			done
		else #: not a single key trigger
			local former='"'${!args[$i]}'"' #: quotes must be added to string in case of spaces
			# xcolor=${cols[$i]}
			read ${args[$i]}
			limit=-1
			#user sent empty string, replace with former
			if [[ ${!args[$i]} = "" && ${args[$i]} != $former ]]
			then
				eval ${args[$i]}=$former
				printf "%34s" " "
				echo -e "${Yellow}${Italic}no change${NC}"; sleep 1
			else
				xcolor=${Green}
			fi
			storelongest
			return
		fi #: end of IF secret

		##: loop through single key inputs, add to cumulative array
		#? will we need this? uncertain

		# if [[ ${opt[*]} =~ $k ]]
		# then
		# 	uinput+=(k)
		# else
		# 	return
		# 	a=a
		# fi
	done #: character input limit hit, or enter key
	if [[ $subz -eq 1 ]] #- temporary
	then
		eval "${args[$i]}"="$uvalue" #: set the EXP variables
	fi
	if [[ ${args[$i]} = $uvalue ]]
	then
		xcolor=${cols[$i]}
	else
		xcolor=${Green}
	fi
	storelongest
	# echo "limit reached" #-- TRACER
}

testlights(){
	if [[ $CONTROLLER == "gpio" ]]
	then
		echo -e "${BYellow}"
		printf "%30s" "Test all / single"
		echo -e "${NC}"
		printf "%32s"  "Chose [X/0/1..9/+] >"
		read -n 1 zkey
		case $zkey in

		"X")			#: zero out crontabs
			return
		;;

		[0-9])			#: load from file
			echo
			echo -e "${Red}   Watch the lights!${NC}"
			echo
			sudo python $SP/util/gpio-test.py -c $DISH_CNT -i $zkey
		;;
		"+")			#: SAVE
			for arg in ${args[@]}
			do
				arg=${!arg}
				if [[ ${#arg} -lt 1 ]]
				then
					echo -e ${Red}
					read -n 1 -p " Cannot save file with any blanks fields..."
					main
				fi
			done
			saveit
			;;
		*)
			;;
		esac
	else
		echo need to write code for this
		read
	fi
}

zero(){
	echo -e "${Yellow}"
	printf "%32s" "zero out crontabs"
	echo -e "${Red}"
	printf "%32s" "[1]..CAPS cron <"
	echo -e
	printf "%32s"  "[2]..ROOT cron <"
	echo -e
	printf "%32s"  "[3]..BOTH <"
	echo -e "${NC}"
	printf "%32s"  "Chose [1/2/3] >"
	read -n 1 zkey
	if [[ $zkey = "1" ]]
	then
		echo `crontab -r`
		echo `sudo python util/clear.py`
	fi
	if [[ $zkey = "2" ]]
	then
		echo `sudo crontab -r`
		echo `sudo python util/clear.py`
	fi
	if [[ $zkey = "3" ]]
	then
		echo `crontab -r`
		echo `sudo crontab -r`
		echo `sudo python util/clear.py`
	fi

}

menukeys(){
	case $key in

	"T")			#: zero out crontabs
		testlights
	;;

	"Z")			#: zero out crontabs
		zero
	;;
	"F")			#: load from file
		sfile
	;;
	"S")			#: SAVE
		for arg in ${args[@]}
		do
			arg=${!arg}
			if [[ ${#arg} -lt 1 ]]
			then
				echo -e ${Red}
				read -n 1 -p " Cannot save file with any blanks fields..."
				main
			fi
		done
		saveit
		;;
	"Q")			#: QUIT
		echo -e ${Red}
		printf "%32s" "q again to quit >"
		read -n 1 key
		if [[ $key = "q" ]]
		then
			exit
		else
			return
		fi
		;;
	*)
		;;
	esac

}

eatkeys(){ #: digest user key inputs
	#echo "(------eatkeys function-----)"; #-- TRACER
	#echo key: $key #-- TRACER
	dindex=0
	if [[ $key = "" ]] #enter
	then
		echo no change
		sleep 1
		return
	fi
	#: routine for toggles
	if [[ ${blurbs[$i]:0:1} = "*" ]] #: if first character is *, this is a toggle
	# if [[ ${opts[$i]} = "[off/on]" ]]
	# if [[ ${types[$i]} = "tog" ]]
	then
		if [[ ${!args[$i]} = "on" ]]
		then
			eval ${args[$i]}="off"
		else
			eval ${args[$i]}="on"
		fi
		cols[$i]=${Green}
		if [[ $key = ${keys[6]} ]] #: lights have toggled
		then
			update ${keys[6]}
		fi
		storelongest #: formating proc to space the display based on longest string
		return
	fi # end toggles
	size=$((${#opts[$i]}+2))
	if [[ ${opts[$i]:0:1} = "C" ]]
	then
		optsbuff=(${optslist[$i]//// })
		for str in "${optsbuff[@]}"
		do
			echo -n -e ${Red}
			printf "%$((34))s" "$str <"
			echo
		done
		echo -n -e ${NC}
	fi
	printf "%$((34-$size))s" "${blurbs[$i]} ["
	echo -e "${Cyan}${Italic}${opts[$i]:2}${NC}] >\c"
	eatinput
	cols[$i]=$xcolor
	if [[ ${keys[$i]} = "d" ]]
	then
		program_lights
	fi
	if [[ ${keys[$i]} = "P" ]]
	then
		i=0
		lj=0
		for argi in "${keys[@]}"
		do
			if [[ $argi = "d" ]]
			then
				program_lights
			fi
			((i++))
		done
	fi
	update $key #: run update to check for changes to the arrays (eg scanner count change)
} #. end eatkeys()

program_lights(){
	# echo "(----------program_lights ()---------)" #-- TRACER
	if [[ firstrun -ne 0 ]] #: escape prog
	then
		local dish=${!args[(($i))]} #: find the value of each dish arg
		case $dish in

		"neg-ctrl")			#: CHOICE
			val=OFF
			;;
		"pos-ctrl")			#: TOGGLE
			val=ON
			;;
		*)
			#! previous code edit
			# lpI=$((${#args[@]}-1))
			# val=${!args[$lpI]}
			IFS='.' read -ra vals <<< $dish

			val=${vals[1]}
			;;
		esac
		eval ${largs[$lj]}=$val #: sets the new value for the dish light
		((lj++))
	fi
}

init_colors(){
	##: use loop to setup initial colors
	for ((i=0;i<${#keys[@]};i++))
	do
		cols+=($LtBlue)
	done
	cols[0]=$Red
}

lights_on(){
	if [[ ${!args[6]} = "on" ]]
	then
		ink=${#args[@]}
		probpos=$ink
		((ink++))
		((ink++)) #- iterate once for each arg entered in thi lights sub group

		insert args $(( ink )) "CONTROLLER"
		insert keys $(( ink )) C
		insert blurbs $(( ink )) "Light Controller"
		insert subs $(( ink )) "_light"
		insert opts $(( ink )) "C/1/2" #C/-/=/1..9
		insert optslist $(( ink )) "1..GPIO/2..Arduino" #C/-/=/1..9
		insert cols $(( ink )) "$LtBlue"
		insert subvals $(( ink )) "C/gpio/arduino"
		insert trueopts $(( ink )) "C/1/2"
		insert subblurbs 3 "${BCyan}${Inv}____Neopixel Light Program_____${NC}"

		((ink++))
		insert args $(( ink )) "PROGRAM"
		insert keys $(( ink )) P
		insert blurbs $(( ink )) "Light Program"
		insert subs $(( ink )) "_light"
		insert opts $(( ink )) "C/1..3" #C/-/=/1..9
		insert optslist $(( ink )) "1..steady/2..ran-on/3..ran-tog" #C/-/=/1..9
		insert cols $(( ink )) "$LtBlue"
		insert subvals $(( ink )) "C/steady/random.on/random.toggle"
		insert trueopts $(( ink )) "C/1/2/3"
	fi
}



load_parms(){
	##: DISK OPS
	#. load last experiment
	source ./release
	source $SFILE #: in one commad, loads all variables
	EXP=$(echo $EXP|tr -d '\n') #? what do these lines do??
	INT=$(echo $INT|tr -d '\n')
	remember_scanners=0
}

update(){
	#echo "(------update function-----)" #-- TRACER
	#echo parm: $1 #-- TRACER
	if [[ remember_scanners -ne SCANNERS && $1 = ${keys[1]} ]] #: number of scanners has changed

	#: delete all args related to old scanner count
	then

		local ix j ins ini inj
		local ins=11 #: insert point in arrays (index padding)
		local xindex=$((remember_scanners*CAPACITY+remember_scanners))

		#: hunt down dish entries and remove them
		for ((ix=((${#keys[@]}-1));ix>0;ix--)) #((ix=0;ix<lKeys;ix++))
		do
			if [[ ${subs[$ix]} = "_dish" ]]
			then
				unset args[$ix]
				unset blurbs[$ix]
				unset keys[$ix]
				unset subs[$ix]
				unset opts[$ix]
				unset optslist[$ix]
				unset trueopts[$ix]
				unset cols[$ix]
				unset subvals[$ix]
			fi
			unset largs[@]
		done
		remember_scanners=$SCANNERS #: reset scanner count memory
		ix=1; #: reset this counter
		#: insert args based on startup settings, or scanner count updates......................
		for ((ix=1;ix<$(( SCANNERS+1 ));ix++)) #: add features related to scanner/multiple
		do
			ini=$((ins+((ix-1))*2+((ix-1))*CAPACITY))
			insert args $(( ini )) SCANNER${ix}_ID
			insert blurbs $(( ini )) "Scanner${ix} ID"
			insert keys $(( ini )) k
			insert subs $(( ini )) "_dish"
			insert opts $(( ini )) "*"
			insert optslist $(( ini )) ""
			insert cols $(( ini )) "$LtBlue"
			insert trueopts $(( ini )) ""
			insert subvals $(( ini )) ""

			((ini++))
			insert args $(( ini )) TEMPLATE${ix}_ID
			insert blurbs $(( ini )) "Template${ix} ID"
			insert keys $(( ini )) t
			insert subs $(( ini )) "_dish"
			insert opts $(( ini )) "*"
			insert optslist $(( ini )) ""
			insert cols $(( ini )) "$LtBlue"
			insert trueopts $(( ini )) ""
			insert subvals $(( ini )) ""

			#: dish specific
			for ((j=1;j<$(( CAPACITY+1 ));j++))
			do
				if [[ $j -eq 1 && $ix -eq 1 ]] #: first dish (numeric)
				then
					lj=0 #: light j(index) reset
					lset="L0"
				else
					lj=${#largs[@]}
					lset="L$lj"
				fi
				inj=$((ini+j))
				insert largs $(( lj )) "$lset"
				insert args $(( inj )) "DISH${ix}_${j}"
				insert keys $(( inj )) d
				insert blurbs $(( inj )) "S${ix} Dish${j}"
				insert subs $(( inj )) "_dish"
				insert opts $(( inj )) "C/-/=/1..9"
				insert optslist $(( ini )) "[-]..neg-ctrl/[=]..pos-ctrl/1..9"
				insert cols $(( inj )) "$LtBlue"
				insert subvals $(( inj )) "C/neg-ctrl/pos-ctrl/group.^"
				insert trueopts $(( inj )) "C/-/=/123456789"
				program_lights
			done
		done
	fi

	#: insert args based on startup settings, or light feature toggle..................
	if [[ $1 = ${keys[6]} ]] #: that's the 'l' key
	then
		#: hunt down light entries and remove them
		for ((ix=((${#keys[@]}-1));ix>0;ix--)) #((ix=0;ix<lKeys;ix++))
		do
			if [[ ${subs[$ix]} = "_light" ]]
			then
				unset args[$ix]
				unset blurbs[$ix]
				unset keys[$ix]
				unset subs[$ix]
				unset opts[$ix]
				unset optslist[$ix]
				unset types[$ix]
				unset trueopts[$ix]
				unset subblurbs[3]
			fi
		done
		lights_on #: run check if lights are on
	fi
	return	# "^ ^ ^ ^ end update function ^ ^ ^ ^"
}

cronit(){
	cp $EP/$EXP.exp $EROOT/last.exp
	echo $EXP $DISH_CNT > $EROOT/current.env

	echo
	echo "# programatic crontab file generated for CAPS scanner control"> $EP/xtab
	echo -n "#" >> $EP/xtab
	printf '.%.0s' {1..34} >> $EP/xtab
	echo >> $EP/xtab
	for ((i=0;i<${#keys[@]};i++))
	do
		echo -n "#" >> $EP/xtab
		printf "%31s" "${blurbs[$i]}: " >> $EP/xtab
		echo ${!args[$i]} >> $EP/xtab
	done

	echo
	echo "sp=$SP" >> $EP/xtab
	echo "ep=$EP" >> $EP/xtab
	echo
	printf "*/$INT * * * * " >> $EP/xtab

	[[ $REF > 0 ]] && \

	printf "\$sp/util/lights.sh off $EXP 2>&1 | tee -a \$ep/LOG; " >> $EP/xtab
	printf "\$sp/util/scan.sh $RES \$ep 2>&1 | tee -a \$ep/LOG; " >> $EP/xtab
	[[ $LIGHTS == "on" ]] && \
	printf "\$sp/util/lights.sh on $EXP 2>&1 | tee -a \$ep/LOG; " >> $EP/xtab
	[[ $XFER == "on" ]] && \
	printf "\$sp/util/transfer.sh \$ep 2>&1 | tee -a \$ep/LOG; " >> $EP/xtab
	echo >> $EP/xtab ###- blank line needed before EOF
	echo
	echo "xtab exported"
	echo
	echo "installing crontab..."
	echo
	echo "--scanning enabled"
	sudo crontab $EP/xtab
	exit
}

saveit(){
	CAPACITY=6 #! I don't know why, but this needs to be declared again. makes no sense to me
	DISH_CNT=$((CAPACITY*SCANNERS))
	EROOT=${SP}/exp/
	EP=$EROOT${EXP}
	if [ ! -d "$EP" ]; then
	    mkdir -p $EP
	fi
	#: write out $EXP.exp and last.exp record files
	echo "working with Directory $EP"
	echo "writing $EXP.exp"
	echo "#exp parameters" 2>&1 | tee $EP/$EXP.exp
	echo CAPACITY="'$CAPACITY'" >> $EP/$EXP.exp
	echo DISH_CNT="'$DISH_CNT'" >> $EP/$EXP.exp
	for arg in "${args[@]}"
	do
	   echo ${arg}="'${!arg}'" >> $EP/$EXP.exp
	done
	if [[ $LIGHTS == "on" ]]
	then
		for larg in "${largs[@]}"
		#. write out the L's; 10 = on, 0 = OFF
		do
			iq=${larg:1} #: eg, 'L0' = '0'
			test="${!largs[$iq]}" #: get the value at index iq
			case $test in
			  "OFF")
			    echo ${larg}="'OFF'" >> $EP/$EXP.exp
			    [[ $PROGRAM == "random.toggle" ]] && echo - >> $EP/tog
			    ;;

			  "ON")
		   		echo ${larg}="'ON'" >> $EP/$EXP.exp
		   		[[ $PROGRAM == "random.toggle" ]] && echo + >> $EP/tog
			    ;;

			  *)
		   		echo ${larg}="'${!larg}'" >> $EP/$EXP.exp
		   		[[ $PROGRAM == "random.toggle" ]] && echo 0 >> $EP/tog
			    ;;
			esac
		done
	else
		# unset largs
		declare -a largs
	fi

	echo
	echo -e "${BRed} install crontab and begin scanning (y/n)${NC}\c"
	read -s -r -n 1 response
	response=${response,,}    # tolower
	if [[ "$response" =~ ^(yes|y)$ ]]
	then
		echo
		echo -e  ${BRed}${Inv} Make sure scanners are connected and powered. ${NC}
		cronit
	else
		return
	fi
}

storelongest(){
	local ix
	local buff=5
	longest=0
	for ((ix=0;ix<${#args[@]};ix++))
	do
		temp=${!args[$ix]}
		comp=${#temp}
		if [[ $comp -gt $longest && ${subs[$ix]} = "_dish" ]]
		then
			longest=$comp
		fi
	done
	margin=$(($buff+$longest))
}

set_all(){
	for ((i=0;i<${#keys[@]};i++))
	do
		if [[ ${blurbs[$i]:0:1} != "*" ]]
		then
			eatkeys
		fi
		if [[ $i -eq 1 ]]
		then
			update ${keys[1]}
		fi
		if [[ $i -eq 6 ]]
		then
			update ${keys[6]}
		fi
	done
}

findi(){
	for q in "${!my_array[@]}"
	do
	   if [[ "${my_array[$q]}" = "${1}" ]]
	   then
	       return
	   fi
	done
}

main(){
 #: main looop --------------------------------------------
 # echo "(------MAIN MAIN MAIN -----)"; sleep 1 #-- TRACER
((firstrun++)) 
if [[ $firstrun -eq 1 ]] #:this catches the LIGHTS on variable for the first UI build
then
	lights_on
fi
while [ "$stay_TF" = "true" ]

		#: BUILD UI MENU-----------------------------------------
	do
		clear -x #!! temp disable for TRACER
		echo -e "${BPurple}"
		printf " CREATE NEW CRONTAB EXPERIMENT - v$release"
		echo
		echo -e "${Green} >> Settings loaded from ${BGreen}$(basename $SFILE)${NC}"
		echo
		isub=0
		dindex=0
		for ((i=0;i<${#keys[@]};i++))
		do
			#: if this is a new subsection, then echo section heading from array
			if [[ $buf != ${subs[$i]} ]]
			then
				buf=${subs[$i]} #: store the subsection in buf
				#: switchin lights on adds the light program spacer
				if ! [[ $buf = "_light" && $LIGHTS = "off" ]]
				then
					spacer isub
					((isub++))
				else
					break
				fi
			fi
			printf "%29s" "${blurbs[$i]} ["
			echo -e "${Cyan}${keys[$i]}${NC}] \c"
			echo -e "${cols[$i]}\c"

			#: determine offset spacing for light color marker

			arg=${!args[$i]}
			arglen=${#arg}
			push=$(($margin-arglen))

			#: display dish settings
			if [[ ${keys[$i]} = "d" && $LIGHTS = "on" ]]
			then
				lp=${!largs[$dindex]} #:light program setting as string		
				((dindex++))
			else
				lp=""
			fi
			# echo -n $arg $lp 
			#: eliminate the dish setup columns by stopping push below; consolidate to one value 

			printf "%1s %${push}s" "$arg" "$lp"
			echo -e ${NC}
			if [[ $LIGHTS = "on" ]] #: considering a column for light display
			then
				### work
				# column "on"
				# printf "%10s" "on"
				# echo
				a=a
			fi
		done

		#: add menu subsection at last position
		echo
		echo -e "${BPurple}`printf '=%.0s' {1..31}`${NC}"
		for ((i=0;i<${#mkeys[@]};i++))
		do
			printf "%29s" "${mblurbs[$i]} ["
			echo -e ${UCyan}${mkeys[$i]}${NC}"]"
		done

		echo -e "\n"
		printf "%27s" "set new parameters with ["
		echo -e "${BCyan}${Italic}key${NC}]" 
		printf "%29s" "set ALL with ["
		echo -e "${BCyan}~${NC}] >\c" 

##. USER INPUT
		lj=0 #: reset this value
		read -n 1 key
		echo
		if [[ $key = '~' ]] #: enter key runs cronit function, then exits
		then
			set_all
		fi

		for ((i=0;i<${#mkeys[@]};i++)) #: find all instances of the hotkey in menuset
		do
			if [[ ${mkeys[$i]} = $key ]]
			then
				menukeys #: send the index of the key from allowable options to process
			fi
		done
		for ((i=0;i<${#keys[@]};i++)) #: find all instances of the hotkey
		do
			#echo i=$i, for lKeys loop #-- TRACER
			if [[ ${keys[$i]} = $key ]] #- || ${keys[$i]} = "${key^}" ]]
			then
				eatkeys #: send the index of the key from allowable options to process
			fi
		done

	# sleep 1 #-- TRACER
	done #: END WHILE stay_TF LOOP
} #......................................... end main

firstrun=0
init_colors
load_parms
update ${keys[1]} #: send scanner count hotkey to populate statrup dish args
#update ${keys[6]} #: now for lights, if on
storelongest
main "$@"
