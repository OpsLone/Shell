#!/bin/bash
. ~/.bash_profile
myfile="Blog.$(date +%y%m%d).tar"
mysqlbp="backfile.sql"
commit_time=$(date +%Y:%m:%d:%H:%M  )
if [ ! -s "$myfile" ]
then
 tar -cvzf /git/${myfile}  /data0/htdocs/blog/*
fi
if [ ! -s "mysqlbp" ]
then 
  mysqldump -h127.0.0.1 -uroot -proot myblog >/git/backfile.sql
fi
if [ $? -eq 0 ]
then     
  cd /git/ 
   /usr/bin/git add $myfile $mysqlbp
    /usr/bin/git commit -m "Update ${commit_time}"
    /usr/bin/git remote add origin git@github.com:OpsLone/git.git
    /usr/bin/git push  origin master
     /bin/mv -f /git/$myfile /tmp/blog.tar
     /bin/mv -f /git/$mysqlbp /tmp/blogsql.sql  
    /usr/bin/git remote rm origin
fi 
