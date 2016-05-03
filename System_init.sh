#!/bin/bash
# Name：System init 
# Date: 2016年5月3日
. /etc/init.d/functions
shopt -s -o nounset
#function
##执行状态监测
Eq_test(){
	 if [ $1 -eq 0 ]
		then 
		success	
        echo "Software install Succees!" 
            sleep 10
     else
         warning
             echo "Error!"  
			 exit 1
	fi 
}
##修改IP，注意输入法和只接受数字
function Modified_ip(){
	tmp_file="/tmp/tmp.$$"
    echo  -ne "\E[31;49m""\033[5mplease input Network Devices(eth0&&eth1):\033[0m"
	read  ethcfg
	ip_conf="/etc/sysconfig/network-scripts/ifcfg-$ethcfg"
	if [ -f $ip_conf ];then 
	    cp $ip_conf $ip_conf.bak
	    echo  "The first block of network card  exist"
	else
	    echo "The first block of network card don't exist'"
	fi
	tmp_file="/tmp/tmp.$$"
	echo -ne "\E[31;49m""\033[5mplease input IP(number):\033[0m"
	 read  ip
	echo -ne "\E[31;49m""\033[5mplease input GATEWAY(number):\033[0m"
	 read  gateway
	echo -ne "\E[31;49m""\033[5mplease input DNS(number):\033[0m" 
    read dns
	sed -e "s/^.*IPADDR=.*/IPADDR=$ip/;s/^.*GATEWAY=.*/GATEWAY=$gateway/;s/^.*DNS1=.*/DNS1=$dns/;s/^.*ONBOOT=.*/ONBOOT=Static/;"  $ip_conf > $tmp_file
	
	if [ $? -eq 0 ];then
	    cp $tmp_file $ip_conf
	    echo -e "\E[32;49m""\033[5mModify the configuration wait...\033[0m" && sleep 5 && echo " "
	    echo -e "\E[32;49m""\033[5mModify the configuration successfully ...\033[0m"
	    cat $ip_conf 
	    echo -e "\E[36;49m""\033[5mservice network restart wait ...\033[0m"
	    service network restart
	else
	    echo -e "\E[31;49m""\033[5mModify the configuration fail...\033[0m"
	    exit 1
	fi	
	}

##Yum test
function Yum_test(){
	echo        "       *******     Test Yum System!  Please wait!   ********"
	rpm -qa 
	yum clean all 1>>/tmp/yum.log
    yum list  1>>/tmp/yum.log  2>>/tmp/yum.log
    if [ $? -eq 0 ]
    then 
       echo    "       *Yum Test Success!  Install.....(Log file path /tmp/yum.log)***"
   #install 
    yum install -y 1>>/tmp/yum.log  2>>/tmp/yum.log 
   eq_suc $?
   else 
   echo    "    *****  Yum is Bad!(Log file path /tmp/yum.log)   ******"
   exit 1
fi			
}






#执行
   yum remove dhclient -y && echo -e "Remove"
  Modified_ip
  ##修改selinux
  lokkit --disabled --selinux=disabled  && echo -e "Selinux set disabled,Reboot$(Reboot)..."