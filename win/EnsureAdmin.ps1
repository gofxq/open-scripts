function Ensure-Admin {
    if (-not ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)) {
        Write-Host "Not running as Administrator. Attempting to restart with admin privileges..."
        Start-Process PowerShell -ArgumentList "-File",("`"" + $MyInvocation.MyCommand.Definition + "`"") -Verb RunAs
        exit
    }
}

# How to use me
# . ".\win\EnsureAdmin.ps1"
# Ensure-Admin