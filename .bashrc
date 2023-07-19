# Sample .bashrc for SuSE Linux
# Copyright (c) SuSE GmbH Nuernberg

# There are 3 different types of shells in bash: the login shell, normal shell
# and interactive shell. Login shells read ~/.profile and interactive shells
# read ~/.bashrc; in our setup, /etc/profile sources ~/.bashrc - thus all
# settings made here will also take effect in a login shell.
#
# NOTE: It is recommended to make language settings in ~/.profile rather than
# here, since multilingual X sessions would not work properly if LANG is over-
# ridden in every subshell.

# Some applications read the EDITOR variable to determine your favourite text
# editor. So uncomment the line below and enter the editor of your choice :-)
#export EDITOR=/usr/bin/vim
#export EDITOR=/usr/bin/mcedit

# For some news readers it makes sense to specify the NEWSSERVER variable here
#export NEWSSERVER=your.news.server

# If you want to use a Palm device with Linux, uncomment the two lines below.
# For some (older) Palm Pilots, you might need to set a lower baud rate
# e.g. 57600 or 38400; lowest is 9600 (very slow!)
#
#export PILOTPORT=/dev/pilot
#export PILOTRATE=115200

test -s ~/.alias && . ~/.alias || true

# osc config
export COMP_WORDBREAKS=${COMP_WORDBREAKS/:/}

# PATH Config
export PATH=$HOME/.local/bin:$PATH

# Start neofetch
/usr/bin/neofetch

# Load user completion statement
# source $HOME/.local/share/bash-completion/completions/*

############################# 回收站配置 ######################################
# 依赖 https://github.com/andreafrancia/trash-cli
# 依赖 autotrash
# 安装 pip3 install trash-cli
# 安装 zypper install autotrash
# 配置 autotrash -T ~/.local/share/trash -d 3 --install  # -d 表示自动清除?天前的文件
# 配置 systemctl --user enable autotrash.timer
# 以下替换rm操作仅在用户操作,shell脚本不受影响
###############################################################################

# 回收站存放目录
export TRASH_CAN=$HOME/.local/share/trash
if [ ! -d "$TRASH_CAN" ]; then
  mkdir -p $TRASH_CAN
fi
# 修改默认目录
alias trash-list="trash-list --trash-dir $TRASH_CAN"
alias trash-empty="trash-empty --trash-dir $TRASH_CAN"
alias trash-put="trash-put --trash-dir $TRASH_CAN"

# 更改trash补全声明为rm
eval "$(trash --print-completion bash)"
complete -F _shtab_trash rm

rpl_rm(){

    OPTS=""
    FILE=""
    LINK=""
    DIR=""
    ONLY_OPTS=true
    REMOVE_DIR=false
    REMOVE_EMPTY_DIR=false

    # 解析操作符
    for ((index=1;index<=$#; index++))
        do
        if [[ "${!index}" == -* ]]; then
            OPTS="$OPTS ${!index}"
            # 如果有递归删除的操作符
            # 将RM_DIR变量设置为true
            if [[ "${!index}" =~ ^-[a-zA-Z]*[rR]|^--recursive$ ]]; then
                REMOVE_DIR=true
            # 是否启用删除空目录选项
            elif [[ "${!index}" =~ ^-[a-zA-Z]*d|^--dir$|^--directory$ ]]; then
                REMOVE_EMPTY_DIR=true
            fi
        else
            ONLY_OPTS=false
            shift $[index-1]
            break
        fi
    done
    
    if [[ $ONLY_OPTS == true ]]; then
        # shift $[index-1]
        trash $OPTS
        return
    fi

    for ((index=1;index<=$#; index++))
        do

        if [ -L "${!index}" ]; then
            LINK="$LINK ${!index}"

        elif [ -f "${!index}" ]; then
            FILE="$FILE ${!index}"

        elif [ -d "${!index}" ]; then
            DIR="$DIR ${!index}"
        
        else
            echo "${!index} 不存在" >&2
        fi

    done 

    # 启用递归删除
    if [[ $REMOVE_DIR == true ]]; then
        trash $OPTS --trash-dir=$TRASH_CAN $FILE $DIR
        return
    # 未启用递归删除
    else
        if [ ! -z "$FILE" ]; then
            trash $OPTS --trash-dir=$TRASH_CAN $FILE
        fi

        if [ ! -z "$DIR" ]; then
            # 启用删除空目录
            if [[ $REMOVE_EMPTY_DIR == true ]]; then
                rm -d $DIR
            else
                rm -i $DIR
            fi
        fi

        if [ ! -z "$LINK" ]; then
            trash -i $OPTS --trash-dir=$TRASH_CAN $LINK
        fi

        return
    fi
}
if [[ $0 == /bin/bash ]]; then
    alias rm=rpl_rm
fi
############################# 回收站配置 ######################################
