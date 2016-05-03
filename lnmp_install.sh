#!/bin/bash
. /etc/init.d/functions
eq_suc(){
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
lib_suc(){
    if  [ $? -eq 0  ]
      then 
          eq_suc 0
    else 
          eq_suc 1 
   fi
}
#Note 
 echo  "       ##############Thanks  for  http://zyan.cc/ ............  "

#yum test
echo        "       *******     Test Yum System!  Please wait!   ********"
if [ $? -eq 0 ]
then 
   echo    "    *****  Yum Test Success!(Log file path /tmp/yum.log)   ******"
   #install 
softpath="/data0/software"
if [ -n "`ls $softpath/*.{gz,tgz,bz2}`" ];
then
     echo "Software is have!"
else
     echo "Directory not have software,Download....."
     sleep 10
     cd  $softpath
   fi
fi
# install php lib 
echo "       Install PHP lib ...... "
tar zxvf libiconv-1.13.1.tar.gz
cd libiconv-1.13.1/
./configure --prefix=/usr/local
make 
make install 
eq_suc  $?
cd /data0/software

tar zxvf libmcrypt-2.5.8.tar.gz 
cd libmcrypt-2.5.8/
./configure
make 
make install 
/sbin/ldconfig
cd libltdl/
./configure --enable-ltdl-install
make 
make install 
eq_suc $?
cd /data0/software

tar zxvf mhash-0.9.9.9.tar.gz
cd mhash-0.9.9.9/
./configure
make 
make install
eq_suc  $?
cd /data0/software




tar zxvf mcrypt-2.6.8.tar.gz
cd mcrypt-2.6.8/
echo -e "include ld.so.conf.d/*.conf \n/usr/local/lib">/etc/ld.so.conf
/sbin/ldconfig
./configure
make 
make install 
eq_suc  $?
cd /data0/software

#install mysql 

#install php 
echo  "       Now Install PHP......"
sleep 10
   tar zxvf php-5.2.14.tar.gz
   gzip -cd php-5.2.14-fpm-0.5.14.diff.gz | patch -d php-5.2.14 -p1
    cp -frp /usr/lib64/libjpeg.* /usr/lib
    cp -frp /usr/lib64/libpng*  /usr/lib
    cp -frp /usr/lib64/libldap* /usr/lib
  cd php-5.2.14/
./configure --prefix=/usr/local/webserver/php --with-config-file-path=/usr/local/webserver/php/etc --with-mysql=/usr/local/webserver/mysql --with-mysqli=/usr/local/webserver/mysql/bin/mysql_config --with-iconv-dir=/usr/local --with-freetype-dir --with-jpeg-dir --with-png-dir --with-zlib --with-libxml-dir=/usr --enable-xml --disable-rpath --enable-discard-path --enable-safe-mode --enable-bcmath --enable-shmop --enable-sysvsem --enable-inline-optimization --with-curl --with-curlwrappers --enable-mbregex --enable-fastcgi --enable-fpm --enable-force-cgi-redirect --enable-mbstring --with-mcrypt --with-gd --enable-gd-native-ttf --with-openssl --with-mhash --enable-pcntl --enable-sockets --with-ldap --with-ldap-sasl --with-xmlrpc --enable-zip --enable-soap   
make ZEND_EXTRA_LIBS='-liconv'
ln -s /usr/local/lib/libiconv.so.2 /usr/lib64/
make install  
eq_suc  $0
cp php.ini-dist /usr/local/webserver/php/etc/php.ini
cd /data0/software

##Install php  extension lib
echo "       Now Install PHP moudle..."
sleep 5
tar zxvf memcache-2.2.5.tgz
cd memcache-2.2.5/
/usr/local/webserver/php/bin/phpize
./configure --with-php-config=/usr/local/webserver/php/bin/php-config
make
make install
lib_suc $?
cd /data0/software

tar jxvf eaccelerator-0.9.6.1.tar.bz2
cd eaccelerator-0.9.6.1/
/usr/local/webserver/php/bin/phpize
./configure --enable-eaccelerator=shared --with-php-config=/usr/local/webserver/php/bin/php-config
make
make install
lib_suc $?
cd /data0/software

tar zxvf PDO_MYSQL-1.0.2.tgz
cd PDO_MYSQL-1.0.2/
/usr/local/webserver/php/bin/phpize
./configure --with-php-config=/usr/local/webserver/php/bin/php-config --with-pdo-mysql=/usr/local/webserver/mysql
make
make install
lib_suc $?
cd /data0/software

tar zxvf ImageMagick.tar.gz
cd ImageMagick-6.5.1-2/
./configure
make
make install
lib_suc $?
cd /data0/software

tar zxvf imagick-2.3.0.tgz
cd imagick-2.3.0/
/usr/local/webserver/php/bin/phpize
./configure --with-php-config=/usr/local/webserver/php/bin/php-config
make
make install
lib_suc $?
cd /data0/software

# modify php.ini
sed -i 's#extension_dir = "./"#extension_dir = "/usr/local/webserver/php/lib/php/extensions/no-debug-non-zts-20060613/"\nextension = "memcache.so"\nextension = "pdo_mysql.so"\nextension = "imagick.so"\n#' /usr/local/webserver/php/etc/php.ini 
    sed -i 's#output_buffering = Off#output_buffering = On#' /usr/local/webserver/php/etc/php.ini  
    sed -i "s#; always_populate_raw_post_data = On#always_populate_raw_post_data = On#g" /usr/local/webserver/php/etc/php.ini      
    sed -i "s#; cgi.fix_pathinfo=0#cgi.fix_pathinfo=0#g" /usr/local/webserver/php/etc/php.ini  
if [ $? -eq 0 ]
then 
	echo "   Modify php.ini Success .....  "
    sleep 5
else 
     echo "  Modify php.ini Fail .....   "
     exit 1 
fi  

#eAccelerator加速PHP
cp /usr/local/webserver/php/etc/php.ini   /usr/local/webserver/php/etc/php.ini.bak 
mkdir -p /usr/local/webserver/eaccelerator_cache
echo -e "[eaccelerator]\nzend_extension="/usr/local/webserver/php/lib/php/extensions/no-debug-non-zts-20060613/eaccelerator.so"\neaccelerator.shm_size="64"\neaccelerator.cache_dir="/usr/local/webserver\neaccelerator_cache"\neaccelerator.enable="1"\neaccelerator.optimizer="1"\neaccelerator.check_mtime="1"\neaccelerator.debug="0"\neaccelerator.filter=""\neaelerator.shm_max="0"\neaccelerator.shm_ttl="3600"\neaccelerator.shm_prune_period="3600"\neaccelerator.shm_only="0"\neaccelerator.compress="1"\neaccelerator.compress_level="9"" >> /usr/local/webserver/php/etc/php.ini
if [ $? -eq 0 ]
then 
echo  -e "   Config   eAccelerator  advance  PHP....\n   Config success php.ini backup php.ini.bak"
else 
    echo " Error  " &&  exit 1
fi
#创建www用户和组，以及供blog.zyan.cc和www.zyan.cc两个虚拟主机使用的目录：
/usr/sbin/groupadd www
/usr/sbin/useradd -g www www
if [ $? -eq 0 ]
then 
  echo "Add  System User and Group www Success....."
  sleep 10 
  mkdir -p /data0/htdocs/blog
  chmod +w /data0/htdocs/blog
  chown -R www:www /data0/htdocs/blog
  mkdir -p /data0/htdocs/www
  chmod +w /data0/htdocs/www
  chown -R www:www /data0/htdocs/www  
else 
  echo "Error:Add User or Group  Fail! "     
  exit 1 
fi 
#创建php-fpm配置文件（php-fpm是为PHP打的一个FastCGI管理补丁，可以平滑变更php.ini配置而无需重启php-cgi）
cd /data0/software/
if [ -e php-fpm.conf ]
then 
   mv  /usr/local/webserver/php/etc/php-fpm.conf  /usr/local/webserver/php/etc/php-fpm.bak 2>/dev/null
   cp $softpath/php-fpm.conf  /usr/local/webserver/php/etc/php-fpm.conf 2>/dev/null
   echo "Creation php-fpm.conf(/usr/local/webserver/php/etc/php-fpm.conf)"
   sleep 5
else
   echo "Creation  file fail,Please from ${softpath} copy!" 
   exit 1
fi

#启动php-cgi进程，监听127.0.0.1的9000端口，进程数为128，用户为www,修改php.ini后不重启php-cgi，重新加载配置文件使用reload。
echo "Start php-cgi process...."
sleep 6
ulimit -SHn 65535
/usr/local/webserver/php/sbin/php-fpm start 2>/tmp/php-cgi.log
if [ $? -eq 0 ]
then 
     echo  "      Start php-fpm success.... Usrage:{start|stop|quit|restart|reload|logrotate}" 

else
     echo "Fail log file path:/tmp/php-cgi.log"
fi

#Install nginx lib 
echo "       Install Nginx  lib ..... "
sleep 5
cd /data0/software
tar zxvf pcre-8.10.tar.gz
cd pcre-8.10/
./configure
make && make install
eq_suc $?

#Install Nginx 
cd /data0/software
echo "       Install Nginx  web ..... "
sleep 5
tar zxvf nginx-0.8.46.tar.gz
cd nginx-0.8.46/
./configure --user=www --group=www --prefix=/usr/local/webserver/nginx --with-http_stub_status_module --with-http_ssl_module
make && make install
eq_suc $?
#创建Nginx日志目录
mkdir -p /data1/logs
chmod +w /data1/logs
chown -R www:www /data1/logs
#在/usr/local/webserver/nginx/conf/目录中创建nginx.conf文件
cd /usr/local/webserver/nginx/conf/
if [ -e nginx.conf ]
then 
  mv /usr/local/webserver/nginx/conf/nginx.conf /usr/local/webserver/nginx/conf/nginx.bak 
  cp  /data0/software/nginx.conf  /usr/local/webserver/nginx/conf/nginx.conf 2>/dev/null
  success &&  echo "Creation nginx.conf configure file"
   sleep 5  
else
   echo "    Creation nginx.conf configure file fail,Please from package copy${softpath}!" 
   exit 1
fi 
#/usr/local/webserver/nginx/conf/目录中创建fcgi.conf文件
if [ -e fcgi.conf ]
then 
cp /data0/software/fcgi.conf  /usr/local/webserver/nginx/conf/fcgi.conf 
success &&  echo "Creation fcgi.conf configure file"
sleep 5  
else
echo "    Creation fcgi.conf configure file fail,Please from package copy${softpath}!" 
exit 1
fi 
#启动Nginx
echo "       Start Nginx Service...."
/usr/local/webserver/nginx/sbin/nginx  -t 2>>/tmp/Nginx.log
if [ $? -eq 0 ]
then 
ulimit -SHn 65535
/usr/local/webserver/nginx/sbin/nginx 2>>/tmp/nginx.log
lsof -i:80 | grep nginx
sleep 6
echo "Start Nginx Service....Usrage:{start|stop(kill)|reload(-s)}" 
else
echo "Start Nginx Service Fail, Log file path:/tmp/Nginx.log"
exit 1
fi
# 配置开机自动启动Nginx + PHP
echo "       Configure Auto Start Nginx + PHP....."
echo -e "ulimit -SHn 65535\n/usr/local/webserver/php/sbin/php-fpm start\n/usr/local/webserver/nginx/sbin/nginx" >> /etc/rc.local
sleep 5
cat /etc/rc.local
success && echo "       Configure Auto Start Nginx + PHP Success..."
#优化Linux内核参数
cd /data0/software/
if [ -e sysctl.conf ]
then 
cp  /data0/software/sysctl.conf  /etc/sysctl.conf 2>/dev/null
success &&  echo "Optimization of Linux kernel parameters..."
modprobe bridge
/sbin/sysctl -p

sleep 5  
else
echo "       modify /etc/sysctl.conf configure file fail,Please from package copy${softpath}!" 
exit 1
fi 
#corntab 
if [ -e cut_nginx_log.sh ]
then 
cp  /data0/software/cut_nginx_log.sh  /usr/local/webserver/nginx/sbin/cut_nginx_log.sh 2>/dev/null
echo "00 00 * * * /bin/bash  /usr/local/webserver/nginx/sbin/cut_nginx_log.sh >>/tmp/cron.log 2>&1" >>/etc/crontab 
success  &&  echo "     Crontab for cutting Nginx logs..... " 
else
echo "       File fail,Please from package copy${softpath}!" 
exit 1
fi 
#test 
echo  "*********************************************************"
echo  "******PHP.ini on /usr/local/webserver/php/etc/php.ini****"
echo  "*************Software on /data0/software ****************"
echo  "*Nginx.conf on /usr/local/webserver/nginx/conf/nginx.conf*"
echo  "**********My.cnf on  /data0/mysql/3306/my.cnf************"
echo  "**********Web home on  /data0/htdocs/********************"
echo  "*********************************************************"
echo "<?php   phpinfo() ?>" >/data0/htdocs/blog/index.php
yum install -y elinks >/dev/null
echo "127.0.0.1 blog.lnmp.com" >>/etc/hosts
echo "Open elinks blog.lnmp.com"
sleep 3
elinks  blog.lnmp.com

