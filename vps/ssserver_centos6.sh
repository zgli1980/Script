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
echo "# Shadowsocks/Python Auto Install for CentOS6"
echo "# Env: Redhat/CentOS"
echo "# Author Url:  http://ace272.ga"
echo "# Version: 1.0"
echo "#############################################################"
echo ""

yum -y update
yum -y install python-setuptools && easy_install pip
pip install --force-reinstall shadowsocks

echo "Create configuration file"
mv /etc/shadowsocks.json /etc/shadowsocks.json.old
cat >>/etc/shadowsocks.json<<EOF
{
    "server":"139.162.21.96",
    "server_port":443,
    "local_port":1080,
    "password":"Rf198012",
    "timeout":600,
    "method":"aes-256-cfb"
}
EOF

#echo "Creat autostart script"
#mv /etc/shadowsocks_autostart.sh shadowsocks_autostart.sh.old
#wget https://github.com/zgli1980/Script/raw/Script/Shadowsocks_autostart.sh
#mv Shadowsocks_autostart.sh /etc/shadowsocks_autostart.sh
#chmod a+x /etc/shadowsocks_autostart.sh

echo "Allow autostart with OS"
echo "bash ssserver -c /etc/shadowsocks.json -d start" >> /etc/rc.local

echo "Start Shadowsocks now"
ssserver -c /etc/shadowsocks.json -d start

