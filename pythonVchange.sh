#!/bin/bash
# Get the current version of python linked to /usr/bin/python.
currentpyv=$(ls -l /usr/bin/python | awk '{print substr($11,10);}')
echo 'The current python version is' $currentpyv
echo 'Do you want to change it?'
echo 'Enter y or n'
read answer

if test $answer = 'y';
then
# Create an array with the possible versions of python availible in /usr/bin.
	posspyv=$( find /usr/bin -maxdepth 1 -type f -name 'python*' | awk '{print substr($1,10);}')
	posspyAR=($posspyv)
# Use PS3 to pick a new version from that array to soflink, bail from the loop if a bad choice is made.
	PS3='Choose a version of python to soft link:'
	select pyver in "${posspyAR[@]}"; do
		if [[ $REPLY == "0" ]]; then
			echo 'Bye!' >&2
			exit
		elif [[ -z $pyver ]]; then
			echo 'bad choice' >&2
		else
			break
		fi
	done
# Check that the program is actually doing something.
		if test /usr/bin/$currentpyv = /usr/bin/$pyver ; then
			echo 'That version of python is already softlinked, exiting'
		else
# Delete the currect python soflink, the create a new one and print it.
			sudo rm /usr/bin/python
			sudo ln -s /usr/bin/$pyver /usr/bin/python
			newpyver=$( ls -l /usr/bin/python | awk '{print substr($11,10)}' )
			echo 'the new softlinked python is' $newpyver 'cya'
		fi
else
# Mandatory double negative based snark. 
echo 'Answer wasnt y, bye.'

fi
exit 0