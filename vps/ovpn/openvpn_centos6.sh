#!/bin/bash
PATH=/bin:/sbin:/usr/bin:/usr/sbin:/usr/local/bin:/usr/local/sbin
export PATH

clear
CUR_DIR=$(pwd)

if [ $(id -u) != "0" ]; then
    printf "Error: You must be root to run this script!"
    exit 1
fi

echo "#############################################################"
echo "# OpenVPN Auto Install for CentOS6"
echo "# Env: Redhat/CentOS"
echo "# Author Url:  http://ace272.cf, https://www.webhostinghero.com/centos6-openvpn-setup/"
echo "# Version: 1.0"
echo "#############################################################"
echo ""


cd ~
mkdir temp
cd temp

wget http://dl.fedoraproject.org/pub/epel/6/i386/epel-release-6-8.noarch.rpm
wget http://ace272.ml/ovpn/vars
wget http://ace272.ml/ovpn/server.conf

rpm -Uvh epel-release-6-8.noarch.rpm

yum -y update
yum -y install openvpn easy-rsa 

mkdir -p /etc/openvpn/easy-rsa/
cp -R /usr/share/easy-rsa/2.0/ /etc/openvpn/easy-rsa/
cp ~/temp/vars /etc/openvpn/easy-rsa/2.0/vars

cd /etc/openvpn/easy-rsa/2.0
chmod 0755 *
source ./vars
./clean-all

./build-ca 

./build-key-server server 

./build-key ace


./build-dh 


cp ~/temp/server.conf /etc/openvpn/ 


#echo "net.ipv4.ip_forward = 1" > /etc/sysctl.conf  
#echo 1 > /proc/sys/net/ipv4/ip_forward
sysctl -p

iptables -A FORWARD -m state --state RELATED,ESTABLISHED -j ACCEPT
iptables -A FORWARD -s 10.8.0.0/24 -j ACCEPT
iptables -A FORWARD -j REJECT
iptables -t nat -A POSTROUTING -s 10.8.0.0/24 -o eth0 -j MASQUERADE
# if openVZ vps
# iptables -t nat -A POSTROUTING -s 10.8.0.0/24 -j SNAT --to-source main.ip.address
service iptables save
service iptables restart

chkconfig --add openvpn
chkconfig openvpn on

service openvpn start
  
cat >>/etc/openvpn/easy-rsa/2.0/keys/ace272.ga.ovpn<<EOF
client
remote 139.162.21.96 1194
dev tun
comp-lzo
ca ca.crt
cert ace.crt
key ace.key
route-delay 2
route-method exe
redirect-gateway def1
dhcp-option DNS 8.8.8.8
dhcp-option DNS 8.8.4.4
dhcp-option DNS 4.2.2.1
dhcp-option DNS 4.2.2.2
verb 3
EOF

cd ~ 
rm -rf ~/temp
echo "openvpn server installed, client configuration file is located /etc/openvpn/easy-rsa/2.0/keys/"
  
  
  
