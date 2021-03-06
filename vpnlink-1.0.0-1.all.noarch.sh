#!/bin/bash

################ Script Info ################		

## Program: Link to my office network V1.0
## Author:Clumart.G
## Date: 2013-05-08
## Update:None


################ Env Define ################

PATH=/bin:/sbin:/usr/bin:/usr/sbin:/usr/local/bin:/usr/local/sbin:~/bin:~/sbin
LANG=C
export PATH
export LANG

################ Var Setting ################

InputVar=$*
HomeDir="/tmp/autoscript/"

################ Func Define ################ 
function _info_msg() {
_header
echo -e " |                                                                |"
echo -e " |                   Thank you for use vpnlink!                   |"
echo -e " |                                                                |"
echo -e " |                         Version: 1.0                           |"
echo -e " |                                                                |"
echo -e " |                     http://www.idcsrv.com                      |"
echo -e " |                                                                |"
echo -e " |                   Author:翅儿学飞(Clumart.G)                   |"
echo -e " |                    Email:myregs6@gmail.com                     |"
echo -e " |                         QQ:1810836851                          |"
echo -e " |                         QQ群:61749648                          |"
echo -e " |                                                                |"
echo -e " |          Hit [ENTER] to continue or ctrl+c to exit             |"
echo -e " |                                                                |"
printf " o----------------------------------------------------------------o\n"	
 read entcs 
clear
}

function _end_msg() {
echo -e "###################################################################"
echo ""
echo -e "                         Configure Finish  :)"
echo ""
echo -e "###################################################################"
echo ""
echo ""
_header
echo -e " |                                                                |"
echo -e " |                 Thank you for use vpnlink!                     |"
echo -e " |                                                                |"
echo -e " |                  The software is working!                      |"
echo -e " |                                                                |"
echo -e " |                     http://www.idcsrv.com                      |"
echo -e " |                                                                |"
echo -e " |                   Author:翅儿学飞(Clumart.G)                   |"
echo -e " |                    Email:myregs6@gmail.com                     |"
echo -e " |                         QQ:1810836851                          |"
echo -e " |                         QQ群:61749648                          |"
echo -e " |                                                                |"
printf " o----------------------------------------------------------------o\n"
}

function _header() {
	printf " o----------------------------------------------------------------o\n"
	printf " | :: VPN LINK                                v1.0.0 (2013/05/08) |\n"
	printf " o----------------------------------------------------------------o\n"	
}

##Program Function

################ Main ################
clear
_info_msg

if [ `id -u` != "0" ]; then
echo -e "You need to be be the root user to run this script.\nWe also suggest you use a direct root login, not su -, sudo etc..."
exit 1
fi

if [ ! -d $HomeDir ]; then
	mkdir -p $HomeDir
fi

cd $HomeDir || exit 1

read -p "Please choose your system:[mac|rpi]" -t 10 sys
sys=`echo $sys|tr A-Z a-z|tr -s " "`
if [ "${sys}x" == 'macx' ]; then
    echo "I'm running on a mac system,only client function can be used!";
    read -p "Route operate:[add|delete]" -t 10 routeop;
    routeop=`echo $routeop|tr A-Z a-z|tr -s " "`
    read -p "Default Config:[1(3G150B)|2(New)]" -t 10 config;
    config=`echo ${config}|tr -s " "`
    if [ "${config}x" == "1x" ]; then
        gw="192.168.13.42";
    else
        read -p "Your VPN Server IP:" -t 10 gw;
        gw=`echo ${gw}|tr -s " "`;
    fi
    if [ "${routeop}x" == "x" ] || [ "${gw}x" == "x" ];then
        echo "I could't get your route operate or vpn server ip,i'm exit. Bye :(";
        exit 0;
    else
        route ${routeop} -net 10.0.0.0/8 ${gw};
        route ${routeop} -net 172.16.0.0/13 ${gw};
        echo "============        route updated          ============"
        echo "============  run 'netstat -nr' to check!  ============"
    fi
elif [ "${sys}x" == "rpix" ];then
    echo "I'm running a rpi system,i can be a route or a client :)"
    if [ -z "`whereis openconnect |cut -d' ' -f2|grep '/'`" ]; then
        echo "I need openconnect! I'm trying install it :)";
        apt-get -y update
        apt-get -y install openconnect
        if [ -z "`whereis openconnect |cut -d' ' -f2|grep '/'`" ]; then
            echo "I need openconnect,but i cann't install it :(";
            exit 0;
        fi
    fi
    read -p "Nat Src IP Config:[1(192.168.13.0/24)|2(New)]" -t 10 srcip;
    srcip=`echo ${srcip}|tr -s " "`
    if [ "${srcip}x" == "1x" ]; then
        srcip="192.168.13.0/24";
    else
        read -p "Your SRC IP Range:" -t 60 srcip;
        srcip=`echo ${srcip}|tr -s " "`;
    fi
    read -p "Choose ISP:[cnc|ct|auto]" -t 20 isp;
    read -p "Username:" -t 60 usr;
    read -s -p "Password:" -t 60 pwd;
    isp=`echo $isp|tr A-Z a-z|tr -s " "`;
    if [ "${isp}x" == "ctx" ];then
        echo ${pwd}|openconnect -b --no-cert-check --authgroup=RSA_Token_Auth --user=${usr} --passwd-on-stdin ct-vpn.baidu.com
    elif [ "${isp}x" == "cncx" ];then
        echo ${pwd}|openconnect -b --no-cert-check --authgroup=RSA_Token_Auth --user=${usr} --passwd-on-stdin cnc-vpn.baidu.com
    else
        echo "I'll location by your local dns :)"
        echo ${pwd}|openconnect -b --no-cert-check --authgroup=RSA_Token_Auth --user=${usr} --passwd-on-stdin vpn.baidu.com
    fi
    iptables -t nat -I POSTROUTING -s ${srcip} -o tun0 -j MASQUERADE
    echo 1 > /proc/sys/net/ipv4/ip_forward
    clear
    echo "==============        vpn connected          =============="
    echo "=== run 'ifconfig' | 'route -n' | 'iptables' to check!  ==="
else
    echo "I can't get your system infomation,i'm exit. Bye :(";
    exit 0;
fi

_end_msg
############  Clean Cache  ############
rm -rf ${HomeDir}
