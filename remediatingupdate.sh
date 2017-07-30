#!/bin/bash

trap '' 2
trap '' SIGTSTP

printf "\n"
checkforsdb1lvm=`fdisk -l | grep /dev/sdb1 | grep "Linux LVM"`
if [ -z "$checkforsdb1lvm" ]
then
	echo "Please create a /dev/sdb1 partition with at least 8GB and LVM system ID first"
else
	# 1.1
	echo -e "\e[4m1.1 : Create Separate Partition for /tmp\e[0m\n"
	tmpcheck=`grep "[[:space:]]/tmp[[:space:]]" /etc/fstab`
	if [ -z "$tmpcheck" ]
	then
		echo "/tmp - FAILED (A separate /tmp partition has not been created.)"
		echo "A seperate /tmp partition will now be created"
		vgcheck=`vgdisplay | grep "VG Name" | grep "MyVG"`
		if [ -z "$vgcheck" ]
		then
			vgcreate MyVG /dev/sdb1 &> /dev/null
		fi
		
		lvcheck=`lvdisplay | grep "LV Name" | grep "TMPLV"`
		if [ -z "$lvcheck" ]
		then 
			lvcreate -L 500M -n TMPLV MyVG &> /dev/null
			mkfs.ext4 /dev/MyVG/TMPLV &> /dev/null
		fi
		echo "/dev/MyVG/TMPLV	/tmp	ext4	defaults 0 0" >> /etc/fstab
		mount -a
		
	else
		echo "/tmp - PASSED (A seperate /tmp partition is already created)"
	fi

	printf "\n\n"
	# 1.2
	echo -e "\e[4m1.2 : Set nodev option for /tmp Partition\e[0m\n"
	nodevcheck1=`grep "[[:space:]]/tmp[[:space:]]" /etc/fstab | grep nodev`
	if [ -z "$nodevcheck1" ]
	then
		echo "/tmp - FAILED (/tmp not mounted persistently with nodev option)"
		echo "/tmp will now be mounted persistently with nodev option"
		sed -ie 's:\(.*\)\(\s/tmp\s\s*\)\(\w*\s*\)\(\w*\s*\)\(.*\):\1\2\3nodev,\4\5:' /etc/fstab
		
	else
		echo "/tmp - PASSED (/tmp is mounted persistently with nodev option)"
	fi
	
	printf "\n"
	
	nodevcheck2=`mount | grep "[[:space:]]/tmp[[:space:]]" | grep nodev`
	if [ -z "$nodevcheck2" ]
	then
		echo "/tmp - FAILED (/tmp not mounted with nodev option)"
		echo "/tmp will now be mounted with nodev option"
		mount -o remount,nodev /tmp
	else
		echo "/tmp - PASSED (/tmp is currently mounted with nodev option)"
	fi

	printf "\n\n"
	# 1.3
	echo -e "\e[4m1.3 : Set nosuid option for /tmp Partition\e[0m\n"
	nosuidcheck1=`grep "[[:space:]]/tmp[[:space:]]" /etc/fstab | grep nosuid`
	if [ -z "$nosuidcheck1" ]
	then
		echo "/tmp - FAILED (/tmp not mounted persistently with nosuid option)"
		echo "/tmp will now be mounted persistently with nosuid option"
		sed -ie 's:\(.*\)\(\s/tmp\s\s*\)\(\w*\s*\)\(\w*\s*\)\(.*\):\1\2\3nosuid,\4\5:' /etc/fstab
	else
		echo "/tmp - PASSED (/tmp is mounted persistently with nosuid option)"
	fi
	
	printf "\n"
	
	nosuidcheck2=`mount | grep "[[:space:]]/tmp[[:space:]]" | grep nosuid`
	if [ -z "$nosuidcheck2" ]
	then
		echo "/tmp - FAILED (/tmp not mounted with nosuid option)"
		echo "/tmp will now be mounted with nosuid option"
		mount -o remount,nosuid /tmp
	else
		echo "tmp - PASSED (/tmp is currently mounted with nosuid option)"
	fi
	
	printf "\n\n"
	
	# 1.4
	echo -e "\e[4m1.4 : Set noexec option for /tmp Partition\e[0m\n"
	noexeccheck1=`grep "[[:space:]]/tmp[[:space:]]" /etc/fstab | grep noexec`
	if [ -z "$noexeccheck1" ]
	then
		echo "/tmp - FAILED (/tmp not mounted persistently with noexec option)"
		echo "/tmp will now be mounted persistently with noexec option"
		sed -ie 's:\(.*\)\(\s/tmp\s\s*\)\(\w*\s*\)\(\w*\s*\)\(.*\):\1\2\3noexec,\4\5:' /etc/fstab
	else
		echo "/tmp - PASSED (/tmp is mounted persistently with noexec option)"
	fi	

	printf "\n"
	
	noexeccheck2=`mount | grep "[[:space:]]/tmp[[:space:]]" | grep noexec`
	if [ -z "$noexeccheck2" ]
	then
		echo "/tmp - FAILED (/tmp not mounted with noexec option)"
		echo "/tmp will now be mounted with noexec option"
		mount -o remount,noexec /tmp
	else
		echo "tmp - PASSED (/tmp is currently mounted with noexec option)"
	fi
	
	printf "\n\n"
	
	# 1.5
	echo -e "\e[4m1.5 : Create Separate Partition for /var\e[0m\n"
	varcheck=`grep "[[:space:]]/var[[:space:]]" /etc/fstab`
	if [ -z "$varcheck" ]
	then
		echo "/var - FAILED (A separate /var partition has not been created.)"
		echo "A seperate /var partition will now be created"
		vgcheck=`vgdisplay | grep "VG Name" | grep "MyVG"`
		if [ -z "$vgcheck" ]
		then
			vgcreate MyVG /dev/sdb1 &> /dev/null
		fi
		
		lvcheck=`lvdisplay | grep "LV Name" | grep "VARLV"`
		if [ -z "$lvcheck" ]
		then 
			lvcreate -L 5G -n VARLV MyVG &> /dev/null
			mkfs.ext4 /dev/MyVG/VARLV &> /dev/null
		fi
		echo "# /dev/MyVG/VARLV	/var	ext4	defaults 0 0" >> /etc/fstab
		mount -a
	
	else
		echo "/var - PASSED (A seperate /var partition is already created)"
	fi

	printf "\n\n"
	# 1.6
	echo -e "\e[4m1.6 : Bind Mount the /var/tmpdirectory to /tmp\e[0m\n"
	vartmpdircheck=`ls -l /var | grep "tmp"`
	if [ -z "$vartmpdircheck" ]
	then
		mkdir -p /var/tmp
	fi

	vartmpcheck1=`grep -e "/tmp[[:space:]]" /etc/fstab | grep "/var/tmp"`

	if [ -z "$vartmpcheck1" ]
	then
		echo "/var/tmp - FAILED (/var/tmp mount has not been binded to /tmp persistently.)"
		echo "/var/tmp will now be binded to /tmp persistently"
		echo "# /tmp	/var/tmp	none	bind	0 0" >> /etc/fstab
		mount -a
	else
		echo "/var/tmp - PASSED (/var/tmp mount has already been binded to /tmp persistently)"
	fi

	printf "\n"
	
	vartmpcheck2=`mount | grep "/var/tmp"`

	if [ -z "$vartmpcheck2" ]
	then
		echo "/var/tmp - FAILED (/var/tmp mount is not currently bounded to /tmp)"
		echo "/var/tmp will now be binded to /tmp"
		mount --bind /tmp /var/tmp
	else
		echo "/var/tmp - PASSED (/var/tmp mount is already currently bounded to /tmp)"
	fi

	printf "\n\n"
	# 1.7
	echo -e "\e[4m1.7 : Create Separate Partition for /var/log\e[0m\n"
	varlogdircheck=`ls -l /var | grep "log"`
	if [ -z "$varlogdircheck" ]
	then
		mkdir -p /var/log
	fi

	varlogcheck=`grep "[[:space:]]/var/log[[:space:]]" /etc/fstab`
	if [ -z "$varlogcheck" ]
	then
		echo "/var/log - FAILED (A separate /var/log partition has not been created.)"
		echo "A seperate /var/log partition will now be created"
		vgcheck=`vgdisplay | grep "VG Name" | grep "MyVG"`
		if [ -z "$vgcheck" ]
		then
			vgcreate MyVG /dev/sdb1 &> /dev/null
		fi
		
		lvcheck=`lvdisplay | grep "LV Name" | grep "VARLOGLV"`
		if [ -z "$lvcheck" ]
		then 
			lvcreate -L 200M -n VARLOGLV MyVG &> /dev/null
			mkfs.ext4 /dev/MyVG/VARLOGLV &> /dev/null
		fi
		echo "/dev/MyVG/VARLOGLV	/var/log	ext4	defaults 0 0" >> /etc/fstab
		mount -a
	
	else
		echo "/var/log - PASSED (A separate /var/log partition has already been created.)"
	fi

	printf "\n\n"
	# 1.8
	echo -e "\e[4m1.8 : Create Separate Partition for /var/log/audit\e[0m\n"
	auditdircheck=`ls -l /var/log | grep "audit"`
	if [ -z "$auditdircheck" ]
	then
		mkdir -p /var/log/audit	
	fi

	varlogauditcheck=`grep "[[:space:]]/var/log/audit[[:space:]]" /etc/fstab`
	if [ -z "$varlogauditcheck" ]
	then
		echo "/var/log/audit - FAILED (A separate /var/log/audit partition has not been created.)"
		echo "A seperate /var/log/audit parition will now be created"
		vgcheck=`vgdisplay | grep "VG Name" | grep "MyVG"`
		if [ -z "$vgcheck" ]
		then
			vgcreate MyVG /dev/sdb1 &> /dev/null
		fi
		
		lvcheck=`lvdisplay | grep "LV Name" | grep "VARLOGAUDITLV"`
		if [ -z "$lvcheck" ]
		then 
			lvcreate -L 200M -n VARLOGAUDITLV MyVG &> /dev/null
			mkfs.ext4 /dev/MyVG/VARLOGAUDITLV &> /dev/null
		fi
		echo "/dev/MyVG/VARLOGAUDITLV	/var/log/audit	ext4	defaults 0 0" >> /etc/fstab
		mount -a
	
	else
		echo "/var/log/audit - PASSED (A separate /var/log/audit partition has already been created.)"
	fi
	
	printf "\n\n"
	# 1.9
	echo -e "\e[4m1.9 : Create Separate Partition for /home\e[0m\n"
	homecheck=`grep "[[:space:]]/home[[:space:]]" /etc/fstab`
	if [ -z "$homecheck" ]
	then
		echo "/home - FAILED (A separate /home partition has not been created.)"
		echo "A seperate /home partition will now be created"
		vgcheck=`vgdisplay | grep "VG Name" | grep "MyVG"`
		if [ -z "$vgcheck" ]
		then
			vgcreate MyVG /dev/sdb1 &> /dev/null
		fi
		
		lvcheck=`lvdisplay | grep "LV Name" | grep "HOMELV"`
		if [ -z "$lvcheck" ]
		then 
			lvcreate -L 500M -n HOMELV MyVG &> /dev/null
			mkfs.ext4 /dev/MyVG/HOMELV &> /dev/null
		fi
		echo "/dev/MyVG/HOMELV	/home	ext4	defaults 0 0" >> /etc/fstab
		mount -a
	else
		echo "/home - PASSED (A separate /home partition has already been created.)"
	fi

	printf "\n\n"
	
	# 1.10
	echo -e "\e[4m1.10 : Add nodev Option to /home\e[0m\n"
	homenodevcheck1=`grep "[[:space:]]/home[[:space:]]" /etc/fstab | grep nodev`
	if [ -z "$homenodevcheck1" ]
	then
		echo "/home - FAILED (/home not mounted persistently with nodev option)"
		echo "/home will now be mounted persistently with nodev option"
		sed -ie 's:\(.*\)\(\s/home\s\s*\)\(\w*\s*\)\(\w*\s*\)\(.*\):\1\2\3nodev,\4\5:' /etc/fstab
	else
		echo "/home - PASSED (/home is already mounted persistently with nodev option)"
	fi
	
	printf "\n"
	
	homenodevcheck2=`mount | grep "[[:space:]]/home[[:space:]]" | grep nodev`
	if [ -z "$homenodevcheck2" ]
	then
		echo "/home - FAILED (/home currently not mounted with nodev option)"
		echo "/home will now be mounted with nodev option"
		mount -o remount,nodev /home
	else
		echo "/home - PASSED (/home is already currently mounted with nodev option)"
	fi
fi

printf "\n\n"

read -n 1 -s -r -p "Press any key to exit!"
kill -9 $PPID