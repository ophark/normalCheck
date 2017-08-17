#!/bin/bash
#written by wenhao

[ -f ../../common/shell/common.sh ] && . ../../common/shell/common.sh

check_nic()
{
    if ls /proc/net/bonding/bond? &>/dev/null;then
        Bond=0;
        Bondnames=($(echo /proc/net/bonding/bond?));
        for Bondname in ${Bondnames[@]}
        do
            bn=${Bondname##*/}
            if [ $(awk '/^Aggregator ID/{s[$0]++}END{for(i in s)m++;print m}' $Bondname) -ne 1 ];then
                echo "$bn: Aggregator ID Error"
            fi
            if [[ $(awk '/Bonding Mode/{print $4}' $Bondname) != "802.3ad" ]];then
                echo "$bn: Bonding Mode Error"
            fi
            if [[ $(awk '/Transmit Hash Policy/{print $4}' $Bondname) != "layer2+3" ]];then
                echo "$bn: Transmit Hash Policy Error"
            fi
            Speed=$(awk '/Speed:/{s+=$2}END{print s}' $Bondname)
            if [[ $Speed -ne 2000 && $Speed -ne 20000 ]];then
                echo "$bn: Speed $Speed"
            fi
        done
   # else
   #     UpIfaces=($(sudo ip a | awk '/state UP/{gsub(":","",$2);print $2}'))
   #     for upiface in ${UpIfaces[@]}
   #     do
   #         Speed=$(sudo ethtool $upiface | awk '/Speed/{gsub("Mb/s","",$NF);print $NF}')
   #         echo "$upiface: Not bonding. Speed $Speed"
   #     done
    fi
}

check_status Check_Nic
