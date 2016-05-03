#!/bin/bash
. /etc/init.d/functions
shopt -s -o nounset
#function
function Modified_ip(){
	tmp_file="/tmp/tmp.$$"
	ip_conf="/etc/sysconfig/network-scripts/ifcfg-eth0"
	if [ -f $ip_conf ];then 
	    cp $ip_conf $ip_conf.bak
	    echo  "The default is the first block of network card"
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
	sed -e "s/^.*IPADDR=.*/IPADDR=$ip/;s/^.*GATEWAY=.*/GATEWAY=$gateway/;s/^.*DNS1=.*/DNS1=$dns/;"  $ip_conf > $tmp_file
	if [ $? -eq 0 ];then
	    cp $tmp_file $ip_conf
	    echo -e "\E[32;49m""\033[5mModify the configuration wait...\033[0m" && sleep 5 && echo " "
	    echo -e "\E[32;49m""\033[5mModify the configuration successfully ...\033[0m"
	    cat $ip_conf 
	    echo -e "\E[36;49m""\033[5mservice network restart wait ...\033[0m"
	    service network restart
	else
	    echo -e "\E[31;49m""\033[5mModify the configuration fail...\033[0m"
	fi	
	}
function Get_Disk_Free(){
		    declare -i TOTAL
			get_usedTotal() {
			    TOTAL=$(df -B 1024K | grep ${p}$ | awk 'NR==1{print $3}')
			    echo "已使用: $TOTAL MB."
			}
			get_avaibleTotal() {
			    TOTAL=$(df -B 1024K | grep ${p}$ | awk 'NR==1{print $4}')
				echo "总共还有: $TOTAL MB."
			}
			p=${1:?'提供分区的挂载点名称，例如: / 或 /home 或 /var'}
			if [[ ! $p == /* ]]; then
			   p=/$p
			fi  
			get_usedTotal $mpoint
			get_avaibleTotal $mpoint

}
function Get_hd_size(){ 
	HD=${1:?'請提供设备名称，比如：hda 或 sda'}
	SIZE=$(fdisk -l /dev/$HD | grep "heads,*" | awk '{print $1 * $3 * $5 / 2048}')
    if [ "$SIZE" = "" ];then 
   	 echo "设备不存在."
    else
	 echo "$HD 的容量大小為 $SIZE MB."
   fi
}
function Get_Sys_load(){
            #Top loading 
			T="/usr/bin/top"
			show_loading=$($T | head -1)
			L1=$(echo $show_loading | awk '{print $12}') 
			L5=$(echo $show_loading | awk '{print $13}')
			L15=$(echo $show_loading | awk '{print $14}')
			L1=${L1%,*}
			L5=${L5%,*}
			L15=${L15%,*}
			echo -e "\E[31;49m""\033[5mSystem Loading\033[0m" 
			echo "1、5、15分钟的平均负载: $L1 $L5 $L15" 
            #Men free   
			FreeCmd="/usr/bin/free"
			Mem=$($FreeCmd | grep ^Mem:)
			TotalMem=$(echo $Mem | awk '{print $2}')
			UsedMem=$(echo $Mem | awk '{print $3}')
			FreeMem=$(echo $Mem | awk '{print $4}')
			echo -e "\E[31;49m""\033[5mMem\033[0m" 
			echo "Mem大小:$TotalMem 已使用:$UsedMem 空余:$FreeMem"
            #Swap Free	
			FreeCmd="/usr/bin/free"
			Mem=$($FreeCmd | grep ^Swap:)
			TotalMem=$(echo $Mem | awk '{print $2}')
			UsedMem=$(echo $Mem | awk '{print $3}')
			FreeMem=$(echo $Mem | awk '{print $4}')
			echo -e "\E[31;49m""\033[5mSwap\033[0m" 
			echo "Swap大小:$TotalMem 已使用:$UsedMem 空余:$FreeMem"
}
function Useradd(){
	read -p "请输入密码文件保存的目录:" Path
	read -p "请输入用户名前缀:" User
	UserDb=$Path/user.db
	FailDb=$Path/fail_user.db
	[ -d "$Path" ] || echo "目录不存在" ||mkdir -p $Path
	[ -f "$UserDb" ] || touch $UserDb
	[ -f "$FailDb" ] || touch $FailDb
	for n in $(seq -w 10)
	do
	passwd=`echo $(date +%t%N)$RANDOM|md5sum|cut -c 2-9`
	useradd $User$n >&/dev/null && user_status=$?
	echo "$passwd"|passwd --stdin user$n >&/dev/null && pass_status=$?
	if [ $user_status -eq 0 -a $pass_status -eq 0 ];then
	action "adduser user$n" /bin/true
	echo -e "user:\tuser$n pass:$passwd" >>$UserDb
	else
	action "adduser oldboy$n" /bin/false
	echo -e "user:\toldboy$n pass:$passwd" >>$FailDb
	fi
	done 
	#ACTfile=`ls /home/user.db`
	#[ ! -f "$ACTfile" ] && echo "帐号文件 $ACTfile 不存在." && exit 1
}
function Userdel(){
	    fail_user=$Path/fail_user.db
	    [ -d "$Path" ] || echo "目录不存在" ||mkdir -p $Path
	    ACTfile=${1:?'错误！请提供帐号文件'}
		[ ! -f "$ACTfile" ] && echo "帐号文件 $ACTfile 不存在."  && exit 1 
		declare -i okdel=0
		act=''
		password=''
		while read act password 
		do
		    userdel -r $act
		    if [ $? -eq 0 ]; then
		       ((okdel++))
		       echo "已删除帐号 $act ...."
		    fi
		done < <(awk 'BEGIN{FS=" "} /\w:\w/ {print $2}' $ACTfile)
		rm -f $1
		rm -f $fail_user 
		echo "共删除 $okdel 个帐号.密码文件已删除"
}	
function Check_host_staus(){
	read -p "请输入网络地址段(192.168.1.)：" ip
	#$ip="192.168.1."
	times=0
	echo -e "\E[31;49m""\033[5mPlease wait\033[0m"
    for n in `seq 1 245`                     
    do 
    	((times++))
        ping -c2 $ip$n >/dev/null 2>&1 
        
    if [ $? -eq 0 ]                      
    then
      echo "$ip$n is up" >>/tmp/uplist.log 
     
    else
      echo "$ip$n is down" >>/tmp/downlist.log 
     
   fi
   done
    echo "检查完成，共用时$times秒，存活主机信息文件在/tmp/uplist.log,失败主机信息文件在/tmp/downlist.log,"
}
#Main
while true
do
	echo -e "\E[36;32m""\033[5m********************\033[0m"
	echo -e "\E[36;32m""\033[5m*  Operation Menu  *\033[0m"
	echo -e "\E[36;32m""\033[5m********************\033[0m"
	echo -e "\E[36;32m""\033[5m*   choice [0-6]   *\033[0m"
cat << EOF 
6)配置网络
5)检查主机状态
4)用户操作(add、del)
3)查看硬盘空间
2)查看分区空间
1)查看系统状态
0)退出
EOF

read -p "Choice:" num
    case  $num in
	    6)
			Modified_ip
		   ;;
		5)
			Check_host_staus
			;;
		4) 
		  while true
		  do
		    echo -e "1-添加用户\n2-删除用户\n3-返回上一级"
		    echo -n "choice:" && read num
			case $num in 
				1)
					Useradd
				;;
				2)
				   read -p "请输入密码文件保存的目录:" Path
	               ACTfile=$Path/user.db
				   #ACTfile="/home/user.db"
				   if [ -f $ACTfile ]
				   	then
					  Userdel $ACTfile
					  if [ $? -eq 0 ]
					    then 
					    	echo "账户删除成功"
					    fi
					else
					
					    echo "密码文件错误！"
				        read -p "请输入密码文件保存的目录:" Path   
				        ACTfile=$Path/user.db
				        [ -f $ACTfile ] 
				        if [ $? -eq 0 ]
					    then 
					        Userdel  $ACTfile
					    	echo "账户删除成功"
					    	break
					    else
					      	 echo "请输入正确的目录！"
					      	 read -p "请输入密码文件保存的目录:" Path   
					      	 echo "你确定是要删除用户？"
					    fi 
					
				   fi 
				;;
				3)
					break
				;;
				*)
					echo "Usage Error!重新输入！"
			    ;;
			esac
		  done
		  ;;
		3)
			read -p "請提供设备名称(hda或sda):" Dev
		   Get_hd_size  $Dev
		   ;;
		2)
           PS3="输入要查询的挂载点数字标识:" 
           export $PS3 2>/dev/null
           select mpoint in `df -B 1024K | awk 'NR>=2{print $6}'`;
           do
                Get_Disk_Free $mpoint   
                break
           done 
             ;;
        1)
        	Get_Sys_load  
        	;;
        0)
            exit 0    
            ;;
		*)
		    echo  "Usage Error!"
		    exit 1  		
       ;;
   esac
done
