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

# 1.11 to 1.13
echo -e "\e[4m1.11 to 1.13 : Add nodev, nosuid and no exec Option to Removable Media Partitions\e[0m\n"
cdcheck=`grep cd /etc/fstab`
if [ -n "$cdcheck" ]
then
	cdnodevcheck=`grep cdrom /etc/fstab | grep nodev`
	if [ -z "$cdnodevcheck" ]
	then
		sed -ie 's:\(.*\)\(\s/cdrom\s\s*\)\(\w*\s*\)\(\w*\s*\)\(.*\):\1\2\3nodev,\4\5:' /etc/fstab
		echo "nodev for /cdrom fixed"
	else
		echo "nodev for /cdrom is already fixed"
	fi

	cdnosuidcheck=`grep cdrom /etc/fstab | grep suid`
	if [ -z "$cdnosuidcheck" ]
	then
		sed -ie 's:\(.*\)\(\s/cdrom\s\s*\)\(\w*\s*\)\(\w*\s*\)\(.*\):\1\2\3nosuid,\4\5:' /etc/fstab
		echo "nosuid for /cdrom fixed"
	else
		echo "nosuid for /cdrom is already fixed"
	fi


	cdnoexeccheck=`grep cdrom /etc/fstab | grep exec`
	if [ -z "$cdnoexeccheck" ]
	then
		sed -ie 's:\(.*\)\(\s/cdrom\s\s*\)\(\w*\s*\)\(\w*\s*\)\(.*\):\1\2\3noexec,\4\5:' /etc/fstab
		echo "noexec for /cdrom fixed"
	else
		echo "noexec for /cdrom is already fixed"
	fi
else
	echo "/cdrom is not mounted"
fi

printf "\n\n"
# 1.14
echo -e "\e[4m1.14 : Set Sticky Bit on All World-Writable Directories\e[0m\n"
checksticky=`df --local -P | awk {'if (NR!=1) print $6'} | xargs -l '{}' find '{}' -xdev -type d \( -perm -0002 -a ! -perm -1000 \) 2> /dev/null`

if [ -n "$checksticky" ]
then
	df --local -P | awk {'if (NR!=1) print $6'} | xargs -l '{}' find '{}' -xdev -type d \( -perm -0002 -a ! -perm -1000 \) 2> /dev/null | xargs chmod o+t

else
	echo "Sticky bit is already set"
fi

printf "\n\n"

# 1.15
echo -e "\e[4m1.15 : Disable Mounting of Legacy Filesystems\e[0m\n"
checkcramfs=`/sbin/lsmod | grep cramfs`
checkfreevxfs=`/sbin/lsmod | grep freevxfs`
checkjffs2=`/sbin/lsmod | grep jffs2`
checkhfs=`/sbin/lsmod | grep hfs`
checkhfsplus=`/sbin/lsmod | grep hfsplus`
checksquashfs=`/sbin/lsmod | grep squashfs`
checkudf=`/sbin/lsmod | grep udf`

if [ -n "$checkcramfs" -o -n "$checkfreevxfs" -o -n "$checkjffs2" -o -n "$checkhfs" -o -n "$checkhfsplus" -o -n "$checksquashfs" -o -n "$checkudf" ]
then
	echo "install cramfs /bin/true" >> /etc/modprobe.d/CIS.conf
	echo "install freevxfs /bin/true" >> /etc/modprobe.d/CIS.conf
	echo "install jffs2 /bin/true" >> /etc/modprobe.d/CIS.conf
	echo "install hfs /bin/true" >> /etc/modprobe.d/CIS.conf
	echo "install hfsplus /bin/true" >> /etc/modprobe.d/CIS.conf
	echo "install squashfs /bin/true" >> /etc/modprobe.d/CIS.conf
	echo "install udf /bin/true" >> /etc/modprobe.d/CIS.conf
else
	echo "Legacy filesystems mounting is already disabled"
fi

printf "\n\n"
# 2.1
echo -e "\e[4m2.1 : Remove telnet Server & Clients\e[0m\n"
checktelnetserver=`yum list telnet-server | grep "Available Packages"`
if [ -n "$checktelnetserver" ]
then
	echo "Telnet-server is not installed, hence no action will be taken"
else
	echo "Telnet-server is installed, it will now be removed"
	yum erase -y telnet-server
fi 

checktelnet=`yum list telnet | grep "Available Packages"`
if [ -n "$checktelnet" ]
then
	echo "Telnet is not installed, hence no action will be taken"
else
	echo "Telnet is installed, it will now be removed"
	yum erase -y telnet
fi 

printf "\n\n"

# 2.2
echo -e "\e[4m2.2 : Remove rshServer & Clients\e[0m\n"
checkrshserver=`yum list rsh-server | grep "Available Packages"`
if [ -n "$checkrshserver" ]
then
	echo "Rsh-server is not installed, hence no action will be taken"
else
	echo "Rsh-server is installed, it will now be removed"
	yum erase -y rsh-server
fi 

checkrsh=`yum list rsh | grep "Available Packages"`
if [ -n "$checkrsh" ]
then
	echo "Rsh is not installed, hence no action will be taken"
else
	echo "Rsh is installed, it will now be removed"
	yum erase -y rsh
fi 

printf "\n\n"

# 2.3
echo -e "\e[4m2.3 : Remove NIS Server and Clients\e[0m\n"
checkypserv=`yum list ypserv | grep "Available Packages"`
if [ -n "$checkypserv" ]
then
	echo "Ypserv is not installed, hence no action will be taken"
else
	echo "Ypserv is installed, it will now be removed"
	yum erase -y ypserv
fi 

checkypbind=`yum list ypbind | grep "Available Packages"`
if [ -n "$checkypbind" ]
then
	echo "Ypbind is not installed, hence no action will be taken"
else
	echo "Ypbind is installed, it will now be removed"
	yum erase -y ypbind
fi

printf "\n\n"

# 2.4
echo -e "\e[4m2.4 : Remove tftpServer and Clients\e[0m\n"

checktftp=`yum list tftp | grep "Available Packages"`
if [ -n "$checktftp" ]
then
	echo "Tftp is not installed, hence no action will be taken"
else
	echo "Tftp is installed, it will now be removed"
	yum erase -y tftp
fi

checktftp=`yum list tftp-server| grep "Available Packages"`
if [ -n "$checktftp-server" ]
then
	echo "Tftp-server is not installed, hence no action will be taken"
else
	echo "Tftp-server is installed, it will now be removed"
	yum erase -y tftp-server
fi 

printf "\n\n"

# 2.5
echo -e "\e[4m2.5 : Remove xinetd\e[0m\n"
checkxinetd=`yum list xinetd | grep "Available Packages"`
if [ -n "$checkxinetd" ]
then
	echo "Xinetd is not installed, hence no action will be taken"
else
	echo "Xinetd is installed, it will now be removed"
	yum erase -y xinetd
fi 

printf "\n\n"
#2.6
echo -e "\e[4m2.6 : Disable chargen-dgram\e[0m\n"
checkxinetd=`yum list xinetd | grep "Available Packages"`
if [ -n "$checkxinetd" ]
then
	echo "Xinetd is not installed, hence chargen-dgram is not installed"
