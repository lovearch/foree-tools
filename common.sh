#!/bin/bash
### Description: 对于已经编译过的版本,可以直接lunch上一次编译的类型
### Author:foree
### Date:20151109

function yes_or_no
{
    read input_choice
    case $input_choice in
        y|yes|Y|Yes)
            echo 'y'
            ;;
        n|no|N|NO)
            echo 'n'
            ;;
        *)
            echo "input error,please again"
            yes_or_no
            ;;
    esac
}

#获取AndroidProject的TOP目录
function _gettopdir()
{

    local TOPDIRFILE=build/core/envsetup.mk
    TOPDIR=
    HERE=`pwd`
    if [ ! -f $TOPDIRFILE ];then
        while [ ! -f $TOPDIRFILE -a "$PWD" != "/" ]; do
            \cd ..
            TOPDIR=`pwd -P`
        done
    else
        TOPDIR=`pwd -P`
    fi

    cd $HERE
    if [ -f $TOPDIR/$TOPDIRFILE ];then
        echo $TOPDIR
    fi
}

#获取一个Android Project的TOP目录
function _getrepodir()
{

    local REPODIRFILE=.repo/manifests/default.xml
    TOPDIR=
    HERE=`pwd`
    if [ ! -f $REPODIRFILE ];then
        while [ ! -f $REPODIRFILE -a "$PWD" != "/" ]; do
            \cd ..
            TOPDIR=`pwd -P`
        done
    else
        TOPDIR=`pwd -P`
    fi

    cd $HERE
    if [ -f $TOPDIR/$REPODIRFILE ];then
        echo $TOPDIR
    fi
}

#获取Android Project的PRODUCT_TARGET
function _gettarget()
{
    local TOPDIR=$(_gettopdir)

    if [ -z $TOPDIR ];then echo "Not Found Project Here !!";return 1 ;fi

    if [ -d $TOPDIR/out/target/product ];then
        cd $TOPDIR/out/target/product
    else
        add_color_for_echo "You Must be run lunch manually first !!" >&2
        return 1
    fi

    previous_path=$(find . -maxdepth 2 -name "previous_build_config.mk" |xargs ls -t1 | grep -v "generic")
    previous_number=$( echo "$previous_path" |wc -l )
    if [ $previous_number -eq '0' ];then
        echo "previous_build_config.mk not found, You Must be run lunch manually first !!"
        cd $HERE
        return 1
    elif [ $previous_number -gt '1' ];then
        previous_path=$(echo "$previous_path" |head -1)
    fi

    product_name=${previous_path#*/}
    product_name=${product_name%/*}
    lunch_name=$( grep $previous_path -e "[a-z]*_$product_name-[a-z]*" -o)

    echo $lunch_name

}

#Log函数：
#1.不同等级log不同颜色标识
#2.平常运行flogI(无色彩)，提示flogW(黄色)，运行出错flogE(红色)，多余的信息flogD(蓝色)
#3.控制log打开使用
function flog()
{
    case $1 in
        -I)
            #flogI
            echo "$2"
            ;;
        -W)
            #flogW
            _echo_yellow "$2"
            ;;
        -E)
            #flogE
            _echo_red "$2"
            ;;
        -D)
            #flogD
            if [ "x$DEBUG" = "xtrue" ];then
                _echo_blue "$2"
            fi
            ;;
        *)
            ;;
    esac


}

#将输入的字符加红色
function _echo_red()
{
    echo -e "\033[31m$1\033[0m"
}

#将输入的字符加天蓝色
function _echo_blue()
{
    echo -e "\033[36m$1\033[0m"
}

#将输入的字符加黄色
function _echo_yellow()
{
    echo -e "\033[33m$1\033[0m"
}

#将输入的字符加绿色
function _echo_green()
{
    echo -e "\033[32m$1\033[0m"
}
