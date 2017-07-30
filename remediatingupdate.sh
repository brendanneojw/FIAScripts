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
checksquid1=`systemctl status squid | grep disabled`
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

# Start of 4.1 coding
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
# End of 4.1 coding

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
#-----------------------------------------------------------------------------------------------------------------
#6.2.1.10

loginfail=`grep "\-w /var/log/faillog -p wa -k logins" /etc/audit/audit.rules`
loginlast=`grep "\-w /var/log/lastlog -p wa -k logins" /etc/audit/audit.rules`
logintally=`grep "\-w /var/log/tallylog -p wa -k logins" /etc/audit/audit.rules`

if [ -z "$loginfail" -o -z "$loginlast" -o -z "$logintally" ]
then
	if [ -z "$loginfail" ]
	then
		echo "-w /var/log/faillog -p wa -k logins" >> /etc/audit/audit.rules
	fi
	if [ -z "$loginlast" ]
	then
		echo "-w /var/log/lastlog -p wa -k logins" >> /etc/audit/audit.rules
	fi
	if [ -z "$logintally" ]
	then
		echo "-w /var/log/tallylog -p wa -k logins" >> /etc/audit/audit.rules
	fi
	echo -e "\e[4m6.2.1.10 : Collect Login and Logout Events\e[0m\n"
	echo "Login and Logout Events collected"
fi
	
pkill -P 1 -HUP auditd

#6.2.1.11

sessionwtmp=`egrep '\-w /var/log/wtmp -p wa -k session' /etc/audit/audit.rules`
sessionbtmp=`egrep '\-w /var/log/btmp -p wa -k session' /etc/audit/audit.rules`
sessionutmp=`egrep '\-w /var/run/utmp -p wa -k session' /etc/audit/audit.rules`

if [ -z "$sessionwtmp" -o -z "$sessionbtmp" -o -z "$sessionutmp" ]
then 
	if [ -z "$sessionwtmp"]
	then 
		echo "-w /var/log/wtmp -p wa -k session" >> /etc/audit/audit.rules
	fi
	if [ -z "$sessionbtmp"]
	then 
		echo "-w /var/log/btmp -p wa -k session" >> /etc/audit/audit.rules
	fi
	if [ -z "$sessionutmp"]
	then
		echo "-w /var/run/utmp -p wa -k session" >> /etc/audit/audit.rules
	fi
	echo -e "\e[4m6.2.1.11 : Collect Session Initiation Information\e[0m\n"
	echo "Session Initiation Information Collected"
fi

pkill -HUP -P 1 auditd

#6.2.1.12

permission1=`grep "\-a always,exit -F arch=b64 -S chmod -S fchmod -S fchmodat -F auid>=1000 -F auid!=4294967295 -k perm_mod" /etc/audit/audit.rules`

permission2=`grep "\-a always,exit -F arch=b32 -S chmod -S fchmod -S fchmodat -F auid>=1000 -F auid!=4294967295 -k perm_mod" /etc/audit/audit.rules`

permission3=`grep "\-a always,exit -F arch=b64 -S chown -S fchown -S fchownat -S|chown -F auid>=1000 -F auid!=4294967295 -k perm_mod" /etc/audit/audit.rules`

permission4=`grep "\-a always,exit -F arch=b32 -S chown -S fchown -S fchownat -S|chown -F auid>=1000 -F auid!=4294967295 -k perm_mod" /etc/audit/audit.rules`

permission5=`grep "\-a always,exit -F arch=b64 -S setxattr -S lsetxattr -S fsetxattr -S removexattr -S lremovexattr -S fremovexattr -F auid>=1000 -Fauid!=4294967295 -k perm_mod" /etc/audit/audit.rules`

permission6=`grep "\-a always,exit -F arch=b32 -S setxattr -S lsetxattr -S fsetxattr -S removexattr -S lremovexattr -S fremovexattr -F auid>=1000 -F auid!=4294967295 -k perm_mod" /etc/audit/audit.rules`

if [ -z "$permission1" -o -z "$permission2" -o -z permission3 -o -z permission4 -o -z permission5 -o -z permission6  ]
then 
	if [ -z "$permission1" ]
	then
		echo "-a always,exit -F arch=b64 -S chmod -S fchmod -S fchmodat -F auid>=1000 -F auid!=4294967295 -k perm_mod" >> /etc/audit/audit.rules
	fi

	if [ -z "$permission2" ]
	then 
		echo "-a always,exit -F arch=b32 -S chmod -S fchmod -S fchmodat -F auid>=1000 -F auid!=4294967295 -k perm_mod" >> /etc/audit/audit.rules
	fi
	if [ -z "$permission3" ]
	then 
		echo "-a always,exit -F arch=b64 -S chown -S fchown -S fchownat -S lchown -F auid>=1000 -F auid!=4294967295 -k perm_mod" >> /etc/audit/audit.rules
	fi
	if [ -z "$permission4" ]
	then
		echo "-a always,exit -F arch=b32 -S chown -S fchown -S fchownat -S lchown -F auid>=1000 -F auid!=4294967295 -k perm_mod" >> /etc/audit/audit.rules
	fi
	if [ -z "$permission5" ]
	then 
		echo "-a always,exit -F arch=b64 -S setxattr -S lsetxattr -S fsetxattr -S removexattr -S lremovexattr -S fremovexattr -F auid>=1000 -F auid!=4294967295 -k perm_mod" >> /etc/audit/audit.rules
	fi
	if [ -z "$permission6" ]
	then 
		echo "-a always,exit -F arch=b32 -S setxattr -S lsetxattr -S fsetxattr -S removexattr -S lremovexattr -S fremovexattr -F auid>=1000 -F auid!=4294967295 -k perm_mod" >> /etc/audit/audit.rules
	fi
	echo -e "\e[4m6.2.1.12 : Collect Discretionary Access Control Permission Modification Events\e[0m\n"
	echo "Discretionary Access Control Permission Modification Events Collected"
fi
pkill -P 1 -HUP auditd

#6.2.1.13

access1=`grep "\-a always,exit -F arch=b64 -S creat -S open -S openat -S truncate -S ftruncate -F exit=-EACCES -F auid>=1000 -F auid!=4294967295 - k access" /etc/audit/audit.rules`

access2=`grep "\-a always,exit -F arch=b32 -S creat -S open -S openat -S truncate -S ftruncate -F exit=-EACCES -F auid>=1000 -F auid!=4294967295 - k access" /etc/audit/audit.rules`

access3=`grep "\-a always,exit -F arch=b64 -S creat -S open -S ope
nat -S truncate -S ftruncate -F exit=-EPERM -F auid>=1000 -F auid!=4294967295 - k access" /etc/audit/audit.rules`

access4=`grep "\-a always,exit -F arch=b32 -S creat -S open -S ope
nat -S truncate -S ftruncate -F exit=-EPERM -F auid>=1000 -F auid!=4294967295 - k access" /etc/audit/audit.rules`

access5=`grep "\-a always,exit -F arch=b32 -S creat -S open -S ope
nat -S truncate -S ftruncate -F exit=-EACCES -F auid>=1000 -F auid!=4294967295 - k access" /etc/audit/audit.rules`

access6=`grep "\-a always,exit -F arch=b32 -S creat -S open -S ope
nat -S truncate -S ftruncate -F exit=-EPERM -F auid>=1000 -F auid!=4294967295 - k access" /etc/audit/audit.rules`

if [ -z "$access1" -o -z "$access2" ]
then
	if [ -z "$access1" ]
	then     
   		echo "-a always,exit -F arch=b64 -S creat -S open -S openat -S truncate -S ftruncate -F exit=-EACCES -F auid>=1000 -F auid!=4294967295 - k access" >> /etc/audit/audit.rules
	fi
	if [ -z "$access2" ]
	then 
		echo "-a always,exit -F arch=b32 -S creat -S open -S openat -S truncate -S ftruncate -F exit=-EACCES -F auid>=1000 -F auid!=4294967295 - k access" >> /etc/audit/audit.rules
	fi
	if [ -z "$access3" ]
	then
		echo "-a always,exit -F arch=b64 -S creat -S open -S openat -S truncate -S ftruncate -F exit=-EPERM -F auid>=1000 -F auid!=4294967295 - k access" >>  /etc/audit/audit.rules
	fi
	if [ -z "$access4" ]
	then 
		echo "-a always,exit -F arch=b32 -S creat -S open -S openat -S truncate -S ftruncate -F exit=-EPERM -F auid>=1000 -F auid!=4294967295 - k access" >>  /etc/audit/audit.rules
	fi
	if [ -z "$access5" ]
	then
		echo "-a always,exit -F arch=b32 -S creat -S open -S openat -S truncate -S ftruncate -F exit=-EACCES -F auid>=1000 -F auid!=4294967295 - k access" >>  /etc/audit/audit.rules
	fi
	if [ -z "$access6" ]
	then 
		echo "-a always,exit -F arch=b32 -S creat -S open -S openat -S truncate -S ftruncate -F exit=-EPERM -F auid>=1000 -F auid!=4294967295 - k access" >>  /etc/audit/audit.rules
	fi
	echo -e "\e[4m6.2.1.13 : Collect Unsuccessful Unauthorized Access Attempts to Files\e[0m\n"
	echo "Unsuccessful Unauthorized Access Attempts to Files Collected"
fi

pkill -P 1 -HUP auditd

#6.2.1.14 Collect Use of Privileged Commands

find / -xdev \( -perm -4000 -o -perm -2000 \) -type f | awk '{print "-a always,exit-F path=" $1 " -F perm=x -F auid>=1000 -F auid!=4294967295 -k privileged" }' > /tmp/1.log
checkpriviledge=`cat /tmp/1.log`
cat /etc/audit/audit.rules | grep -- "$checkpriviledge" > /tmp/2.log
checkpriviledgenotinfile=`grep -F -x -v -f /tmp/2.log /tmp/1.log`

if [ -n "$checkpriviledgenotinfile" ]
then
	echo "$checkpriviledgenotinfile" >> /etc/audit/audit.rules
	echo -e "\e[4m6.2.1.14 : Collect Use of Privileged Commands\e[0m\n"
	echo "Use of Privileged Commands Collected"
fi

rm /tmp/1.log
rm /tmp/2.log

#6.2.1.15 Collect Successful File System Mounts

