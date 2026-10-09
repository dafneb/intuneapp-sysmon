<#
    Intune Win32 app - Requirement script for built-in Sysmon

    Intune settings for this script:
      Output data type ........ Boolean
      Operator ................ Equals
      Value ................... Yes
      Run as 32-bit process ... No
      Run with logged-on creds  No

    Rule: this script must write exactly ONE value to STDOUT (True/False).
    Everything else goes to the log file only - no Write-Host, no transcript
    (Start-/Stop-Transcript print their own lines to STDOUT and break the result).
#>

$packageName = 'Sysmon'
$logFile     = "$env:ProgramData\Microsoft\IntuneManagementExtension\Logs\${packageName}_Requirements.log"

function Write-Log([string]$Message) {
    $line = '{0}  {1}' -f (Get-Date -Format 'yyyy-MM-dd HH:mm:ss'), $Message
    Add-Content -Path $logFile -Value $line -ErrorAction SilentlyContinue
}

function Exit-Result([bool]$Result, [string]$Reason) {
    Write-Log "RESULT: $Result - $Reason"
    Write-Output $Result          # the only line on STDOUT
    exit 0
}

try {
    Write-Log "===== Requirements check of $packageName ====="

    # 1. OS must offer the built-in Sysmon optional feature
    $feature = Get-WindowsOptionalFeature -Online -FeatureName Sysmon -ErrorAction SilentlyContinue
    if (-not $feature) {
        Exit-Result $false 'Built-in Sysmon optional feature not available on this OS build'
    }
    Write-Log "Feature state: $($feature.State)"

    # 2. Standalone (Sysinternals) Sysmon must not be present - it cannot coexist.
    #    A Sysmon service while the feature is NOT enabled = standalone install.
    #    A Sysmon service while the feature IS enabled = our built-in one (already deployed / re-run) -> OK.
    $services = @(Get-Service -Name 'sysmon*' -ErrorAction SilentlyContinue)
    if ($services.Count -gt 0) {
        $svcInfo = ($services | ForEach-Object { "$($_.Name) [$($_.Status)]" }) -join ', '
        Write-Log "Found Sysmon service(s): $svcInfo"

        if ([string]$feature.State -ne 'Enabled') {
            Exit-Result $false 'Standalone Sysmon detected - uninstall it (sysmon -u) before deploying built-in Sysmon'
        }
    }

    Exit-Result $true 'All requirements met'
}
catch {
    Write-Log "ERROR: $($_.Exception.Message)"
    Exit-Result $false 'Unexpected error during requirements check'
}