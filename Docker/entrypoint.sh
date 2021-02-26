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

if [ -f "/home/container/.config/EXILED/Plugins/DiscordIntegration.dll" ]; then
        cd DiscordIntegration &&
        if [ ! -d "/home/container/DiscordIntegration/node_modules" ]; then
                npm install package.json
        fi
        
        node discordIntegration.js > /home/container/DiscordIntegration/logs/latest.log &
        sed "s/port:.*/port: ${SERVER_PORT}/g" config.yml > output.txt &&
        rm -rf config.yml &&
        mv output.txt config.yml &&
        cd /home/container &&
       
        sed "s/port:.*/port: ${SERVER_PORT}/g" .config/EXILED/Configs/${SERVER_PORT}-config.yml > output.txt &&
        rm -rf .config/EXILED/Configs/${SERVER_PORT}-config.yml &&
        mv output.txt .config/EXILED/Configs/${SERVER_PORT}-config.yml
fi

cd /home/container/scp_server &&
${MODIFIED_STARTUP};