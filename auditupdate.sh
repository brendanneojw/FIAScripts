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

# 4.1 and 4.2
echo -e "\e[4m4.1 to 4.2 : Set User/Group Owner and Permissions on /boot/grub2/grub.cfg\e[0m\n"
checkgrubowner=`stat -L -c "owner=%U group=%G" /boot/grub2/grub.cfg`

if  [ "$checkgrubowner" == "owner=root group=root" ]
then
	checkgrubpermission=`stat -L -c "%a" /boot/grub2/grub.cfg | cut -b 2,3`

	if [ "$checkgrubpermission" == "00" ]
	then
		echo "/boot/grub2/grub.cfg - PASSED (Owner, group owner and permission of file is configured correctly)"

	else
		echo "/boot/grub2/grub.cfg - FAILED (Permission of file is configured incorrectly)"
	fi

else
	echo "/boot/grub2/grub.cfg - FAILED (Owner and group owner of file is configured incorrectly)"
fi

printf "\n\n"

# 4.3
echo -e "\e[4m4.3 : Set Boot Loader Password\e[0m\n"
checkbootloaderuser=`grep "^set superusers" /boot/grub2/grub.cfg`

if [ -z "$checkbootloaderuser" ]
then
	echo "Boot Loader Password - FAILED (Boot loader is not configured with any superuser)"

else
	checkbootloaderpassword=`grep "^passwd" /boot/grub2/grub.cfg`

	if [ -z "$checkbootloaderpassword" ]
	then
		echo "Boot Loader Password - FAILED (Boot loader is not configured with a password)"

	else
		echo "Boot Loader Password - PASSED (Boot loader is configured with a superuser and password)"
	fi

fi	

printf "\n\n"
# 5.1
echo -e "\e[4m5.1 : Restrict Core Dumps\e[0m\n"
checkcoredump=`grep "hard core" /etc/security/limits.conf`
coredumpval="* hard core 0"

if [ "$checkcoredump" == "$coredumpval" ]
then
	checksetuid=`sysctl fs.suid_dumpable`
	setuidval="fs.suid_dumpable = 0"

	if [ "$checksetuid" == "$setuidval" ]
	then
		echo "Core Dump - PASSED (Core dumps are restricted and setuid programs are prevented from dumping core)"

	else
		echo "Core Dump - FAILED (Setuid programs are not prevented from dumping core)"
	fi

else
	echo "Core Dump - FAILED (Core dumps are not restricted)"
fi

printf "\n\n"

# 5.2
echo -e "\e[4m5.2 : Enable Randomized Virtual Memory Region Placement\e[0m\n"
checkvirtualran=`sysctl kernel.randomize_va_space`
virtualranval="kernel.randomize_va_space = 2"

if [ "$checkvirtualran" == "$virtualranval" ]
then
	echo "Randomized Virtual Memory Region Placement - PASSED (Virtual memory is randomized)"

else
	echo "Randomized Virtual Memory Region Placement - FAILED (Virtual memory is not randomized)"
fi

printf "\n\n"

# 6.1
printf "============================================================================\n"
printf "6.1 : Configure rsyslog\n"
printf "============================================================================\n"
printf "\n"

# 6.1.1 and 6.1.2
echo -e "\e[4m6.1.1 to 6.1.2 : Install the rsyslogpackage and Activate the rsyslog Service\e[0m\n"
checkrsyslog=`rpm -q rsyslog | grep "^rsyslog"`
if [ -n "$checkrsyslog" ]
then
	checkrsysenable=`systemctl is-enabled rsyslog`

	if [ "$checkrsysenable" == "enabled" ]
	then
		echo "Rsyslog - PASSED (Rsyslog is installed and enabled)"

	else
		echo "Rsyslog - FAILED (Rsyslog is disabled)"
	fi

else
	echo "Rsyslog - FAILED (Rsyslog is not installed)"
fi

printf "\n\n"

# 6.1.3
echo -e "\e[4m6.1.3 to 6.1.4 : Configure /etc/rsyslog.conf and Create and Set Permissions on rsyslog Log Files\e[0m\n"
checkvarlogmessageexist=`ls -l /var/log/ | grep messages`

