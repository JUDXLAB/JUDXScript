import os
import csv
import re
import sys
from pathlib import Path

# 使用脚本所在目录作为基准
script_dir = os.path.dirname(os.path.abspath(__file__))
working_directory = os.path.join(script_dir, "data")
replacement_csv = os.path.join(working_directory, "Replace.csv")
output_csv = os.path.join(working_directory, "OutputReplace.csv")

# 确保 data 目录存在
if not os.path.exists(working_directory):
    os.makedirs(working_directory)
    print(f"已创建数据目录：{working_directory}")

# 检查替换关系文件是否存在
if not os.path.exists(replacement_csv):
    print(f"替换关系文件不存在，请检查路径：{replacement_csv}")
    sys.exit(1)

# 加载替换关系表
replacement_table = []
with open(replacement_csv, 'r', encoding='utf-8') as f:
    csv_reader = csv.DictReader(f)
    for row in csv_reader:
        replacement_table.append(row)

# 检索所有 SRT 文件
srt_files = []
for root, dirs, files in os.walk(working_directory):
    for file in files:
        if file.endswith('.srt'):
            srt_files.append(os.path.join(root, file))

if len(srt_files) == 0:
    print(f"未找到任何 SRT 文件，请检查目录：{working_directory}")
    sys.exit(1)

# 初始化替换记录
replacement_log = []

# 遍历每个 SRT 文件
for file_path in srt_files:
    print(f"正在处理文件：{file_path}")

    # 读取文件内容
    with open(file_path, 'r', encoding='utf-8') as f:
        content = f.read()

    # 初始化标志，记录文件是否被修改
    file_modified = False

    # 遍历替换关系表
    for replacement in replacement_table:
        old_text = replacement['OldText']
        new_text = replacement['NewText']

        # 检查是否需要替换
        if re.search(re.escape(old_text), content):
            # 替换内容
            content = re.sub(re.escape(old_text), new_text, content)
            file_modified = True

            # 记录替换关系
            replacement_log.append({
                'FileName': file_path,
                'OldText': old_text,
                'NewText': new_text
            })

    # 如果文件被修改，则将修改后的内容写回文件
    if file_modified:
        with open(file_path, 'w', encoding='utf-8') as f:
            f.write(content)
        print(f"文件已更新：{file_path}")
    else:
        print(f"文件未修改：{file_path}")

# 将替换记录保存到 CSV 文件
if replacement_log:
    with open(output_csv, 'w', encoding='utf-8', newline='') as f:
        fieldnames = ['FileName', 'OldText', 'NewText']
        writer = csv.DictWriter(f, fieldnames=fieldnames)
        writer.writeheader()
        writer.writerows(replacement_log)

print(f"所有文件处理完成，替换记录已保存到：{output_csv}")
