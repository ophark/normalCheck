#!/bin/bash
#written by wenhao

[ -f ../../common/shell/common.sh ] && . ../../common/shell/common.sh

check_irq()
{
    for i in $(awk '/(eth[0-9]-|92xx|nvme|megasas)/{print $1 }' /proc/interrupts | sed 's/://g')
    do
        cat /proc/irq/$i/smp_affinity
    done | grep -q 00005555
    [ $? -eq 0 ] && echo not irq balance
}

check_status Check_IRQ
