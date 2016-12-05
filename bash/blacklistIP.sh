#!/bin/bash
blIP_workDir="/etc/blacklistIP/"
blIP_saveFile="${blIP_workDir}blacklistIP_save"
blIP_sortFile="${blIP_workDir}blacklistIP_sort"
blIP_compFile="${blIP_workDir}blacklistIP_comp"

# ERR
# Send error message to stderr
# Usage:
#	ERR code_segment_identifier - error message
#	eg: ERR Vaild_IPv4 - quartet is out of range
function __blacklistIP_ERR { echo "!!! ERROR : $@" 1>&2; }

function __blacklistIP {
case "$1" in
	exists)
		# Check for return rule in BLACKLIST chain, fails if no rule or chain, both legit failures
		iptables -C BLACKLIST -j RETURN
		if [ $? -gt 0 ]; then return 1; fi
		# Check for jump target in INPUT chain, grep returns 1 if not found
		iptables -n -L INPUT | grep -q 'BLACKLIST[ \t]'
		if [ $? -gt 0 ]; then return 1; fi
		return 0
	;;
	create)
		iptables -N BLACKLIST				# Create new chain
		iptables -A BLACKLIST -j RETURN	# Add return statement at bottom
		iptables -I INPUT 1 -j BLACKLIST	# Insert global jump statement to INPUT chain
		return 0
	;;
	reset)
		iptables -D INPUT -j BLACKLIST		# Remove global jump statement from INPUT chain
		iptables -F BLACKLIST				# Deletes all rules in chain
		iptables -X BLACKLIST				# Deletes the chain
		__blacklistIP create
		return 0
	;;
	remove)
		iptables -D INPUT -j BLACKLIST		# Remove global jump statement from INPUT chain
		iptables -F BLACKLIST				# Deletes all rules in chain
		iptables -X BLACKLIST				# Deletes the chain
	return 0
	;;
	usage)	# print usage for _blacklistIP (NOT __blacklistIP)
		echo "Usage: blacklistIP [OPTION]  [ARGUMENT]"
		echo -e "User-friendly front-end to dropping all inbound packets from specified IPs using iptables\n"
		echo -e "  [OPTION]\t [ARGUMENT]\t Descriptive statement"
		echo -e "  -a --add\t  IP[,IP[,...]]\t Drop/Block incoming packets from IP(s)"
		echo -e "  -c --compare\t  --NONE--\t Compare the current BLACKLIST chain to the saved one"
		echo -e "  -d --load\t  --NONE--\t Initializes the iptables and loads the IPs to block from"
				echo -e "\t\t\t\t\t${blIP_saveFile} (only useful after a reboot)"
		echo -e "  -h --help\t  --NONE--\t Prints help & usage information (this message)"
		echo -e "  -l --list\t  --NONE--\t Prints list of blocked IPs in chain"
		echo -e "  -i --import\t  --NONE--\t Adds any IPs in ${blIP_saveFile} that are not currently in the chain"
		echo -e "  -o --overwrite  --NONE--\t clears all IPs from the chain and loads all IPs in "$blIP_saveFile
		echo -e "  -r --rem\t  IP\t\t Removes IP from chain"
		echo -e "  -s --sort\t  --NONE--\t Sort the IPs in the chain"
		echo -e "  -w --save\t  --NONE--\t Saves the IPs in the chain to "$blIP_saveFile
		return 0
	;;
	*)
		__blacklistIP_ERR "__blacklistIP: invalid argument"
		;;
esac
}

