
$packageName = "Sysmon"

Start-Transcript -Path "$env:ProgramData\Microsoft\IntuneManagementExtension\Logs\${packageName}_Uninstall.log" -Append
Write-Host "Starting uninstallation of $packageName..."

Write-Host "Uninstalling Sysmon..."
sysmon -u

Write-Host "Deleting Sysmon configuration file..."
Remove-Item -Path "C:\Windows\SysmonConfig.xml" -Force -ErrorAction SilentlyContinue

Stop-Transcript
return 0
