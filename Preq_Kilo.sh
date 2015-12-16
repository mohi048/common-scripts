#!/bin/bash

apt-get update
apt-get -y upgrade
apt-get -y install python-software-properties
apt-get -y install ubuntu-cloud-keyring
echo "deb http://ubuntu-cloud.archive.canonical.com/ubuntu trusty-updates/kilo main" > /etc/apt/sources.list.d/cloudarchive-kilo.list
apt-get -y update && apt-get -y dist-upgrade

echo "###############################################"
echo "#		Installing OVS bridge		    #"
echo "###############################################"

apt-get -y install openvswitch-switch python-openvswitch
/etc/init.d/openvswitch-switch restart

eth=$(/sbin/ifconfig eth0 | grep 'inet addr:' | cut -d: -f2 | awk '{ print $1}')
gateway=$(ip route show default | awk '/default/ {print $3}')

echo "###############################################"
echo "#		Updating rc.local file		    #"
echo "###############################################"

if grep -q "ifconfig" /etc/rc.local; then
        echo "------------- i m skipping addition to rc.local file ....."
else
        printf '$i\nsleep 10\n.\nwq\n' | ex - /etc/rc.local
        printf '$i\nifconfig eth0 0\n.\nwq\n' | ex - /etc/rc.local
        printf '$i\nifconfig br-int up\n.\nwq\n' | ex - /etc/rc.local
        printf '$i\nifconfig br-ex '$eth' netmask 255.255.255.0 up\n.\nwq\n' | ex - /etc/rc.local
        printf '$i\nroute add default gw '$gateway' dev br-ex metric 100\n.\nwq\n' | ex - /etc/rc.local

fi


echo "###############################################"
echo "#		UPDATING sysctl.conf		    #"
echo "###############################################"

if grep -q "#net.ipv4.ip_forward" /etc/sysctl.conf; then
        sed -i 's/#net.ipv4.ip_forward=1/net.ipv4.ip_forward=1/g' /etc/sysctl.conf
else
        echo "----------- exitting net.ipv4.ip_forward"
fi


if grep -q "#net.ipv4.conf.all.rp_filter" /etc/sysctl.conf; then
        sed -i 's/#net.ipv4.conf.all.rp_filter=1/net.ipv4.conf.all.rp_filter=0/g' /etc/sysctl.conf
else
        echo "----------- exitting net.ipv4.conf.all.rp_filter"
fi


if grep -q "#net.ipv4.conf.default.rp_filter" /etc/sysctl.conf; then
        sed -i 's/#net.ipv4.conf.default.rp_filter=1/net.ipv4.conf.default.rp_filter=0/g' /etc/sysctl.conf
else
        echo "---------- exitting net.ipv4.conf.default.rp_filter"
fi

ovs-vsctl add-br br-int
ovs-vsctl add-br br-ex
shutdown -r +1 && ovs-vsctl add-port br-ex eth0
echo "Rebooting the machine , Please standBy !!!!!"
echo "################ SSH IP ADDRESS $eth TO RE-LOGIN ###############"