if [ -n "$checkvarlogmessageexist" ]
then
	checkvarlogmessageown=`ls -l /var/log/messages | cut -d ' ' -f3,4`

	if [ "$checkvarlogmessageown" == "root root" ]
	then
		checkvarlogmessagepermit=`ls -l /var/log/messages | cut -d ' ' -f1`

		if [ "$checkvarlogmessagepermit" == "-rw-------." ]
		then
			checkvarlogmessage=`grep /var/log/messages /etc/rsyslog.conf`

			if [ -n "$checkvarlogmessage" ]
			then
				checkusermessage=`grep /var/log/messages /etc/rsyslog.conf | grep "^auth,user.*"`

				if [ -n "$checkusermessage" ]
				then
					echo "/var/log/messages - PASSED (Owner, group owner, permissions, facility are configured correctly; messages logging is set)"

				else
					echo "/var/log/messages - FAILED (Facility is not configured correctly)"
				fi

			else
				echo "/var/log/messages - FAILED (messages logging is not set)"
			fi

		else
			echo "/var/log/messages - FAILED (Permissions of file is configured incorrectly)"
		fi

	else
		echo "/var/log/messages - FAILED (Owner and group owner of file is configured incorrectly)"
	fi

else
	echo "/var/log/messages - FAILED (/var/log/messages file does not exist)"
fi

printf "\n"

checkvarlogkernexist=`ls -l /var/log/ | grep kern.log`

if [ -n "$checkvarlogkernexist" ]
then
	checkvarlogkernown=`ls -l /var/log/kern.log | cut -d ' ' -f3,4`

	if [ "$checkvarlogkernown" == "root root" ]
	then
		checkvarlogkernpermit=`ls -l /var/log/kern.log | cut -d ' ' -f1`

		if [ "$checkvarlogkernpermit" == "-rw-------." ]
		then
			checkvarlogkern=`grep /var/log/kern.log /etc/rsyslog.conf`

			if [ -n "$checkvarlogkern" ]
			then
				checkuserkern=`grep /var/log/kern.log /etc/rsyslog.conf | grep "^kern.*"`

				if [ -n "$checkuserkern" ]
				then
					echo "/var/log/kern.log - PASSED (Owner, group owner, permissions, facility are configured correctly; kern.log logging is set)"

				else
					echo "/var/log/kern.log - FAILED (Facility is not configured correctly)"
				fi

			else
				echo "/var/log/kern.log - FAILED (kern.log logging is not set)"
			fi

		else
			echo "/var/log/kern.log - FAILED (Permissions of file is configured incorrectly)"
		fi

	else
		echo "/var/log/kern.log - FAILED (Owner and group owner of file is configured incorrectly)"
	fi

else
	echo "/var/log/kern.log - FAILED (/var/log/kern.log file does not exist)"
fi

printf "\n"

checkvarlogdaemonexist=`ls -l /var/log/ | grep daemon.log`

if [ -n "$checkvarlogdaemonexist" ]
then
	checkvarlogdaemonown=`ls -l /var/log/daemon.log | cut -d ' ' -f3,4`

	if [ "$checkvarlogdaemonown" == "root root" ]
	then
		checkvarlogdaemonpermit=`ls -l /var/log/daemon.log | cut -d ' ' -f1`

		if [ "$checkvarlogdaemonpermit" == "-rw-------." ]
		then
			checkvarlogdaemon=`grep /var/log/daemon.log /etc/rsyslog.conf`

			if [ -n "$checkvarlogdaemon" ]
			then
				checkuserdaemon=`grep /var/log/daemon.log /etc/rsyslog.conf | grep "^daemon.*"`

				if [ -n "$checkuserdaemon" ]
				then
					echo "/var/log/daemon.log - PASSED (Owner, group owner, permissions, facility are configured correctly; daemon.log logging is set)"

				else
					echo "/var/log/daemon.log - FAILED (Facility is not configured correctly)"
				fi

			else
				echo "/var/log/daemon.log - FAILED (daemon.log logging is not set)"
			fi

		else
			echo "/var/log/daemon.log - FAILED (Permissions of file is configured incorrectly)"
		fi

	else
		echo "/var/log/daemon.log - FAILED (Owner and group owner of file is configured incorrectly)"
	fi

else
	echo "/var/log/daemon.log - FAILED (/var/log/daemon.log file does not exist)"
fi

printf "\n"

checkvarlogsyslogexist=`ls -l /var/log/ | grep syslog.log`