bit64mountb64=`grep "\-a always,exit -F arch=b64 -S mount -F auid>=1000 -F auid!=4294967295 -k mounts" /etc/audit/audit.rules`
bit64mountb32=`grep "\-a always,exit -F arch=b32 -S mount -F auid>=1000 -F auid!=4294967295 -k mounts" /etc/audit/audit.rules`
bit32mountb32=`grep "\-a always,exit -F arch=b32 -S mount -F auid>=1000 -F auid!=4294967295 -k mounts" /etc/audit/audit.rules`

if [ -z "$bit64mountb64" ]
then
	echo "-a always,exit -F arch=b64 -S mount -F auid>=1000 -F auid!=4294967295 -k mounts" >> /etc/audit/audit.rules
	echo -e "\e[4m6.2.1.15 : Collect Successful File System Mounts\e[0m\n"
	echo "Successful File System Mounts Collected"
fi

if [ -z "$bit64mountb32" ]
then
	echo "-a always,exit -F arch=b32 -S mount -F auid>=1000 -F auid!=4294967295 -k mounts" >> /etc/audit/audit.rules
	echo -e "\e[4m6.2.1.15 : Collect Successful File System Mounts\e[0m\n"
	echo "Successful File System Mounts Collected"
fi

pkill -HUP -P 1 auditd

if [ -z "$bit32mountb32" ]
then
	echo "-a always,exit -F arch=b32 -S mount -F auid>=1000 -F auid!=4294967295 -k mounts" >> /etc/audit/audit.rules
	echo -e "\e[4m6.2.1.15 : Collect Successful File System Mounts\e[0m\n"
	echo "Successful File System Mounts Collected"
fi

pkill -HUP -P 1 auditd

#2.6.1.16 Collect File Delection Events by User

bit64delb64=`grep "\-a always,exit -F arch=b64 -S unlink -S unlinkat -S rename -S renameat -F auid>=1000 -F auid!=4294967295 -k delete" /etc/audit/audit.rules`
bit64delb32=`grep "\-a always,exit -F arch=b32 -S unlink -S unlinkat -S rename -S renameat -F auid>=1000 -F auid!=4294967295 -k delete" /etc/audit/audit.rules`
bit32delb32=`grep "\-a always,exit -F arch=b32 -S unlink -S unlinkat -S rename -S renameat -F auid>=1000 -F auid!=4294967295 -k delete" /etc/audit/audit.rules`

if [ -z "$bit64delb64" ]
then
	echo "-a always,exit -F arch=b64 -S unlink -S unlinkat -S rename -S renameat -F auid>=1000 -F auid!=4294967295 -k delete" >> /etc/audit/audit.rules
	echo -e "\e[4m6.2.1.16 : Collect File Delection Events by User\e[0m\n"
	echo "File Delection Events by User Collected"
fi

if [ -z "$bit64delb32" ]
then
	echo "-a always,exit -F arch=b32 -S unlink -S unlinkat -S rename -S renameat -F auid>=1000 -F auid!=4294967295 -k delete" >> /etc/audit/audit.rules
	echo -e "\e[4m6.2.1.16 : Collect File Delection Events by User\e[0m\n"
	echo "File Delection Events by User Collected"
fi

pkill -HUP -P 1 auditd

if [ -z "$bit32delb32" ]
then
	echo "-a always,exit -F arch=b32 -S unlink -S unlinkat -S rename -S renameat -F auid>=1000 -F auid!=4294967295 -k delete" >> /etc/audit/audit.rules
	echo -e "\e[4m6.2.1.16 : Collect File Delection Events by User\e[0m\n"
	echo "File Delection Events by User Collected"
fi

pkill -P 1 -HUP auditd

#6.2.1.17 Collect Changes to System Administrator Scope

sudoers=`grep "\-w /etc/sudoers -p wa -k scope" /etc/audit/audit.rules`

if [ -z "$sudoers" ]
then
	echo "-w /etc/sudoers -p wa -k scope" >> /etc/audit/audit.rules
	echo -e "\e[4m6.2.1.17 : Collect Changes to System Administrator Scope\e[0m\n"
	echo "Changes to System Administrator Scope Collected"
fi
pkill -HUP -P 1 auditd

#6.2.1.18

remauditrules=`grep actions /etc/audit/audit.rules`
auditrules='-w /var/log/sudo.log -p wa -k actions'

if [ -z "$remauditrules" -o "$remauditrules" != "$auditrules" ] 
then
	echo "$auditrules" >> /etc/audit/audit.rules
	echo -e "\e[4m6.2.1.18 : Collect System Administrator Actions\e[0m\n"
	echo "System Administrator Actions Collected"
fi

pkill -HUP -P 1 auditd

#6.2.1.19

remmod1=`grep "\-w /sbin/insmod -p x -k modules" /etc/audit/audit.rules`
remmod2=`grep "\-w /sbin/rmmod -p x -k modules" /etc/audit/audit.rules`
remmod3=`grep "\-w /sbin/modprobe -p x -k modules" /etc/audit/audit.rules`
remmod4=`grep "\-a always,exit -F arch=b64 -S init_module -S delete_module -k modules" /etc/audit/audit.rules`

if [ -z "$remmod1" -o -z "$remmod2" -o -z "$remmod3" -o -z "$remmod4" -o -z "$remmod5" ]
then
	if [ -z "$remmod1" ]
	then
		echo "-w /sbin/insmod -p x -k modules" >> /etc/audit/audit.rules
		echo -e "\e[4m6.2.1.19 : Collect Kernel Module Loading and Unloading\e[0m\n"
		echo "Kernel Module Loading and Unloading Collected"
	fi

	if [ -z "$remmod2" ]
	then	
		echo "-w /sbin/rmmod -p x -k modules" >> /etc/audit/audit.rules
		echo -e "\e[4m6.2.1.19 : Collect Kernel Module Loading and Unloading\e[0m\n"
		echo "Kernel Module Loading and Unloading Collected"
	fi

	if [ -z "$remmod3" ]
	then
		echo "-w /sbin/modprobe -p x -k modules" >> /etc/audit/audit.rules
		echo -e "\e[4m6.2.1.19 : Collect Kernel Module Loading and Unloading\e[0m\n"
		echo "Kernel Module Loading and Unloading Collected"
	fi

	if [ -z "$remmod4" ]
	then
		echo "-a always,exit -F arch=b64 -S init_module -S delete_module -k modules" >> /etc/audit/audit.rules
		echo -e "\e[4m6.2.1.9 : Collect Kernel Module Loading and Unloading\e[0m\n"
		echo "Kernel Module Loading and Unloading Collected"
	fi
fi

#6.2.1.20

remimmute=`grep "^-e 2" /etc/audit/audit.rules`
immute='-e 2'

if [ -z "$remimmute" -o "$remimmute" != "$immute" ]
then
	echo "$immute" >> /etc/audit/audit.rules
	echo -e "\e[4m6.2.1.20 : Make the Audit Configuration Immutable\e[0m\n"
	echo "Audit Configuration is Immutable"
fi

#6.2.1.21

remlogrotate=`grep "/var/log" /etc/logrotate.d/syslog`
logrotate='/var/log/messages /var/log/secure /var/log/maillog /var/log/spooler /var/log/boot.log /var/log/cron {'

if [ -z "$remlogrotate" -o "$remlogrotate" != "$logrotate" ]
then
	rotate1=`grep "/var/log/messages" /etc/logrotate.d/syslog`
	rotate2=`grep "/var/log/secure" /etc/logrotate.d/syslog`
	rotate3=`grep "/var/log/maillog" /etc/logrotate.d/syslog`
	rotate4=`grep "/var/log/spooler" /etc/logrotate.d/syslog`
	rotate5=`grep "/var/log/boot.log" /etc/logrotate.d/syslog`
	rotate6=`grep "/var/log/cron" /etc/logrotate.d/syslog`
	
	if [ -z "$rotate1" ]
	then
		echo "/var/log/messages" >> /etc/logrotate.d/syslog
	fi

	if [ -z "$rotate2" ]
	then
		echo "/var/log/secure" >> /etc/logrotate.d/syslog
	fi

	if [ -z "$rotate3" ]
	then 
		echo "/var/log/maillog" >> /etc/logrotate.d/syslog
	fi

	if [ -z "$rotate4" ]
	then
		echo "/var/log/spooler" >> /etc/logrotate.d/syslog
	fi

	if [ -z "$rotate5" ]
	then
		echo "/var/log/boot.log" >> /etc/logrotate.d/syslog
	fi

	if [ -z "$rotate6" ]
	then
		echo "/var/log/cron" /etc/logrotate.d/syslog
	fi
	echo -e "\e[4m6.2.1.21 : Configure logrotate\e[0m\n"
	echo "logrotate Configured"
fi


# 7.1 Set Password Expiration Days

current=$(cat /etc/login.defs | grep "^PASS_MAX_DAYS" | awk '{ print $2 }')
standard=90 #change this value according to the enterprise's required standard
if [ ! $current = $standard ]; then
	sed -i "s/^PASS_MAX_DAYS.*99999/PASS_MAX_DAYS $standard/" /etc/login.defs | grep "^PASS_MAX_DAYS.*$standard"
	printf "\n"
	echo -e "\e[4m7.1 Set Password Expiration Days\e[0m\n"
	echo "Password Expiration Days have been set"
fi

# 7.2 Set Password Change Minimum Number of Days

current=$(cat /etc/login.defs | grep "^PASS_MIN_DAYS" | awk '{ print $2 }')
standard=7 #change this value according to the enterprise's required standard
if [ ! $current = $standard ]; then
	sed -i "s/^PASS_MIN_DAYS.*0/PASS_MIN_DAYS $standard/" /etc/login.defs | grep "^PASS_MIN_DAYS.*$standard"
	printf "\n"
	echo -e "\e[4m7.2 Set Password Change Minimum Number of Days\e[0m\n"
	echo "Password Change Minimum Days have been set"
fi


# 7.3 Set Password Expiring Warning Days

current=$(cat /etc/login.defs | grep "^PASS_WARN_AGE" | awk '{ print $2 }')
standard=7 #change this value according to the enterprise's required standard
if [ ! $current = $standard ]; then
	sed -i "s/^PASS_WARN_AGE.*0/PASS_WARN_AGE $standard/" /etc/login.defs | grep "^PASS_WARN_AGE.*$standard"
	printf "\n"
	echo -e "\e[4m7.3 Set Password Expiring Warning Days\e[0m\n"
	echo "Password Expiring Warning Days have been set"
