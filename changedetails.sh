#!/bin/bash
### General Scripts for UBUNTU OS to change Hostname , IP Address and SSH Root login Permissions ###


NewHostName="NewServer"
NewIpAddr="192.168.72.130"
RootLogin="Yes"

THISHOST=$(hostname)
ThisIP=$(ifconfig | awk -F':' '/inet addr/&&!/127.0.0.1/{split($2,_," ");print _[1]}')

sed -i "s/$THISHOST/$NewHostName/g" /etc/hosts
sed -i "s/$THISHOST/$NewHostName/g" /etc/hostname
sed -i "s/$ThisIP/$NewIpAddr/g" /etc/network/interfaces
sed -i "/PermitRootLogin/c\PermitRootLogin Yes"  /etc/ssh/sshd_config
apt-get -y install git

echo "New IP Address = $NewIpAddr"
echo "New Machine Name = $NewHostName"
echo "Setting Root Login permission to $RootLogin"
echo "Rebooting the machine , Please standBy !!!!!"
echo "################ USE THE NEW IP ADDRESS $NewIpAddr TO LOGIN ###############"
shutdown -r




