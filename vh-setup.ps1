# Enable strict mode
Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

# Config
$FORGE_VERSION = "40.2.9"
$VH3_JAVA = $env:VH3_JAVA ?: "java"
$VH3_RESTART = $env:VH3_RESTART ?: "true"
$VH3_INSTALL_ONLY = $env:VH3_INSTALL_ONLY ?: "false"
$ScriptDir = Split-Path -Parent $MyInvocation.MyCommand.Definition
$INSTALLER = "$ScriptDir\forge-1.18.2-$FORGE_VERSION-installer.jar"
$FORGE_URL = "https://maven.minecraftforge.net/net/minecraftforge/forge/1.18.2-$FORGE_VERSION/forge-1.18.2-$FORGE_VERSION-installer.jar"

# Verify Java installation
try {
    & $VH3_JAVA -version | Out-Null
} catch {
    Write-Host "Minecraft 1.18 requires Java 17 - Java not found"
    exit 1
}

# Change to script directory
Set-Location $ScriptDir

# Install Forge if not installed
if (-not (Test-Path "libraries")) {
    Write-Host "Forge not installed, installing now."

    if (-not (Test-Path $INSTALLER)) {
        Write-Host "No Forge installer found, downloading from $FORGE_URL"
        Invoke-WebRequest -Uri $FORGE_URL -OutFile $INSTALLER
    }

    Write-Host "Running Forge installer..."
    & $VH3_JAVA -jar $INSTALLER --installServer
}

# Ask about Sky Vaults (interactive only)
if ($Host.UI.RawUI.KeyAvailable) {
    $skyvaults = Read-Host "Would you like to use Sky Vaults? (y/n)"
} else {
    $skyvaults = "n"
}

# Create server.properties if not present
if (-not (Test-Path "server.properties")) {
    Set-Content -Path "server.properties" -Value "allow-flight=true`nmotd=Vault Hunters 3 - 1.18.2"

    switch ($skyvaults.ToLower()) {
        "y" { Add-Content -Path "server.properties" -Value "level-type=the_vault:sky_vaults" }
        "yes" { Add-Content -Path "server.properties" -Value "level-type=the_vault:sky_vaults" }
        default { Add-Content -Path "server.properties" -Value "level-type=default" }
    }
}

# Install-only mode
switch ($VH3_INSTALL_ONLY.ToLower()) {
    "true" {
        Write-Host "INSTALL_ONLY: complete"
        exit 0
    }
    "yes" {
        Write-Host "INSTALL_ONLY: complete"
        exit 0
    }
}

# Check Java version
$javaVerOutput = & $VH3_JAVA -fullversion 2>&1
if ($javaVerOutput -match 'version "(\d+)(\.\d+)?') {
    $JVER = [int]$matches[1]
    if ($JVER -lt 17) {
        Write-Host "Minecraft 1.18 requires Java 17 - found Java $JVER"
        exit 1
    }
}

# Accept EULA
@"
#By changing the setting below to TRUE you are indicating your agreement to our EULA (https://account.mojang.com/documents/minecraft_eula).
eula=true
"@ | Set-Content -Path "eula.txt"

# Watchdog loop
do {
    & $VH3_JAVA @user_jvm_args.txt @libraries/net/minecraftforge/forge/1.18.2-$FORGE_VERSION/win_args.txt nogui

    switch ($VH3_RESTART.ToLower()) {
        "false" { break }
        "no"    { break }
    }

    Write-Host "Restarting automatically in 10 seconds (Ctrl+C to cancel)..."
    Start-Sleep -Seconds 10
} while ($true)
