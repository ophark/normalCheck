#!/bin/bash

dec2bin()
{
    local num=$1
    local result=
    while [ $num -gt 0 ]                        #辗转相除法
    do
        result=$((num%2))$result
        num=$((num>>1))
    done
    echo "$result"
}

dec2bin2()
{
    Arr=({0..1}{0..1}{0..1}{0..1}{0..1}{0..1}{0..1}{0..1})
    [[ $1 -gt 255 ]] && { echo 00000000; return 1; }
    echo ${Arr[$1]}
}

inet_aton()
{
    for ip in $@
    do
        [[ $ip =~ ^[0-9]+\.[0-9]+\.[0-9]+\.[0-9]+$ ]] || { printf "%-16s%s\n" "$ip" "ErrorIP";continue; }
        read n1 n2 n3 n4 <<<$(echo $ip | awk -F '.' '{print $1,$2,$3,$4}')
        (( $n1 > 255 || $n2 > 255 || $n3 > 255 || $n4 > 255 )) && { printf "%-16s%s\n" "$ip" "ErrorGT255";continue; }
        n=$(( (n1<<24) + (n2<<16) + (n3<<8) + n4 ))
        #echo -e "$ip\t$n"
        printf "%-16s%s\n" $ip $n
    done
}

inet_ntoa()
{
    for n in $@
    do
        [[ $n =~ ^[0-9]+$ ]] || { printf "%s\t%s\n" "$n" "ErrorNumber";continue; }
        (( $n > 4294967296 )) && { printf "%s\t%s\n" "$n" "ErrorGT32";continue; }
        ip=$((n>>24 & 255)).$((n>>16 & 255)).$((n>>8 & 255)).$((n & 255))
        #echo -e "$n:\t$ip"
        printf "%s\t%s\n" $n $ip
    done
}

