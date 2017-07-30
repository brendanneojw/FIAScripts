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
# 1.11 to 1.13
echo -e "\e[4m1.11 to 1.13 : Add nodev, nosuid and no exec Option to Removable Media Partitions\e[0m\n"
cdcheck=`grep cd /etc/fstab`
if [ -n "$cdcheck" ]
then
	cdnodevcheck=`grep cdrom /etc/fstab | grep nodev`
	cdnosuidcheck=`grep cdrom /etc/fstab | grep nosuid`
	cdnosuidcheck=`grep cdrom /etc/fstab | grep noexec`
	if [ -z "$cdnosuidcheck" ]
	then
			echo "/cdrom - FAILED (/cdrom not mounted with nodev option)"
	elif [ -z "$cdnosuidcheck" ]
	then
			echo "/cdrom - FAILED (/cdrom not mounted with nosuid option)"
	elif [ -z "$cdnosuidcheck" ]
	then
			echo "/cdrom - FAILED (/cdrom not mounted with noexec option)"
	else
		"/cdrom - PASSED (/cdrom is a mounted with nodev,nosuid,noexec option)"
	fi
else
	echo "/cdrom - PASSED (/cdrom not mounted)"
fi
 
printf "\n\n"

# 1.14
echo -e "\e[4m1.14 : Set Sticky Bit on All World-Writable Directories\e[0m\n"
checkstickybit=`df --local -P | awk {'if (NR1=1) print $6'} | xargs -l '{}' -xdev -type d \(--perm -0002 -a ! -perm -1000 \) 2> /dev/null`
if [ -n "$checkstickybit" ]
then
	echo "Sticky Bit - FAILED (Sticky bit is not set on all world-writable directories)"
else
	echo "Sticky Bit - PASSED (Sticky bit is set on all world-writable directories)"
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
	echo "Legacy File Systems - FAILED (Not all legacy file systems are disabled i.e. cramfs, freevxfs, jffs2, hfs, hfsplus, squashfs and udf)"
else
	echo "Legacy File Systems - PASSED (All legacy file systems are disabled i.e. cramfs, freevxfs, jffs2, hfs, hfsplus, squashfs and udf)"
fi

printf "\n\n"

# 2.1 to 2.5
echo -e "\e[4m2.1 to 2.5 : Remove telnet Server & Clients, rsh Server and Clients, NIS Server and Clients, tftp Server and Clients and xinetd\e[0m\n"
services=( "telnet" "telnet-server" "rsh-server" "rsh" "ypserv" "ypbind" "tftp" "tftp-server" "xinetd" )

for eachservice in ${services[*]}
do 
	yum -q list installed $eachservice &>/dev/null && echo "$eachservice - FAILED ($eachservice is Installed)" || echo "$eachservice - PASSED ($eachservice is not installed) "
done 	

printf "\n\n"
# 2.6 to 2.10
echo -e "\e[4m2.6 to 2.10 : Disable chargen-dgram, daytime-dgram/daytime-stream, echo-dgram/echo-stream and tcpmux-server\e[0m\n"
chkservices=( "chargen-stream" "daytime-dgram" "daytime-stream" "echo-dgram" "echo-stream" "tcpmux-server" ) 

for eachchkservice in ${chkservices[*]}
do 
	checkxinetd=`yum list xinetd | grep "Available Packages"`
	if [ -n "$checkxinetd" ]
	then
		echo "Xinetd is not installed, hence $eachchkservice is not installed"
	else
		checkchkservices=`chkconfig --list $eachchkservice | grep "off"`
		if [ -n "$checkchkservices" ]
		then 
			echo "$eachchkservice - PASSED ($eachchkservice is not active) "

		else 
			echo "$eachchkservice - FAILED ($eachchkservice is active)"
		fi
	fi
done

printf "\n\n"

# 3.1
echo -e "\e[4m3.1 : Set Daemon umask\e[0m\n"
checkumask=`grep ^umask /etc/sysconfig/init`

if [ "$checkumask" == "umask 027" ]
then 
	echo "Umask - PASSED (umask is set to 027)"
else 
	echo "Umask - FAILED (umask is not set to 027)"
fi

printf "\n\n"
# 3.2
echo -e "\e[4m3.2 : Remove the X Window System\e[0m\n"
checkxsystem=`ls -l /etc/systemd/system/default.target | grep graphical.target` #Must return empty
checkxsysteminstalled=`rpm  -q xorg-x11-server-common`	#Must return something
	
