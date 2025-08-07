Param(
    [Parameter(Mandatory = $true)][string]$IdpHostname,
    [Parameter(Mandatory = $true)][string]$Token,
    [string]$ExeUrl
)

$ErrorActionPreference = "Stop"
Write-Host "`nStarting Guardicore Agent installation..."

# Define EXE installer path
$exeFileName = "GuardicorePlatformAgent.exe"
$downloadPath = "$env:TEMP\$exeFileName"

# Download the EXE installer if a URL is provided
if (-not [string]::IsNullOrWhiteSpace($ExeUrl)) {
    Write-Host "Downloading Guardicore Agent EXE from $ExeUrl..."
    try {
        Invoke-WebRequest -Uri $ExeUrl -OutFile $downloadPath -UseBasicParsing
        Write-Host "Download complete: $downloadPath"
    } catch {
        Write-Error "Failed to download EXE from $ExeUrl. Error: $_"
        exit 1
    }
} else {
    Write-Host "No EXE URL provided. Assuming EXE is pre-staged at $downloadPath."
    if (-not (Test-Path $downloadPath)) {
        Write-Error "EXE file not found at $downloadPath and no URL provided. Exiting."
        exit 1
    }
}

# Construct argument list
$arguments = "/quiet IDP=$IdpHostname TOKEN=$Token"
Write-Host "Executing Guardicore Agent installer..."

try {
    $process = Start-Process -FilePath $downloadPath -ArgumentList $arguments -Wait -PassThru

    if ($process.ExitCode -ne 0) {
        Write-Error "Installer exited with code $($process.ExitCode). Installation may have failed."
        exit $process.ExitCode
    }

    Write-Host "Installation completed. Verifying service status..."
    Start-Sleep -Seconds 30

    $service = Get-Service -Name "GuardicoreAgent" -ErrorAction SilentlyContinue
    if ($service) {
        Write-Host "Guardicore Agent service found. Installation successful."
    } else {
        Write-Warning "Guardicore Agent service not found. Please verify installation logs manually."
    }
} catch {
    Write-Error "Installation failed: $_"
    exit 1
}

# Cleanup installer
try {
    if (Test-Path $downloadPath) {
        Remove-Item $downloadPath -Force
        Write-Host "Temporary installer deleted: $downloadPath"
    }
} catch {
    Write-Warning "Failed to delete temporary EXE: $_"
}

Write-Host "`nGuardicore Agent installation script completed."