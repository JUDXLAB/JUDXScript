# 项目说明
本仓库用于批量替换 SRT 字幕文件中的特定文本，并输出替换日志。

## 文件结构
| 文件 / 目录 | 说明 |
|-------------|------|
| Replace-src.ps1 | PowerShell 实现 |
| Replace-src.py  | Python 实现 |
| replace.csv     | 替换对照表 (列：OldText, NewText) |
| data/           | 放置 Replace.csv 与所有 .srt 文件 |
| data/OutputReplace.csv | 输出的替换日志 |

> 注意：脚本读取的是 `data/Replace.csv`（大小写敏感），需与脚本内名称一致。若仓库内为 `replace.csv` 请统一。

## 工作原理
1. 读取同目录下 `data/Replace.csv`（需放入 `data/`，命名与大小写一致）。
2. 递归查找 `data/` 下所有 `.srt` 文件。
3. 逐条按精确文本（转义后作为正则字面量）替换。
4. 写回已修改的文件（原地覆盖）。
5. 汇总生成 `data/OutputReplace.csv`（逐次出现都会记录）。

## 使用方法

### PowerShell 版本
```powershell
# 运行（示例）
pwsh ./Replace-src.ps1
```

### Python 版本
```bash
python Replace-src.py
echo $?   # 退出码：0 成功；1 缺少 CSV 或无 SRT
```

### CSV 规则
- 列名：`OldText,NewText`
- `OldText` 为空的行会被跳过。
- 特殊符号会自动转义后进行字面量匹配。
- 匹配区分大小写（默认）。
- 多次出现全部替换。

#### replace.csv 示例（请复制为 `data/Replace.csv`）
```csv
OldText,NewText
示例旧文本,示例新文本
```

#### 注意
- 使用正则字面量精确匹配（已转义）。
- 请确保文件编码为 UTF-8（无 BOM 优先）。
- 命名大小写需与脚本一致：`Replace.csv`.

## 输出
- 被修改的 `.srt` 文件：原地覆盖（无备份，操作前请手动备份）。
- 日志：`data/OutputReplace.csv` 列：`FileName,OldText,NewText`（每次出现均记录一行）。

## 常见改进点（可自行扩展）
- 备份：写入同名 `*.bak`。
- Dry-run：增加 `-WhatIf`（PowerShell）或命令行参数模拟。
- 不区分大小写：PowerShell 用 `-ireplace` / `-imatch`，Python 用 `re.IGNORECASE`。
- 减少重复扫描：合并正则或建立索引。
- 日志去重：按 `(FileName,OldText,NewText)` 使用哈希表过滤。
- 大文件处理：改为流式逐行读写。

### 示例增强（PowerShell 片段：备份 + 不区分大小写）
```powershell
$original = Get-Content $srtPath -Raw
Copy-Item $srtPath "$srtPath.bak" -ErrorAction Stop
foreach ($row in $csv) {
    if ([string]::IsNullOrWhiteSpace($row.OldText)) { continue }
    $pattern = [Regex]::Escape($row.OldText)
    $new = ($original -ireplace $pattern, [Regex]::Escape($row.NewText))
    if ($new -ne $original) {
        $log += [pscustomobject]@{
            FileName = (Split-Path $srtPath -Leaf)
            OldText  = $row.OldText
            NewText  = $row.NewText
        }
        $original = $new
    }
}
Set-Content $srtPath $original -Encoding UTF8
```

## 运行前检查
- `data/Replace.csv` 是否存在且为 UTF-8。
- `.srt` 文件编码是否 UTF-8（否则先转换）。
- 文件命名大小写是否为 `Replace.csv`。
- 需求：是否需要预先备份。

## 退出码（Python）
- 0：成功
- 1：缺少 CSV 或无 SRT

## 许可与安全
- 覆写操作不可逆，请先备份。
- 处理超大文件时建议改为流式处理以降低内存占用。
- 请在受控目录内执行，避免误操作。