fi


# 7.4  Disable System Accounts

for user in `awk -F: '($3 < 1000) { print $1 }' /etc/passwd` ; do 
	if [ $user != "root" ]; then 
		usermod -L $user &> /dev/null 
		if [ $user != "sync" ] && [ $user != "shutdown" ] && [ $user != "halt" ]; then
			usermod -s /sbin/nologin $user &> /dev/null
			fi 
		fi 
	done
printf "\n"
echo -e "\e[4m7.4 Disable System Accounts\e[0m\n"
echo "System Accounts has been disabled"

# 7.5 Set Default Group for root Account

current=$(grep "^root:" /etc/passwd | cut -f4 -d:)
  
if [ "$current" != 0 ]; then
    usermod -g 0 root
	printf "\n"
	echo -e "\e[4m7.5 Set Default Group for root Account\e[0m\n"
    echo "Default Group for root Account is modified successfully"
fi

# 7.6 Set Default umask for Users

remedy=$(egrep -h "\s+umask ([0-7]{3})" /etc/bashrc /etc/profile | awk '{ print $2 }')

if [ "$remedy" != 077 ];then 
	sed -i 's/022/077/g' /etc/profile /etc/bashrc
	sed -i 's/002/077/g' /etc/profile /etc/bashrc
	printf "\n"
	echo -e "\e[4m7.6 Set Default umask for Users\e[0m\n"
	echo "Default umask has been set for Users"
fi

# 7.7 Lock Inactive User Accounts
printf "\n"
echo -e "\e[4m7.7 Lock Inactive User Accounts\e[0m\n"
useradd -D -f 30
echo "Inactive User Accounts has been locked"

# 7.8 Ensure Password Fields are Not Empty
printf "\n"
echo -e "\e[4m7.8 Ensure Password Fields are Not Empty\e[0m\n"

current=$(cat /etc/shadow | awk -F: '($2 == ""){print $1}')

for line in ${current}
do
	/usr/bin/passwd -l ${line}	
done
echo "Password has been set for all users"


# 7.9 Verify No Legacy "+" Entries Exist in /etc/passwd, /etc/shadow and /etc/group files
printf "\n"
echo -e "\e[4m7.9 Verify No Legacy \"+\" Entries Exist in /etc/passwd,/etc/shadow,/etc/group\e[0m\n"


passwd=$(grep '^+:' /etc/passwd)
shadow=$(grep '^+:' /etc/shadow)
group=$(grep '^+:' /etc/group)

for accounts in $passwd
do
  	if [ "$accounts" != "" ];then
                userdel --force $accounts
                groupdel --force $accounts
fi
done
echo "No Legacy \"+\" Entries Exist in /etc/passwd,/etc/shadow,/etc/group"

# 7.10 Verify No UID 0 Accounts Exist Other Than root
printf "\n"
echo -e "\e[4m7.10 Verify No UID 0 Accounts Exist Other Than Root\e[0m\n"


remedy=$(/bin/cat /etc/passwd | /bin/awk -F: '($3 == 0) { print $1 }')

for accounts in $remedy
do
	if [ "$accounts" != "root" ];then
		userdel --force $accounts
		groupdel --force $accounts
fi
done
echo "No UID 0 Accounts Exist Other Than Root"

#-----------------------------------------------------------------------------------------------------------------

count=11
echo "============================================================"
echo -e "\t${bold}7.$count Ensure root PATH Integrity${normal}"
echo "------------------------------------------------------------"

check=0

#Check for Empty Directory in PATH (::)
if [ "`echo $PATH | grep ::`" != "" ]
then
	#echo "Empty Directory in PATH (::)"
	((check++))
fi

#Check for Trailing : in PATH
if [ "`echo $PATH | grep :$`" != "" ]
then
	#echo "Trailing : in PATH"
	((check++))
fi

p=`echo $PATH | sed -e 's/::/:/' -e 's/:$//' -e 's/:/ /g'`
set -- $p
while [ "$1" != "" ]
do
	#Check if PATH contains .
        if [ "$1" = "." ]
        then
		#echo "PATH contains ."
		((check++))
		shift
		continue
        fi
	
	#Check if PATH entry is a directory
        if [ -d $1 ]
        then
                dirperm=`ls -ldH $1 | cut -f1 -d" "`
                #Check if Group Write permission is set on directory
		if [ `echo $dirperm | cut -c6` != "-" ]
                then
			#echo "Group Write permission set on directory $1"
			((check++))
                fi
		#Check if Other Write permission is set on directory
                if [ `echo $dirperm | cut -c9` != "-" ]
		then
			#echo "Other Write permission set on directory $1"
			((check++))
                fi
		
		#Check if PATH entry is owned by root
                dirown=`ls -ldH $1 | awk '{print $3}'`
                if [ "$dirown" != "root" ]
                then
                       #echo $1 is not owned by root
			((check++))
                fi
        else
		#echo $1 is not a directory
		((check++))
        fi
	shift
done

#echo ${check}
if [ ${check} == 0 ]
then
	echo "Result: PASSED! (Path is set correctly)"
	((count++))
elif [ ${check} != 0 ]
then
	echo "Result: FAILED! (Path is not set correctly)"
	((count++))
else
	echo "Result: ERROR, CONTACT SYSTEM ADMINISTRATOR!"
	((count++))
fi
####################################### 7.12 ######################################
echo "========================================================================"
echo -e "\t7.$count Check Permissions on User Home Directories"
echo "------------------------------------------------------------------------"
x=0
while [ $x = 0 ]
do
                intUserAcc="$(/bin/cat /etc/passwd | /bin/egrep -v '(root|halt|sync|shutdown)' | /bin/awk -F: '($7 != "/sbin/nologin"){ print $6 }')"
                if [ -z "$intUserAcc" ]
                then
                        echo "There is no interactive user account."
                        echo ' '
                else
                        /bin/cat /etc/passwd | /bin/egrep -v '(root|halt|sync|shutdown)' | /bin/awk -F: '($7 != "/sbin/nologin"){ print $6 }' | while read -r line; do
                                chmod g-x $line
                                chmod o-rwx $line
                                echo "Directory $line permission is set default."
                        done
                fi
		 x=1
                
done
((count++))
####################################### 7.13 #######################################
echo "========================================================================"
echo -e "\t7.$count Check Permissions on User Home Directories"
echo "------------------------------------------------------------------------"
x=0
while [ $x = 0 ]
do

                intUserAcc="$(/bin/cat /etc/passwd | /bin/egrep -v '(root|halt|sync|shutdown)' | /bin/awk -F: '($7 != "/sbin/nologin"){ print $6 }')"
                if [ -z "$intUserAcc" ]
                then
                        echo "There is no interactive user account."
                        echo ' '
                else
                        /bin/cat /etc/passwd | /bin/egrep -v '(root|halt|sync|shutdown)' | /bin/awk -F: '($7 != "/sbin/nologin"){ print $6 }' | while read -r line; do
                                hiddenfiles="$(echo .*)"

                                if [ -z "$hiddenfiles" ]
                                then
                                        echo "There is no hidden files."
                                else
					for file in ${hiddenfiles[*]}
                                        do
                                                chmod g-w $file
                                                chmod o-w $file
                                                echo "User directory $line hidden file $file permission is set as default"
                                        done
                                fi
                        done
                fi
                x=1
done
((count++))
####################################### 7.14 #######################################
echo "========================================================================"
echo -e "\t7.$count Check Permissions on User Home Directories"
echo "------------------------------------------------------------------------"
x=0
while [ $x = 0 ]
do

                intUserAcc="$(/bin/cat /etc/passwd | /bin/egrep -v '(root|halt|sync|shutdown)' | /bin/awk -F: '($7 != "/sbin/nologin"){ print $6 }')"
                if [ -z "$intUserAcc" ]
                then
                        echo "There is no interactive user account."
                        echo ' '
                else
                        /bin/cat /etc/passwd | /bin/egrep -v '(root|halt|sync|shutdown)' | /bin/awk -F: '($7 != "/sbin/nologin"){ print $6 }' | while read -r line; do
				  permission="$(ls -al $line | grep .netrc)"
                                if [ -z "$permission" ]
                                then
                                        echo "There is no .netrc file in user directory $line"
                                        echo ' '
                                else
                                        ls -al $line | grep .netrc | while read -r netrc; do
                                                for file in $netrc
                                                do

 cd $line

 if [[ $file = *".netrc"* ]]

 then

         chmod go-rwx $file

         echo "User directory $line .netrc file $file permission is set as default"

 fi
                                                done
                                        done
                                fi
                        done
                fi
                x=1
                
done

((count++))
####################################### 7.15 #######################################
echo "========================================================================"
echo -e "\t7.$count Check Permissions on User Home Directories"
echo "------------------------------------------------------------------------"
intUserAcc="$(/bin/cat /etc/passwd | /bin/egrep -v '(root|halt|sync|shutdown)' | /bin/awk -F: '($7 != "/sbin/nologin"){ print $6 }')"
if [ -z "$intUserAcc" ]
then
        #echo "There is no interactive user account."
        echo ''
else
        /bin/cat /etc/passwd | /bin/egrep -v '(root|halt|sync|shutdown)' | /bin/awk -F: '($7 != "/sbin/nologin"){ print $6 }' | while read -r line; do
                #echo "Checking user home directory $line"
		rhostsfile="$(ls -al $line | grep .rhosts)"
                if  [ -z "$rhostsfile" ]
                then
                        #echo " There is no .rhosts file"
                        echo ''
                else
                        ls -al $line | grep .rhosts | while read -r rhosts; do
                                for file in $rhosts
                                do
                                        if [[ $file = *".rhosts"* ]]
                                        then
                                                #echo " Checking .rhosts file $file"
                                                #check if file created user matches directory user
                                                filecreateduser=$(stat -c %U $line/$file)
                                                if [[ $filecreateduser = *"$line"* ]]
                                                then
#echo -e "${GREEN} $file created user is the same user in the directory${NC}"

 echo ''
                                                else

 #echo -e "${RED} $file created user is not the same in the directory. This file should be deleted! ${NC}"

 echo ''
                                                        cd $line

 rm $file
                                                fi
                                        fi
                                done
                        done
                fi
        done
fi
((count++))

