#!/bin/bash
#written by wenhao

[ -f ../../common/shell/common.sh ] && . ../../common/shell/common.sh

OSType=$(check_os_type)
if [[ $OSType = "debian" ]];then
    megacli=/usr/sbin/megacli
elif [[ $OSType = "redhat" ]];then
    megacli=/opt/MegaRAID/MegaCli/MegaCli64
fi
lsscsi=/usr/bin/lsscsi

check_cmd $megacli
check_cmd $lsscsi

isSSD()
{
    tid=$(lsscsi | grep $1 | awk -F ':' '{print $3}')
    [[ -z "$tid" ]] && return 1
    $megacli -ldpdinfo -aall -NoLog | sed -n "/Target Id: $tid/,/Media Type:/p"  | grep -q "Solid State Device"
    return $?
}

check_ssd()
{
    for i in /sys/block/sd*
    do
        d=/dev/${i##*/}
        f=$i/queue/scheduler
        if isSSD $d ;then
            printf "%s:\t" $i
            grep -o '\[.*\]' $f 
        fi
    done
}

check_status Check_SSD