if [ -n "$checkvarlogsyslogexist" ]
then
	checkvarlogsyslogown=`ls -l /var/log/syslog.log | cut -d ' ' -f3,4`

	if [ "$checkvarlogsyslogown" == "root root" ]
	then
		checkvarlogsyslogpermit=`ls -l /var/log/syslog.log | cut -d ' ' -f1`

		if [ "$checkvarlogsyslogpermit" == "-rw-------." ]
		then
			checkvarlogsyslog=`grep /var/log/syslog.log /etc/rsyslog.conf`

			if [ -n "$checkvarlogsyslog" ]
			then
				checkusersyslog=`grep /var/log/syslog.log /etc/rsyslog.conf | grep "^syslog.*"`

				if [ -n "$checkusersyslog" ]
				then
					echo "/var/log/syslog.log - PASSED (Owner, group owner, permissions, facility are configured correctly; syslog.log logging is set)"

				else
					echo "/var/log/syslog.log - FAILED (Facility is not configured correctly)"
				fi

			else
				echo "/var/log/syslog.log - FAILED (syslog.log logging is not set)"
			fi

		else
			echo "/var/log/syslog.log - FAILED (Permissions of file is configured incorrectly)"
		fi

	else
		echo "/var/log/syslog.log - FAILED (Owner and group owner of file is configured incorrectly)"
	fi

else
	echo "/var/log/syslog.log - FAILED (/var/log/syslog.log file does not exist)"
fi

printf "\n"

checkvarlogunusedexist=`ls -l /var/log/ | grep unused.log`

if [ -n "$checkvarlogunusedexist" ]
then
	checkvarlogunusedown=`ls -l /var/log/unused.log | cut -d ' ' -f3,4`

	if [ "$checkvarlogunusedown" == "root root" ]
	then
		checkvarlogunusedpermit=`ls -l /var/log/unused.log | cut -d ' ' -f1`

		if [ "$checkvarlogunusedpermit" == "-rw-------." ]
		then
			checkvarlogunused=`grep /var/log/unused.log /etc/rsyslog.conf`

			if [ -n "$checkvarlogunused" ]
			then
				checkuserunused=`grep /var/log/unused.log /etc/rsyslog.conf | grep "^lpr,news,uucp,local0,local1,local2,local3,local4,local5,local6.*"`

				if [ -n "$checkuserunused" ]
				then
					echo "/var/log/unused.log - PASSED (Owner, group owner, permissions, facility are configured correctly; unused.log logging is set)"

				else
					echo "/var/log/unused.log - FAILED (Facility is not configured correctly)"
				fi

			else
				echo "/var/log/unused.log - FAILED (unused.log logging is not set)"
			fi

		else
			echo "/var/log/unused.log - FAILED (Permissions of file is configured incorrectly)"
		fi

	else
		echo "/var/log/unused.log - FAILED (Owner and group owner of file is configured incorrectly)"
	fi

else
	echo "/var/log/unused.log - FAILED (/var/log/unused.log file does not exist)"
fi

printf "\n\n"

# 6.1.5
echo -e "\e[4m6.1.5 : Configure rsyslogto Send Logs to a Remote Log Host\e[0m\n"
checkloghost=$(grep "^*.*[^|][^|]*@" /etc/rsyslog.conf)
if [ -z "$checkloghost" ]  # If there is no log host
then
	printf "Remote Log Host : FAILED (Remote log host has not been configured)\n"
else
	printf "Remote Log Host : PASSED (Remote log host has been configured)\n"
fi

printf "\n\n"
# 6.1.6
echo -e "\e[4m6.1.6 : Accept Remote rsyslog Messages Only on Designated Log Hosts\e[0m\n"
checkrsysloglis=`grep '^$ModLoad imtcp.so' /etc/rsyslog.conf`
checkrsysloglis1=`grep '^$InputTCPServerRun' /etc/rsyslog.conf`

if [ -z "$checkrsysloglis" -o -z "$checkrsysloglis1" ]
then
	echo "Remote rsyslog - FAILED (Rsyslog is not listening for remote messages)"

else
	echo "Remote rsyslog - PASSED (Rsyslog is listening for remote messages)"
fi

printf "\n\n"

printf "============================================================================\n"
printf "6.2 : Configure System Accounting\n"
printf "============================================================================\n"
printf "\n"
echo "----------------------------------------------------------------------------"
printf "6.2.1 : Configure Data Retention\n"
echo "----------------------------------------------------------------------------"
printf "\n"

# 6.2.1.1
echo -e "\e[4m6.2.1.1 : Configure Audit Log Storage Size\e[0m\n"
checklogstoragesize=`grep max_log_file[[:space:]] /etc/audit/auditd.conf | awk '{print $3}'`

