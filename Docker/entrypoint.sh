#!/bin/bash
echo "Hello!"
cd /home/container
MODIFIED_STARTUP=`eval echo $(echo ${STARTUP} | sed -e 's/{{/${/g' -e 's/}}/}/g')`
echo "/home/container/scp_server$: ${MODIFIED_STARTUP}"

if [ $REINSTALL == 1 ]; then
        if [ ! -f "steamcmd.sh" ]; then
            curl -sqL "https://steamcdn-a.akamaihd.net/client/installer/steamcmd_linux.tar.gz" | tar zxvf -
        fi
        if [ ! -d "steamcmd" ]; then
            curl -sqL "https://steamcdn-a.akamaihd.net/client/installer/steamcmd_linux.tar.gz" | tar zxvf -
        fi
        EX=""
        if [ ! -z $SPECIAL_BRANCH ]; then
                EX="-beta $SPECIAL_BRANCH"
        fi
        ./steamcmd.sh +login anonymous +force_install_dir /home/container/scp_server +app_update 996560 validate $EX +quit
fi


echo "Updating Installer.."
rm -rf Exiled.Installer-Linux
wget https://github.com/Exiled-Team/EXILED/releases/download/2.2.5/Exiled.Installer-Linux
chmod +x Exiled.Installer-Linux
echo "Installer updated. Running.."
EXTRA=""
if [ $PRE_RELEASE == 1 ]; then
        EXTRA="--pre-releases"
fi
if [ ! -z $EXILED_VER ]; then
        EXTRA="--pre-releases --target-version $EXILED_VER"
fi

./Exiled.Installer-Linux -p /home/container/scp_server $EXTRA
rm -rf "temp" &&
mkdir "temp" &&
export DOTNET_BUNDLE_EXTRACT_BASE_DIR="temp"
./Exiled.Installer-Linux -p /home/container/scp_server --pre-releases --exit
cd .config &&

cd /home/container &&

stats=false
integration=false

if [ -f "/home/container/.config/EXILED/Plugins/PlayerStats.dll" ]; then
    stats=true
fi

if [ -f "/home/container/.config/EXILED/Plugins/DiscordIntegration_Plugin.dll" ]; then
    integration=true
fi

if $integration && $stats; then
    cd DiscordIntegration &&
    mono DiscordIntegration_Bot.exe > /home/container/DiscordIntegration/logs/latest.log &
    cd /home/container/PlayerStatsBot &&
    mono PlayerStatsBot.exe > /home/container/PlayerStatsBot/latest.log &
    cd /home/container/scp_server &&
    ${MODIFIED_STARTUP};
elif $integration; then
    cd DiscordIntegration &&
    mono DiscordIntegration_Bot.exe > /home/container/DiscordIntegration/logs/latest.log &
    cd /home/container/scp_server &&
    ${MODIFIED_STARTUP};
elif $stats; then
    cd PlayerStatsBot &&
    mono PlayerStatsBot.exe > /home/container/PlayerStatsBot/latest.log &
    cd /home/container/scp_server &&
    ${MODIFIED_STARTUP};
else
    cd /home/container/scp_server &&
    ${MODIFIED_STARTUP};
fi
