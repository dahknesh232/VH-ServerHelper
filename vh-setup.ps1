# Requires PowerShell 5.1+ (Windows) or PowerShell Core 7+ (cross-platform)
Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"

# Config
$FORGE_VERSION = "40.2.9"
$VH3_JAVA = $env:VH3_JAVA
if (-not $VH3_JAVA) { $VH3_JAVA = "java" }

$VH3_RESTART = $env:VH3_RESTART
if (-not $VH3_RESTART) { $VH3_RESTART = "true" }

$VH3_INSTALL_ONLY = $env:VH3_INSTALL_ONLY
if (-not $VH3_INSTALL_ONLY) { $VH3_INSTALL_ONLY = "false" }

$INSTALLER = Join-Path -Path $PSScriptRoot -ChildPath "forge-1.18.2-$FORGE_VERSION-installer.jar"
$FORGE_URL = "https://maven.minecraftforge.net/net/minecraftforge/forge/1.18.2-$FORGE_VERSION/forge-1.18.2-$FORGE_VERSION-installer.jar"

# Java check
try {
    & $VH3_JAVA -version | Out-Null
} catch {
    Write-Error "Minecraft 1.18 requires Java 17 - Java not found"
    exit 1
}

Set-Location -Path $PSScriptRoot

# Install Forge if missing
if (-not (Test-Path "libraries")) {
    Write-Host "Forge not installed, installing now."

    if (-not (Test-Path $INSTALLER)) {
        Write-Host "No Forge installer found, downloading from $FORGE_URL"
        Invoke-WebRequest -Uri $FORGE_URL -OutFile $INSTALLER
    }

    Write-Host "Running Forge installer..."
    & $VH3_JAVA -jar $INSTALLER --installServer
}

# Prompt Sky Vaults
$skyvaults = "n"
if ($Host.UI.RawUI -and $Host.UI.RawUI.KeyAvailable) {
    $skyvaults = Read-Host "Would you like to use Sky Vaults? (y/n)"
}

# Create server.properties
if (-not (Test-Path "server.properties")) {
    Set-Content -Path "server.properties" -Value "allow-flight=true`nmotd=Vault Hunters 3 - 1.18.2"

    switch ($skyvaults.ToLower()) {
        "y" { Add-Content -Path "server.properties" -Value "level-type=the_vault:sky_vaults" }
        "yes" { Add-Content -Path "server.properties" -Value "level-type=the_vault:sky_vaults" }
        default { Add-Content -Path "server.properties" -Value "level-type=default" }
    }
}

# Handle install-only mode
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

# Java version check
$javaVersionOutput = & $VH3_JAVA -fullversion 2>&1
$versionMatch = $javaVersionOutput -match 'version\s+"(\d+)\.' 
if ($versionMatch) {
    $JVER = [int]$Matches[1]
    if ($JVER -lt 17) {
        Write-Error "Minecraft 1.18 requires Java 17 - found Java $JVER"
        exit 1
    }
}

# Write EULA
Set-Content -Path "eula.txt" -Value @"
#By changing the setting below to TRUE you are indicating your agreement to our EULA (https://account.mojang.com/documents/minecraft_eula).
eula=true
"@

# OS-specific args.txt
if ($IsWindows) {
    $ARGS_FILE = "libraries/net/minecraftforge/forge/1.18.2-$FORGE_VERSION/win_args.txt"
} else {
    $ARGS_FILE = "libraries/net/minecraftforge/forge/1.18.2-$FORGE_VERSION/unix_args.txt"
}

# Watchdog loop
while ($true) {
    & $VH3_JAVA "@user_jvm_args.txt" "@$ARGS_FILE" "nogui"

    switch ($VH3_RESTART.ToLower()) {
        "false" { break }
        "no" { break }
    }

    Write-Host "Restarting automatically in 10 seconds (Ctrl+C to cancel)..."
    Start-Sleep -Seconds 10
}