if [ "$checklogstoragesize" == 5 ]
then
	echo "Audit Log Storage Size - PASSED (Maximum size of audit log files is configured correctly)"

else
	echo "Audit Log Storage Size - FAILED (Maximum size of audit log files is not configured correctly)"
fi

printf "\n\n"

# 6.2.1.2
echo -e "\e[4m6.2.1.2 : Keep All Auditing Information\e[0m\n"
checklogfileaction=`grep max_log_file_action /etc/audit/auditd.conf | awk '{print $3}'`
 
if [ "$checklogfileaction" == keep_logs ]
then
	echo "Audit Log File Action - PASSED (Action of the audit log file is configured correctly)"

else
	echo "Audit Log File Action - FAILED (Action of the audit log file is not configured correcly)"
fi

printf "\n\n"

# 6.2.1.3
echo -e "\e[4m6.2.1.3 : Disable System on Audit Log Full\e[0m\n"
checkspaceleftaction=`grep space_left_action /etc/audit/auditd.conf | grep "email"`

if [ -n "$checkspaceleftaction" ]
then
	checkactionmailacc=`grep action_mail_acct /etc/audit/auditd.conf | awk '{print $3}'`
	if [ "$checkactionmailacc" == root ]
	then
		checkadminspaceleftaction=`grep admin_space_left_action /etc/audit/auditd.conf | awk '{print $3}'`
		if [ "$checkadminspaceleftaction" == halt ]
		then
			echo "Disable System - PASSED (Auditd is correctly configured to notify the administrator and halt the system when audit logs are full)"
		else
			echo "Disable System - FAILED (Auditd is not configured to halt the system when audit logs are full)"
		fi

	else
		echo "Disable System - FAILED (Auditd is not configured to notify the administrator when audit logs are full)"
	fi
	
else
	echo "Disable System - FAILED (Auditd is not configured to notify the administrator by email when audit logs are full)"
fi

printf "\n\n"

# 6.2.1.4
echo -e "\e[4m6.2.1.4 : Enable auditd Service\e[0m\n"
checkauditdservice=`systemctl is-enabled auditd`

if [ "$checkauditdservice" == enabled ]
then
	echo "Auditd Service - PASSED (Auditd is enabled)"

else
	echo "Auditd Service - FAILED (Auditd is not enabled)"
fi

printf "\n\n"

# 6.2.1.5
echo -e "\e[4m6.2.1.5 : Enable Auditing for Processes That Start Prior to auditd\e[0m\n"
checkgrub=$(grep "linux" /boot/grub2/grub.cfg | grep "audit=1") 
if [ -z "$checkgrub" ]
then
	printf "System Log Processes : FAILED (System is not configured to log processes that start prior to auditd\n"

else
	printf "System Log Processes : PASSED (System is configured to log processes that start prior to auditd\n"
fi

printf "\n\n"

# 6.2.1.6
echo -e "\e[4m6.2.1.6 : Record Events That Modify Date and Time Information\e[0m\n"
checksystem=`uname -m | grep "64"`
checkmodifydatetimeadjtimex=`egrep 'adjtimex|settimeofday|clock_settime' /etc/audit/audit.rules`

if [ -z "$checksystem" ]
then
	echo "It is a 32-bit system."
	printf "\n"
	if [ -z "$checkmodifydatetimeadjtimex" ]
	then
        echo "Date & Time Modified Events - FAILED (Events where system date and/or time has been modified are not captured)"

	else
		echo "Date & Time Modified Events - PASSED (Events where system date and/or time has been modified are captured)"
	fi

else
	echo "It is a 64-bit system."
	printf "\n" 
	if [ -z "$checkmodifydatetimeadjtimex" ]
	then
        echo "Date & Time Modified Events - FAILED (Events where system date and/or time has been modified are not captured)"

	else
		echo "Date & Time Modified Events - PASSED (Events where system date and/or time has been modified are captured)"
	fi

fi

printf "\n\n"

# 6.2.1.7
echo -e "\e[4m6.2.1.7 : Record Events That Modify User/Group Information\e[0m\n"
checkmodifyusergroupinfo=`egrep '\/etc\/group' /etc/audit/audit.rules`

if [ -z "$checkmodifyusergroupinfo" ]
then
        echo "Group Configuration - FAILED (Group is not configured)"

else
        echo "Group Configuration - PASSED (Group is already configured)"
fi

printf "\n"

