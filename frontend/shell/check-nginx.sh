#!/bin/bash
#written by wenhao

[ -f ../../common/shell/common.sh ] && . ../../common/shell/common.sh

check_nginx_conf()
{
    msg=$(nginx -t 2>&1)
    if [[ ! $msg =~ ^.*successful.*$ ]];then
        echo "$msg"
    fi
}

check_nginx_worker()
{
    ps aux  | awk '/[n]ginx.*worker/{print $9}' | grep -q '[a-zA-Z]'
    if [ $? -eq 0 ];then
        echo "nginx worker start time warning"
    fi
}

check_nginx()
{
    msg=$(check_nginx_conf)
    if [[ ! -z "$msg" ]];then
        echo "$msg"
    fi
    msg=$(check_nginx_worker)
    if [[ ! -z "$msg" ]];then
        echo "$msg"
    fi
}

check_status Check_Nginx
