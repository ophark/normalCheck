#!/bin/bash
#written by wenhao

[ -f ../../common/shell/common.sh ] && . ../../common/shell/common.sh

check_raid()
{
    have_raid=0
    message=''
    lspci |grep -iq raid && have_raid=1
    if [ $have_raid -eq 0 ];then
        :
    else
    # 0 -> arcconf; 1 -> megacli
        raid_type=0
        lspci |grep -i raid|egrep -iq 'arc|Adaptec'  && raid_type=0
        lspci |grep -i raid|egrep -iq 'dell|mega|lsi' && raid_type=1
        if [ $raid_type -eq 1 ];then
            message=`megasasctl 2> /dev/null|grep 'B RAID'|grep -i -v optimal`
        elif [ $raid_type -eq 0 ];then
            message=`arcconf getconfig 1 ld 2> /dev/null |grep "Status of logical device"|grep -i -v Optimal`
        else
            :
        fi
        echo $message
    fi
}

check_status Check_Raid