####################################### 7.16 ######################################
echo "========================================================================"
echo -e "\t7.$count Check Groups in /etc/passwd"
echo "------------------------------------------------------------------------"
x=0
while [ $x = 0 ]
do
                
		for i in $(cut -s -d: -f4 /etc/passwd | sort -u); do
        		grep -q -P "^.*?:x:$i:" /etc/group
        		if [ $? -ne 0 ]
        		then
					echo -e "${RED}Group $i is referenced by /etc/passwd but does not exist in /etc/group${NC}"
					groupadd -g $i group$i
				fi
		done
		echo -e "${RED}Remediation Finished${NC}"
	x=1
done
((count++))
####################################### 7.17 ######################################
echo "========================================================================"
echo -e "\t7.$count Check That Users Are Assigned Valid Home \n\tDirectories and Home Directory Ownership is Correct"
echo "------------------------------------------------------------------------"

x=0
while [ $x = 0 ]
do
                echo "You choose to assign a home directory for all users without an assigned home directory."
                cat /etc/passwd | awk -F: '{ print $1,$3,$6 }' | while read user uid dir; do
                       if [ "$uid" -ge "500" -a ! -d "$dir" -a "$user" != "nfsnobody" ]
                        then
							mkhomedir_helper $user
                        fi
                done
        x=1
done

echo "Remediation for 7.17 For users without ownership for its home directory"
x=0
while [ $x = 0 ]
do
		cat /etc/passwd | awk -F: '{ print $1,$3,$6 }' | while read user uid dir; do
                        if [ $uid -ge 500 -a -d"$dir" -a $user != "nfsnobody" ]
                        then
				sudo chown $user: $dir
                        fi
                done
	x=1
done
echo "============================================================"
echo -e "\t${bold}7.$count Check for Duplicate UIDs${normal}"
echo "------------------------------------------------------------"
#Get etc/passwd file
cat /etc/passwd| cut -f3 -d":" | sort -n | uniq -c | while read x ; do
[ -z "${x}" ] && break
set - $x
if [ $1 -gt 1 ]; then
#Checks for duplicate UIDs
	users=`/bin/gawk -F: '($3 == n) { print $1 }' n=$2 /etc/passwd| /usr/bin/xargs`
	printf "\e[31mResult: Failed! (Duplicate UID: ($2))\e[0m\n"
else
	printf "\e[32mResult: Passed! (UID: ($2))\e[0m\n"
fi
done
((count++))
echo "============================================================"
echo -e "\t${bold}7.$count Check for Duplicate GIDs${normal}"
echo "------------------------------------------------------------"
printf "Checking for duplicate GIDs\n"
#Get etc/group file
cat /etc/group | cut -f3 -d":" | sort -n | uniq -c | while read x ; do
[ -z "${x}" ] && break
set - $x
if [ $1 -gt 1 ]; then
#Checks for duplicate GIDs
	grps=`/bin/gawk -F: '($3 == n) { print $1 }' n=$2 /etc/group | /usr/bin/xargs`
	printf "\e[31mResult: Failed! (Duplicate GID: ($2))\e[0m\n"
else
	printf "\e[32mResult: Passed! (GID: ($2))\e[0m\n"
fi
done
((count++))
#######################################################################
#7.20 - Check that reserved UIDs are assigned to only system accounts

echo "============================================================"
echo -e "\t${bold}7.$count Check that reserved UIDs are assigned to only system accounts${normal}"
echo "------------------------------------------------------------"

#All System Accounts
checkUsers="root bin daemon adm lp sync shutdown halt mail news uucp operator games gopher ftp nobody nscd vcsa rpc nscd vcsa rpc mailnull smmsp pcap ntp dbus avahi sshd rpcuser nfsnobody haldaemon avahi-autoipd distcache apache oprofile webalizer dovecot squid named xfs gdm sabayon usbmuxd rtkit abrt saslauth pulse postfix tcpdump"
#Checks that reserved UIDs are assigned to system accounts
cat /etc/passwd | awk -F : '($3 < 500) {print $1, $3}' | while read user uid; do found=0
for tUser in ${checkUsers}
	do
		if [ ${user} = ${tUser} ]; then
		found=1
		fi
	done
	if [ $found -eq 0 ]; then
	echo "Result: Failed! (User $user has a reserved UID ($uid))"
	fi
done
((count++))
echo "============================================================"
echo -e "\t${bold}7.$count Check for Duplicate User Names${normal}"
echo "------------------------------------------------------------"
#Get etc/passwd file
cat /etc/passwd | cut -f1 -d":" | /bin/sort -n | /usr/bin/uniq -c | while read x ; do [ -z "${x}" ] && break
set - $x
#Checks for duplicate user names
if [ $1 -gt 1 ]; then
	uids=`/bin/gawk -F: '($1 == n) { print $3 }' n=$2 \/etc/passwd | xargs`
	printf "\e[31mResult: Failed! (Duplicate User Name: $2)\e[0m\n"
else
	printf "\e[32mResult: Passed! ($2)\e[0m\n"
fi
done
((count++))
echo "============================================================"
echo -e "\t${bold}7.$count Check for Duplicate Group Names${normal}"
echo "------------------------------------------------------------"
#Get etc/group file
cat /etc/group | cut -f1 -d":" | /bin/sort -n | /usr/bin/uniq -c | while read x ; do [ -z "${x}" ] && break
set - $x
#Checks for duplicate group names
if [ $1 -gt 1 ]; then
	gids=`/bin/gawk -F: '($1 == n) { print $3 }' n=$2 /etc/group | xargs`
	printf "\e[31mResult: Failed! (Duplicate Group Name: $2)\e[0m\n"
else 
	printf "\e[32mResult: Passed! ($2)\e[0m\n"
fi
	done
((count++))
#7.23 Check for presence of user .forward files
echo ""
echo "========================================================================"
echo -e "\t7.$count Check for Presence of User .forward Files"
echo "------------------------------------------------------------------------"
echo "Checking for presence of user .forward files."

for dir in `/bin/cat /etc/passwd | /bin/awk -F: '{ print $6 }'`; do
if [ ! -h "$dir/.forward" -a -f "$dir/.forward" ]; then
	chmod u=rw- $dir/.forward
	chmod g=--- $dir/.forward
	chmod o=--- $dir/.forward
	echo "Remediation performed for presence of $dir/.forward file."
	echo "$dir/.forward can only be read and written by the owner only now."
fi

done
	echo "Remediation done"
count=1
###############################################################################################################
echo "========================================================================"
echo -e "\t8.$count Set Warning Banner for Standard Login Services"
echo "------------------------------------------------------------------------"
setwarningbanner=`echo "WARNING: UNAUTHORIZED USERS WILL BE PROSECUTED!" > '/etc/motd'`
if $setwarningbanner; then 
	echo "Remediation for 8.$count: Success!"
	((count++))
else 
	echo "Remediation for 8.$count: Failed! (Unable to write to file '/etc/motd')"
	((count++))
fi
###############################################################################################################
printf "\n"
echo "========================================================================"
echo -e "\t8.$count Remove OS Information from Login Warning Banners"
echo "------------------------------------------------------------------------"
current1=$(egrep '(\\v|\\r|\\m|\\s)' /etc/issue)
current2=$(egrep '(\\v|\\r|\\m|\\s)' /etc/motd)
current3=$(egrep  '(\\v|\\r|\\m|\\s)' /etc/issue.net)

string1="\\v"
string2="\\r"
string3="\\m"
string4="\\s"

if [[ $current1 =~ $string1 || $current1 =~ $string2 || $current1 =~ $string3 || $current1 =~ $string4 ]]; then
		 sed -i.bak '/\\v\|\\r\|\\m\|\\s/d' /etc/issue
fi
		echo "(1/3) Remediation for 8.$count: PASSED (Remediated /etc/issue file)"

if [[ $current2 =~ $string1 || $current2 =~ $string2 || $current2 =~ $string3 || $current2 =~ $string4 ]]; then
		 sed -i.bak '/\\v\|\\r\|\\m\|\\s/d' /etc/motd
fi
		 echo "(2/3) Remediation for 8.$count: PASSED (Remediated /etc/motd file)"


if [[ $current3 =~ $string1 || $current3 =~ $string2 || $current3 =~ $string3 || $current4 =~ $string4 ]]; then
        sed -i.bak '/\\v\|\\r\|\\m\|\\s/d' /etc/issue.net
fi
		echo "(3/3) Remediation for 8.$count: PASSED (Remediated /etc/issue.net file)"
count=1
#Check whether Anacron Daemon is installed or not and install if it is found to be uninstalled
printf "\n"
echo "========================================================================"
echo -e "\t9.$count Enable Anacron Daemon"
echo "------------------------------------------------------------------------"
checkanacron=`rpm -q cronie-anacron`
if [ -n "$checkanacron" ] 
then 
    	echo "Remediation for 9.$count: Success!"
else
		echo "Anacron Daemon is not installed! Installing now ..."
    	sudo yum install cronie-anacron -y
		echo "Anacron Daemon is installed!"
		echo "Remediation for 9.$count: Success!"
fi

if [ -n "$checkanacron" ]  #double checking 
then
	:
else
	echo "Remediation for 9.$count: Failed! (Please ensure that yum is available for installation)"
fi
((count++))
printf "\n"
echo "========================================================================"
echo -e "\t9.$count Enable crond Daemon"
echo "------------------------------------------------------------------------"
#Check if Crond Daemon is enabled and enable it if it is not enabled
checkCrondDaemon=$(systemctl is-enabled crond)
if [ "$checkCrondDaemon" = "enabled" ]
then
    	echo "Remediation for 9.$count: Success!"
else
    	systemctl enable crond
	doubleCheckCrondDaemon=$(systemctl is-enabled crond)
	if [ "$doubleCheckCrondDaemon" = "enabled" ]
	then
		:
	else
		echo "Remediation for 9.$count: Failed! (Please ensure that yum is available for installation)"
	fi
fi
((count++))
printf "\n"
echo "========================================================================"
echo -e "\t9.$count Set User/Group Owner and Permission on /etc/anacrontab"
echo "------------------------------------------------------------------------"
#Check if the correct permissions is configured for /etc/anacrontab and configure them if they are not
anacrontabFile="/etc/anacrontab"
anacrontabPerm=$(stat -c "%a" "$anacrontabFile")
anacrontabRegex="^[0-7]00$"
if [[ $anacrontabPerm =~ $anacrontabRegex ]]
then
	echo "(1/3) Remediation for 9.$count - Permissions: Success!"
