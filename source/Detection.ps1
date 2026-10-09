$packageName = "Sysmon"

Start-Transcript -Path "$env:ProgramData\Microsoft\IntuneManagementExtension\Logs\${packageName}_Detection.log" -Append
Write-Host "Starting detection of $packageName..."



Stop-Transcript
