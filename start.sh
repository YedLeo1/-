#!/bin/bash

# 循环执行4次操作
for ((i=1; i<=2; i++)); do
    echo "===== 第 $i 次执行 ====="
    
    # 1. 执行1.py
    echo "执行1.py..."
    python3 1.py  # 若使用python2可改为python 1.py
    
    # 2. 执行ls命令（生成ls的文件列表输出）
    echo "当前文件列表："
    ls
    
    # 3. 删除指定文件和脚本
    echo "删除指定文件..."
    rm -f recovered_text.txt step2_output.txt step3.sh \
           step1_output.txt step2.sh customize.sh \
           step1.sh step3_output.txt step4.sh
    
    # 4. 将step4_output.txt重命名为customize.sh
    echo "重命名step4_output.txt为customize.sh..."
    mv -f step4_output.txt customize.sh  # -f参数确保强制覆盖
    
    echo "第 $i 次执行完成"
    echo "------------------------"
done

echo "所有操作已完成4次循环"