else
	sudo chmod og-rwx $anacrontabFile
	anacrontabPermCheck=$(stat -c "%a" "$anacrontabFile")
        anacrontabRegexCheck="^[0-7]00$"
	if [[ $anacrontabPermCheck =~ $anacrontabRegexCheck ]]
	then
		:
	else
		echo "(1/3) Remediation for 9.$count - Permissions: Failed! (Permissions for $anacrontabFile cannot be configured as required)"
	fi
fi

anacrontabOwn=$(stat -c "%U" "$anacrontabFile")
if [ $anacrontabOwn = "root" ]
then
	echo "(2/3) Remediation for 9.$count - Owner: Success!"
else
	sudo chown root:root $anacrontabFile
	anacrontabOwnCheck=$(stat -c "%U" "$anacrontabFile")
       	if [ $anacrontabOwnCheck = "root" ]
       	then
                :
	else
		echo "(2/3) Remediation for 9.$count - Owner: Failed! (The owner of the file $anacrontabFile cannot be set as root)"
        fi
fi

anacrontabGrp=$(stat -c "%G" "$anacrontabFile")
if [ $anacrontabGrp = "root" ]
then
	echo "(3/3) Remediation for 9.$count - Group Owner: Success!"
else
	sudo chown root:root $anacrontabFile
	anacrontabGrpCheck=$(stat -c "%G" "$anacrontabFile")
        if [ $anacrontabGrpCheck = "root" ]
	then
		: 
	else
		echo "(3/3) Remediation for 9.$count - Group Owner: Failed! (The group owner of the $anacrontabFile file cannot be set as root)"
        fi
fi
((count++))
printf "\n"
echo "========================================================================"
echo -e "\t9.$count Set User/Group Owner and Permission on /etc/crontab"
echo "------------------------------------------------------------------------"
#Check if the correct permissions has been configured for /etc/crontab and configure them if they are not
crontabFile="/etc/crontab"
crontabPerm=$(stat -c "%a" "$crontabFile")
crontabRegex="^[0-7]00$"
if [[ $crontabPerm =~ $crontabRegex ]]
then
	echo "(1/3) Remediation for 9.$count - Permissions: Success!"
else
	sudo chmod og-rwx $crontabFile
	checkCrontabPerm=$(stat -c "%a" "$crontabFile")
	checkCrontabRegex="^[0-7]00$"
	if [[ $checkCrontabPerm =~ $checkCrontabRegex ]]
	then
		:
	else
		echo "(1/3) Remediation for 9.$count - Permissions: Failed! (Permisions of the file $crontabFile cannot be set as recommended)"
	fi
fi

crontabOwn=$(stat -c "%U" "$crontabFile")
if [ $crontabOwn = "root" ]
then
	echo "(2/3) Remediation for 9.$count - Owner : Success!"
else
	sudo chown root:root $crontabFile
	checkCrontabOwn=$(stat -c "%U" "$crontabFile")
	if [ $checkCrontabOwn = "root" ]
	then
        	:
	else
		echo "(2/3) Remediation for 9.$count - Owner: Failed! (The owner of the file $crontabFile cannot be set as root)"
	fi

fi

crontabGrp=$(stat -c "%G" "$crontabFile")
if [ $crontabGrp = "root" ]
then
	echo "(3/3) Remediation for 9.$count - Group Owner: Success!"
else
	sudo chown root:root $crontabFile
	checkCrontabGrp=$(stat -c "%G" "$crontabFile")
	if [ $checkCrontabGrp = "root" ]
	then
        	:
	else
		echo "(3/3) Remediation for 9.$count - Group Owner: Failed! (The group owner of the $crontabFile file cannot be set as root)"
	fi
fi
((count++))
printf "\n"
echo "========================================================================"
echo -e "\t9.$count Set User/Group Owner and Permission on /etc/cron.\n\t[hourly,daily,weekly,monthly]"
echo "------------------------------------------------------------------------"
#Check if the correct permissions has been set for /etc/cron.XXXX and change them if they are not
patchCronHDWMPerm(){
        local cronHDWMType=$1
        local cronHDWMFile="/etc/cron.$cronHDWMType"

	local cronHDWMPerm=$(stat -c "%a" "$cronHDWMFile")
	local cronHDWMRegex="^[0-7]00$"
	if [[ $cronHDWMPerm =~ $cronHDWMRegex ]]
	then
		echo "(1/3) Remediation for 9.$count - Permissions: Success!"
	else
		sudo chmod og-rwx $cronHDWMFile
		local checkCronHDWMPerm=$(stat -c "%a" "$cronHDWMFile")
	        local checkCronHDWMRegex="^[0-7]00$"
		if [[ $checkCronHDWMPerm =~ $checkCronHDWMRegex ]]
       		then
                	:
       		else
			echo "(1/3) Remediation for 9.$count - Permissions: Failed! (Permissions for the $cronHDWMFile file cannot be set as recommended)"
		fi
	fi

	local cronHDWMOwn="$(stat -c "%U" "$cronHDWMFile")"
	if [ $cronHDWMOwn = "root" ]
        then
		echo "(2/3) Remediation for 9.$count - Owner : Success!"
	else
		sudo chown root:root $cronHDWMFile
		local checkCronHDWMOwn="$(stat -c "%U" "$cronHDWMFile")"
	        if [ $checkCronHDWMOwn = "root" ]
	        then
        	        :
	        else
			echo "(2/3) Remediation for 9.$count - Owner: Failed! (The owner of the file $cronHDWMFile cannot be set as root)"
		fi

	fi

	local cronHDWMGrp="$(stat -c "%G" "$cronHDWMFile")"
        if [ $cronHDWMGrp = "root" ]
        then
		echo "(3/3) Remediation for 9.$count - Group Owner: Success!"
	else
		sudo chown root:root $cronHDWMFile
		local checkCronHDWMGrp="$(stat -c "%G" "$cronHDWMFile")"
	        if [ $checkCronHDWMGrp = "root" ]
	        then
        	        :
       		else
			echo "(3/3) Remediation for 9.$count - Group Owner: Failed! (The group owner of the $cronHDWMFile file cannot be set as root)"
		fi
	fi
}
echo "------------------------------------------------------------------------"
echo -e "\t[Hourly]"
echo "------------------------------------------------------------------------"
patchCronHDWMPerm "hourly"
echo "------------------------------------------------------------------------"
echo -e "\t[Daily]"
echo "------------------------------------------------------------------------"
patchCronHDWMPerm "daily"
echo "------------------------------------------------------------------------"
echo -e "\t[Weekly]"
echo "------------------------------------------------------------------------"
patchCronHDWMPerm "weekly"
echo "------------------------------------------------------------------------"
echo -e "\t[Monthly]"
echo "------------------------------------------------------------------------"
patchCronHDWMPerm "monthly"
((count++))
printf "\n"
#Check if the permissions has been set correctly for /etc/cron.d
echo "========================================================================"
echo -e "\t9.$count Set User/Group Owner and Permission on /etc/cron.d"
echo "------------------------------------------------------------------------"
#Check if the permissions has been set correctly for /etc/cron.d and set them right if they are not
cronDFile="/etc/cron.d"
cronDPerm=$(stat -c "%a" "$cronDFile")
cronDRegex="^[0-7]00$"
if [[ $cronDPerm =~ $cronDRegex ]]
then
	echo "(1/3) Remediation for 9.$count - Permissions: Success!"
else
	sudo chmod og-rwx $cronDFile
	checkCronDPerm=$(stat -c "%a" "$cronDFile")
	checkCronDRegex="^[0-7]00$"
	if [[ $checkCronDPerm =~ $checkCronDRegex ]]
	then
		:
	else
		echo "(1/3) Remediation for 9.$count - Permissions: Failed! (Permisions of the file $cronDFile cannot be set as recommended)"
	fi

fi

cronDOwn=$(stat -c "%U" "$cronDFile")
if [ $cronDOwn = "root" ]
then
	echo "(2/3) Remediation for 9.$count - Owner : Success!"
else
        sudo chown root:root $cronDFile
	checkCronDOwn=$(stat -c "%U" "$cronDFile")
	if [ $checkCronDOwn = "root" ]
	then
        	:
	else
		echo "(2/3) Remediation for 9.$count - Owner: Failed! (The owner of the file $cronDFile cannot be set as root)"
	fi
fi

cronDGrp=$(stat -c "%G" "$cronDFile")
if [ $cronDGrp = "root" ]
then
	echo "(3/3) Remediation for 9.$count - Group Owner: Success!"
else
	sudo chown root:root $cronDFile
	checkCronDGrp=$(stat -c "%G" "$cronDFile")
	if [ $checkCronDGrp = "root" ]
	then
        	:
	else
		echo "(3/3) Remediation for 9.$count - Group Owner: Failed! (The group owner of the $cronDFile file cannot be set as root)"
	fi
fi
((count++))
printf "\n"
echo "========================================================================"
echo -e "\t9.$count Restrict at Daemon"
echo "------------------------------------------------------------------------"
#Check if /etc/at.deny is deleted and that a /etc/at.allow exists and check the permissions of the /e$
atDenyFile="/etc/at.deny"
if [ -e "$atDenyFile" ]
then	
		echo "$atDenyFile exist, deleting now ..."
    	rmdeny=`sudo rm $atDenyFile`
		if "$rmdeny"; then
			echo "(1/4) Remediation for 9.$count: Success! - $atDenyFile is deleted"
		else 
			echo "(1/4) Remediation for 9.$count: Failed! - $atDenyFile cannot be deleted"
		fi
else
    	echo "(1/4) Remediation for 9.$count: Success! - $atDenyFile is deleted or does not exist."
fi

