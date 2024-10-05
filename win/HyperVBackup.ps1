# 检查是否以管理员权限运行
if (-not ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole] "Administrator")) {
    # 重新以管理员身份运行脚本
    Start-Process PowerShell -ArgumentList "-File",("`"" + $MyInvocation.MyCommand.Definition + "`"") -Verb RunAs
    exit
}

$backupPath = "C:\hv_backups\" # 备份存储路径
$vmNames = @("ubuntu-server", "iKuai", "OpenWRT") # 虚拟机名称列表

foreach ($vmName in $vmNames) {
    $currentBackupPath = Join-Path $backupPath "$vmName-current"
    $previousBackupPath = Join-Path $backupPath "$vmName-pre"

    # 检查并删除旧的“前一天”备份
    if (Test-Path $previousBackupPath) {
        Remove-Item -Path $previousBackupPath -Recurse
    }

    # 将“当前”备份重命名为“前一天”备份
    if (Test-Path $currentBackupPath) {
        Rename-Item -Path $currentBackupPath -NewName $previousBackupPath
    }

    # 创建新的“当前”备份目录
    if (-not (Test-Path $currentBackupPath)) {
        New-Item -Path $currentBackupPath -ItemType Directory
    }

    # 导出虚拟机到“当前”备份目录
    Export-VM -Name $vmName -Path $currentBackupPath
}
