
$packageName = "Sysmon"
$ErrorActionPreference = 'SilentlyContinue'

Start-Transcript -Path "$env:ProgramData\Microsoft\IntuneManagementExtension\Logs\${packageName}_Install.log" -Append
Write-Host "Starting installation of $packageName..."

Write-Host "Enabling Sysmon feature..."
Enable-WindowsOptionalFeature -Online -FeatureName Sysmon

Write-Host "Copying Sysmon configuration file..."
Copy-Item -Path .\data\sysmonconfig-export.xml -Destination "C:\Windows\SysmonConfig.xml" -Force

Write-Host "Installing Sysmon with the configuration file..."
sysmon -accepteula -i C:\Windows\SysmonConfig.xml

Stop-Transcript
return 0
