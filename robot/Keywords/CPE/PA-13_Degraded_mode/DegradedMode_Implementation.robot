*** Settings ***
Documentation     Degraded Mode Implementation keywords
Resource          ../Common/Stbinterface.robot
Resource          ../Json/Json_handler.robot

*** Keywords ***
Reset all created iptables rules
    [Documentation]    This keyword logins into the STB via SSH and deletes all newly created iptables rules, loading
    ...    either the default iptables file /etc/iptables.sav or a backup in the /tmp folder if the IPTABLES_BACKUP
    ...    variable is set via the iptables-restore command.
    ${iptables_backup_exists}    run keyword and return status    variable should exist    ${IPTABLES_BACKUP}
    ${backup_file}    set variable if    ${iptables_backup_exists}    /tmp/iptables_backup    /etc/iptables.sav
    ${ssh_handle}    Remote.open connection    ${STB_IP}
    Remote.login    ${STB_IP}    ${ssh_handle}    ${username}    ${password}
    Remote.execute command    ${STB_IP}    ${ssh_handle}    /usr/sbin/iptables-restore ${backup_file}
    Remote.close connection    ${STB_IP}    ${ssh_handle}