atAllowFile="/etc/at.allow"
if [ -e "$atAllowFile" ]
then
    	atAllowPerm=$(stat -c "%a" "$atAllowFile")
        atAllowRegex="^[0-7]00$"
        if [[ $atAllowPerm =~ $atAllowRegex ]]
        then
            	echo "(2/4) Remediation for 9.$count - Permissions: Success!"
        else
            	sudo chmod og-rwx $atAllowFile
		checkAtAllowPerm=$(stat -c "%a" "$atAllowFile")
	        checkAtAllowRegex="^[0-7]00$"
	        if [[ $checkAtAllowPerm =~ $checkAtAllowRegex ]]	
	        then
        	        :
        	else
			echo "(2/4) Remediation for 9.$count - Permissions: Failed! (Permisions of the file $atAllowFile cannot be set as recommended)"
		fi
        fi

	atAllowOwn=$(stat -c "%U" "$atAllowFile")
        if [ $atAllowOwn = "root" ]
        then
            	echo "(3/4) Remediation for 9.$count - Owner : Success!"
        else
            	sudo chown root:root $atAllowFile
		checkAtAllowOwn=$(stat -c "%U" "$atAllowFile")
	       	if [ $checkAtAllowOwn = "root" ]
	       	then
			:
		else
			echo "(3/4) Remediation for 9.$count - Owner: Failed! (The owner of the file $overallCounter cannot be set as root)"
		fi
        fi

	atAllowGrp=$(stat -c "%G" "$atAllowFile")
        if [ $atAllowGrp = "root" ]
        then
            	echo "(4/4) Remediation for 9.$count - Group Owner: Success!"
        else
            	sudo chown root:root $atAllowFile
		checkAtAllowGrp=$(stat -c "%G" "$atAllowFile")
	        if [ $checkAtAllowGrp = "root" ]
	        then
	                :
        	else
			echo "(4/4) Remediation for 9.$count - Group Owner: Failed! (The group owner of the $atAllowFile file cannot be set as root)"
		fi
        fi
else
    	touch $atAllowFile
	sudo chmod og-rwx $atAllowFile
        checkAtAllowPerm2=$(stat -c "%a" "$atAllowFile")
        checkAtAllowRegex2="^[0-7]00$"
        if [[ $checkAtAllowPerm2 =~ $checkAtAllowRegex2 ]]
        then
		:
	else
		echo "(2/4) Remediation for 9.$count - Permissions: Failed! (Permisions of the file $atAllowFile cannot be set as recommended)"
	fi
	
	sudo chown root:root $atAllowFile
        checkAtAllowOwn2=$(stat -c "%U" "$atAllowFile")
        if [ $checkAtAllowOwn2 = "root" ]
        then
               	:
       	else
                echo "(3/4) Remediation for 9.$count - Owner: Failed! (The owner of the file $overallCounter cannot be set as root)"
       	fi	

	sudo chown root:root $atAllowFile
        checkAtAllowGrp2=$(stat -c "%G" "$atAllowFile")
        if [ $checkAtAllowGrp2 = "root" ]
        then
		:
	else
		echo "(4/4) Remediation for 9.$count - Group Owner: Failed! (The group owner of the $atAllowFile file cannot be set as root)"
	fi
fi
((count++))
echo "========================================================================"
echo -e "\t9.$count Restrict at/cron to Authorized User"
echo "------------------------------------------------------------------------"
#Check if /etc/cron.deny is deleted and that a /etc/cron.allow exists and check the permissions, configure as recommended if found to have not been configured correctly
cronDenyFile="/etc/cron.deny"
if [ -e "$cronDenyFile" ]
then
		echo "$cronDenyFile exist, deleting now ..."
    	rmdenycron=`sudo rm $cronDenyFile`
		if "$rmdenycron"; then
			echo "(1/4) Remediation for 9.$count: Success! - $atDenyFile is deleted"
		else 
			echo "(1/4) Remediation for 9.$count: Failed! - $atDenyFile cannot be deleted"
		fi
else
    	echo "(1/4) Remediation for 9.$count: Success! - $atDenyFile is deleted or does not exist"
fi

cronAllowFile="/etc/cron.allow"
if [ -e "$cronAllowFile" ]
then
        cronAllowPerm=$(stat -c "%a" "$cronAllowFile")
        cronAllowRegex="^[0-7]00$"
       	if [[ $cronAllowPerm =~ $cronAllowRegex ]]
    	then
                echo "(2/4) Remediation for 9.$count - Permissions: Success!"
        else
            	sudo chmod og-rwx $cronAllowFile
               	checkCronAllowPerm=$(stat -c "%a" "$atAllowFile")
            	checkCronAllowRegex="^[0-7]00$"
               	if [[ $checkCronAllowPerm =~ $checkCronAllowRegex ]]
               	then
                       	:
               	else
                        echo "(2/4) Remediation for 9.$count - Permissions: Failed! (Permisions of the file $cronAllowFile cannot be set as recommended)"
                fi
       	fi

	cronAllowOwn=$(stat -c "%U" "$cronAllowFile")
        if [ $cronAllowOwn = "root" ]
        then
            	echo "(3/4) Remediation for 9.$count - Owner : Success!"
        else
            	sudo chown root:root $cronAllowFile
                checkCronAllowOwn=$(stat -c "%U" "$cronAllowFile")
                if [ $checkCronAllowOwn = "root" ]
                then
                    	:
                else
                        echo "(3/4) Remediation for 9.$count - Owner: Failed! (The owner of the file $cronAllowFile cannot be set as root)"
                fi
        fi

	cronAllowGrp=$(stat -c "%G" "$cronAllowFile")
        if [ $cronAllowGrp = "root" ]
        then
            	echo "(4/4) Remediation for 9.$count - Group Owner: Success!"
        else
            	sudo chown root:root $cronAllowFile
                checkCronAllowGrp=$(stat -c "%G" "$cronAllowFile")
                if [ $checkCronAllowGrp = "root" ]
                then
                    	:
                else
                        echo "(4/4) Remediation for 9.$count - Group Owner: Failed! (The group owner of the $cronAllowFile file cannot be set as root)"
                fi
        fi
else
	touch $cronAllowFile
        sudo chmod og-rwx $cronAllowFile
        checkCronAllowPerm2=$(stat -c "%a" "$cronAllowFile")
        checkCronAllowRegex2="^[0-7]00$"
        if [[ $checkCronAllowPerm2 =~ $checkCronAllowRegex2 ]]
        then
            	:
        else
                echo "(2/4) Remediation for 9.$count - Permissions: Failed! (Permisions of the file $cronAllowFile cannot be set as recommended)"
        fi

        sudo chown root:root $cronAllowFile
        checkCronAllowOwn2=$(stat -c "%U" "$cronAllowFile")
        if [ $checkCronAllowOwn2 = "root" ]
        then
            	:
        else
                echo "(3/4) Remediation for 9.$count - Owner: Failed! (The owner of the file $cronAllowFile cannot be set as root)"
        fi

	sudo chown root:root $cronAllowFile
	checkCronAllowGrp2=$(stat -c "%G" "$cronAllowFile")
        if [ $checkCronAllowGrp2 = "root" ]
        then
            	:
        else
		echo "(4/4) Remediation for 9.$count - Group Owner: Failed! (The group owner of the $cronAllowFile file cannot be set as root)"
	fi
fi

#10.1 Set SSH Protocol to 2
echo -e "\e[4m10.1 : Set SSH Protocol to 2\e[0m\n"
remsshprotocol=`grep "^Protocol 2" /etc/ssh/sshd_config`
if [ "$remsshprotocol" != "Protocol 2" ]
then
	sed -ie "23s/#//" /etc/ssh/sshd_config
	echo "SSH Protocol has been set to 2"
	printf "\n"
else
	echo "SSH Protocol has already been set to 2, " 
	echo "hence no action will be taken"
	printf "\n"
fi

#10.2 Set LogLevel to INFO
echo -e "\e[4m10.2 : Set LogLevel to INFO\e[0m\n"
remsshloglevel=`grep "^LogLevel" /etc/ssh/sshd_config`
if [ "$remsshloglevel" != "LogLevel INFO" ]
then
	sed -ie "43s/#//" /etc/ssh/sshd_config
	echo "LogLevel has been set to INFO"
	printf "\n"
else
	echo "LogLevel has already been set to INFO, " 
	echo "hence no action will be taken"
	printf "\n"
fi

#10.3 Set Permissions on /etc/ssh/shd_config
echo -e "\e[4m10.3 : Set Permissions on /etc/ssh/shd_config\e[0m\n"
remdeterusergroupownership=`grep "^LogLevel" /etc/ssh/sshd_config`
if [ -z "$remdeterusergroupownership" ]
then
	chown root:root /etc/ssh/sshd_config
	chmod 600 /etc/ssh/sshd_config
	echo "Permissions have been configured"
	printf "\n"
else
	echo "Permissions have already been configiured correctly, "
	echo "hence no action will be taken"
	printf "\n"
fi

#10.4 Disable SSH X11 Forwarding
echo -e "\e[4m10.4 : Disable SSH X11 Forwarding\e[0m\n"
remsshx11forwarding=`grep "^X11Forwarding" /etc/ssh/sshd_config`
if [ "$remsshx11forwarding" != "X11Forwarding no" ]
then
	sed -ie "116s/#//" /etc/ssh/sshd_config
	sed -ie "117s/^/#/" /etc/ssh/sshd_config
	echo "SSH X11 Forwarding has been disabled"
	printf "\n"
else
	echo "SSH X11 Forwarding has already been disabled, "
	echo "hence no action will be taken"
	printf "\n"
fi

#10.5 Set SSH MaxAuthTries to 4 or Less
echo -e "\e[4m10.5 : Set SSH MaxAuthTries to 4 or Less\e[0m\n"
maxauthtries=`grep "^MaxAuthTries 4" /etc/ssh/sshd_config`
if [ "$maxauthtries" != "MaxAuthTries 4" ]
then
	sed -ie "50d" /etc/ssh/sshd_config
	sed -ie "50iMaxAuthTries 4" /etc/ssh/sshd_config
	echo "MaxAuthTries has been set to 4"
	printf "\n"
else
	echo "MaxAuthTries has already been set to 4, "
	echo "hence no action will be taken"
	printf "\n"
fi

#10.6 Set SSH IgnoreRhosts to Yes
echo -e "\e[4m10.6 : Set SSH IgnoreRhosts to Yes\e[0m\n"
ignorerhosts=`grep "^IgnoreRhosts" /etc/ssh/sshd_config`
if [ "$ignorerhosts" != "IgnoreRhosts yes" ]
then
	sed -ie "73d" /etc/ssh/sshd_config
	sed -ie "73iIgnoreRhosts yes" /etc/ssh/sshd_config
	echo "SSH IgnoreRhosts has been set to Yes"
	printf "\n"
else
	echo "SSH IgnoreRhosts has already been set to Yes, "
	echo "hence no action will be taken "
	printf "\n"
fi

