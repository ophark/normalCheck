#!/bin/bash
#written by wenhao

[ -f ../../common/shell/common.sh ] && . ../../common/shell/common.sh

check_process()
{
    ps aux | egrep "\s(Z|D)\s"
}

check_status Check_Process
