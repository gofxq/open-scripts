# 检查是否以管理员权限运行
if (-not ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole] "Administrator")) {
    # 重新以管理员身份运行脚本
    Start-Process PowerShell -ArgumentList "-File",("`"" + $MyInvocation.MyCommand.Definition + "`"") -Verb RunAs
    exit
}

$taskName = "HyperVBackupTask"
$taskDescription = "Daily Hyper-V Backup at 5 AM"
$scriptPath = "C:\apps\scrpits\win\HyperVBackup.ps1" # 更新为您备份脚本的实际路径
$triggerTime = New-ScheduledTaskTrigger -Daily -At 5am

$action = New-ScheduledTaskAction -Execute "Powershell.exe" -Argument "-File `"$scriptPath`""

# 注册任务
Register-ScheduledTask -TaskName $taskName -Description $taskDescription -Trigger $triggerTime -Action $action -RunLevel Highest -User "SYSTEM"