else	
	checkchargendgram=`chkconfig --list chargen-dgram | grep "off"`
	if [ -n "$checkchargendgram" ]
	then
		echo "chargen-dgram is not active, hence no action will be taken"
	else
		echo "chargen-dgram is active, it will now be disabled"
		chkconfig chargen-dgram off
	fi 
fi 

printf "\n\n"

# 2.7
echo -e "\e[4m2.7 : Disable chargen-stream\e[0m\n"
if [ -n "$checkxinetd" ]
then
	echo "Xinetd is not installed, hence chargen-stream is not installed"
else	
	checkchargenstream=`chkconfig --list chargen-stream | grep "off"`
	if [ -n "$checkchargenstream" ]
	then
		echo "chargen-stream is not active, hence no action will be taken"
	else
		echo "chargen-stream is active, it will now be disabled"
		chkconfig chargen-stream off
	fi 
fi 

printf "\n\n"

# 2.8
echo -e "\e[4m2.8 : Disable daytime-dgram / daytime-stream\e[0m\n"
if [ -n "$checkxinetd" ]
then
	echo "Xinetd is not installed, hence daytime-dgram is not installed"
else	
	checkdaytimedgram=`chkconfig --list daytime-dgram | grep "off"`
	if [ -n "$checkdaytimedgram" ]
	then
	echo "daytime-dgram is not active, hence no action will be taken"
	else
	echo "daytime-dgram is active, it will now be disabled"
	chkconfig daytime-dgram off
	fi 
fi

printf "\n"

if [ -n "$checkxinetd" ]
then
	echo "Xinetd is not installed, hence daytime-stream is not installed"
else	
	checkdaytimestream=`chkconfig --list daytime-stream | grep "off"`
	if [ -n "$checkdaytimestream" ]
	then
		echo "daytime-stream is not active, hence no action will be taken"
	else
		echo "daytime-stream is active, it will now be disabled"
		chkconfig daytime-stream off
	fi 
fi 

printf "\n\n"

# 2.9
echo -e "\e[4m2.9 : Disable echo-dgram / echo-stream\e[0m\n"
if [ -n "$checkxinetd" ]
then
	echo "Xinetd is not installed, hence echo-dgram is not installed"
else	
	checkechodgram=`chkconfig --list echo-dgram | grep "off"`
	if [ -n "$checkechodgram" ]
	then
		echo "echo-dgram is not active, hence no action will be taken"
	else
		echo "echo-dgram is active, it will now be disabled"
		chkconfig echo-dgram off
	fi
fi

printf "\n"

if [ -n "$checkxinetd" ]
then
	echo "Xinetd is not installed, hence echo-stream is not installed"
else	
	checkechostream=`chkconfig --list echo-stream | grep "off"`
	if [ -n "$checkechostream" ]
	then
		echo "echo-stream is not active, hence no action will be taken"
	else
		echo "echo-stream is active, it will now be disabled"
		chkconfig echo-stream off
	fi 
fi

printf "\n\n"
# 2.10
echo -e "\e[4m2.10 : Disable tcpmux-server\e[0m\n"
if [ -n "$checkxinetd" ]
then
	echo "Xinetd is not installed, hence tcpmux-server is not installed"
else	
	checktcpmuxserver=`chkconfig --list tcpmux-server | grep "off"`
	if [ -n "$checktcpmuxserver" ]
	then
		echo "tcpmux-server is not active, hence no action will be taken"
	else
		echo "tcpmux-server is active, it will now be disabled"
		chkconfig tcpmux-server off
	fi 
fi 

printf "\n\n"

# 3.1
echo -e "\e[4m3.1 : Set Daemon umask\e[0m\n"
umaskcheck=`grep ^umask /etc/sysconfig/init`
if [ -z "$umaskcheck" ]
then
	echo "umask 027" >> /etc/sysconfig/init
	echo "umask is now set correctly"
else
	echo "umask is not set correctly"
fi

printf "\n\n"
# 3.2
echo -e "\e[4m3.2 : Remove the X Window System\e[0m\n"
checkxsystem=`ls -l /etc/systemd/system/default.target | grep graphical.target`
checkxsysteminstalled=`rpm  -q xorg-x11-server-common | grep "not installed"`

if [ -n "$checkxsystem" ]
then
	if [ -z "$checkxsysteminstalled" ]
	then
		rm '/etc/systemd/system/default.target'
		ln -s '/usr/lib/systemd/system/multi-user.target' '/etc/systemd/system/default.target'
		yum remove -y xorg-x11-server-common
		echo "xorg-x11-server-common is now uninstalled"
	else
		echo "xorg-x11-server-common is already uninstalled"
	fi
else
	echo "the default.target is already multi-user.target"
fi

printf "\n\n"
# 3.3
echo -e "\e[4m3.3 : Disable AvahiServer\e[0m\n"
checkavahi=`systemctl status avahi-daemon | grep inactive`
checkavahi1=`systemctl status avahi-daemon | grep disabled`

if [ -z "$checkavahi" -o -z "$checkavahi1" ]
then
	systemctl disable avahi-daemon.service avahi-daemon.socket
	systemctl stop avahi-daemon.service avahi-daemon.socket
	yum remove -y avahi-autoipd avahi-libs avahi
	echo "avahi-autoipd, avahi-libs and avahi are now disabled and uninstalled"
else
	echo "avahi-autoipd, avahi-libs and avahi is already disabled and uninstalled"
fi

printf "\n\n"

# 3.4
echo -e "\e[4m3.4 : Disable Print Server - cups\e[0m\n"
checkcupsinstalled=`yum list cups | grep "Available Packages" `
checkcups=`systemctl status cups | grep inactive`
checkcups1=`systemctl status cups | grep disabled`
if [ -z "$checkcupsinstalled" ]
then
	if [ -z "$checkcups" -o -z "$checkcups1" ]
	then
		systemctl stop cups
		systemctl disable cups
		echo "cups is now stopped and disabled"
	else
		echo "cups is already stopped and disabled"
	fi
else
	echo "cups is already not installed"
fi

printf "\n\n"

# 3.5
echo -e "\e[4m3.5 : Remove DHCP Server\e[0m\n"
checkyumdhcp=`yum list dhcp | grep "Available Packages" `
checkyumdhcpactive=`systemctl status dhcp | grep inactive `
checkyumdhcpenable=`systemctl status dhcp | grep disabled `
if [ -z "$checkyumdhcp" ]
then
	if [ -z "$checkyumdhcpactive" -o -z "$checkyumdhcpenable" ]
	then
		systemctl disable dhcp
		systemctl stop dhcp
		yum -y erase dhcp
		echo "dhcp is now disabled and uninstalled"
	else
		echo "dhcp is already disabled and uninstalled"
	fi
else
	echo "dhcp is already not installed"
fi

printf "\n\n"

# 3.6
echo -e "\e[4m3.6 : Configure Network Time Protocol (NTP)\e[0m\n"
checkntpinstalled=`yum list ntp | grep "Installed"`

if [ -z "$checkntpinstalled" ]
then
	yum install -y ntp
	echo "ntp is now installed"
else
	echo "ntp is already installed"
