#!/bin/bash
# Intiate a var for a switch supplied python version
PYTHONVERSION_ARG='none'
# Help text
USEAGE="$(basename "$0")\n
[-h, --help] [-p=, --pythonversion= (pythonversion)]\n\n
A script that changes the softlinked python version.\n\n
    -h, --help :                Shows this help text\n
    -p=, --pythonversion=() :   Sets the softlinked python to the given arg\n
    (no args) :                 Runs an interactive chooser
"

# Command line options
for switch in "$@"; do
	case $switch in
        -p=*|--pythonversion=*)
        PYTHONVERSION_ARG="${switch#*=}"
        ;;
        -h|--help)
        echo -e $USEAGE
        exit
		;;
		*)
		echo "Run -h or --help for useage"
		exit
        ;;
    esac
done

# Get the current version of python linked to with /usr/bin/python.
# Create an array with the possible versions of python availible in /usr/bin.
CURRENTPYV=$(readlink /usr/bin/python)
POSSPYV=$( find /usr/bin -maxdepth 1 -type f -name 'python*' |
			awk '{print substr($1,10);}' )
POSSPYAR=($POSSPYV)

# Dont run the interactive menu if -p or --pythonversion is provided
if [[ $PYTHONVERSION_ARG == 'none' ]]; then
	echo 'The current python version is' $CURRENTPYV
	echo 'Do you want to change it?'
	read -s -n1 -p 'Enter Yes or No' answer
	case $answer in
		Y | y) echo
			echo 'Select a python version to softlink'
			# Use PS3 to choose a new python version from the array to soflink, 
			# bail from the program if a bad choice is made, bail from the loop
			# when the version is selected.
			PS3='Select a number:'
			select pyver in "${POSSPYAR[@]}"; do
				if [[ $REPLY == "0" ]]; then
					echo 'Bye!' >&2
					exit 1
				elif [[ -z $pyver ]]; then
					echo 'bad choice' >&2
					exit 1
				else
					break
				fi
			done
			# Check that the program is actually doing something.
			test $CURRENTPYV == /usr/bin/$pyver
			if [[ $? == "0" ]]; then
				echo 'That version of python is already softlinked, exiting'
				exit 1
			else
			# Delete the currect python soflink, the create a new one and print it.
				sudo rm /usr/bin/python
				sudo ln -s /usr/bin/$pyver /usr/bin/python
				newpyver=$( ls -l /usr/bin/python | awk '{print substr($11,10)}' )
				echo 'the new softlinked python is' $newpyver 'cya'
			fi
			exit;;
		N | n)
		# Mandatory double negative based snark. 
			echo 'Answer wasnt y, bye.'
			exit;;
		*)
		# Chooooose, wisely.
			echo -e '\n' $answer 'Is not a valid choice, whats wrong with you?'
	esac
else
	# If PYTHONVERSION_ARG is entered as a switch test its:
	# 1:) Not currently softlinked
	# 2:) In the array of installed versions and therfore valid.
	# Then change it.
	if [[ /usr/bin/$PYTHONVERSION_ARG == $CURRENTPYV ]]; then
		echo 'That version of python is already softlinked, exiting.'
		exit 1 
	elif [[ ! "${POSSPYAR[@]}" =~ "${PYTHONVERSION_ARG}" ]]; then
		echo 'Arg given isnt an installed Python version'
		exit 1
	else
		echo 'Changeing soflinked python version to' $PYTHONVERSION_ARG
		sudo rm /usr/bin/python
		sudo ln -s /usr/bin/$PYTHONVERSION_ARG /usr/bin/python
		newpyver=$( ls -l /usr/bin/python | awk '{print substr($11,10)}' )
		echo 'the new softlinked python is' $newpyver 'cya'			
	fi	
fi
exit 0