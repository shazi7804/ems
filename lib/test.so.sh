#!/bin/bash
# ##############################################################################
#   MySQL
# ##############################################################################

# test
MYSQL_ID='ems'
MYSQL_PWD='emspwd'
MYSQL_HOST='localhost'
MYSQL_SCHEMA='ems'

# staging
# MYSQL_ID='scott'
# MYSQL_PWD='tiger'
# MYSQL_HOST='localhost'
# MYSQL_SCHEMA='test'

MYSQL_COMMAND_ARGS="-s -h ${MYSQL_HOST} -u${MYSQL_ID} -p${MYSQL_PWD} --database=${MYSQL_SCHEMA}"
MYSQL_IGNORE_WARNING='Warning: Using a password on the command line interface can be insecure.'

function MyEcho()
{
    echo "[`date '+%Y/%m/%d %T'`] $1"
}

# MySQL コマンドでSQL実行 -値を1つだけ取得
# argv1 : SQL
# return : $ret
function getValue()
{
    unset ret
    unset SQLGetValue
    SQLGetValue=$1

    RetValue=`echo "$SQLGetValue" | mysql ${MYSQL_COMMAND_ARGS} 2>&1`
    Ret=$?

    # ワーニング削除
    RetValue=${RetValue#$MYSQL_IGNORE_WARNING}

    if [ $Ret -gt 0 ]; then
        MyEcho "on error($Ret) $SQLGetValue"
        echo $RetValue
        return $Ret
    fi

    # 配列化
    ValueArray=(${RetValue//\r/ })
    # echo '*' ${ValueArray[*]}   # 返却内容
    # echo '0' ${ValueArray[0]}   # ID句
    # echo '1' ${ValueArray[1]}   # Value スペース分割される '2014-03-18 01:15:00' の場合は '2014-03-18'

    unset ValueArray[0]         # ID句を削除

    # cnt=0
    # for el in ${ValueArray[@]}; do
    #     let cnt++
    #     echo "$cnt : $el"
    # done
    # echo "ret : ${RetValue[1]}"

    ret="${ValueArray[*]}"
    return $Ret
}

# MySQL コマンドでSQL実行
# argv1 : SQL
function snedMySQLCommand()
{
    getValue "$1"
    return $?
}

sql="SELECT id,createtime FROM ems_keystore"
#sql=$sql" ORDER BY help_keyword_id LIMIT 1"
getValue "$sql"
Ret=$?
# if [ $Ret -gt 0 ]; then
#     echo "on error($Ret) $sql"
# else
#     echo getValue return value:$ret
# fi


# for (( i = 0; i < ${#ValueArray[@]}; i++ )); do
#     echo ${ValueArray[i]}
# done

# echo '*' ${ValueArray[*]}   # 返却内容
# echo '0' ${ValueArray[0]}   # ID句
# echo '1' ${ValueArray[1]}

    cnt=0
    for el in ${ValueArray[@]}; do
        let cnt++
        echo "$cnt : $el"
    done
    echo "ret : ${RetValue[1]}"