fi
checkntp1=`grep "^restrict default" /etc/ntp.conf`
checkntp2=`grep "^restrict -6 default" /etc/ntp.conf`
checkntp3=`grep "^server" /etc/ntp.conf`
checkntp4=`grep "ntp:ntp" /etc/sysconfig/ntpd`

if [ "$checkntp1" != "restrict default kod nomodify notrap nopeer noquery" ]
then
	sed -ie '8d' /etc/ntp.conf
	sed -ie '8irestrict default kod nomodify notrap nopeer noquery' /etc/ntp.conf
	echo "restrict default kod nomodify notrap nopeer noquery is now configured"
else
	echo "restrict default kod nomodify notrap nopeer noquery is already configured"
fi
printf "\n"
if [ "$checkntp2" != "restrict -6 default kod nomodify notrap nopeer noquery" ]
then
	sed -ie '9irestrict -6 default kod nomodify notrap nopeer noquery' /etc/ntp.conf
	echo "restrict -6 default kod nomodify notrap nopeer noquery is now configured"
else
	echo "restrict -6 default kod nomodify notrap nopeer noquery is already configured"
fi
printf "\n"
if [ -z "$checkntp3" ]
then
	sed -ie '21iserver 10.10.10.10' /etc/ntp.conf #Assume 10.10.10.10 is NTP server
	echo "server is now configured"
else
	echo "server is already configured"
fi
printf "\n"
if [ -z "$checkntp4" ]
then
	sed -ie '2d' /etc/sysconfig/ntpd
	echo "1iOPTIONS=\"-u ntp:ntp -p /var/run/ntpd.pid\" " >> /etc/sysconfig/ntpd
	echo "options is now configured"
else
	echo "options is already configured"
fi

printf "\n\n"

# 3.7
echo -e "\e[4m3.7 : Remove LDAP\e[0m\n"
checkldapclientinstalled=`yum list openldap-clients | grep "Available Packages"`
checkldapserverinstalled=`yum list openldap-servers | grep "Available Packages"`

if [ -z "$checkldapclientinstalled" ]
then
	yum  -y erase openldap-clients
	echo "openldap-clients is now uninstalled"
else
	echo "openldap-clients is already uninstalled"
fi
printf "\n"
if [ -z "$checkldapserverinstalled" ]
then
	yum -y erase openldap-servers
	echo "openldap-servers is now uninstalled"
else
	echo "openldap-servers is already uninstalled"
fi

printf "\n\n"

# 3.8
echo -e "\e[4m3.8 : Disable NFS and RPC\e[0m\n"
checknfslock=`systemctl is-enabled nfs-lock | grep "disabled"`
checknfssecure=`systemctl is-enabled nfs-secure | grep "disabled"`
checkrpcbind=`systemctl is-enabled rpcbind | grep "disabled"`
checknfsidmap=`systemctl is-enabled nfs-idmap | grep "disabled"`
checknfssecureserver=`systemctl is-enabled nfs-secure-server | grep "disabled"`

if [ -z "$checknfslock" ]
then
	systemctl disable nfs-lock
	echo "nfs-lock is now disabled"
else
	echo "nfs-lock is already disabled"
fi

printf "\n"

if [ -z "$checknfssecure" ]
then
	systemctl disable nfs-secure
	echo "nfs-secure is now disabled"
else
	echo "nfs-secure is already disabled"
fi

printf "\n"

if [ -z "$checkrpcbind" ]
then
	systemctl disable rpcbind
	echo "rpcbind is now disabled"
else
	echo "rpcbind is already disabled"
fi

printf "\n"

if [ -z "$checknfsidmap" ]
then
	systemctl disable nfs-idmap
	echo "nfs-idmap is now disabled"
else
	echo "nfs-idmap is already disabled"
fi

printf "\n"

if [ -z "$checknfssecureserver" ]
then
	systemctl disable nfs-secure-server
	echo "nfs-secure-server is now disabled"
else
	echo "nfs-secure-server is already disabled"
fi

printf "\n\n"

# 3.9
echo -e "\e[4m3.9 : Remove DNS, FTP, HTTP, HTTP-Proxy, SNMP\e[0m\n"
checkyumdns=`yum list bind | grep "Available Packages" `
checkdns=`systemctl status named | grep inactive`
checkdns1=`systemctl status named | grep disabled`
if [ -z "$checkyumdns" ]
then
	if [ -z "$checkdns" -o -z "$checkdns1" ]
	then
		systemctl stop named
		systemctl disable named
		echo "dns service is now disabled and stopped"
	else
		echo "dns service is already disabled and stopped"
	fi
else
	echo "dns service is already not installed"
fi

printf "\n"

checkyumftp=`yum list vsftpd | grep "Available Packages" `
checkftp=`systemctl status vsftpd | grep inactive`
checkftp1=`systemctl status vsftpd | grep disabled`
if [ -z "$checkyumftp" ]
then
	if [ -z "$checkftp" -o -z "$checkftp1" ]
	then
		systemctl stop vsftpd
		systemctl disable vsftpd
		echo "vsftpd service is now disabled and stopped"
	else
		echo "vsftpd service is already disabled and stopped"
	fi
else
	echo "vsftpd service is already not installed"
fi

printf "\n"

checkyumhttp=`yum list httpd | grep "Available Packages" `
checkhttp=`systemctl status httpd | grep inactive`
checkhttp1=`systemctl status httpd | grep disabled`
if [ -z "$checkyumhttp" ]
then
	if [ -z "$checkhttp" -o -z "$checkhttp1" ]
	then
		systemctl stop httpd
		systemctl disable httpd
		echo "httpd service is now disabled and stopped"
	else
		echo "httpd service is already disabled and stopped"
	fi
else
	echo "httpd service is already not installed"
fi

printf "\n"

checkyumsquid=`yum list squid | grep "Available Packages" `
checksquid=`systemctl status squid | grep inactive`
checksquid=`systemctl status squid | grep disabled`
if [ -z "$checkyumsquid" ]
then
	if [ -z "$checksquid" -o -z "$checksquid1" ]
	then
		systemctl stop squid
		systemctl disable squid
		echo "squid service is now disabled and stopped"
	else
		echo "squid service is already disabled and stopped"
	fi
else
	echo "squid service is already not installed"
fi

printf "\n"

checkyumsnmp=`yum list net-snmp | grep "Available Packages" `
checksnmp=`systemctl status snmpd | grep inactive`
checksnmp1=`systemctl status snmpd | grep disabled`
if [ -z "$checkyumsnmp" ]
	then
	if [ -z "$checksnmp" -o -z "$checsnmp1" ]
	then
		systemctl stop snmpd
		systemctl disable snmpd
		echo "snmpd service is now disabled and stopped"
	else
		echo "snmpd service is already disabled and stopped"
	fi
else
	echo "snmpd service is already not installed"
fi

printf "\n\n"

# 3.10
echo -e "\e[4m3.10 : Configure Mail Transfer Agent for Local-Only Mode\e[0m\n"
checkmta=`netstat -an | grep LIST | grep "127.0.0.1:25[[:space:]]"`

if [ -z "$checkmta" ]
then
	sed -ie '116iinet_interfaces = localhost' /etc/postfix/main.cf
	echo "Mail transfer agent is now configured for local-only mode"
else
	echo "Mail transfer agent is already configured for local-only mode"
fi


printf "\n\n"

