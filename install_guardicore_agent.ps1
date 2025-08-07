Param(
    [string]$AggregatorsFQDN,
    [string]$SecurePassword,
    [string]$AgentExeUrl
)

$ErrorActionPreference = "Stop"
Write-Host "`nStarting Guardicore Agent installation..."

# Define EXE installer path
$exeFileName = "GuardicorePlatformAgent.exe"
$downloadPath = "$env:TEMP\$exeFileName"

# Download the EXE installer if a URL is provided
if (-not [string]::IsNullOrWhiteSpace($AgentExeUrl)) {
    Write-Host "Downloading Guardicore Agent installer from $AgentExeUrl..."
    try {
        Invoke-WebRequest -Uri $AgentExeUrl -OutFile $downloadPath -UseBasicParsing
        Write-Host "Download complete: $downloadPath"
    } catch {
        Write-Error "Failed to download installer from $AgentExeUrl. Error: $_"
        exit 1
    }
} else {
    Write-Host "No EXE URL provided. Assuming installer is pre-staged at $downloadPath."
    if (-not (Test-Path $downloadPath)) {
        Write-Error "Installer not found at $downloadPath and no URL provided. Exiting."
        exit 1
    }
}

# Construct correct argument list as per engineering team's guide
$arguments = "/offline /a $AggregatorsFQDN /p `"$SecurePassword`" /installation-profile windows_adminlock /q /override-uuid-file-reload"

Write-Host "Executing Guardicore Agent installer with arguments:`n$arguments"
try {
    $process = Start-Process -FilePath $downloadPath -ArgumentList $arguments -Wait -PassThru

    if ($process.ExitCode -ne 0) {
        Write-Error "Installer exited with code $($process.ExitCode). Installation may have failed."
        exit $process.ExitCode
    }

    Write-Host "Installation completed. Verifying service status..."
    Start-Sleep -Seconds 30

    $service = Get-Service -Name "GC-AGENTS-SERVICE" -ErrorAction SilentlyContinue
    if ($service) {
        Write-Host "Guardicore Agent service is running. Installation successful."
    } else {
        Write-Warning "Guardicore Agent service not found. Please check installation logs."
    }
} catch {
    Write-Error "Installation failed: $_"
    exit 1
} finally {
    if (Test-Path $downloadPath) {
        Remove-Item $downloadPath -Force
        Write-Host "Cleaned up installer: $downloadPath"
    }
}

Write-Host "`nGuardicore Agent installation script completed."