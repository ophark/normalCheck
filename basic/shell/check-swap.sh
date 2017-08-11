#!/bin/bash
#written by wenhao

[ -f ../../common/shell/common.sh ] && . ../../common/shell/common.sh

check_swap()
{
    awk '/SwapCached/{if($2 > 0) print $0}' /proc/meminfo
}

check_status Check_Swap
