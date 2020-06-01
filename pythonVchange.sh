#!/bin/bash
currentpyv=$(ls -l /usr/bin/python | awk '{print substr($11,10);}')
echo 'The current python version is' $currentpyv
echo 'Do you want to change it?'
echo 'Enter y or n'
read answer
if test $answer = 'y';
then
	posspyv=$( find /usr/bin -maxdepth 1 -type f -name 'python*' | awk '{print substr($1,10);}')
	posspyAR=($posspyv)
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
		if test /usr/bin/$currentpyv = /usr/bin/$pyver ; then
			echo 'That version of python is already softlinked, exiting'
		else
			sudo rm /usr/bin/python
			sudo ln -s /usr/bin/$pyver /usr/bin/python
			newpyver=$( ls -l /usr/bin/python | awk '{print substr($11,10)}' )
			echo 'the new softlinked python is' $newpyver 'cya'
		fi
else 
echo 'Answer wasnt y, bye.'

fi
exit 0