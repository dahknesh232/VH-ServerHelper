@echo off
set FORGE_VERSION=40.2.9
:: To use a specific Java runtime, set an environment variable named VH3_JAVA to the full path of java.exe.
:: To disable automatic restarts, set an environment variable named VH3_RESTART to false.
:: To install the pack without starting the server, set an environment variable named VH3_INSTALL_ONLY to true.

set INSTALLER="%~dp0forge-1.18.2-%FORGE_VERSION%-installer.jar"
set FORGE_URL="http://files.minecraftforge.net/maven/net/minecraftforge/forge/1.18.2-%FORGE_VERSION%/forge-1.18.2-%FORGE_VERSION%-installer.jar"

:JAVA
if not defined VH3_JAVA (
    set VH3_JAVA=java
)

"%VH3_JAVA%" -version 1>nul 2>nul || (
   echo Minecraft 1.18 requires Java 17 - Java not found
   pause
   exit /b 1
)

:FORGE
setlocal
cd /D "%~dp0"
if not exist "libraries" (
    echo Forge not installed, installing now.
    if not exist %INSTALLER% (
        echo No Forge installer found, downloading from %FORGE_URL%
        bitsadmin.exe /rawreturn /nowrap /transfer forgeinstaller /download /priority FOREGROUND %FORGE_URL% %INSTALLER%
    )
    
    echo Running Forge installer.
    "%VH3_JAVA%" -jar %INSTALLER% -installServer
)

set /p skyvaults="Would you like to use Sky Vaults? (y/n): "

if not exist "server.properties" (
    (
        echo allow-flight=true
        echo motd=Vault Hunters 3 - 1.18.2
        if "%skyvaults%" == "y" (
            echo level-type=the_vault:sky_vaults
        ) else (
            echo level-type=default
        )
    )> "server.properties"
)

if "%VH3_INSTALL_ONLY%" == "true" (
    echo INSTALL_ONLY: complete
    goto:EOF
)

for /f tokens^=2-5^ delims^=.-_^" %%j in ('"%VH3_JAVA%" -fullversion 2^>^&1') do set "jver=%%j"
if not %jver% geq 17  (
    echo Minecraft 1.18 requires Java 17 - found Java %jver%
    pause
    exit /b 1
) 

if not exist "eula.txt" (
    echo "#By changing the setting below to TRUE you are indicating your agreement to our EULA (https://account.mojang.com/documents/minecraft_eula)."> "eula.txt"
    echo eula=true>> "eula.txt"
) else (
    echo "#By changing the setting below to TRUE you are indicating your agreement to our EULA (https://account.mojang.com/documents/minecraft_eula)."> "eula.txt"
    echo eula=true>> "eula.txt"
)


:START
"%VH3_JAVA%" @user_jvm_args.txt @libraries/net/minecraftforge/forge/1.18.2-%FORGE_VERSION%/win_args.txt nogui

if "%VH3_RESTART%" == "false" ( 
    goto:EOF 
)

echo Restarting automatically in 10 seconds (press Ctrl + C to cancel)
timeout /t 10 /nobreak > NUL
goto:START