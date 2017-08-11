#!/bin/bash
#written by wenhao

[ -f ../../common/shell/common.sh ] && . ../../common/shell/common.sh

thresholdSpeed=2000

check_cpu()
{
    egrep -i 'proce|MHz' /proc/cpuinfo  | sed 'N;s/\n/ /' | awk -v th=$thresholdSpeed '$NF<th{print $0}'
}

check_status Check_Cpu
