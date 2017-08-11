#!/bin/bash
#written by wenhao

[ -f ../../common/shell/common.sh ] && . ../../common/shell/common.sh

check_ipmi()
{
    if check_cmd ipmitool;then
        ipmitool sel list
    fi
}

modprobe ipmi_devintf &>/dev/null;
modprobe ipmi_si &>/dev/null;
check_status Check_Ipmi