checkmodifyuserpasswdinfo=`egrep '\/etc\/passwd' /etc/audit/audit.rules`

if [ -z "$checkmodifyuserpasswdinfo" ]
then
        echo "Password Configuration - FAILED (Password is not configured)"

else
        echo "Password Configuration - PASSED (Password is configured)"
fi

printf "\n"

checkmodifyusergshadowinfo=`egrep '\/etc\/gshadow' /etc/audit/audit.rules`

if [ -z "$checkmodifyusergshadowinfo" ]
then
        echo "GShadow Configuration - FAILED (GShadow is not configured)"

else
        echo "GShadow Configuration - PASSED (GShadow is configured)"
fi

printf "\n"

# 6.2.1.8
checkmodifyusershadowinfo=`egrep '\/etc\/shadow' /etc/audit/audit.rules`

if [ -z "$checkmodifyusershadowinfo" ]
then
        echo "Shadow Configuration - FAILED (Shadow is not configured)"

else
        echo "7Shadow Configuration - PASSED (Shadow is configured)"
fi

printf "\n"

checkmodifyuseropasswdinfo=`egrep '\/etc\/security\/opasswd' /etc/audit/audit.rules`

if [ -z "$checkmodifyuseropasswdinfo" ]
then
        echo "OPasswd Configuration- FAILED (OPassword not configured)"

else
        echo "OPasswd Configuration - PASSED (OPassword is configured)"
fi

printf "\n\n"

# 6.2.1.8
echo -e "\e[4m6.2.1.8 : Record Events That Modify the System's Network Environment\e[0m\n"
checksystem=`uname -m | grep "64"`
checkmodifynetworkenvironmentname=`egrep 'sethostname|setdomainname' /etc/audit/audit.rules`

if [ -z "$checksystem" ]
then
	echo "It is a 32-bit system."
	printf "\n"
	if [ -z "$checkmodifynetworkenvironmentname" ]
	then
        	echo "Modify the System's Network Environment Events - FAILED (Sethostname and setdomainname is not configured)"

	else
		echo "Modify the System's Network Environment Events - PASSED (Sethostname and setdomainname is configured)"
	fi

else
	echo "It is a 64-bit system."
	printf "\n"
	if [ -z "$checkmodifynetworkenvironmentname" ]
	then
        echo "Modify the System's Network Environment Events - FAILED (Sethostname and setdomainname is not configured)"

	else
		echo "Modify the System's Network Environment Events - PASSED (Sethostname and setdomainname is configured)"
	fi

fi

printf "\n"

checkmodifynetworkenvironmentissue=`egrep '\/etc\/issue' /etc/audit/audit.rules`

if [ -z "$checkmodifynetworkenvironmentissue" ]
then
    echo "Modify the System's Network Environment Events - FAILED (/etc/issue is not configured)"

else
    echo "Modify the System's Network Environment Events - PASSED (/etc/issue is configured)"
fi

printf "\n"

checkmodifynetworkenvironmenthosts=`egrep '\/etc\/hosts' /etc/audit/audit.rules`

if [ -z "$checkmodifynetworkenvironmenthosts" ]
then
    echo "Modify the System's Network Environment Events - FAILED (/etc/hosts is not configured)"

else
     echo "Modify the System's Network Environment Events - PASSED (/etc/hosts is configured)"
fi

printf "\n"

checkmodifynetworkenvironmentnetwork=`egrep '\/etc\/sysconfig\/network' /etc/audit/audit.rules`

if [ -z "$checkmodifynetworkenvironmentnetwork" ]
then
    echo "Modify the System's Network Environment Events - FAILED (/etc/sysconfig/network is not configured)"

else
    echo "Modify the System's Network Environment Events - PASSED (/etc/sysconfig/network is configured)"
fi

printf "\n\n"
# 6.2.1.9
echo -e "\e[4m6.2.1.9 : Record Events That Modify the System's Mandatory Access Controls\e[0m\n"
checkmodifymandatoryaccesscontrol=`grep \/etc\/selinux /etc/audit/audit.rules`

if [ -z "$checkmodifymandatoryaccesscontrol" ]
then
	echo "Modify the System's Mandatory Access Controls Events - FAILED (Recording of modified system's mandatory access controls events is not configured)"

else
	echo "Modify the System's Mandatory Access Controls Events - PASSED (Recording of modified system's mandatory access controls events is configured)"
fi

printf "\n\n"

# Force exit
read -n 1 -s -r -p "Press any key to exit!"
kill -9 $PPID