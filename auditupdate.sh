#!/bin/bash

trap '' 2
trap '' SIGTSTP
printf "\n"
# 1.1 to 1.4
echo -e "\e[4m1.1 to 1.4 : Create Separate Partition for /tmp and Setting nodev, nosuid and noexec Option\e[0m\n"
checktmp=`grep "[[:space:]]/tmp[[:space:]]" /etc/fstab`

if [ -z "$checktmp" ]
then
	echo "/tmp - FAILED (A separate /tmp partition has not been created.)"
else
	checknodev=`grep "[[:space:]]/tmp[[:space:]]" /etc/fstab | grep nodev`
	checknodev1=`mount | grep "[[:space:]]/tmp[[:space:]]" | grep nodev`
	if [ -z "$checknodev" -a -z "$checknodev1" ]
	then
		echo "/tmp - FAILED (/tmp not mounted with nodev option)"
	elif [ -z "$checknodev" -a -n "$checknodev1" ]
	then
		echo "/tmp - FAILED (/tmp not mounted persistently with nodev option)"
	elif [ -n "$checknodev" -a -z "$checknodev1" ]
	then
		echo "/tmp - FAILED (/tmp currently not mounted with nodev option)"
	else
		checknosuid=`grep "[[:space:]]/tmp[[:space:]]" /etc/fstab | grep nosuid`
		checknosuid1=`mount | grep "[[:space:]]/tmp[[:space:]]" | grep nosuid`
		if [ -z "$checknosuid" -a -z "$checknosuid1" ]
		then
			echo "/tmp - FAILED (/tmp not mounted with nosuid option)"
		elif [ -z "$checknosuid" -a -n "$checknosuid1" ]
		then
			echo "/tmp - FAILED (/tmp not mounted persistently with nosuid option)"
		elif [ -n "$checknosuid" -a -z "$checknosuid1" ]
		then
			echo "/tmp - FAILED (/tmp currently not mounted with nosuid option)"
		else	
			checknoexec=`grep "[[:space:]]/tmp[[:space:]]" /etc/fstab | grep noexec`
			checknoexec1=`mount | grep "[[:space:]]/tmp[[:space:]]" | grep noexec`
			if [ -z "$checknoexec" -a -z "$checknoexec1" ]
			then
				echo "/tmp - FAILED (/tmp not mounted with noexec option)"
			elif [ -z "$checknoexec" -a -n "$checknoexec1" ]
			then
				echo "/tmp - FAILED (/tmp not mounted persistently with noexec option)"
			elif [ -n "$checknoexec" -a -z "$checknoexec1" ]
			then
				echo "/tmp - FAILED (/tmp currently not mounted with noexec option)"
			else
				echo "/tmp - PASSED (/tmp is a separate partition with nodev,nosuid,noexec option)"
			fi
		fi
	fi
fi

printf "\n\n"
# 1.5
echo -e "\e[4m1.5 : Create Separate Partition for /var\e[0m\n"
checkvar=` grep "[[:space:]]/var[[:space:]]" /etc/fstab`
if [ -z "$checkvar" ]
then
	echo "/var - FAILED (A separate /var partition has not been created.)"
else 
	echo "/var - PASSED (A separate /var partition has been created)"
fi	

printf "\n\n"
# 1.6
echo -e "\e[4m1.6 : Bind Mount the /var/tmpdirectory to /tmp\e[0m\n"
checkbind=`grep -e "^/tmp[[:space:]]" /etc/fstab | grep /var/tmp` 
checkbind1=`mount | grep /var/tmp`
if [ -z "$checkbind" -a -z "$checkbind1" ]
then
	echo "/var/tmp - FAILED (/var/tmp mount is not bounded to /tmp)"
elif [ -z "$checkbind" -a -n "$checkbind1" ]
then
	echo "/var/tmp - FAILED (/var/tmp mount has not been binded to /tmp persistently.)"
elif [ -n "$checkbind" -a -z "$checkbind1" ]
then
	echo "/var/tmp - FAILED (/var/tmp mount is not currently bounded to /tmp)"
else 
	echo "/var/tmp - PASSED (/var/tmp has been binded and mounted to /tmp)"
fi

printf "\n\n"
# 1.7
echo -e "\e[4m1.7 : Create Separate Partition for /var/log\e[0m\n"
checkvarlog=`grep "[[:space:]]/var/log[[:space:]]" /etc/fstab`
if [ -z "$checkvarlog" ]
then
	echo "/var/log - FAILED (A separate /var/log partition has not been created.)"
else 
	echo "/var/log - PASSED (A separate /var/log partition has been created)"
fi	

printf "\n\n"
# 1.8
echo -e "\e[4m1.8 : Create Separate Partition for /var/log/audit\e[0m\n"
checkvarlogaudit=`grep "[[:space:]]/var/log/audit[[:space:]]" /etc/fstab`
if [ -z "$checkvarlogaudit" ]
then
	echo "/var/log/audit - FAILED (A separate /var/log/audit partition has not been created.)"
else 
	echo "/var/log/audit - PASSED (A separate /var/log/audit partition has been created)"
fi

printf "\n\n"

# 1.9 to 1.10
echo -e "\e[4m1.9 to 1.10 : Create Separate Partition for /home and Setting nodev Option\e[0m\n"
checkhome=` grep "[[:space:]]/home[[:space:]]" /etc/fstab`
if [ -z "$checkhome" ]
then
	echo "/home - FAILED (A separate /home partition has not been created.)"
else 
	checknodevhome=`grep "[[:space:]]/home[[:space:]]" /etc/fstab | grep nodev`
	checknodevhome1=`mount | grep "[[:space:]]/home[[:space:]]" | grep nodev`
	
	if [ -z "$checknodevhome" -a -z "$checknodevhome1" ]
	then
		echo "/home - FAILED (/home not mounted with nodev option)"
	elif [ -z "$checknodevhome" -a -n "$checknodevhome1" ]
	then
		echo "/home - FAILED (/home not mounted persistently with nodev option)"
	elif [ -n "$checknodevhome" -a -z "$checknodevhome1" ]
	then
		echo "/home - FAILED (/home currently not mounted with nodev option)"
	else
		echo "/home - PASSED (/home is a separate partition with nodev option)"
	fi
fi

printf "\n\n"

read -n 1 -s -r -p "Press any key to exit!"
kill -9 $PPID