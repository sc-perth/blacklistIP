#!/bin/bash
# Build comparison file
blIP_compFile="./comp"
blIP_saveFile="./save"
cp /etc/blacklistIP/blacklistIP_save $blIP_saveFile

echo '*filter' > "$blIP_compFile"
# get all of the lines relating to the BLACKLIST chain
iptables-save | grep -e ".*BLACKLIST.*" >> "$blIP_compFile"
# append 'COMMIT' as iptables-restore expects
echo 'COMMIT' >> "$blIP_compFile"
# replace -Add instruction with -Insert instruction
sed -i 's/.A INPUT -j BLACKLIST/-I INPUT 1 -j BLACKLIST/' "$blIP_compFile"


#LEFT file (exists in current but not in save)
mapfile -t blIP_commL < <( comm -23 <(egrep -o "[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}" "$blIP_compFile" | sort) <(egrep -o "[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}" "$blIP_saveFile" | sort) )
#RIGHT file (exists in save but not in current)
mapfile -t blIP_commR < <( comm -13 <(egrep -o "[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}" "$blIP_compFile" | sort) <(egrep -o "[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}" "$blIP_saveFile" | sort) )

if [[ ${#blIP_commL[@]} -eq 0 && ${#blIP_commR[@]} -eq 0 ]]; then
	echo "Everything is identical."
elif [ ${#blIP_commL[@]} -gt 0 ]; then
	echo "IPs currently in the BLACKLIST chain that are NOT saved:"
	for ((arr_itter=0; arr_itter < ${#blIP_commL[@]}; arr_itter++)); do	#${#arrName[@]} = num elements in array
		echo -e "\t${blIP_commL[$arr_itter]}"
	done
elif [ ${#blIP_commR[@]} -gt 0 ]; then
	echo "IPs currently SAVED that are NOT currently in the BLACKLIST chain:"
	for ((arr_itter=0; arr_itter < ${#blIP_commR[@]}; arr_itter++)); do	#${#arrName[@]} = num elements in array
		echo -e "\t${blIP_commR[$arr_itter]}"
	done
fi






#mapfile -t blIP_iparr < <( comm -3 <(sort "$blIP_compFile") <(sort "$blIP_saveFile") )
#echo blIP_iparr has ${blIP_iparr[@]} entries
#for ip_iterr in ${blIP_iparr[@]}; do
#	echo iptables $ip_iterr
#done
#echo blIP_iparr has ${blIP_iparr[@]} entries
#echo done