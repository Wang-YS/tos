#
# 初始化
#

SERVER_DATA_DIR=${SERVER_DATA_DIR-"$HOME/.tos"}
SERVER_DATA_FILE=${SERVER_DATA_DIR}"/sData"

# todo:
# SERVER_DATA_DIR=${SERVER_DATA_DIR-"./.tos"}
# SERVER_DATA_FILE=${SERVER_DATA_DIR}"/sData"

SERVER_HOST=
SERVER_USERNAME=

setup_file () {
    mkdir -p $SERVER_DATA_DIR
    touch $SERVER_DATA_FILE
}

setup_file

#
# 报错
#

log_err () {
    printf " \033[41;30mERROR\033[0m : %s \n" $1 && exit 1
}

#
# 新增服务器 "username@host" name
#

add_server () {
    local host=${1##*@}
    if [ -z $host ] || [ $host = $1 ]; then
        log_err "缺少host"
    fi

    local username=${1%@*}
    if [ -z "$username" ] || [ $username = "$auth" ]; then
        log_err "缺少username"
    fi
    
    local name=$2
    if [ -z $name ]; then
        name=$host
    fi

    printf "${name} ${host} ${username}\n" >> $SERVER_DATA_FILE
    exit 0
}

#
# 检测文件是否存在，不存在则创建
#



#
# 显示服务器列表 显示 "name<host>"
#

display_list () {
    echo
    awk '{if(length!=0) printf "\t\033[31m"$1"\033[0m<"$2">\n"}' $SERVER_DATA_FILE
    echo
}

#
# 显示手册
#

display_manual () {
    cat << EOF

    tos)
        -a : 增加服务器
        -d : 删除服务器
        -h : 显示操作手册
        -l : 显示服务器列表

        name : 连接服务器

EOF
}

#
# 删除服务器记录
#

delete_server () {
    sed -i '' /^$1/d $SERVER_DATA_FILE
    exit 0
}

#
# 连接服务器
#

connect_server () {
    ssh $1"@"$2
}

#
# 查询指定name的服务器
#

find_server () {
    SERVER_HOST=$(egrep ^$1 $SERVER_DATA_FILE | head -n 1 \
    | awk '{print $2}')
    SERVER_USERNAME=$(egrep ^$1 $SERVER_DATA_FILE | head -n 1 \
    | awk '{print $3}')
}

#
# 主程序
#

if (( $# == 0 )); then
    display_list
    exit 0
else
    case $1 in
    "-a")
        if [ -n "$2" ]; then
            if [ -n "$3" ] && [ "$3" = "--name" ] && [ -n "$4" ]; then
                add_server $2 $4
            else
                add_server $2
            fi
        else 
            log_err 缺少参数
        fi
        ;;
    "-d")
        if [ -z "$2" ]; then
            log_err 缺少参数
        fi
        delete_server $2
        ;;
    "-l")
        display_list
        exit 0
        ;;
    "-h")
        display_manual
        exit 0
        ;;
    *)
        find_server $1
        if [ -z '$SERVER_HOST' ] || [ -z "$SERVER_USERNAME" ]; then
            log_err "服务器信息不存在"
        else
            connect_server $SERVER_USERNAME $SERVER_HOST
        fi
        ;;
    esac
fi
