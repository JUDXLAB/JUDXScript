项目说明
本仓库用于批量替换 SRT 字幕文件中的特定文本，并输出替换日志。

文件结构
Replace-src.ps1 PowerShell 实现
Replace-src.py Python 实现
replace.csv 替换对照表 (列：OldText, NewText)
工作原理
读取同目录下 data/ 子目录中的 Replace.csv（需放入 data/ 并命名为 Replace.csv，注意大小写与脚本一致）。
递归查找 data/ 下所有 .srt 文件。
逐条按精确文本（转义后作正则字面量匹配）替换。
写回已修改的文件。
汇总生成 OutputReplace.csv（位于 data/）。
使用方法
PowerShell 版本
Python 版本
CSV 规则
replace.csv 示例（需复制为 data/Replace.csv）：

注意：

匹配为区分大小写的字面量匹配（因使用转义后的正则）。
同一行若 OldText 为空会跳过；含特殊符号会被自动转义。
多次出现会全部替换。
输出
修改过的 SRT 文件被原地覆盖（无备份，建议先做副本）。
日志：data/OutputReplace.csv，列：FileName, OldText, NewText（每次出现都会记录一次）。
常见改进点
增加备份：复制到 *.bak。
添加 -WhatIf / dry-run。
支持大小写不敏感：PowerShell 使用 -imatch / -ireplace，Python 用 flags=re.IGNORECASE。
避免重复扫描：对内容先做索引或合并正则。
去重日志：可用哈希表按 (FileName,OldText,NewText) 过滤。
示例增强（PowerShell 备份与大小写不敏感）
运行前检查
data/Replace.csv 是否存在且编码 UTF-8。
SRT 文件编码是否为 UTF-8（否则需先转码）。
文件名大小写：脚本用 Replace.csv，仓库当前为 replace.csv，需统一。
退出码（Python）
1：缺少 CSV 或无 SRT。
0：成功。
许可与安全
覆写操作不可逆，请先备份。
若需处理超大文件，建议改为流式逐行替换。