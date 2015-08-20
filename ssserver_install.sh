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
echo "# Author Url:  http://ace272.tk"
echo "# Version: 1.0"
echo "#############################################################"
echo ""

yum -y update
yum -y install python-setuptools && easy_install pip
pip install shadowsocks

cp /etc/shadowsocks.json /etc/shadowsocks.json.old
cat >>/etc/shadowsocks.json<<EOF
"server":"45.79.79.130",
"server_port":8272,
"local_port":1080,
"password":"Rf198012",
"timeout":600,
"method":"aes-256-cfb"
EOF

cp /etc/shadowsocks_autostart.sh shadowsocks_autostart.sh.old
cat >>/etc/shadowsocks_autostart.sh<<EOF
pids="$($_CMD pgrep ss-server)"
if [ ! $pids ]; then
        screen -dmS shadowsocks ssserver -c /etc/shadowsocks/config.json
fi
EOF
chmod a+x /etc/shadowsocks_autostart.sh

echo "bash /etc/shadowsocks_autostart.sh" >> /etc/rc.local

shadowsocks_autostart.sh