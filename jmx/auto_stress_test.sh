#!/usr/bin/env bash

# 压测脚本模板中设定的压测时间应为60秒
export jmx_template="iInterface"     # 脚本名称
export suffix=".jmx"    # 脚本后缀名
export jmx_template_filename="${jmx_template}${suffix}"  # 拼接
export os_type=`uname`  #   获取系统名


# 需要在系统变量中定义jmeter根目录的位置，如下
# export jmeter_path="/your jmeter path/"
#export jmeter_path="/d/ProgramFiles(x86)/apache-jmeter-5.3"
export jmeter_path="/d/ProgramFiles(x86)/apache-jmeter-5.3"

echo "自动化压测开始"

# 压测并发数列表
thread_number_array=(10 20 30)
for num in "${thread_number_array[@]}"
do
    # 生成对应压测线程的jmx文件  ，因为jmx文件不能外部传参，只能生成对应的10 20 30 并发数的jmx文件
    export jmx_filename="${jmx_template}_${num}${suffix}"
    export jtl_filename="test_${num}.jtl"      # jtl文件是jmeter压测的原始数据的文件
    export web_report_path_name="web_${num}"   # 拼接报告名

    rm -f ${jmx_filename} ${jtl_filename}    # 环境清理
    rm -rf ${web_report_path_name}           # 环境清理

    cp ${jmx_template_filename} ${jmx_filename}    # 复制原始文件 生成对应的并发文件名
    echo "生成jmx压测脚本 ${jmx_filename}"

    if [[ "${os_type}" == "Darwin" ]]; then
        sed -i "" "s/thread_num/${num}/g" ${jmx_filename}   # 把压测模板的并发数据修改成 对应的并发数,形成压测脚本
    else
        sed -i "s/thread_num/${num}/g" ${jmx_filename}
    fi

    # JMeter 静默压测
    ${jmeter_path}/bin/jmeter -n -t ${jmx_filename} -l ${jtl_filename}

    # 生成Web压测报告
    ${jmeter_path}/bin/jmeter -g ${jtl_filename} -e -o ${web_report_path_name}

    rm -f ${jmx_filename} ${jtl_filename}
done
echo "自动化压测全部结束"

