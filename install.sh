#!/bin/bash
### Description: 自己的工具集合的安装脚本
### Author: foree
### Date: 20151025

source ./foree-tools.conf
source ./common.sh

#FUNCTION_LIST="common.sh fastboot_flash.sh pick_branch.sh ssh_bringup.sh fadb_funtion fkill foree-tools.conf SERVER_0 SERVER_1"
FUNCTION_LIST=`ls |grep -v "install.sh"| grep -v "update.sh" | grep -v "README.md"`
LINK_LIST="bringup_ssh fadb fkill frepo ftools flash_fastboot"
LINK_PATH=

#导出函数列表到指定文件
function _export_function_to_shell()
{
    local SHELL_RC

    #判断当前shell
    if (echo -n $SHELL |grep -q "bash" ); then
        SHELL_RC=.bashrc
    elif ( echo -n $SHELL |grep -q "zsh" ); then
        SHELL_RC=.zshrc
    fi

    #是否已经导出函数列表
    if [ ! -z "$(cat ~/$SHELL_RC |grep foree-tools)" ];then
        echo "$SHELL_RC write already! skip !"
    else
        whattime=`date +%Y_%m%d_%H%M`
        cat>> ~/$SHELL_RC <<EOF
# $whattime add by foree-tools
# This is auto generate by foree-tools, Do Not Delete it
source $DEBUG_PATH/export_to_shell
# end by foree-tools
EOF
        echo "Add to $SHELL_RC success"
    fi
}

#根据README.md输出帮助文档
function _output_help()
{
    echo
    flog -w "帮助文档"
    echo

    sed -f ./sed_command README.md > _foree_tools_help

    source _foree_tools_help

    rm _foree_tools_help
}

#链接可执行文件
function _link_script()
{
    for i in $LINK_LIST
    do
        if [ ! -f /usr/local/bin/$i -a -n "$LINK_PATH" ];then
            sudo ln -s $LINK_PATH/$i /usr/local/bin/$i
            echo "Linking $i =====> /usr/local/bin/$i"
        fi
    done
}

function main()
{
    #检查是否以sudo运行命令
    if (sudo echo -n);then
        echo -n
    else
        echo "You must be root Or use \"sudo install.sh\""
        exit
    fi

    #检查是否安装realpath软件包
    realpath
    if [ $? -ne '0' ];then
        flog -e "realpath not install!!"
        exit 1
    fi
    #检查

    #取得DEBUG路径,并写入配置文件
    DEBUG_PATH=`pwd`
    sed -i "/DEBUG_PATH/ s#=.*#=$DEBUG_PATH#" ./foree-tools.conf

    LINK_PATH=$DEBUG_PATH

    #取得链接的文件,并写入配置文件
    sed -i "/LINK_LIST/ s#=.*#=\"$LINK_LIST\"#" $LINK_PATH/foree-tools.conf

    #导出函数列表到环境变量
    _export_function_to_shell

    #链接可执行文件
    _link_script

    #输出帮助文档
    _output_help

}
main $@
