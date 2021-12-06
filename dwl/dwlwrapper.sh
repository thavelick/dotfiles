#!/bin/sh

fifo_base=/tmp/dwltags-

displays=("WL-1")

while IFS='$\n' read -r line;
do
		echo $line >> /tmp/dwlwrapper.log
	output=$(echo $line | cut -d ' ' -f 1)
	data=$(echo $line | cut -d ' ' -f 2-)

	for d in ${displays[@]};
	do
		if [ "$output" == "$d" ];
		then

			if [ ! -p "$fifo_base$output" ];
			then
				mkfifo "$fifo_base$output"
			fi
			echo "$data" > $fifo_base$output
		fi
	done


done