# Start of 4,1 coding
echo -e "\e[4m4.1 : Set User/Group Owner on /boot/grub2/grub.cfg\e[0m"
checkowner=$(stat -L -c "owner=%U group=%G" /boot/grub2/grub.cfg)
if [ "$checkowner" == "owner=root group=root" ]
then
	#If owner and group is configured CORRECTLY
	printf "\nBoth owner and group belong to ROOT user : PASSED"
	printf "\n$checkowner"
else
	#If owner ang group is configured INCORRECTLY
	chown root:root /boot/grub2/grub.cfg
	printf "\nBoth owner and group belong to ROOT user : FAILED"
	printf "\nChanging the owner and group..."
	printf "\nDone, Change SUCCESSFUL\n"
fi
# End of 4,1 coding

#To create space
printf "\n\n"

# Start of 4.2 coding
echo -e "\e[4m4.2 : Set Permissions on /boot/grub2/grub.cfg\e[0m"
checkpermission=$(stat -L -c "%a" /boot/grub2/grub.cfg | cut -c 2,3)
if [ "$checkpermission" == 00 ]
then
	#If the permission is configured CORRECTLY
	printf "\nConfiguration of Permission: PASSED"
else
	#If the permission is configured INCORRECTLY
	printf "\nConfiguration of Permission: FAIlED"
	printf "\nChanging configuration..."
	chmod og-rwx /boot/grub2/grub.cfg
	printf "\nDone, Change SUCCESSFUL\n"
fi
# End of 4.2 coding

# To create space
printf "\n\n"

# Start of 4.3 coding
echo -e "\e[4m4.3 : Set Boot Loader Password\e[0m"
checkboot=$(grep "set superusers" /boot/grub2/grub.cfg | sort | head -1 | awk -F '=' '{print $2}' | tr -d '"')
user=$(grep "set superusers" /boot/grub2/grub.cfg | sort | head -1 | awk -F '=' '{print $2}')
if [ "$checkboot" == "root" ]
then
	#If the configuration is CORRECT
	printf "\nBoot Loader Settings : PASSED"
	printf "\nThe following are the superusers: "
	printf "$user\n\n"
else
	#If the configuration is INCORRECT
	printf "\nBoot Loader Settings : FAILED"
	printf "\nConfiguring Boot Loader Settings..."
	printf "\n"
	printf "password\npassword" >> /etc/bootloader.txt
	grub2-mkpasswd-pbkdf2 < /etc/bootloader.txt > /etc/boot.md5
	printf "\n" >> /etc/grub.d/00_header
	printf "cat << EOF\n" >> /etc/grub.d/00_header
	printf "set superusers=root\n" >> /etc/grub.d/00_header
	ans=$(cat /etc/boot.md5 | grep "grub" | awk -F ' ' '{print $7}')
	printf "passwd_pbkdf2 root $ans\n" >> /etc/grub.d/00_header
	printf "EOF" >> /etc/grub.d/00_header
	grub2-mkconfig -o /boot/grub2/grub.cfg &> /dev/null
	printf "\nBoot loader settings are now configured"
	printf "\n"
	newuser=$(grep "set superusers" /boot/grub2/grub.cfg | sort | head -1 | awk -F '=' '{print $2}')

	printf "\nThe following are the superusers: "
	printf "$newuser\n\n"
fi
# End of 4.3 coding

# To have space
printf "\n"

# Start of 5.1 coding
echo -e "\e[4m5.1 : Restrict Core Dumps\e[0m"
checkcoredump=$(grep "hard core" /etc/security/limits.conf)
if [ -z "$checkcoredump" ]
then
	#If it is configured INCORRECTLY
	printf "\nHard Limit Settings : FAILED"
	printf "\n* hard core 0" >> /etc/security/limits.conf
	printf "\nfd.suid_dumpable = 0" >> /etc/sysctl.conf
	printf "\nConfiguring settings...."
	printf "\nDone, Change SUCCESSFUL"
else
	#If it is configured CORRECTLY
	printf "\nHard Limit Settings : PASSED\n"
fi
# End of 5.1 coding

# To have space
printf "\n\n"

# Start of 5.2 coding
echo -e "\e[4m5.2 : Enable Randomized Virtual Memory Region Placement\e[0m"
checkkernel=$(sysctl kernel.randomize_va_space)
checkkerneldeep=$(sysctl kernel.randomize_va_space | awk -F ' ' '{print $3}')
if [ "$checkkerneldeep" == 2 ]
then
	#If the configurations are CORRECT
	printf "\nVirtual Memory Randomization Settings : PASSED"
	printf "\nRandomization of Virtual Memory : "
	printf "$checkkernel\n"
else
	#If the configuratiions are INCORRECT
	printf "\nVirtual Memory Randomization Settings : FAILED"
	echo 2 > /proc/sys/kernel/randomize_va_space
	printf "\nConfiguring settings...."
	printf "\nDone, Change SUCCESSFUL"
	printf "\n\nNew Randomization of Virtual Memory : "
	newcheckkernel=$(sysctl kernel.randomize_va_space)
	printf "$newcheckkernel\n"
fi
# End of 5.2 coding

# To have space
printf "\n\n"

# To have space

printf "============================================================================\n"
printf "6.1 : Configure rsyslog\n"
printf "============================================================================\n"
printf "\n"

# Start of 6.1.1 coding
echo -e "\e[4m6.1.1 : Install the rsyslogpackage\e[0m"
checkrsyslog=`rpm -q rsyslog | grep "^rsyslog"`
if [ -n "$checkrsyslog" ]
then
	printf "\nRsyslog : PASSED (Rsyslog is already installed)"
else
	echo "\nRsyslog : FAILED (Rsyslog is not installed)"
	echo "\nRsyslog service will now be installed"
	yum -y install rsyslog &> /dev/null
	echo "\nRsyslog successfully downloaded"
fi

printf "\n\n\n"

# Start of 6.1.2 coding
echo -e "\e[4m6.1.2 : Activate the rsyslog Service\e[0m"
checkrsysenable=`systemctl is-enabled rsyslog`
if [ "$checkrsysenable" == "enabled" ]
then
	printf "\nRsyslog Enabled - PASSED (Rsyslog is already enabled)"
else
	printf "\nRsyslog Enabled - FAILED (Rsyslog is disabled)"
fi

printf "\n\n\n"
# Start of 6.1.3 coding
echo -e "\e[4m6.1.3 : Configure /etc/rsyslog.conf\e[0m\n"
checkmessages=$(cat /etc/rsyslog.conf | grep "/var/log/messages" | awk -F ' ' '{print $1}')
if [ "$checkmessages" != "auth,user.*" ]
then
	#Change it here (If it is not a null)
	if [ -n "$checkmessages" ]
	then
		sed -i /$checkmessages/d /etc/rsyslog.conf
	fi
		printf "\nauth,user.*	/var/log/messages" >> /etc/rsyslog.conf
		echo "Facility will be now changed to auth,user.* for /var/log/messages.log"
else
	#Correct
	echo "/var/log/messages : PASSED (Facility is configured correctly)"
fi 

