#!/bin/bash
#
# Replace variables with the proper values.
#
# Once done, as root run 'crontab -e' and put the following line to run this current sh-script:
# * * * * * /bin/bash /path/to/script/vpn_restarter.sh
# This will check VPN connectivity every minute and restart the VPN py-script if needed.
# Note: snx VPN client should be already installed (use snx_install_2013_07_26_800007075.sh).
#
IP_ADDRESS="172.30.135.24"  # any IP address available through VPN only (to check connectivity)
#Set environment variables with the valid VPN USER and PASSWORD
export SNX_USER=your_vpn_username
export SNX_PWD=your_vpn_password
SCRIPT_DIR="/tmp/git/e2e_si_automation/scripts/vpn"   # abs path to the script folder.
SCRIPT_NAME="snx_vpn_connect.py"  # take it from "scripts" folder in "e2e_si_automation" repo.

# Below can be left intact
dt="$(date '+%Y-%m-%d %H:%M:%S')"
if [ "$(ping -c1 -W1 $IP_ADDRESS > /dev/null && echo 'up' || echo 'down')" == "down" ]
then
    if ! pgrep -x "snx" > /dev/null
    then
        echo "Closing all the existing instance of python snx_vpn_connect.py and snx"
        kill $(ps ax | grep 'python snx_vpn_connect.py' | grep -v grep | awk '{print $1}')
        kill $(pidof snx)
        echo "${dt} Restarting: 'python $SCRIPT_DIR/$SCRIPT_NAME'"
        cd $SCRIPT_DIR && python $SCRIPT_NAME
    fi
fi
