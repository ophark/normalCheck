#!/bin/bash
#written by wenhao

[ -f ../../common/shell/common.sh ] && . ../../common/shell/common.sh

thresholdSpeed=6000

check_fan()
{
    modprobe ipmi_devintf &>/dev/null;
    modprobe ipmi_si &>/dev/null;
    if check_cmd ipmitool;then
        Avgspeed=$(ipmitool -I open sensor | awk -F'|' '/^Fan[0-9]|FAN_[0-9]/{if($2!~"na"){count+=1;sum+=$2;}}END{if(count==0)print "0"; else print sum/count;}');
    fi
    if [ $Avgspeed -lt $thresholdSpeed ];then
        echo "Fan speed less than $thresholdSpeed"
    fi
}

check_status Check_Fan