#10.7 Set SSH HostbasedAuthentication to No
echo -e "\e[4m10.7 : Set SSH HostbasedAuthentication to No\e[0m\n"
hostbasedauthentication=`grep "^HostbasedAuthentication" /etc/ssh/sshd_config`
if [ "$hostbasedauthentication" != "HostbasedAuthentication no" ]
then
	sed -ie "68d" /etc/ssh/sshd_config
	sed -ie "68iHostbasedAuthentication no" /etc/ssh/sshd_config
	echo "SSH HostbasedAuthentication has been set to No"
	printf "\n"
else
	echo "SSH HostbasedAuthentication has already been set to No, "
	echo "hence no action will be taken"
	printf "\n"
fi

#10.8 Disable SSH Root Login
echo -e "\e[4m10.8 : Disable SSH Root Login\e[0m\n"
remsshrootlogin=`grep "^PermitRootLogin" /etc/ssh/sshd_config`
if [ "$remsshrootlogin" != "PermitRootLogin no" ]
then
	sed -ie "48d" /etc/ssh/sshd_config
	sed -ie "48iPermitRootLogin no" /etc/ssh/sshd_config
	echo "SSH Root Login has been disabled"
	printf "\n"
else
	echo "SSH Root Login has already been disabled, "
	echo "hence no action will be taken"
	printf "\n"
fi

#10.9 Set SSH PermitEmptyPasswords to No
echo -e "\e[4m10.9 : Set SSH PermitEmptyPasswords to No\e[0m\n"
remsshemptypswd=`grep "^PermitEmptyPasswords" /etc/ssh/sshd_config`
if [ "$remsshemptypswd" != "PermitEmptyPasswords no" ]
then
	sed -ie "77d" /etc/ssh/sshd_config
	sed -ie "77iPermitEmptyPasswords no" /etc/ssh/sshd_config
	echo "SSH PermitEmptyPasswords has been set to No"
	printf "\n"
else
	echo "SSH PermitEmptyPasswords has already been set to No, "
	echo "hence no action will be taken"
	printf "\n"
fi

#10.10 Use Only Approved cipher in Counter Mode
echo -e "\e[4m10.10 : Set SSH PermitEmptyPasswords to No\e[0m\n"
remsshcipher=`grep "Ciphers" /etc/ssh/sshd_config`
if [ "$remsshcipher" != "Ciphers aes128-ctr,aes192-ctr,aes256-ctr" ]
then
	sed -ie "36d" /etc/ssh/sshd_config
	sed -ie "36iCiphers aes128-ctr,aes192-ctr,aes256-ctr" /etc/ssh/sshd_config
	echo "Approved Ciphers have been set"
	printf "\n"
else
	echo "Approved Ciphers have already been set, "
	echo "hence no action will be taken"
	printf "\n"
fi

#10.11 Set Idle Timeout Internval for User Login
echo -e "\e[4m10.11 : Set Idle Timeout Interval for User Login\e[0m\n"
remsshcai=`grep "^ClientAliveInterval" /etc/ssh/sshd_config`
remsshcacm=`grep "^ClientAliveCountMax" /etc/ssh/sshd_config`

if [ "$remsshcai" != "ClientAliveInterval 300" ]
then
	sed -ie "127d" /etc/ssh/sshd_config
	sed -ie "127iClientAliveInterval 300" /etc/ssh/sshd_config
	echo "ClientAliveInterval has been set to 300"
	printf "\n"
else
	echo "ClientAliveInterval has already been set to 300, "
	echo "hence no action will be taken"
	printf "\n"
fi

if [ "$remsshcacm" != "ClientAliveCountMax 0" ]
then
	sed -ie "128d" /etc/ssh/sshd_config
	sed -ie "128iClientAliveCountMax 0" /etc/ssh/sshd_config
	echo "ClientAliveCountMax has been set to 0"
	printf "\n"
else
	echo "ClientAliveCountMax has already been set to 0, "
	echo "hence no action will be taken"
	printf "\n"
fi

#10.12 Limit Access via SSH	
echo -e "\e[4m10.12 : Limit Access via SSH\e[0m\n"
remsshalwusrs=`grep "^AllowUsers" /etc/ssh/sshd_config`
remsshalwgrps=`grep "^AllowGroups" /etc/ssh/sshd_config`
remsshdnyusrs=`grep "^DenyUsers" /etc/ssh/sshd_config`
remsshdnygrps=`grep "^DenyGroups" /etc/ssh/sshd_config`

if [ -z "$remsshalwusrs" -o "$remsshalwusrs" == "AllowUsers[[:space:]]" ]
then
	echo "AllowUsers user1" >> /etc/ssh/sshd_config
	echo "User: user1 is now able to access the system via SSH"
	printf "\n"
else
	echo "User: user1 is already able to access the system via SSH, "
	echo "hence no action will be taken"
	printf "\n"
fi

if [ -z "$remsshalwgrps" -o "$remsshalwgrps" == "AllowUsers[[:space:]]" ]
then
	echo "AllowGroups group1" >> /etc/ssh/sshd_config
	echo "Group: group1 is now able to access the system via SSH"
	printf "\n"
else
	echo "Group: group1 is already able to access the system via SSH, "
	echo "hence no action will be taken"
	printf "\n"
fi

if [ -z "$remsshdnyusrs" -o "$remsshdnyusrs" == "AllowUsers[[:space:]]" ]
then
	echo "DenyUsers user2 user3" >> /etc/ssh/sshd_config
	echo "User: user2 and user3 are now not able to access the system via SSH"
	printf "\n"
else
	echo "User: user2 and user3 are already not able to access the system via SSH, "
	echo "hence no action will be taken"
	printf "\n"
fi

if [ -z "$remsshdnygrps" -o "$remsshdnygrps" == "AllowUsers[[:space:]]" ]
then
	echo "DenyGroups group2" >> /etc/ssh/sshd_config
	echo "Group: group2 is now not able to access the system via SSH"
	printf "\n"
else
	echo "Group: group2 is already not able to access the system via SSH, "
	echo "hence no action will be taken"
	printf "\n"
fi

#10.13 Set SSH Banner
echo -e "\e[4m10.13 : Set SSH Banner\e[0m\n"	
remsshbanner=`grep "Banner" /etc/ssh/sshd_config | awk '{ print $2 }'`

if [ "$remsshbanner" == "/etc/issue.net" -o "$remsshbanner" == "/etc/issue" ]
then
	echo "SSH Banner has already been set, "
	echo "hence no action will be taken"
	printf "\n"
else
	sed -ie "138d" /etc/ssh/sshd_config
	sed -ie "138iBanner /etc/issue.net" /etc/ssh/sshd_config
	echo "SSH Banner has been set"
	printf "\n"
fi 

#11.1 Upgrade Password Hashing Algorithm to SHA-512
echo -e "\e[4m11.1 : Upgrade Password Hashing Algorithm to SHA-512\e[0m\n"
checkPassAlgo=$(authconfig --test | grep hashing | grep sha512)
checkPassRegex=".*sha512"
if [[ $checkPassAlgo =~ $checkPassRegex ]]
then
    	echo "The password hashing algorithm is set to SHA-512 as recommended."
		printf "\n"
else
    	authconfig --passalgo=sha512 --update
	doubleCheckPassAlgo2=$(authconfig --test | grep hashing | grep sha512)
	doubleCheckPassRegex2=".*sha512"
	if [[ $doubleCheckPassAlgo2 =~ $doubleCheckPassRegex2 ]]
	then
    		echo "The password hashing algorithm is set to SHA-512 as recommended."
			printf "\n"
		cat /etc/passwd | awk -F: '($3 >= 1000 && $1 != "test") { print $1 }' | xargs -n 1 chage -d 0
		if [ $? -eq 0 ]
		then
			echo "Users will be required to change their password upon the next log in session."
			printf "\n"
		else
			echo "It seems as if error has occured and that the userID cannot be immediately expired. After a password hashing algorithm update, it is essential to ensure that all the users have changed their passwords."
			printf "\n"
		fi
	else
		echo "It seems as if an error has occured and the password hashing algorithm cannot be set as SHA-512."
		printf "\n"
	fi
fi

#11.2 Set Password Creation Requirement Parameters Using pam_pwquality
echo -e "\e[4m11.2 : Set Password Creation Requirement Parameters Using pam_pwquality\e[0m\n"
pampwquality=$(grep pam_pwquality.so /etc/pam.d/system-auth)
pampwqualityrequisite=$(grep "password    requisite" /etc/pam.d/system-auth)
correctpampwquality="password    requisite     pam_pwquality.so try_first_pass local_users_only retry=3 authtok_type="
if [[ $pampwquality == $correctpampwquality ]]
then
	#echo "No remediation needed."
	echo "Password Creation Requirement Parameters (/etc/pam.d/system-auth) have been set, hence no action will be taken"
	printf "\n"
else
	if [[ -n $pampwqualityrequisite ]]
	then
		sed -i 's/.*requisite.*/password    requisite     pam_pwquality.so try_first_pass local_users_only retry=3 authtok_type=/' /etc/pam.d/system-auth
		#echo "Remediation completed."
		echo "/etc/pam.d/system-auth has been Updated"
		printf "\n"
	else
		echo $correctpampwquality >> /etc/pam.d/system-auth
		#echo "Remediation completed."
		echo "/etc/pam.d/system-auth has been Updated"
		printf "\n"
	fi
fi

minlen=$(grep "minlen" /etc/security/pwquality.conf)
dcredit=$(grep "dcredit" /etc/security/pwquality.conf)
ucredit=$(grep "ucredit" /etc/security/pwquality.conf)
ocredit=$(grep "ocredit" /etc/security/pwquality.conf)
lcredit=$(grep "lcredit" /etc/security/pwquality.conf)
correctminlen="# minlen = 14"
correctdcredit="# dcredit = -1"
correctucredit="# ucredit = -1"
correctocredit="# ocredit = -1"
correctlcredit="# lcredit = -1"

if [[ $minlen == $correctminlen && $dcredit == $correctdcredit && $ucredit == $correctucredit && $ocredit == $correctocredit && $lcredit == $correctlcredit ]]
then
	#echo "No Remediation needed."
	echo "Password Creation Requirement Parameters (/etc/security/pwquality.conf) have been set, hence no action will be taken"
	printf "\n"
else
	sed -i -e 's/.*minlen.*/# minlen = 14/' -e 's/.*dcredit.*/# dcredit = -1/' -e  's/.*ucredit.*/# ucredit = -1/' -e 's/.*ocredit.*/# ocredit = -1/' -e 's/.*lcredit.*/# lcredit = -1/' /etc/security/pwquality.conf
	#echo "Remediation completed."
	echo "/etc/security/pwquality.conf has been Updated"
	printf "\n"
