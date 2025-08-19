$Timestamp = Get-Date -Format "yyyyMMdd_HHmm"
$OutputPath = Join-Path $PSScriptRoot "MigBatch/AllMailboxDataWithLogonTime_$Timestamp.csv"
$OutputDir = Split-Path $OutputPath
if (-not (Test-Path $OutputDir)) {
    New-Item -Path $OutputDir -ItemType Directory -Force
}

Write-Host "--- 正在获取全部邮箱数据（包含类型和最后登录时间）并输出到 $($OutputPath) ---"

try {
Get-Mailbox -ResultSize Unlimited | ForEach-Object {
    $mailbox = $_
    $mailboxStats = Get-MailboxStatistics -Identity $mailbox.Identity -ErrorAction SilentlyContinue
    $archiveStats = $null

    if ($mailbox.ArchiveState -eq "Local") {
        $archiveStats = Get-MailboxStatistics -Identity $mailbox.Identity -Archive -ErrorAction SilentlyContinue
    }

    [PSCustomObject]@{
        '显示名称'        = $mailbox.DisplayName
        '主要SMTP地址'    = $mailbox.PrimarySmtpAddress
        '别名'            = $mailbox.Alias
        '邮箱类型'        = $mailbox.RecipientTypeDetails
        '邮箱数据库'      = $mailbox.Database
        '托管服务器'      = $mailbox.ServerName
        '总项目大小 (MB)' = if ($mailboxStats) {$mailboxStats.TotalItemSize.Value.ToMB()} else {"N/A"}
        '项目数'          = if ($mailboxStats) {$mailboxStats.ItemCount} else {"N/A"}
        '最后登录时间'    = if ($mailboxStats) {$mailboxStats.LastLogonTime} else {"N/A"}
        '启用归档邮箱'       = $mailbox.ArchiveState
        '归档邮箱数据库'     = $mailbox.ArchiveDatabase
        '归档邮箱大小 (MB)'  = if ($archiveStats) {$archiveStats.TotalItemSize.Value.ToMB()} else {"N/A"}
        '归档项目数'         = if ($archiveStats) {$archiveStats.ItemCount} else {"N/A"}
        '警告配额 (MB)'      = if ($mailbox.IssueWarningQuota -eq 'Unlimited') {'Unlimited'} else {$mailbox.IssueWarningQuota.Value.ToMB()}
        '阻止发送配额 (MB)'   = if ($mailbox.ProhibitSendQuota -eq 'Unlimited') {'Unlimited'} else {$mailbox.ProhibitSendQuota.Value.ToMB()}
        '阻止接收配额 (MB)'   = if ($mailbox.ProhibitSendReceiveQuota -eq 'Unlimited') {'Unlimited'} else {$mailbox.ProhibitSendReceiveQuota.Value.ToMB()}
        '启用OWA'            = $mailbox.OWAEnabled
        '启用ActiveSync'     = $mailbox.ActiveSyncEnabled
    }


    } | Export-Csv -Path $OutputPath -NoTypeInformation -Encoding UTF8

    Write-Host "数据已成功导出到 $($OutputPath)"

} catch {
    Write-Host "获取或导出邮箱数据时发生错误。错误: $($_.Exception.Message)"
}