#!/bin/bash
echo "Hello!"
# Default the TZ environment variable to UTC.
TZ=${TZ:-UTC}
export TZ
cd /home/container || exit
MODIFIED_STARTUP=$(eval echo "$(echo "${STARTUP}" | sed -e 's/{{/${/g' -e 's/}}/}/g')")
echo "/home/container/scp_server$: ${MODIFIED_STARTUP}"

if [ $REINSTALL == 1 ]; then
        if [ ! -f "steamcmd.sh" ]; then
            curl -sqL "https://steamcdn-a.akamaihd.net/client/installer/steamcmd_linux.tar.gz" | tar zxvf -
        fi
        if [ ! -d "steamcmd" ]; then
            curl -sqL "https://steamcdn-a.akamaihd.net/client/installer/steamcmd_linux.tar.gz" | tar zxvf -
        fi
        EX=""
        if [ ! -z $SL_BRANCH ]; then
                EX="-beta $SL_BRANCH"
                if  [ ! -z $BRANCH_PASSWORD ]; then
                        EX="-beta $SL_BRANCH -betapassword $BRANCH_PASSWORD"
                fi
        fi
        echo $EX
        ./steamcmd.sh +login anonymous +force_install_dir ./scp_server +app_update 996560 validate $EX +quit
#        cp -r ~/Steam/steamapps/common/SCP*/* ~/scp_server
fi

cd /home/container/scp_server &&
${MODIFIED_STARTUP};
