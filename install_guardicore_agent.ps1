Param(
    [string]$IdpHostname,
    [string]$Token,
    [string]$ExeUrl
)

$ErrorActionPreference = "Stop"

Write-Host "Starting Guardicore Agent installation..."

$EXEFileName = "GuardicorePlatformAgent.EXE"
$downloadPath = "$env:TEMP\$EXEFileName"

# Download the EXE installer if a URL is provided
if (-not [string]::IsNullOrEmpty($ExeUrl)) {
    Write-Host "Downloading Guardicore Agent EXE from $ExeUrl..."
# Download the MSI installer if a URL is provided
if ($MsiUrl -match '\S') {
    Write-Host "Downloading Guardicore Agent MSI from $MsiUrl..."
    try {
        Invoke-WebRequest -Uri $ExeUrl -OutFile $downloadPath -UseBasicParsing
        Write-Host "Download complete."
    } catch {
        Write-Error "Failed to download EXE from $ExeUrl $_"
        exit 1
    }
} else {
    Write-Host "No EXE URL provided. Assuming EXE is pre-staged or available locally at $downloadPath."
    # For this script, we'll make it an error if the file doesn't exist and no URL is given.
    if (-not (Test-Path $downloadPath)) {
        Write-Error "EXE file not found at $downloadPath and no download URL provided. Exiting."
        exit 1
    }
}
}

# Construct the installation command
$installCommand = "msiexec /i `"$downloadPath`" /quiet"

if ($IdpHostname -match '\S') {
    $installCommand += " IDP=`"$IdpHostname`""
}

if ($Token -match '\S') {
    $installCommand += " TOKEN=`"$Token`""
}

Write-Host "Executing installation command: $installCommand"

try {
    Invoke-Expression $installCommand
    Write-Host "Guardicore Agent installation initiated. Checking for success..."

    # You might want to add more robust checks here, e.g., checking service status or logs
    Start-Sleep -Seconds 30 # Give some time for the installation to proceed

    if (Get-Service -Name "GuardicoreAgent" -ErrorAction SilentlyContinue) {
        Write-Host "Guardicore Agent service found. Installation likely successful."
    } else {
        Write-Warning "Guardicore Agent service not found after installation. Please check logs for errors."
    }

} catch {
    Write-Error "Guardicore Agent installation failed: $_"
    exit 1
}

Write-Host "Guardicore Agent installation script finished."