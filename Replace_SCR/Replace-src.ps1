# 使用脚本所在目录作为基准
$WorkingDirectory = Join-Path $PSScriptRoot "data"  # 相对于脚本的data子目录
$ReplacementCSV = Join-Path $WorkingDirectory "Replace.csv"
$OutputCSV = Join-Path $WorkingDirectory "OutputReplace.csv"

# 确保 data 目录存在
if (-not (Test-Path $WorkingDirectory)) {
    New-Item -Path $WorkingDirectory -ItemType Directory
    Write-Host "已创建数据目录：$WorkingDirectory" -ForegroundColor Green
}

# 确保 PowerShell 使用 UTF-8 编码，避免中文乱码
$OutputEncoding = [System.Text.Encoding]::UTF8

# 检查替换关系文件是否存在
if (-not (Test-Path $ReplacementCSV)) {
    Write-Host "替换关系文件不存在，请检查路径：$ReplacementCSV" -ForegroundColor Red
    exit
}

# 加载替换关系表
$ReplacementTable = Import-Csv -Path $ReplacementCSV -Encoding UTF8

# 检索所有 SRT 文件
$SRTFiles = Get-ChildItem -Path $WorkingDirectory -Recurse -Filter "*.srt"

if ($SRTFiles.Count -eq 0) {
    Write-Host "未找到任何 SRT 文件，请检查目录：$WorkingDirectory" -ForegroundColor Yellow
    exit
}

# 初始化替换记录
$ReplacementLog = @()

# 遍历每个 SRT 文件
foreach ($File in $SRTFiles) {
    Write-Host "正在处理文件：$($File.FullName)" -ForegroundColor Green

    # 读取文件内容（确保使用 UTF-8 编码）
    $Content = Get-Content -Path $File.FullName -Encoding UTF8

    # 初始化标志，记录文件是否被修改
    $FileModified = $false

    # 遍历替换关系表
    foreach ($Replacement in $ReplacementTable) {
        $OldText = $Replacement.OldText
        $NewText = $Replacement.NewText

        # 检查是否需要替换
        if ($Content -match [regex]::Escape($OldText)) {
            # 替换内容
            $Content = $Content -replace [regex]::Escape($OldText), $NewText
            $FileModified = $true

            # 记录替换关系
            $ReplacementLog += [PSCustomObject]@{
                FileName = $File.FullName
                OldText  = $OldText
                NewText  = $NewText
            }
        }
    }

    # 如果文件被修改，则将修改后的内容写回文件
    if ($FileModified) {
        Set-Content -Path $File.FullName -Value $Content -Encoding UTF8
        Write-Host "文件已更新：$($File.FullName)" -ForegroundColor Cyan
    } else {
        Write-Host "文件未修改：$($File.FullName)" -ForegroundColor Yellow
    }
}

# 将替换记录保存到 CSV 文件
$ReplacementLog | Export-Csv -Path $OutputCSV -NoTypeInformation -Encoding UTF8

Write-Host "所有文件处理完成，替换记录已保存到：$OutputCSV" -ForegroundColor Green