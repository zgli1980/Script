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
echo "# PPTP VPN Auto Install for OpenVZ/Xen/KVM"
echo "# Env: Debian/Ubuntu"
echo "# Author Url:  http://diahosting.com && http://wangyan.org"
echo "# Modified  by http://99way.com on 2013.03.12"
echo "# Version: 1.1"
echo "#############################################################"
echo ""

apt-get -y update
apt-get -y autoremove pptpd
apt-get -y install pptpd iptables

sed -i '/exit 0/d' /etc/rc.local

mknod /dev/ppp c 108 0
echo "mknod /dev/ppp c 108 0" >> /etc/rc.local
sed -i 's/#net.ipv4.ip_forward=1/net.ipv4.ip_forward=1/g' /etc/sysctl.conf
sysctl -p
echo echo 1 \> \/proc\/sys\/net\/ipv4\/ip_forward >> /etc/rc.local

echo exit 0 >> /etc/rc.local

cat >>/etc/pptpd.conf<<EOF
localip 172.16.36.1
remoteip 172.16.36.2-254
EOF

cp /etc/ppp/pptpd-options /etc/ppp/pptpd-options.old
cat >/etc/ppp/pptpd-options<<EOF
name pptpd
refuse-pap
refuse-chap
refuse-mschap
require-mschap-v2
require-mppe-128
ms-dns 8.8.8.8
ms-dns 8.8.4.4
proxyarp
#debug
#dump
lock
nobsdcomp
novj
novjccomp
logfile /var/log/pptpd.log
EOF

echo zgli1980 pptpd Rf198012 \* >> /etc/ppp/chap-secrets

iptables-save > /etc/iptables.down.rules

n=`ifconfig  | grep 'venet0:0' | awk 'NR==1 { print $1}'`
if test "$n" == venet0:0; then
# For OpenVZ
iptables -t nat -D POSTROUTING -s 172.16.36.0/24 -j SNAT --to-source `ifconfig  | grep 'inet addr:'| grep -v '127\.0\.0\.' | grep -v '10\.' | grep -v '172.16\.' | grep -v '192\.168\.' | cut -d: -f2 | awk 'NR==1 { print $1}'`
iptables -t nat -A POSTROUTING -s 172.16.36.0/24 -j SNAT --to-source `ifconfig  | grep 'inet addr:'| grep -v '127\.0\.0\.' | grep -v '10\.' | grep -v '172.16\.' | grep -v '192\.168\.' | cut -d: -f2 | awk 'NR==1 { print $1}'`
else
# For Xen and KVM
iptables -t nat -D POSTROUTING -s 172.16.36.0/24 -o eth1 -j MASQUERADE
iptables -t nat -A POSTROUTING -s 172.16.36.0/24 -o eth1 -j MASQUERADE
fi

iptables -D FORWARD -p tcp --syn -s 172.16.36.0/24 -j TCPMSS --set-mss 1356
iptables -A FORWARD -p tcp --syn -s 172.16.36.0/24 -j TCPMSS --set-mss 1356

iptables-save > /etc/iptables.up.rules

cat >>/etc/network/if-pre-up.d/iptables<<EOF
#!/bin/bash
/sbin/iptables-restore < /etc/iptables.up.rules
EOF

chmod +x /etc/network/if-pre-up.d/iptables

/etc/init.d/pptpd restart