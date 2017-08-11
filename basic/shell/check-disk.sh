#!/bin/bash
#written by wenhao

[ -f ../../common/shell/common.sh ] && . ../../common/shell/common.sh

thresholdSpace="85"
thresholdInode="85"

check_space()
{
    df | tr -d '%' | awk -v th="$thresholdSpace" 'NR>1{if($5>th)print $NF}' 
}

check_inode()
{
    df -i | tr -d '%' | awk -v th="$thresholdInode" 'NR>1{if($5>th)print $NF}'
}

check_disk()
{
    if [[ -z $(check_space) && -z $(check_inode) ]];then
        :
    else
        echo "disk full"
    fi
}

check_status Check_Disk
