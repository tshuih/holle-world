#!/bin/bash

#file is check_mysql.sh
#Author by tom 20151202

mstool="mysql -h $1 -u tshuih -p****"
sltool="mysql -S /tmp/mysql$2.sock -uroot -p****"

declare -a slave_stat
slave_stat=($($sltool -e "show slave status\G"|grep Running |awk '{print $2}'))

if [ "${slave_stat[0]}" = "Yes" -a "${slave_stat[1]}" = "Yes" ]
     then
     echo "OK slave is running"
     exit 0
else
     echo "Critical slave is error"
     echo
     echo "*********************************************************"
     echo "Now Starting replication with Master Mysql!"
        file=`$mstool -e "show master status\G"|grep "File"|awk '{print $2}'`
        pos=`$mstool -e "show master status\G"|grep "Pos"|awk '{print $2}'`
        $sltool -e "slave stop;change master to master_log_file='$file',master_log_pos=$pos;slave start;"
        sleep 3
        $sltool -e "show slave status\G;"|grep Running
    echo
    echo "Now Replication is Finished!"
    echo
    echo "**********************************************************"
        exit 2
fi