function _blacklistIP {
case "$1" in
	-h | --help)
		__blacklistIP usage
		return 0
	;;
	-a | --add)
		# Check to see if input is a valid IP (also works on multiple, comma seperated IPs;
		#	might let bad IPs through if they aren't the first in the list)
		if [[ $2 =~  [0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3} ]]; then
				
			# Check if BLACKLIST chain exists, if not: create it
			__blacklistIP exists
			if [ $? -gt 0 ]; then __blacklistIP create; fi
			
			# Insert supplied IPs into BLACKLIST chain, insert keeps return statement as last rule.
			iptables -I BLACKLIST 1 -s $2 -j DROP
			return 0
		fi
	;;
	-c | --compare)
		__blacklistIP exists
		if [ $? -gt 0 ]; then
			__blacklistIP_ERR "blacklistIP: IPchain 'BLACKLIST' does not exist."
			return 1
		fi
		#BUILD COMPARISON FILE
		echo '*filter' > "$blIP_compFile"
		# get all of the lines relating to the BLACKLIST chain
		iptables-save | grep -e ".*BLACKLIST.*" >> "$blIP_compFile"
		# append 'COMMIT' as iptables-restore expects
		echo 'COMMIT' >> "$blIP_compFile"
		# replace -Add instruction with -Insert instruction
		sed -i 's/.A INPUT -j BLACKLIST/-I INPUT 1 -j BLACKLIST/' "$blIP_compFile"

		#OUTPUT
		#LEFT file (exists in current but not in save)
		mapfile -t blIP_commL < <( comm -23 <(egrep -o "[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}" "$blIP_compFile" | sort) <(egrep -o "[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}" "$blIP_saveFile" | sort) )
		#RIGHT file (exists in save but not in current)
		mapfile -t blIP_commR < <( comm -13 <(egrep -o "[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}" "$blIP_compFile" | sort) <(egrep -o "[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}" "$blIP_saveFile" | sort) )

		if [[ ${#blIP_commL[@]} -eq 0 && ${#blIP_commR[@]} -eq 0 ]]; then
			echo "Everything is identical."
		else
			if [ ${#blIP_commL[@]} -gt 0 ]; then
				echo "IPs currently in the BLACKLIST chain that are NOT saved:"
				for ((arr_itter=0; arr_itter < ${#blIP_commL[@]}; arr_itter++)); do	#${#arrName[@]} = num elements in array
					echo -e "\t${blIP_commL[$arr_itter]}"
				done
			fi
			if [ ${#blIP_commR[@]} -gt 0 ]; then
				echo "IPs currently SAVED that are NOT currently in the BLACKLIST chain:"
				for ((arr_itter=0; arr_itter < ${#blIP_commR[@]}; arr_itter++)); do	#${#arrName[@]} = num elements in array
					echo -e "\t${blIP_commR[$arr_itter]}"
				done
			fi
		fi
	;;
	-l | --list)
		__blacklistIP exists
		if [ $? -gt 0 ]; then
			__blacklistIP_ERR "blacklistIP: IPchain 'BLACKLIST' does not exist."
			return 1
		fi
		iptables -L BLACKLIST --line-numbers -n
	;;
	-r | --rem)
		__blacklistIP exists
		if [ $? -gt 0 ]; then
			__blacklistIP_ERR "blacklistIP: IPchain 'BLACKLIST' does not exist."
			return 1
		fi
		# Check to see if input is a valid IP (also works on multiple, comma seperated IPs;
		#	might let bad IPs through if they aren't the first in the list)
		if [[ $2 =~  [0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3} ]]; then
			# Check for target
			iptables -C BLACKLIST -s $2 -j DROP
			if [[ $? -gt 0 ]]; then
				__blacklistIP_ERR "blacklistIP: rm: Target does not exist in chain."
				__blacklistIP_ERR "blacklistIP: rm: Target: $2"
				return 1
			fi
			# If target exists, delete it
			iptables -D BLACKLIST -s $2 -j DROP
			return 0
		fi
	;;
	-s | --sort)
		__blacklistIP exists
		if [ $? -gt 0 ]; then 
			__blacklistIP_ERR "blacklistIP: IPchain 'BLACKLIST' does not exist, please create and populate first"
			return 1
		fi

		# Do some grep magic to extract all valid & non zero ip addresses from BLACKLIST chain
		#  sort them and shove them into an array
		#15:09 < geirha> mapfile -t ips < <(pipe line|that outputs|ips|one per line)
		mapfile -t blIP_iparr < <(sudo iptables -n -L BLACKLIST | egrep -o "[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}" | grep -v "0.0.0.0" | sort -V)
		#declare -a blIP_iparr=($( iptables -n -L BLACKLIST | tr '\n' ' ' | grep "Chain BLACKLIST.*" | egrep -o "[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}" | grep -v "0.0.0.0" | sort -V | tr '\n' ' ' ));

		# Clear the blacklist
		__blacklistIP reset
		iptables -D INPUT -j BLACKLIST

		# Clear $blIP_sortFile and prep file for iptables-restore
		echo '*filter' > "$blIP_sortFile"
		echo ':BLACKLIST - [0:0]' >> "$blIP_sortFile"
		echo '-I INPUT 1 -j BLACKLIST' >> "$blIP_sortFile"

		# Iterate through and add the sorted IPs to sortFile in iptables-restore command format
		for iter_ip in "${blIP_iparr[@]}"; do
			echo -A BLACKLIST -s "${iter_ip}/32" -j DROP >> "$blIP_sortFile"
		done
		
		# Finish the file as iptables-restore expects
		echo '-A BLACKLIST -j RETURN' >> "$blIP_sortFile"
		echo 'COMMIT' >> "$blIP_sortFile"

		# Redirect the file into iptables-restore not modifying anything else
		iptables-restore -nc --table=filter < "$blIP_sortFile"
		return 0
	;;
	-w | --save)
		__blacklistIP exists
		if [ $? -gt 0 ]; then 
			__blacklistIP_ERR "blacklistIP: IPchain 'BLACKLIST' does not exist, please create and populate first"
			return 1
		fi
		# If chain exists
		# clear $blIP_saveFile, append '*filter' (iptable name) as iptables-restore expects
		echo '*filter' > "$blIP_saveFile"
		# get all of the lines relating to the BLACKLIST chain
		iptables-save | grep ".*BLACKLIST.*" >> "$blIP_saveFile"
		# append 'COMMIT' as iptables-restore expects
		echo 'COMMIT' >> "$blIP_saveFile"
		# replace -Add instruction with -Insert instruction
		sed -i 's/.A INPUT -j BLACKLIST/-I INPUT 1 -j BLACKLIST/' "$blIP_saveFile"
		return 0
	;;
	-d | --load)
		# If file exists, and can be read
		if [[ -f $blIP_saveFile && -r $blIP_saveFile ]]; then
			__blacklistIP exists
			if [ $? -eq 0 ]; then
				__blacklistIP_ERR "blacklistIP: IP chain already exists!"
				echo "!!! WARNING : blacklistIP: IPchain already exists! Please use"
				echo -e "\t'blacklistIP --overwrite' which will clear all current rules, and load only the saved rules"
				echo -e "or\t'blacklistIP --loadnew' which will keep all current rules, and only load new rules from the saved rules"
				return 1
			fi
			iptables -N BLACKLIST
			# use iptables-restore to insert BLACKLIST chain and all rules,
			#  and don't modify anything else
			iptables-restore -nc --table=filter < "$blIP_saveFile"
		else
			__blacklistIP_ERR "blacklistIP: ${blIP_saveFile} does not exist or is not readable"
			return 1
		fi
	;;
	-o | --overwrite)
		__blacklistIP remove
		_blacklistIP --load
	;;
	-i | --import)
		# If file exists, and can be read
		if [[ ! -f $blIP_saveFile && ! -r $blIP_saveFile ]]; then 
			__blacklistIP_ERR "blacklistIP: ${blIP_saveFile} does not exist or is not readable";
		fi
		__blacklistIP exists
		if [ $? -gt 0 ]; then
			__blacklistIP_ERR "blacklistIP: IPchain 'BLACKLIST' does not exist, please create and populate first"
			return 1
		fi
		# Create a file similar to $blIP_saveFile
		echo '*filter' > "$blIP_compFile"
		# get all of the lines relating to the BLACKLIST chain
		iptables-save | grep ".*BLACKLIST.*" >> "$blIP_compFile"
		# append 'COMMIT' as iptables-restore expects
		echo 'COMMIT' >> "$blIP_compFile"
		# replace -Add instruction with -Insert instruction
		sed -i 's/.A INPUT -j BLACKLIST/-I INPUT 1 -j BLACKLIST/' "$blIP_compFile"


		# Compare the 2 files; assign any IPs unique to $blIP_saveFile to an array entry
		mapfile -t blIP_iparr < <( comm -13 <(sort "$blIP_compFile") <(sort "$blIP_saveFile") | grep -Eo '[0-9]{1,3}.[0-9]{1,3}.[0-9]{1,3}.[0-9]{1,3}' )
		
		# Encase those rules into an iptables-restore file
		echo '*filter' > "$blIP_compFile"
		echo ':BLACKLIST - [0:0]' >> "$blIP_compFile"
		for ip_iterr in ${blIP_iparr[@]}; do
			echo "-A BLACKLIST -s ${ip_iterr}/32 -j DROP" >> "$blIP_compFile"
		done
		echo 'COMMIT' >> "$blIP_compFile"
		iptables-restore -nc --table=filter < "$blIP_compFile"
		_blacklistIP --sort
	;;
	*)
		__blacklistIP_ERR "blacklistIP: FATAL: invalid arguments"
		__blacklistIP usage
		return 1
	;;
esac
}

# This line allows this script to be placed in /usr/bin/blacklistIP and used at a prompt as a command ("blacklistIP")
if [ "$(id -u)" = "0" ]; then
	_blacklistIP $@
else
	echo "You do not have the necessary privilages to run this command"
	exit 1
fi