checkkern=$(cat /etc/rsyslog.conf | grep "/var/log/kern.log" | awk -F ' ' '{print $1}')
if [ "$checkkern" != "kern.*" ]
then
		printf "\n"
		echo "/var/log/kern.log : FAILED (Facility is configured incorrectly)"
        #Change it here
		if [ -n "$checkkern" ]
		then
        	sed -i /$checkkern/d /etc/rsyslog.conf
		fi
        printf "\nkern.*   /var/log/kern.log" >> /etc/rsyslog.conf
        echo "Facility will be now changed to kern.* for /var/log/kern.log"
else
        #Correct
        echo "/var/log/kern.log : PASSED (Facility is configured correctly)"
fi 


checkdaemon=$(cat /etc/rsyslog.conf | grep "/var/log/daemon.log" | awk -F ' ' '{print $1}')
if [ "$checkdaemon" != "daemon.*" ]
then
		printf "\n"
		echo "/var/log/daemon.log : FAILED (Facility is configured incorrectly)"
        #Change it here
		if [ -n "$checkdaemon" ]
		then
				sed -i /$checkdaemon/d /etc/rsyslog.conf
		fi
		printf "\ndaemon.*   /var/log/daemon.log" >> /etc/rsyslog.conf
        echo "Facility will be now changed to daemon.* for /var/log/daemon.log"
else
        #Correct
        echo "/var/log/daemon.log : PASSED (Facility is configured correctly)"
fi 


checksyslog=$(cat /etc/rsyslog.conf | grep "/var/log/syslog" | awk -F ' ' '{print $1}')
if [ "$checksyslog" != "syslog.*" ]
then
		printf "\n"
		echo "/var/log/syslog.log : FAILED (Facility is configured incorrectly)"
        #Change it here
		if [ -n "$checksyslog" ]
		then
        	sed -i /$checksyslog/d /etc/rsyslog.conf
		fi
        printf "\nsyslog.*   /var/log/syslog.log" >> /etc/rsyslog.conf
        echo "Facility will be now changed to syslog.* for /var/log/syslog.log"
else
        #Correct
        echo "/var/log/syslog : PASSED (Facility is configured correctly)"
fi 


checkunused=$(cat /etc/rsyslog.conf | grep "/var/log/unused.log" | awk -F ' ' '{print $1}')
if [ "$checkunused" != "lpr,news,uucp,local0,local1,local2,local3,local4,local5,local6.*" ]
then
		printf "\n"
		echo "/var/log/unused.log : FAILED (Facility is configured incorrectly)"
        #Change it here
		if [ -n "$checkunused" ]
		then
        	sed -i /$checkunused/d /etc/rsyslog.conf
        fi
		printf "\nlpr,news,uucp,local0,local1,local2,local3,local4,local5,local6.*   /var/log/unused.log" >> /etc/rsyslog.conf
        echo "Facility will be now changed to lpr,news,uucp,local0,local1,local2,local3,local4,local5,local6.* for /var/log/unused.log"
else
        #Correct
        echo "/var/log/unused.log : PASSED (Facility is configured correctly)"
fi

pkill -HUP rsyslogd
# End of 6.1.3 coding

# To have space
printf "\n\n"

# Start of 6.1.4 coding
echo -e "\e[4m6.1.4 : Create and Set Permissions on rsyslog Log Files\e[0m"

checkformsgfile=$(ls /var/log/ | grep messages)
if [ -z "$checkformsgfile" ]
then
	printf "\n/var/log/messages : FAILED (/var/log/messages file does not exist)"
	printf "\nFile will now be created"
	touch /var/log/messages
else
	printf "\n/var/log/messages : PASSED (/var/log/messages file exist)"
fi

checkmsgowngrp=$(ls -l /var/log/messages | awk -F ' ' '{print $3,$4}')
if [ "$checkmsgowngrp" != "root root" ]
then
	#It is configured wrongly
	printf "\n/var/log/messages : FAILED (Owner and Group owner of file is configured wrongly)"
	chown root:root /var/log/messages
	printf "\nOwner and Group owner will now be changed to root root"	
else
	printf "\n/var/log/messages : PASSED (Owner and Group owner of file is configured correctly)"
fi

checkmsgper=$(ls -l /var/log/messages | awk -F ' ' '{print $1}')
if [ "$checkmsgper" != "-rw-------." ]
then
	printf "\n/var/log/messages : FAILED (Permission of file is configured wrongly)"
	chmod og-rwx /var/log/messages
	printf "\nPermission of file will now be changed to 0600"
else
	printf "\n/var/log/messages : PASSED (Permission of file is configured correctly)"
fi

printf "\n"

# kern.log
checkforkernfile=$(ls /var/log/ | grep kern.log)
if [ -z "$checkforkernfile" ]
then
	printf "\n/var/log/kern.log : FAILED (/var/log/kern.log file does not exist)"
	printf "\nFile will now be created"
	touch /var/log/kern.log
else
	printf "\n/var/log/kern.log : PASSED (/var/log/kern.log file exist)"
fi

checkkernowngrp=$(ls -l /var/log/kern.log | awk -F ' ' '{print $3,$4}')
if [ "$checkkernowngrp" != "root root" ]
then
	#It is configured wrongly
	printf "\n/var/log/kern.log : FAILED (Owner and Group owner of file is configured wrongly)"
	chown root:root /var/log/kern.log
	printf "\nOwner and Group owner will now be changed to root root"	
else
	printf "\n/var/log/kern.log : PASSED (Owner and Group owner of file is configured correctly)"
fi

checkkernper=$(ls -l /var/log/kern.log | awk -F ' ' '{print $1}')
if [ "$checkkernper" != "-rw-------." ]
then
	printf "\n/var/log/kern.log : FAILED (Permission of file is configured wrongly)"
	chmod og-rwx /var/log/kern.log
	printf "\nPermission of file will now be changed to 0600"
else
	printf "\n/var/log/kern.log : PASSED (Permission of file is configured correctly)"
fi

printf "\n"

#daemon.log
checkfordaefile=$(ls /var/log/ | grep daemon.log)
if [ -z "$checkfordaefile" ]
then
	printf "\n/var/log/daemon.log : FAILED (/var/log/daemon.log file does not exist)"
	printf "\nFile will now be created"
	touch /var/log/daemon.log
else
	printf "\n/var/log/daemon.log : PASSED (/var/log/daemon.log file exist)"
fi

checkdaeowngrp=$(ls -l /var/log/daemon.log | awk -F ' ' '{print $3,$4}')
if [ "$checkdaeowngrp" != "root root" ]
then
	#It is configured wrongly
	printf "\n/var/log/daemon.log : FAILED (Owner and Group owner of file is configured wrongly)"
	chown root:root /var/log/daemon.log
	printf "\nOwner and Group owner will now be changed to root root"	
else
	printf "\n/var/log/daemon.log : PASSED (Owner and Group owner of file is configured correctly)"
fi

checkdaeper=$(ls -l /var/log/daemon.log | awk -F ' ' '{print $1}')
if [ "$checkdaeper" != "-rw-------." ]
then
	printf "\n/var/log/daemon.log : FAILED (Permission of file is configured wrongly)"
	chmod og-rwx /var/log/daemon.log
	printf "\nPermission of file will now be changed to 0600"
else
	printf "\n/var/log/daemon.log : PASSED (Permission of file is configured correctly)"
fi

