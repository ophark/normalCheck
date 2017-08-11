#!/bin/bash
#written by wenhao

[ -f ../../common/shell/common.sh ] && . ../../common/shell/common.sh

check_sysctl()
{
    if [[ $(cat /proc/sys/net/netfilter/nf_conntrack_max) -le 65536 || $(sysctl -a 2>/dev/null | awk '/net.netfilter.nf_conntrack_max/{print $NF}') -le 65536 ]];then
        echo "Warning: net.netfilter.nf_conntrack_max"
    fi
}

check_status Check_Sysctl
