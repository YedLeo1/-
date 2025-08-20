import subprocess
import os

# 第一步：恢复原始文件（删除反斜杠）
def recover_without_backslash(input_file, output_file):
    """读取原始文件，合并字符并删除所有反斜杠"""
    try:
        with open(input_file, 'r') as f:
            # 合并所有行（每行一个字符），不保留换行
            content = ''.join([line.rstrip('\n') for line in f])
        # 核心：删除所有反斜杠（保留此步骤）
        content = content.replace('\\', '')
        with open(output_file, 'w') as f:
            f.write(content)
        print(f"已处理原始文件，删除反斜杠后保存为 {output_file}")
        return content
    except Exception as e:
        print(f"恢复文件时出错: {str(e)}")
        return None

# 后续步骤：替换内容并执行
def replace_and_execute(input_content, replace_rules, output_sh, output_log):
    """替换内容生成shell脚本，执行并保存输出"""
    content = input_content
    for old, new in replace_rules:
        content = content.replace(old, new)
    
    # 生成可执行shell脚本
    with open(output_sh, 'w') as f:
        f.write('#!/bin/bash\n')
        f.write(content)
    os.chmod(output_sh, 0o755)
    
    # 执行并捕获输出
    try:
        result = subprocess.run(
            f'./{output_sh}', 
            shell=True, 
            check=True, 
            stdout=subprocess.PIPE, 
            stderr=subprocess.STDOUT, 
            text=True
        )
        output = result.stdout
    except subprocess.CalledProcessError as e:
        output = f"执行错误: {e.stdout}"
    
    with open(output_log, 'w') as f:
        f.write(output)
    print(f"已生成 {output_sh}，输出保存到 {output_log}")
    return output

if __name__ == "__main__":
    # 原始输入文件（你的customize.txt）
    original_file = "customize.sh"
    # 第一步：处理原始文件，删除反斜杠，生成recovered_text.txt
    recovered_content = recover_without_backslash(original_file, "recovered_text.txt")
    if not recovered_content:
        print("无法继续，退出流程")
        exit(1)
    
    # 步骤1：替换recovered_text.txt中的eval为echo，执行
    step1_rules = [('eval', 'echo')]
    step1_output = replace_and_execute(
        recovered_content, 
        step1_rules, 
        'step1.sh', 
        'step1_output.txt'
    )
    
    # 步骤2：将step1输出中的$e换成echo，执行
    step2_rules = [('$e', 'echo')]
    step2_output = replace_and_execute(
        step1_output, 
        step2_rules, 
        'step2.sh', 
        'step2_output.txt'
    )
    
    # 步骤3：替换特定set语句
    old_str3 = "set +x; $(echo -n 'lave' | awk '{for(j=length;j!=0;j--)x=x substr($0,j,1)} END{print x}')"
    new_str3 = "set +x; echo $(echo -n 'lave' | awk '{for(j=length;j!=0;j--)x=x substr($0,j,1)} END{print x}')"
    step3_rules = [(old_str3, new_str3)]
    step3_output = replace_and_execute(
        step2_output, 
        step3_rules, 
        'step3.sh', 
        'step3_output.txt'
    )
    
    # 步骤4：替换_CMD_EVAL语句
    old_str4 = '$_CMD_EVAL "$($_CMD_ECHO "$_full_payload" | $_CMD_B64 -d | $_CMD_GUNZIP | $_CMD_BZCAT)"'
    new_str4 = '$_CMD_ECHO "$($_CMD_ECHO "$_full_payload" | $_CMD_B64 -d | $_CMD_GUNZIP | $_CMD_BZCAT)"'
    step4_rules = [(old_str4, new_str4)]
    step4_output = replace_and_execute(
        step3_output, 
        step4_rules, 
        'step4.sh', 
        'step4_output.txt'
    )
    
    print("\n所有步骤完成！最终输出保存在 step4_output.txt")