printf "\n"

#syslog.log
checkforsysfile=$(ls /var/log/ | grep syslog.log)
if [ -z "$checkforsysfile" ]
then
	printf "\n/var/log/syslog.log : FAILED (/var/log/syslog.log file does not exist)"
	printf "\nFile will now be created"
	touch /var/log/syslog.log
else
	printf "\n/var/log/syslog.log : PASSED (/var/log/syslog.log file exist)"
fi

checksysowngrp=$(ls -l /var/log/syslog.log | awk -F ' ' '{print $3,$4}')
if [ "$checksysowngrp" != "root root" ]
then
	#It is configured wrongly
	printf "\n/var/log/syslog.log : FAILED (Owner and Group owner of file is configured wrongly)"
	chown root:root /var/log/syslog.log
	printf "\nOwner and Group owner will now be changed to root root"	
else
	printf "\n/var/log/syslog.log : PASSED (Owner and Group owner of file is configured correctly)"
fi

checksysper=$(ls -l /var/log/syslog.log | awk -F ' ' '{print $1}')
if [ "$checksysper" != "-rw-------." ]
then
	printf "\n/var/log/syslog.log : FAILED (Permission of file is configured wrongly)"
	chmod og-rwx /var/log/syslog.log
	printf "\nPermission of file will now be changed to 0600"
else
	printf "\n/var/log/syslog.log : PASSED (Permission of file is configured correctly)"
fi

printf "\n"

#unused
checkforunufile=$(ls /var/log/ | grep unused.log)
if [ -z "$checkforunufile" ]
then
	printf "\n/var/log/unused.log : FAILED (/var/log/unused.log file does not exist)"
	printf "\nFile will now be created"
	touch /var/log/unused.log
else
	printf "\n/var/log/unused.log : PASSED (/var/log/unused.log file exist)"
fi

checkunuowngrp=$(ls -l /var/log/unused.log | awk -F ' ' '{print $3,$4}')
if [ "$checkunuowngrp" != "root root" ]
then
	#It is configured wrongly
	printf "\n/var/log/unused.log : FAILED (Owner and Group owner of file is configured wrongly)"
	chown root:root /var/log/unused.log
	printf "\nOwner and Group owner will now be changed to root root"	
else
	printf "\n/var/log/unused.log : PASSED (Owner and Group owner of file is configured correctly)"
fi

checkunuper=$(ls -l /var/log/unused.log | awk -F ' ' '{print $1}')
if [ "$checkunuper" != "-rw-------." ]
then
	printf "\n/var/log/unused.log : FAILED (Permission of file is configured wrongly)"
	chmod og-rwx /var/log/unused.log
	printf "\nPermission of file will now be changed to 0600"
else
	printf "\n/var/log/unused.log : PASSED (Permission of file is configured correctly)"
fi

printf "\n"
# End of 6.1.4 coding

# To have space
printf "\n\n"

# Start of 6.1.5 coding
echo -e "\e[4m6.1.5 : Configure rsyslogto Send Logs to a Remote Log Host\e[0m\n"
checkloghost=$(grep "^*.*[^|][^|]*@" /etc/rsyslog.conf)
if [ -z "$checkloghost" ]  # If there is no log host
then
	printf "Remote Log Host : FAILED (Remote log host has not been configured)\n"
	printf "\nRemote log host will now be configured"
	printf "\n*.* @@logfile.example.com\n" >> /etc/rsyslog.conf
	
else
	printf "Remote Log Host : PASSED (Remote log host has been configured)\n"
fi
# End of 6.1.5 coding

# Start of 6.1.6 coding
printf "\n\n"

echo -e "\e[4m6.1.6 : Accept Remote rsyslog Messages Only on Designated Log Hosts\e[0m"
checkmodload=$(grep '^$ModLoad imtcp.so' /etc/rsyslog.conf)
checkinput=$(grep '^$InputTCPServerRun' /etc/rsyslog.conf)
if [ -z "$checkmodload" ]
then
	# If the thing has been commented out
	printf "\nModLoad imtcp.so : FAILED (ModLoad imtcp is not configured)"
	printf "\n\$ModLoad imtcp.so" >> /etc/rsyslog.conf
	printf "\nModLoad imtcp will now be configured\n"
else
	#If the string has not been commented out
	printf "\nModLoad imtcp : PASSED (ModLoad imtcp is configured)\n"
fi


if [ -z "$checkinput" ]
then
	# If the string has been commented ouit
    printf "\nInputTCPServerRun : FAILED (InputTCPServerRun is not configured)"
	printf "\n\$InputTCPServerRun 514" >> /etc/rsyslog.conf
    printf "\nInputTCPServerRun wil now be configured\n"
else
    #If the string has not been commented out
    printf "\nInputTCPServerRun : PASSED (InputTCPServerRun is configured)\n"
fi
# End of 6.1.6 coding

# To have space
printf "\n\n"

printf "============================================================================\n"
printf "6.2 : Configure System Accounting\n"
printf "============================================================================\n"
printf "\n"
echo "----------------------------------------------------------------------------"
printf "6.2.1 : Configure Data Retention\n"
echo "----------------------------------------------------------------------------"
printf "\n"

#start of 6.2.1.1 coding
echo -e "\e[4m6.2.1.1 : Configure Audit Log Storage Size\e[0m\n"
checkvalue=$(grep -w "max_log_file" /etc/audit/auditd.conf | awk -F ' ' '{print $3}')
if [ "$checkvalue" != "5" ]
then
	printf "Audit Log Storage Size : FAILED (Maximum size of audit log file is configured incorrectly)\n"
	sed -i /$checkvalue/d /etc/audit/auditd.conf
	printf "max_log_file = 5" >> /etc/audit/auditd.conf
	printf "Audit log storage size value will now be configured\n"
else
	printf "Audit Log Storage Size : PASSED (Maximum size of audit log file is configured correctly)\n"
fi

printf "\n\n"
#end of 6.2.1.1 coding


#start of 6.2.1.2 coding
echo -e "\e[4m6.2.1.2 : Keep All Auditing Information\e[0m\n"
checkvalue2=$(grep -w "max_log_file_action" /etc/audit/auditd.conf | awk -F ' ' '{print $3}')
if [ "$checkvalue2" != "keep_logs" ]
then
	printf "Audit Information : FAILED (All audit logs are not retained)\n"
    sed -i /$checkvalue2/d /etc/audit/auditd.conf
    printf "\nmax_log_file_action = keep_logs" >> /etc/audit/auditd.conf
    printf "All audit log files will now be retained\n"
else
    printf "Audit Information: PASSED (Audit logs are retained)\n"
fi

printf "\n\n"
#End of 6.2.1.2 coding


#Start of 6.2.1.3 coding
echo -e "\e[4m6.2.1.3 : Disable System on Audit Log Full\e[0m\n"
checkvalue3=$(grep -w "space_left_action" /etc/audit/auditd.conf | awk -F ' ' '{print $3}')
if [ "$checkvalue3" != "email" ]
then
	printf "Action : FAILED (Action to take on low disk space is configured incorrectly)\n"
    sed -i /$checkvalue3/d /etc/audit/auditd.conf
    printf "\nspace_left_action = email" >> /etc/audit/auditd.conf
    printf "Action to take on low disk space will now be configured\n"