fi

#11.3 Set Lockout for Failed Password Attempts
echo -e "\e[4m11.3 : Set Lockout for Failed Password Attempts\e[0m\n"
faillockpassword=$(grep "pam_faillock" /etc/pam.d/password-auth)
faillocksystem=$(grep "pam_faillock" /etc/pam.d/system-auth)

read -d '' correctpamauth << "BLOCK"
auth        required      pam_faillock.so preauth silent audit deny=5 unlock_time=900
auth        [default=die] pam_faillock.so authfail audit deny=5
auth        sufficient    pam_faillock.so authsucc audit deny=5
account     required      pam_faillock.so
BLOCK


if [[ $faillocksystem == "$correctpamauth" && $faillockpassword == "$correctpamauth" ]]
then
	#echo "No remediation needed."
	echo "Lockout for Failed Password Attempts is already set, hence no action will be taken"
	printf "\n"
elif [[ $faillocksystem == "$correctpamauth" && $faillockpassword != "$correctpamauth" ]]
then
	if [[ -n $faillockpassword ]]
	then
		sed -i '/pam_faillock.so/d' /etc/pam.d/password-auth
		sed -i -e '5i auth        required      pam_faillock.so preauth silent audit deny=5 unlock_time=900' -e '7i auth        [default=die] pam_faillock.so authfail audit deny=5' -e '8i auth        sufficient    pam_faillock.so authsucc audit deny=5' -e '10i account     required      pam_faillock.so' /etc/pam.d/password-auth
		#echo "Remediation completed."
		echo "Lockout for Failed Password Attempts has been set"
		printf "\n"
	else
		sed -i -e '5i auth        required      pam_faillock.so preauth silent audit deny=5 unlock_time=900' -e '7i auth        [default=die] pam_faillock.so authfail audit deny=5' -e '8i auth        sufficient    pam_faillock.so authsucc audit deny=5' -e '10i account     required      pam_faillock.so' /etc/pam.d/password-auth
		#echo "Remediation completed."
		echo "Lockout for Failed Password Attempts has been set"
		printf "\n"
	fi
elif [[ $faillocksystem != "$correctpamauth" && $faillockpassword == "$correctpamauth" ]]
then
	if [[ -n $faillocksystem ]]
	then
		sed -i '/pam_faillock.so/d' /etc/pam.d/system-auth
		sed -i -e '5i auth        required      pam_faillock.so preauth silent audit deny=5 unlock_time=900' -e '7i auth        [default=die] pam_faillock.so authfail audit deny=5' -e '8i auth        sufficient    pam_faillock.so authsucc audit deny=5' -e '10i account     required      pam_faillock.so' /etc/pam.d/system-auth
		#echo "Remediation completed."
		echo "Lockout for Failed Password Attempts has been set"
		printf "\n"
	else
		sed -i -e '5i auth        required      pam_faillock.so preauth silent audit deny=5 unlock_time=900' -e '7i auth        [default=die] pam_faillock.so authfail audit deny=5' -e '8i auth        sufficient    pam_faillock.so authsucc audit deny=5' -e '10i account     required      pam_faillock.so' /etc/pam.d/system-auth
		#echo "Remediation completed."
		echo "Lockout for Failed Password Attempts has been set"
		printf "\n"
	fi
else
	if [[ -n $faillocksystem && -z $faillockpassword ]]
	then
		sed -i '/pam_faillock.so/d' /etc/pam.d/system-auth
		sed -i -e '5i auth        required      pam_faillock.so preauth silent audit deny=5 unlock_time=900' -e '7i auth        [default=die] pam_faillock.so authfail audit deny=5' -e '8i auth        sufficient    pam_faillock.so authsucc audit deny=5' -e '10i account     required      pam_faillock.so' /etc/pam.d/system-auth
		sed -i -e '5i auth        required      pam_faillock.so preauth silent audit deny=5 unlock_time=900' -e '7i auth        [default=die] pam_faillock.so authfail audit deny=5' -e '8i auth        sufficient    pam_faillock.so authsucc audit deny=5' -e '10i account     required      pam_faillock.so' /etc/pam.d/password-auth
		#echo "Remediation completed."
		echo "Lockout for Failed Password Attempts has been set"
		printf "\n"
	elif [[ -z $faillocksystem && -n $faillockpassword ]]
	then
		sed -i '/pam_faillock.so/d' /etc/pam.d/password-auth
		sed -i -e '5i auth        required      pam_faillock.so preauth silent audit deny=5 unlock_time=900' -e '7i auth        [default=die] pam_faillock.so authfail audit deny=5' -e '8i auth        sufficient    pam_faillock.so authsucc audit deny=5' -e '10i account     required      pam_faillock.so' /etc/pam.d/password-auth
		sed -i -e '5i auth        required      pam_faillock.so preauth silent audit deny=5 unlock_time=900' -e '7i auth        [default=die] pam_faillock.so authfail audit deny=5' -e '8i auth        sufficient    pam_faillock.so authsucc audit deny=5' -e '10i account     required      pam_faillock.so' /etc/pam.d/system-auth
		#echo "Remediation completed."
		echo "Lockout for Failed Password Attempts has been set"
		printf "\n"
	elif [[ -n $faillocksystem && -n $faillockpassword ]]
	then
		sed -i '/pam_faillock.so/d' /etc/pam.d/system-auth
		sed -i -e '5i auth        required      pam_faillock.so preauth silent audit deny=5 unlock_time=900' -e '7i auth        [default=die] pam_faillock.so authfail audit deny=5' -e '8i auth        sufficient    pam_faillock.so authsucc audit deny=5' -e '10i account     required      pam_faillock.so' /etc/pam.d/system-auth
		sed -i '/pam_faillock.so/d' /etc/pam.d/password-auth
		sed -i -e '5i auth        required      pam_faillock.so preauth silent audit deny=5 unlock_time=900' -e '7i auth        [default=die] pam_faillock.so authfail audit deny=5' -e '8i auth        sufficient    pam_faillock.so authsucc audit deny=5' -e '10i account     required      pam_faillock.so' /etc/pam.d/password-auth
		#echo "Remediation completed."
		echo "Lockout for Failed Password Attempts has been set"
		printf "\n"
	else
		sed -i -e '5i auth        required      pam_faillock.so preauth silent audit deny=5 unlock_time=900' -e '7i auth        [default=die] pam_faillock.so authfail audit deny=5' -e '8i auth        sufficient    pam_faillock.so authsucc audit deny=5' -e '10i account     required      pam_faillock.so' /etc/pam.d/system-auth
		sed -i -e '5i auth        required      pam_faillock.so preauth silent audit deny=5 unlock_time=900' -e '7i auth        [default=die] pam_faillock.so authfail audit deny=5' -e '8i auth        sufficient    pam_faillock.so authsucc audit deny=5' -e '10i account     required      pam_faillock.so' /etc/pam.d/password-auth
		#echo "Remediation completed."
		echo "Lockout for Failed Password Attempts has been set"
		printf "\n"
	fi
fi

#11.4 Limit Password Reuse
echo -e "\e[4m11.4 : Limit Password Reuse\e[0m\n"
pamlimitpw=$(grep "remember" /etc/pam.d/system-auth)
existingpamlimitpw=$(grep "password.*sufficient" /etc/pam.d/system-auth)
if [[ $pamlimitpw == *"remember=5"* ]]
then
	#echo "No remediation needed."
	echo "Password Reuse Limit has been set, hence no action will be taken"
	printf "\n"
else
	if [[ -n $existingpamlimitpw ]]
	then
		sed -i 's/password.*sufficient.*/password    sufficient    pam_unix.so sha512 shadow nullok remember=5 try_first_pass use_authtok/' /etc/pam.d/system-auth
		#echo "Remediation completed."
		echo "Password Reuse Limit has been set"
		printf "\n"
	else
		sed -i '/password/a password sufficient pam_unix.so remember=5' /etc/pam.d/system-auth
		#echo "Remediation completed."
		echo "Password Reuse Limit has been set"
		printf "\n"
	fi
fi 

#11.5 Restrict root Login to System Console
echo -e "\e[4m11.5 : Restrict root Login to System Console\e[0m\n"
systemConsole="/etc/securetty"
systemConsoleCounter=0
while read -r line; do
	if [ -n "$line" ]
	then
		[[ "$line" =~ ^#.*$ ]] && continue
		if [ "$line" == "vc/1" ] || [ "$line" == "tty1" ]
		then
			systemConsoleCounter=$((systemConsoleCounter+1))
		else	
			systemConsoleCounter=$((systemConsoleCounter+1))
		fi
	fi
done < "$systemConsole"

read -d '' correctsyscon << "BLOCKED"
vc/1
tty1
BLOCKED


if [ $systemConsoleCounter != 2 ]
then
	echo "$correctsyscon" > /etc/securetty
	#echo "Remediation completed."
	echo "Root login to System Console has been restricted"
	printf "\n"
else
	#echo "No remediation needed."
	echo "Root login to System Console has already been restricted, hence no action will be taken"
	printf "\n"
fi

#11.6 Restrict Access to the su Command
echo -e "\e[4m11.6 : Restrict Access to the su Command\e[0m\n"
pamsu=$(grep pam_wheel.so /etc/pam.d/su | grep required)
if [[ $pamsu =~ ^#auth.*required ]]
then
	sed -i 's/#.*pam_wheel.so use_uid/auth            required        pam_wheel.so use_uid/' /etc/pam.d/su
	#echo "Remediation completed."
	echo "Remediation completed, now only users in the wheel group can access the su command"
	printf "\n"
else
	#echo "No remediation needed."
	echo "Only users in the wheel group can access the su command, hence no action will be taken"
	printf "\n"
fi

pamwheel=$(grep wheel /etc/group)
if [[ $pamwheel =~ ^wheel.*root ]]
then
	#echo "No remediation needed."
	echo "User is already in the wheel group, hence no action will be taken"
	printf "\n"
else
	usermod -aG wheel root
	#echo "Remediation completed."
	echo "User has been added to the wheel group"
	printf "\n"
fi

printf "\n\n"
#To capture escaped strings and close the terminal
read -n 1 -s -r -p "Press any key to exit!"
kill -9 $PPID
