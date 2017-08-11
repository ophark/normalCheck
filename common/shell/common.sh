#!/bin/bash
#written by wenhao

export EchoLockFile=/tmp/echolock

check_os_type()
{
    if [[ -f /etc/redhat-release ]]; then
        echo redhat
    elif [[ -f /etc/debian_version ]]; then
        echo debian
    fi
}

install_locker()
{
    OS=$(check_os_type)
    if [[ "$OS" = "debian" ]];then
        apt-get -y install procmail
    elif [[ "$OS" = "redhat" ]];then
        yum -y install procmail
    fi
}

lock_echo()
{
    if ! check_cmd lockfile &>/dev/null;then
        install_locker
    fi
    lockfile -l 3 $EchoLockFile
}

unlock_echo()
{
    rm -f $EchoLockFile
}

check_cmd()
{
    if which $1 &>/dev/null;then
        return $?
    else
        echo "Command $1 not found"
        exit $?
    fi
}

check_status()
{
    Status=0
    ret=$(${1,,})
    Msg=""
    if [[ -z "${ret}" ]];then
        Status=0
        Msg="''"
    else
        Status=1
        Msg="'$ret'"
    fi
    lock_echo
    echo ==$1: $Status
    echo "Msg: $Msg"
    unlock_echo
}

export -f check_os_type install_locker lock_echo unlock_echo check_cmd check_status