else
    printf "Action : PASSED (Action to take on low disk space is configured correctly)\n"
fi

printf "\n"

checkvalue4=$(grep -w "action_mail_acct" /etc/audit/auditd.conf | awk -F ' ' '{print $3}')
if [ "$checkvalue4" != "root" ]
then
	printf "Email Account : FAILED (Email account specified for warnings to be sent to is configured incorrectly)\n"
    sed -i /$checkvalue4/d /etc/audit/auditd.conf
    printf "\naction_mail_acct = root" >> /etc/audit/auditd.conf
    printf "Email account specified for warnings to be sent to will now be configured\n"
else
    printf "Email Account : PASSED (Email account specified for warnings to be sent to is configured correctly)\n"
fi

printf "\n"

checkvalue5=$(grep -w "admin_space_left_action" /etc/audit/auditd.conf | awk -F ' ' '{print $3}')
if [ "$checkvalue5" != "halt" ]
then
	printf "Admin Action : FAILED (Admin action to take on low disk space is configured incorrectly)\n"
    sed -i /$checkvalue5/d /etc/audit/auditd.conf
    printf "\nadmin_space_left_action = halt" >> /etc/audit/auditd.conf
    printf "Admin action to take on low disk space will now be configured\n"
else
    printf "Admin Action : PASSED (Admin action to take on low disk space is configured correctly)\n"
fi

printf "\n\n"
#End of 6.2.1.3 coding

#Start of 6.2.1.4 coding
echo -e "\e[4m6.2.1.4 : Enable auditd Service\e[0m\n"
checkauditdservice=`systemctl is-enabled auditd`
if [ "$checkauditdservice" == enabled ]
then
	echo "Auditd Service : PASSED (Auditd is enabled)"

else
	echo "Auditd Service : FAILED (Auditd is not enabled)"
	systemctl enable auditd
	echo "Auditd Service is now enabled"
fi
#End of 6.2.1.4 coding

printf "\n\n"

#Start of 6.2.1.5 coding
echo -e "\e[4m6.2.1.5 : Enable Auditing for Processes That Start Prior to auditd\e[0m\n"
checkgrub=$(grep "linux" /boot/grub2/grub.cfg | grep "audit=1") 
if [ -z "$checkgrub" ]
then
	printf "System Log Processes : FAILED (System is not configured to log processes that start prior to auditd\n"
	var="GRUB_CMDLINE_LINUX"
	sed -i /$var/d /etc/default/grub
	printf "GRUB_CMDLINE_LINUX=\"audit=1\"" >> /etc/default/grub
	printf "System will now be configured to log processes that start prior to auditd\n"
	grub2-mkconfig -o /boot/grub2/grub.cfg &> /dev/null
else
	printf "System Log Processes : PASSED (System is configured to log processes that start prior to auditd\n"
fi

#End of 6.2.1.5 coding

printf "\n\n"

#start of 6.2.1.6 coding
echo -e "\e[4m6.2.1.6 : Record Events That Modify Date and Time Information\e[0m\n"
checksystem=`uname -m | grep "64"`
checkmodifydatetimeadjtimex=`egrep 'adjtimex|settimeofday|clock_settime' /etc/audit/audit.rules`
if [ -z "$checksystem" ]
then
	echo "It is a 32-bit system."
	printf "\n"
	if [ -z "$checkmodifydatetimeadjtimex" ]
	then
        echo "Date & Time Modified Events : FAILED (Events where system date and/or time has been modified are not captured)"
        echo "-a always,exit -F arch=b32 -S adjtimex -S settimeofday -S stime -k time-change" >> /etc/audit/rules.d/audit.rules
		echo "-a always,exit -F arch=b32 -S adjtimex -S settimeofday -S stime -k time-change" >> /etc/audit/audit.rules
		echo "-a always,exit -F arch=b32 -S clock_settime -k time-change" >> /etc/audit/rules.d/audit.rules
		echo "-a always,exit -F arch=b32 -S clock_settime -k time-change" >> /etc/audit/audit.rules
		echo "-w /etc/localtime -p wa -k time-change" >> /etc/audit/rules.d/audit.rules
		echo "-w /etc/localtime -p wa -k time-change" >> /etc/audit/audit.rules
        echo "Events where system date and/or time has been modified will now be captured"

	else
		echo "Date & Time Modified Events : PASSED (Events where system date and/or time has been modified are captured)"
	fi

else
	echo "It is a 64-bit system."
	printf "\n"
	if [ -z "$checkmodifydatetimeadjtimex" ]
	then
        echo "Date & Time Modified Events : FAILED (Events where system date and/or time has been modified are not captured)"
		echo "-a always,exit -F arch=b64 -S adjtimex -S settimeofday -k time-change" >> /etc/audit/rules.d/audit.rules
		echo "-a always,exit -F arch=b64 -S adjtimex -S settimeofday -k time-change" >> /etc/audit/audit.rules
        echo "-a always,exit -F arch=b32 -S adjtimex -S settimeofday -S stime -k time-change" >> /etc/audit/rules.d/audit.rules
		echo "-a always,exit -F arch=b32 -S adjtimex -S settimeofday -S stime -k time-change" >> /etc/audit/audit.rules
		echo "-a always,exit -F arch=b64 -S clock_settime -k time-change" >> /etc/audit/rules.d/audit.rules
		echo "-a always,exit -F arch=b64 -S clock_settime -k time-change" >> /etc/audit/audit.rules
        echo "-a always,exit -F arch=b32 -S clock_settime -k time-change" >> /etc/audit/rules.d/audit.rules
		echo "-a always,exit -F arch=b32 -S clock_settime -k time-change" >> /etc/audit/audit.rules
		echo "-w /etc/localtime -p wa -k time-change" >> /etc/audit/rules.d/audit.rules
		echo "-w /etc/localtime -p wa -k time-change" >> /etc/audit/audit.rules
        echo "Events where system date and/or time has been modified will now be captured"

	else
		echo "Date & Time Modified Events : PASSED (Events where system date and/or time has been modified are captured)"
	fi

fi

pkill -P 1 -HUP auditd
#End of 6.2.1.6 coding

printf "\n\n"


#Start of 6.1.2.7 coding
echo -e "\e[4m6.2.1.7 : Record Events That Modify User/Group Information\e[0m\n"
checkmodifyusergroupinfo=`egrep '\/etc\/group' /etc/audit/audit.rules`

if [ -z "$checkmodifyusergroupinfo" ]
then
        echo "Group Configuration - FAILED (Group is not configured)"
        echo "-w /etc/group -p wa -k identity" >> /etc/audit/audit.rules
		echo "-w /etc/group -p wa -k identity" >> /etc/audit/rules.d/audit.rules
        echo "Group will now be configured"

else
        echo "Group Configuration - PASSED (Group is already configured)"
fi

printf "\n"

checkmodifyuserpasswdinfo=`egrep '\/etc\/passwd' /etc/audit/audit.rules`

if [ -z "$checkmodifyuserpasswdinfo" ]
then
        echo "Password Configuration - FAILED (Password is not configured)"
        echo "-w /etc/passwd -p wa -k identity" >> /etc/audit/audit.rules
		echo "-w /etc/passwd -p wa -k identity" >> /etc/audit/rules.d/audit.rules
        echo "Password will now be configured"

