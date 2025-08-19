# MailboxStatus.ps1 使用说明

## 功能概述
批量导出本地 Exchange 组织全部用户/共享/系统等邮箱的：
- 基本属性（显示名称 / 主 SMTP / 别名 / 类型 / 数据库 / 服务器）
- 主邮箱统计（大小MB / 项目数 / 最后登录时间）
- 归档邮箱统计（启用状态 / 归档库 / 大小MB / 项目数）
- 配额（警告 / 阻止发送 / 阻止收发）
- 协议启用状态（OWA / ActiveSync）

输出 CSV：MigBatch/AllMailboxDataWithLogonTime_yyyyMMdd_HHmm.csv（脚本目录下自动创建 MigBatch）。

## 运行前提
- 在 Exchange 管理 Shell 或已加载 Exchange 管理模块的 PowerShell 中运行
- 账户需具备读取邮箱与统计信息权限（如 View-Only Organization Management）
- PowerShell 5.1+（默认 Windows）  
- 脚本文件：ExchangeServer/MailboxStatus.ps1

## 使用
```powershell
cd <JUDXScript 根目录>\ExchangeServer
.\MailboxStatus.ps1