if [ -z "$checkxsystem" -a -z "$checkxsysteminstalled" ]
then 
	echo "X Window System - FAILED (Xorg-x11-server-common is installed)"
elif [ -z "$checkxsystem" -a -n "$checkxsysteminstalled" ]
then
	echo "X Window System - PASSED (Xorg-x11-server-common is not installed and is not the default graphical interface)"
elif [ -n "$checkxsystem" -a -z "$checkxsysteminstalled" ]
then
	echo "X Window System - FAILED (Xorg-x11-server-common is not installed and is the default graphical interface)"
else 
	echo "X Window System - FAILED (Xorg-x11-server-common is installed and is the default graphical interface)"
fi

printf "\n\n"
# 3.3
echo -e "\e[4m3.3 : Disable AvahiServer\e[0m\n"
checkavahi=`systemctl status avahi-daemon | grep inactive`
checkavahi1=`systemctl status avahi-daemon | grep disabled`
if [ -n "$checkavahi" -a -n "$checkavahi1" ]
then 
	echo "Avahi-daemon - PASSED (Avahi-daemon is inactive and disabled) "
		
elif [ -n "$checkavahi" -a -z "$checkavahi1" ]
then 
	echo "Avahi-daemon - FAILED (Avahi-daemon is inactive but not disabled)"

elif [ -z "$checkavahi" -a -n "$checkavahi1" ]
then 
	echo "Avahi-daemon - FAILED (Avahi-daemon is disabled but active)"
	
else 
	echo "Avahi-daemon - FAILED (Avahi-daemon is active and enabled)"

fi

printf "\n\n"

# 3.4
echo -e "\e[4m3.4 : Disable Print Server - cups\e[0m\n"
checkcupsinstalled=`yum list cups | grep "Available Packages"`
checkcups=`systemctl status cups | grep inactive`
checkcups1=`systemctl status cups | grep disabled`

if [ -n "$checkcupsinstalled" ]
then
	echo "Cups - PASSED (Cups is not installed) "
else
	if [ -n "$checkcups" -a -n "$checkcups1" ]
	then 
		echo "Cups - PASSED (Cups is inactive and disabled) "
	elif [ -n "$checkcups" -a -z "$checkcups1" ]
	then 
		echo "Cups - FAILED (Cups is inactive but not disabled)"

	elif [ -z "$checkcups" -a -n "$checkcups1" ]
	then 
		echo "Cups - FAILED (Cups is disabled but active)"

	else 
		echo "Cups - FAILED (Cups is active and enabled)"
	
	fi
fi

printf "\n\n"

# 3.5
echo -e "\e[4m3.5 : Remove DHCP Server\e[0m\n"
checkyumdhcp=`yum list dhcp | grep "Available Packages" `
checkyumdhcpactive=`systemctl status dhcp | grep inactive `
checkyumdhcpenable=`systemctl status dhcp | grep disabled `
if [ -n "$checkyumdhcp" ]
then 
	echo "DHCP Server - PASSED (DHCP is not installed) "

else 
	if [ -z "$checkyumdhcpactive" -a -z "$checkyumdhcpenable" ]
	then 
		echo "DHCP - FAILED (DHCP is active and enabled)"

	elif [ -z "$checkyumdhcpactive" -a -n "$checkyumdhcpenable" ]
	then 
		echo "DHCP - FAILED (DHCP is active but disabled)"

	elif [ -n "$checkyumdhcpactive" -a -z "$checkyumdhcpenable" ]
	then
		echo "DHCP - FAILED (DHCP is inactive but enabled)"

	else 
		echo "DHCP - PASSED (DHCP is inactive and disabled)"

	fi
fi

printf "\n\n"

# 3.6
echo -e "\e[4m3.6 : Configure Network Time Protocol (NTP)\e[0m\n"
checkntp1=`grep "^restrict default kod nomodify notrap nopeer noquery" /etc/ntp.conf`
checkntp2=`grep "^restrict -6 default kod nomodify notrap nopeer noquery" /etc/ntp.conf` 
checkntp3=`grep "^server" /etc/ntp.conf | grep server`
checkntp4=`grep 'OPTIONS="-u ntp:ntp -p /var/run/ntpd.pid"' /etc/sysconfig/ntpd `

