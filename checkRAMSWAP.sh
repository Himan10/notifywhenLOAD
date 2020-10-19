#! /bin/bash

# notify the user
password="thisIsNotMyPassword"
notify-send -u low -t 8000 "checkRAWSWAP" "Monitoring Starts"

### getthe memory and swap int.
var=0
while true; do
	mem=$(free -m | grep -P 'Mem.*' --line-buffered | sed -r 's/(\s)+/_/g' | cut -d '_' -f 3) 
	# g flag in sed command means "globally", change should affect other matched parts too. 
	
	if [ $mem -gt 2100 ] && [ $var -eq 0 ]
	then
		python /home/hi-man/python/pyproject/notifywhenLOAD/notifyME.py "RAM" $mem "show"
		var=1

	elif [ $mem -gt 2350 ] && [ $var -eq 1 ]
       	then
		python /home/hi-man/python/pyproject/notifywhenLOAD/notifyME.py "RAM" $mem "update"
		i=0
		while [ $i -lt 10 ] && [ $mem -gt 2350 ]; do
			if [ $i -eq 9 ]
			then
				pidCommand=$(ps -u hi-man -o pid,%mem,command | sort -bhr -k 2 | head -n 1 | awk '{print $1 $3}')
				# seperate the pid and command
				pid=$(echo "$pidCommand" | grep -Po '^\d+')
				commandName=$(echo "$pidCommand" | grep -Po '.(?<=/)[\w\d\S]+')
				#kill -STOP $pid
				notify-send -t 6000 -u normal "MOST CONSUMING $pid" "$commandName"
			fi
			i=$((i+1))
		done
		# send the pause signal to application after N seconds.
	fi
	
	sleep 0.3 # Pause the current (MEM) and check for others (Swap)
	
	### Check for SWAP 
	swap=$(free -m | grep -P 'Swap.*' --line-buffered | sed -r 's/(\s)+/_/g' | cut -d '_' -f 3)
	
	if [ $swap -gt 20 ]
	then
		python /home/hi-man/python/pyproject/notifywhenLOAD/notifyME.py "SWAP" $swap "update"
		i=0

		while [ $i -lt 10 ] && [ $swap -gt 15 ]; do
			sleep 0.5
			if [ $i -eq 5 ]
			then
				notify-send -u normal -t 1500 'Executing After 5 sec' 'sudo swapoff -a'

			elif [ $i -eq 10 ]
			then	
				# Anyone can open the file and read the password here, let's save myself
				echo -e "$password\n" | sudo -S swapoff -a >> /dev/null
			fi
			i=$((i+1))
		done
	fi

	if [ $mem -lt 2000 ] && [ $swap -eq 0 ] && [ $var -eq 1 ]
	then
		python /home/hi-man/python/pyproject/notifywhenLOAD/notifyME.py "NORMAL" 0 "show"
		#kill -CONT $pid
		var=0
	fi
done

# To fetch which process is consuming more memory
# ps -u hi-man -o pid,user,%mem,command | sort -bhr -k 3 | head -n 1 | grep -P "(?<=\s)[\d]+(?=\s)"
# Once i get the process name, and pid then PAUSE IT