inet_maska()
{
    for m in $@
    do
        if [[ $m =~ ^[0-9]+$ && $m -le 32 ]];then
            # m <= 32
            local maskpre=
            local maskpost=
            eval printf -v maskpre "%.s1" {1..$m}
            [ $m -lt 32 ] && eval printf -v maskpost "%.s0" {1..$((32-m))}
            maskn=$[2#$maskpre$maskpost]
            read e maska <<<$(inet_ntoa $maskn)
        elif [[ $m =~ ^[0-9]+\.[0-9]+\.[0-9]+\.[0-9]+$ ]];then
            read n1 n2 n3 n4 <<<$(echo $m | awk -F '.' '{print $1,$2,$3,$4}')
            (( $n1 > 255 || $n2 > 255 || $n3 > 255 || $n4 > 255 )) && { printf "%-16s%s\n" "$ip" "ErrorGT255";continue; }
            read e maskn <<<$(inet_aton $m)
            maskbin=$(dec2bin $maskn)
            [[ "$maskbin" =~ ^1+0*$ ]] || { printf "%-16s%s\n" "$m" "ErrorMask";continue; }
            maska=$m
        else
            printf "%-16s%s\n" "$m" "ErrorMask"
            return 1
        fi
        printf "%-16s%s\n" $m $maska
    done
}

inet_maskn()
{
    for m in $@
    do
        if [[ $m =~ ^[0-9]+$ && $m -le 32 ]];then
            # m < 32
            local maskpre=
            local maskpost=
            eval printf -v maskpre "%.s1" {1..$m}
            [ $m -lt 32 ] && eval printf -v maskpost "%.s0" {1..$((32-m))}
            maskn=$[2#$maskpre$maskpost]
        elif [[ $m =~ ^[0-9]+\.[0-9]+\.[0-9]+\.[0-9]+$ ]];then
            read n1 n2 n3 n4 <<<$(echo $m | awk -F '.' '{print $1,$2,$3,$4}')
            (( $n1 > 255 || $n2 > 255 || $n3 > 255 || $n4 > 255 )) && { printf "%-16s%s\n" "$ip" "ErrorGT255";continue; }
            read e maskn <<<$(inet_aton $m)
            maskbin=$(dec2bin $maskn)
            [[ "$maskbin" =~ ^1+0*$ ]] || { printf "%-16s%s\n" "$m" "ErrorMask";continue; }
        else
            printf "%-16s%s\n" "$m" "ErrorMask"
            return 1
        fi
        printf "%-16s%s\n" $m $maskn
    done
}

inet_maskpre()
{
    for m in $@
    do
        if [[ $m =~ ^[0-9]+$ && $m -le 32 ]];then
            maskpre=$m
        elif [[ $m =~ ^[0-9]+\.[0-9]+\.[0-9]+\.[0-9]+$ ]];then
            read n1 n2 n3 n4 <<<$(echo $m | awk -F '.' '{print $1,$2,$3,$4}')
            (( $n1 > 255 || $n2 > 255 || $n3 > 255 || $n4 > 255 )) && { printf "%-16s%s\n" "$ip" "ErrorGT255";continue; }
            read e maskn <<<$(inet_aton $m)
            #maskprebin=$(echo "ibase=10;obase=2;$maskn" | bc | egrep -o '^1+')
            masknbin=$(dec2bin $maskn)
            maskprebin=$(echo $maskbin | egrep -o '^1+')
            maskpre=${#maskprebin}
        else
            printf "%-16s%s\n" "$m" "ErrorMask"
            return 1
        fi
        printf "%-16s%s\n" $m $maskpre
    done
}

inet_netn()
{
    for cidr in $@
    do
        read ip mask <<<$(echo $cidr | awk -F '/' '{print $1,$2}')
        read e ipn <<<$(inet_aton $ip)
        read e maskn <<<$(inet_maskn $mask)
        if echo $ipn | grep -iq error;then
            printf "%-32s%s\n" $cidr $ipn
            continue
        elif echo $maskn | grep -iq error;then
            printf "%-32s%s\n" $cidr $maskn
            continue
        else
            :
        fi
        netn=$((ipn & maskn))
        printf "%-32s%s\n" $cidr $netn
    done
}

inet_neta()
{
    for cidr in $@
    do
        read ip mask <<<$(echo $cidr | awk -F '/' '{print $1,$2}')
        read e ipn <<<$(inet_aton $ip)
        read e maskn <<<$(inet_maskn $mask)
        if echo $ipn | grep -iq error;then
            printf "%-32s%s\n" $cidr $ipn
            continue
        elif echo $maskn | grep -iq error;then
            printf "%-32s%s\n" $cidr $maskn
            continue
        else
            :
        fi
        netn=$((ipn & maskn))
        read e neta <<<$(inet_ntoa $netn)
        printf "%-32s%s\n" $cidr $neta
    done
}

inet_brodcast()
{
    for cidr in $@
    do
        read ip mask <<<$(echo $cidr | awk -F '/' '{print $1,$2}')
        read e ipn <<<$(inet_aton $ip)
        read e maskn <<<$(inet_maskn $mask)
        if echo $ipn | grep -iq error;then
            printf "%-32s%s\n" $cidr $ipn
            continue
        elif echo $maskn | grep -iq error;then
            printf "%-32s%s\n" $cidr $maskn
            continue
        else
            :
        fi
        netn=$((ipn & maskn))
        maskpostn=$(( ((1<<32) - 1)  ^ maskn ))
        brdcastn=$(( netn | maskpostn ))
        read e brdcast <<<$(inet_ntoa $brdcastn)
        printf "%-32s%s\n" $cidr $brdcast
    done
}

inet_minip()
{
    for cidr in $@
    do
        read ip mask <<<$(echo $cidr | awk -F '/' '{print $1,$2}')
        read e ipn <<<$(inet_aton $ip)
        read e maskn <<<$(inet_maskn $mask)
        if echo $ipn | grep -iq error;then
            printf "%-32s%s\n" $cidr $ipn
            continue
        elif echo $maskn | grep -iq error;then
            printf "%-32s%s\n" $cidr $maskn
            continue
        else
            :
        fi
        netn=$((ipn & maskn))
        minipn=$((netn + 1))
        read e minip <<<$(inet_ntoa $minipn)
        printf "%-32s%s\n" $cidr $minip
    done
}

inet_minipn()
{
    for cidr in $@
    do
        read ip mask <<<$(echo $cidr | awk -F '/' '{print $1,$2}')
        read e ipn <<<$(inet_aton $ip)
        read e maskn <<<$(inet_maskn $mask)
        if echo $ipn | grep -iq error;then
            printf "%-32s%s\n" $cidr $ipn
            continue
        elif echo $maskn | grep -iq error;then
            printf "%-32s%s\n" $cidr $maskn
            continue
        else
            :
        fi
        netn=$((ipn & maskn))
        minipn=$((netn + 1))
        printf "%-32s%s\n" $cidr $minipn
    done
}

inet_maxip()
{
    for cidr in $@
    do
        read ip mask <<<$(echo $cidr | awk -F '/' '{print $1,$2}')
        read e ipn <<<$(inet_aton $ip)
        read e maskn <<<$(inet_maskn $mask)
        if echo $ipn | grep -iq error;then
            printf "%-32s%s\n" $cidr $ipn
            continue
        elif echo $maskn | grep -iq error;then
            printf "%-32s%s\n" $cidr $maskn
            continue
        else
            :
        fi
        netn=$((ipn & maskn))
        maskpostn=$(( ((1<<32) - 1)  ^ maskn ))
        maxipn=$(((netn | maskpostn) - 1))
        read e maxip <<<$(inet_ntoa $maxipn)
        printf "%-32s%s\n" $cidr $maxip
    done
}

inet_maxipn()
{
    for cidr in $@
    do
        read ip mask <<<$(echo $cidr | awk -F '/' '{print $1,$2}')
        read e ipn <<<$(inet_aton $ip)
        read e maskn <<<$(inet_maskn $mask)
        if echo $ipn | grep -iq error;then
            printf "%-32s%s\n" $cidr $ipn
            continue
        elif echo $maskn | grep -iq error;then
            printf "%-32s%s\n" $cidr $maskn
            continue
        else
            :
        fi
        netn=$((ipn & maskn))
        maskpostn=$(( ((1<<32) - 1)  ^ maskn ))
        maxipn=$(((netn | maskpostn) - 1))
        printf "%-32s%s\n" $cidr $maxipn
    done
}

# inet_neta 172.19.1.10/21 10.200.152.189/21 123.58.180.186/24 123.58.180.186/255.a.255.0 192.168.188.133/255.255.255.254
#inet_minip $@
#inet_maxip $@
#inet_neta $@
#inet_brodcast $@