else
        echo "Password Configuration - PASSED (Password is configured)"
fi

printf "\n"

checkmodifyusergshadowinfo=`egrep '\/etc\/gshadow' /etc/audit/audit.rules`

if [ -z "$checkmodifyusergshadowinfo" ]
then
        echo "GShadow Configuration - FAILED (GShadow is not configured)"
        echo "-w /etc/gshadow -p wa -k identity" >> /etc/audit/audit.rules
		echo "-w /etc/gshadow -p wa -k identity" >> /etc/audit/rules.d/audit.rules
        echo "GShadow will now be configured"

else
        echo "GShadow Configuration - PASSED (GShadow is configured)"
fi

printf "\n"

checkmodifyusershadowinfo=`egrep '\/etc\/shadow' /etc/audit/audit.rules`

if [ -z "$checkmodifyusershadowinfo" ]
then
        echo "Shadow Configuration - FAILED (Shadow is not configured)"
        echo "-w /etc/shadow -p -k identity" >> /etc/audit/audit.rules
		echo "-w /etc/shadow -p -k identity" >> /etc/audit/rules.d/audit.rules
        echo "Shadow will now be configured"
else
        echo "Shadow Configuration - PASSED (Shadow is configured)"
fi

printf "\n"

checkmodifyuseropasswdinfo=`egrep '\/etc\/security\/opasswd' /etc/audit/audit.rules`

if [ -z "$checkmodifyuseropasswdinfo" ]
then
        echo "OPasswd Configuration- FAILED (OPassword not configured)"
        echo "-w /etc/security/opasswd -p wa -k identity" >> /etc/audit/audit.rules
		echo "-w /etc/security/opasswd -p wa -k identity" >> /etc/audit/rules.d/audit.rules
        echo "OPassword will now be configured"

else
        echo "OPasswd Configuration - PASSED (OPassword is configured)"
fi

pkill -P 1 -HUP auditd
#End of 6.2.1.7 coding

printf "\n\n"

#Start of 6.2.1.8 coding
echo -e "\e[4m6.2.1.8 : Record Events That Modify the System's Network Environment\e[0m\n"
checksystem=`uname -m | grep "64"`
checkmodifynetworkenvironmentname=`egrep 'sethostname|setdomainname' /etc/audit/audit.rules`

if [ -z "$checksystem" ]
then
	echo "It is a 32-bit system."
	printf "\n"
	if [ -z "$checkmodifynetworkenvironmentname" ]
	then
        echo "Modify the System's Network Environment Events : FAILED (Sethostname and setdomainname is not configured)"
        echo "-a always,exit -F arch=b32 -S sethostname -S setdomainname -k system-locale" >> /etc/audit/rules.d/audit.rules
		echo "-a always,exit -F arch=b32 -S sethostname -S setdomainname -k system-locale" >> /etc/audit/audit.rules
        echo "Sethostname and setdomainname will now be configured"

	else
		echo "Modify the System's Network Environment Events : PASSED (Sethostname and setdomainname is configured)"
	fi

else
	echo "It is a 64-bit system."
	printf "\n"
	if [ -z "$checkmodifynetworkenvironmentname" ]
	then
        echo "Modify the System's Network Environment Events : FAILED (Sethostname and setdomainname is not configured)"
        echo "-a always,exit -F arch=b64 -S sethostname -S setdomainname -k system-locale" >> /etc/audit/rules.d/audit.rules
		echo "-a always,exit -F arch=b64 -S sethostname -S setdomainname -k system-locale" >> /etc/audit/audit.rules
		echo "-a always,exit -F arch=b32 -S sethostname -S setdomainname -k system-locale" >> /etc/audit/rules.d/audit.rules
		echo "-a always,exit -F arch=b32 -S sethostname -S setdomainname -k system-locale" >> /etc/audit/audit.rules
        echo "Sethostname will now be configured"

	else
		echo "Modify the System's Network Environment Events : PASSED (Sethostname and setdomainname is configured)"
	fi

fi

printf "\n"

checkmodifynetworkenvironmentissue=`egrep '\/etc\/issue' /etc/audit/audit.rules`

if [ -z "$checkmodifynetworkenvironmentissue" ]
then
       	echo "Modify the System's Network Environment Events : FAILED (/etc/issue is not configured)"
       	echo "-w /etc/issue -p wa -k system-locale" >> /etc/audit/rules.d/audit.rules
		echo "-w /etc/issue -p wa -k system-locale" >> /etc/audit/audit.rules
       	echo "-w /etc/issue.net -p wa -k system-locale" >> /etc/audit/rules.d/audit.rules
		echo "-w /etc/issue.net -p wa -k system-locale" >> /etc/audit/audit.rules
       	echo "/etc/issue will now be configured"

else
       	echo "Modify the System's Network Environment Events : PASSED (/etc/issue is configured)"
fi

printf "\n"

checkmodifynetworkenvironmenthosts=`egrep '\/etc\/hosts' /etc/audit/audit.rules`

if [ -z "$checkmodifynetworkenvironmenthosts" ]
then
       	echo "Modify the System's Network Environment Events : FAILED (/etc/hosts is not configured)"
       	echo "-w /etc/hosts -p wa -k system-locale" >> /etc/audit/rules.d/audit.rules
		echo "-w /etc/hosts -p wa -k system-locale" >> /etc/audit/audit.rules
       	echo "/etc/hosts will now be configured"

else
       	echo "Modify the System's Network Environment Events : PASSED (/etc/hosts is configured)"
fi

printf "\n"

checkmodifynetworkenvironmentnetwork=`egrep '\/etc\/sysconfig\/network' /etc/audit/audit.rules`

if [ -z "$checkmodifynetworkenvironmentnetwork" ]
then
       	echo "Modify the System's Network Environment Events : FAILED (/etc/sysconfig/network is not configured)"
       	echo "-w /etc/sysconfig/network -p wa -k system-locale" >> /etc/audit/rules.d/audit.rules
		echo "-w /etc/sysconfig/network -p wa -k system-locale" >> /etc/audit/audit.rules
       	echo "/etc/sysconfig/network will now be configured"

else
       	echo "Modify the System's Network Environment Events : PASSED (/etc/sysconfig/network is configured)"
fi

pkill -P 1 -HUP auditd
#End of 6.2.1.8 coding

printf "\n\n"

#Start of 6.1.2.9 coding
echo -e "\e[4m6.2.1.9 : Record Events That Modify the System's Mandatory Access Controls\e[0m\n"
var=$(grep \/etc\/selinux /etc/audit/audit.rules)
if [ -z "$var" ]
then
	printf "Monitoring SELinux Mandatory Access Controls : FAILED (/etc/selinux is not configured)\n"
	printf "\n-w /etc/selinux/ -p wa -k MAC-policy" >> /etc/audit/audit.rules
	printf "/etc/selinux will now be configured"
else
	printf "Monitoring SELinux Mandatory Access Controls : PASSED (/etc/selinux is configured)\n"
fi
#End of 6.2.1.9 coding

printf "\n\n"
#To capture escaped strings and close the terminal
read -n 1 -s -r -p "Press any key to exit!"
kill -9 $PPID