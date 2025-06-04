#!/bin/bash
set -euo pipefail

FORGE_VERSION="40.2.9"
VH3_JAVA="${VH3_JAVA:-java}"
VH3_RESTART="${VH3_RESTART:-true}"
VH3_INSTALL_ONLY="${VH3_INSTALL_ONLY:-false}"
INSTALLER="$(dirname "$0")/forge-1.18.2-${FORGE_VERSION}-installer.jar"
FORGE_URL="https://maven.minecraftforge.net/net/minecraftforge/forge/1.18.2-${FORGE_VERSION}/forge-1.18.2-${FORGE_VERSION}-installer.jar"

# Verify Java installation
if ! "$VH3_JAVA" -version >/dev/null 2>&1; then
  echo "Minecraft 1.18 requires Java 17 - Java not found"
  exit 1
fi

cd "$(dirname "$0")"

# Install Forge if not installed
if [ ! -d "libraries" ]; then
  echo "Forge not installed, installing now."

  if [ ! -f "$INSTALLER" ]; then
    echo "No Forge installer found, downloading from $FORGE_URL"
    curl -Lo "$INSTALLER" "$FORGE_URL"
  fi

  echo "Running Forge installer..."
  "$VH3_JAVA" -jar "$INSTALLER" --installServer
fi

# Ask user about Sky Vaults (only if interactive)
if [ -t 0 ]; then
  read -p "Would you like to use Sky Vaults? (y/n): " skyvaults
else
  skyvaults="n"
fi

# Create server.properties if not present
if [ ! -f server.properties ]; then
  echo "allow-flight=true" > server.properties
  echo "motd=Vault Hunters 3 - 1.18.2" >> server.properties

  case "${skyvaults,,}" in
    y|yes)
      echo "level-type=the_vault:sky_vaults" >> server.properties
      ;;
    *)
      echo "level-type=default" >> server.properties
      ;;
  esac
fi

# Install-only mode
case "$VH3_INSTALL_ONLY" in
  true|TRUE|True|yes|YES|Yes)
    echo "INSTALL_ONLY: complete"
    exit 0
    ;;
esac

# Check Java version
JVER=$("$VH3_JAVA" -fullversion 2>&1 | grep -oP '(?<=version ")[^"]+' | cut -d. -f1)
if [[ "$JVER" -lt 17 ]]; then
  echo "Minecraft 1.18 requires Java 17 - found Java $JVER"
  exit 1
fi

# Accept EULA
cat > eula.txt <<EOF
#By changing the setting below to TRUE you are indicating your agreement to our EULA (https://account.mojang.com/documents/minecraft_eula).
eula=true
EOF

# Start the server in a watchdog loop if restart is enabled
while true; do
  "$VH3_JAVA" @user_jvm_args.txt @libraries/net/minecraftforge/forge/1.18.2-${FORGE_VERSION}/unix_args.txt nogui

  case "$VH3_RESTART" in
    false|FALSE|False|no|NO|No)
      break
      ;;
  esac

  echo "Restarting automatically in 10 seconds (Ctrl+C to cancel)..."
  sleep 10
done