if [ -n "$checkntp1" ]
then 
	if [ -n "$checkntp2" ]
	then 
		if [ -n "$checkntp3" ]
			then 
				if [ -n "$checkntp4" ]
				then
					echo "NTP - PASSED (NTP has been properly configured)"
					
				else 
					echo "NTP - FAILED (Option has not been configured in /etc/sysconfig/ntpd)" 
					
				fi
		else
			echo "NTP - FAILED (Failed to list down NTP servers)"
			
		fi
	else 
		echo "NTP - FAILED (Failed to implement restrict -6 default kod nomodify notrap nopeer noquery)"
		
	fi
else 
	echo "NTP - FAILED (Failed to implement restrict default kod nomodify notrap nopeer noquery)"

fi

printf "\n\n"

# 3.7
echo -e "\e[4m3.7 : Remove LDAP\e[0m\n"
checkldapclients=`yum list openldap-clients | grep 'Available Packages'`
checkldapservers=`yum list openldap-servers | grep 'Available Packages'`

if [ -n "checkldapclients" -a -n "checkldapservers" ]
then 
	echo "LDAP - PASSED (LDAP server and client are both not installed)"
	
elif [ -n "checkldapclients" -a -z "checkldapservers" ]
then
	echo "LDAP - FAILED (LDAP server is installed)"
	
elif [ -z "checkldapclients" -a -n "checkldapservers" ]
then
	echo "LDAP - FAILED (LDAP client is installed)"
	
else 
	echo "LDAP - FAILED (Both LDAP client and server are installed)"
	
fi

printf "\n\n"

# 3.8
echo -e "\e[4m3.8 : Disable NFS and RPC\e[0m\n"
nfsservices=( "nfs-lock" "nfs-secure" "rpcbind" "nfs-idmap" "nfs-secure-server" )

for eachnfsservice in ${nfsservices[*]}
do 
	checknfsservices=`systemctl is-enabled $eachnfsservice | grep enabled`
	if [ -z "$checknfsservices" ]
	then 
		echo "$eachnfsservice - PASSED ($eachnfsservice is disabled) "

	else 
		echo "$eachnfsservice - FAILED ($eachnfsservice is enabled)"

	fi
done 	

printf "\n\n"

# 3.9
echo -e "\e[4m3.9 : Remove DNS, FTP, HTTP, HTTP-Proxy, SNMP\e[0m\n"
standardservices=( "named" "vsftpd" "httpd" "sshd" "snmpd") 

for eachstandardservice in ${standardservices[*]}
do 
	checkserviceexist=`systemctl status $eachstandardservice | grep not-found`
	if [ -n "$checkserviceexist" ]
	then
		echo "$eachstandardservice - PASSED ($eachstandardservice does not exist in the system)"

	else
		checkstandardservices=`systemctl status $eachstandardservice | grep disabled`
		checkstandardservices1=`systemctl status $eachstandardservice | grep inactive`
		if [ -z "$checkstandardservices" -a -z "$checkstandardservices1" ]
		then 
			echo "$eachstandardservice - FAILED ($eachstandardservice is active and enabled) "
			
		elif [ -z "$checkstandardservices" -a -n "$checkstandardservices1" ]
		then 
			echo "$eachstandardservice - FAILED ($eachstandardservice is inactive but enabled) "
	
		elif [ -n "$checkstandardservices" -a -z "$checkstandardservices1" ]
		then 
			echo "$eachstandardservice - FAILED ($eachstandardservice is disabled but active) "

		else 
			echo "$eachstandardservice - PASSED ($eachstandardservice is disabled and inactive)"
		
		fi
	fi
done 	

printf "\n\n"

# 3.10
echo -e "\e[4m3.10 : Configure Mail Transfer Agent for Local-Only Mode\e[0m\n"
checkmailtransferagent=`netstat -an | grep ":25[[:space:]]"`

if [ -n "$checkmailtransferagent" ]
then
	checklistening=`netstat -an | grep LISTEN`
	if [ -n "$checklistening" ]
	then
		checklocaladdress=`netstat -an | grep [[:space:]]127.0.0.1:25[[:space:]] | grep LISTEN`
		if [ -n "$checklocaladdress" ]
		then
			echo "MTA - PASSED (Mail Transfer Agent is listening on the loopback address)"
		else
			echo "MTA - FAILED (Mail Transfer Agent is not listening on the loopback address)"
		fi
	else
		echo "MTA - FAILED (Mail Transfer Agent is not in listening mode)"
	fi
else
	echo "MTA - FAILED (Mail Transfer Agent is not configured/installed)"
fi

printf "\n\n"

read -n 1 -s -r -p "Press any key to exit!"
kill -9 $PPID