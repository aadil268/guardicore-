# URLs
$cloudbaseUrl = "https://cloudbase.it/downloads/CloudbaseInitSetup_Stable_x64.msi"
$cloudinitScriptUrl = "https://raw.githubusercontent.com/aadil268/cloudbase-Init/main/config/cloudinit.cmd"
$configUrl = "https://raw.githubusercontent.com/aadil268/cloudbase-Init/main/config/cloudbase-init.conf"
$bypassMetaPYUrl = "https://raw.githubusercontent.com/aadil268/cloudbase-Init/main/config/init.py"
$CustomPSScriptUrl = "https://raw.githubusercontent.com/aadil268/cloudbase-Init/main/config/cloudinit.ps1"

# Paths
$installerPath = "C:\CloudbaseInitSetup.msi"
$scriptPath = "C:\Program Files\Cloudbase Solutions\Cloudbase-Init\LocalScripts\cloudinit.cmd"
$configPath = "C:\Program Files\Cloudbase Solutions\Cloudbase-Init\conf\cloudbase-init.conf"
$bypassMetaPYPath = "C:\Program Files\Cloudbase Solutions\Cloudbase-Init\Python\Lib\site-packages\cloudbaseinit\init.py"
$CustomPSScriptPath = "C:\Scripts\cloudinit.ps1"

# Step 1: Download Cloudbase-Init
Write-Output "Downloading Cloudbase-Init..."
Invoke-WebRequest -Uri $cloudbaseUrl -OutFile $installerPath

Write-Output "Installing Cloudbase-Init..."
Start-Process msiexec.exe -Wait -ArgumentList "/i `"$installerPath`" /qn"

# Step 2: Download cloudinit.cmd
Write-Output "Downloading cloudinit.cmd..."
New-Item -ItemType Directory -Force -Path (Split-Path $scriptPath)
Invoke-WebRequest -Uri $cloudinitScriptUrl -OutFile $scriptPath
Unblock-File $scriptPath

# Step 3: Download and overwrite cloudbase-init.conf
Write-Output "Downloading cloudbase-init.conf..."
Invoke-WebRequest -Uri $configUrl -OutFile $configPath
Unblock-File $configPath

# Step 4: Download and overwrite init.py to bypass MeteData service
Write-Output "Downloading cloudbase-init.conf..."
Invoke-WebRequest -Uri $bypassMetaPYUrl -OutFile $bypassMetaPYPath
Unblock-File $bypassMetaPYPath

# Step 5: Download Custom PSScript
Write-Output "Downloading Custom PSScript..."
New-Item -ItemType Directory -Force -Path (Split-Path $CustomPSScriptPath)
Invoke-WebRequest -Uri $CustomPSScriptUrl -OutFile $CustomPSScriptPath
Unblock-File $CustomPSScriptPath

# Step 6: Start service
Write-Output "Starting Cloudbase-Init service..."
Start-Service cloudbase-init
Write-Output "Cloudbase-Init setup complete."