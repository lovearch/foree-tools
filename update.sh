#!/bin/bash
### Description: 添加对整个工具的更新
### Author: foree
### Date: 20151119
source ./foree-tools.conf

FUNCTION_LIST=`ls |grep -v "install.sh"| grep -v "update.sh" | grep -v "README.md"`

#1.user版本的更新:git pull
#2.所有版本更新project list
#3.

#更新服务器的project列表,不加参数,默认不更新服务器project列表
if [ "x$1" = "x-a" ];then
    ./find_project.sh
    if [ "$?" -ne '0' ];then echo "find project error" ;exit 1 ;fi
else
    echo "skip update server list"
fi

if [ "x$2" = "x-u" ];then
#更新相关文件
for function_list_file in $FUNCTION_LIST
do
    if [ ./$function_list_file -nt $TOOLS_CONFIG_DIR/$function_list_file ];then
        echo "Updating $function_list_file ..."
        cp ./$function_list_file $TOOLS_CONFIG_DIR/$function_list_file
    fi
done
fi
