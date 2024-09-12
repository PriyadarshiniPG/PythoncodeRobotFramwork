*** Settings ***
Documentation     Keywords related to power operations, standby, power cycling

*** Keywords ***
Verify that STB is not in standby mode
    [Documentation]    Get STB power state and Verify that STB is not in standby mode
    ${power_state}    Get current power state via AS
    should be equal    ${power_state}    ${Operational_Powerstate}    STB failed to come out of standby

#Restart UI via command over SSH
#    [Documentation]    Sends a STB restart command over SSH
#    ${ssh_handle}    Remote.open connection    ${STB_IP}
#    Remote.login    ${STB_IP}    ${ssh_handle}
#    Remote.execute_command    ${STB_IP}    ${ssh_handle}    systemctl restart lgias
#    Remote.close connection    ${STB_IP}    ${ssh_handle}
#    wait until keyword succeeds    2 min    5 s    Get Ui Json

#Restart UI via command over SSH by invoking /sbin/reboot
#    [Documentation]    This keyword restart UI on the STB by invoking /sbin/reboot script
#    Power cycle and make sure that STB is active

the preferred standby setting is set to ${standbymode}
    [Documentation]    To set the standby settings in the stb
    log    Not Implemented    WARN

I put stb in standby cycle    #USED
    [Documentation]    Put the stb in/out of standby. Currently doing power cycle as standby feature not implemented
    I put stb in standby
    I put stb out of standby
    ${power_state}    Get current power state via AS
    ${power_state}    convert to lowercase    ${power_state}
    should be equal as strings    '${power_state}'    'operational'    STB did not come out of standby

I put stb in standby   #USED
    [Documentation]    Put the stb to standby by pressing the Power key
    I Press    POWER
    wait until keyword succeeds    4 times    1s    content unavailable

I put stb out of standby   #USED
    [Documentation]    Put the stb out of standby by pressing the Power key
    I Press    POWER
    verify content is valid on the stb with all possible means

I put stb in standby to clear unlock history
    [Documentation]    Put the stb in standby in order to clear the unlock history of the channels
    I Press    POWER
    wait until keyword succeeds    10s    0s    Check content is unavailable

I put stb out of standby to clear unlock history
    [Documentation]    Put the stb out of standby in order to clear the unlock history of the channels
    I Press    POWER
    I wait for 5 second
    wait until keyword succeeds    4 times    1s    Verify that STB is not in standby mode

I power cycle the STB
    [Documentation]    Only powercycle the STB
    power cycle    ${STB_SLOT}    ${STB_PDU_SLOT}

I reboot the STB and wait for it to come up
    [Documentation]    Reboot and wait to let STB come up again
    I reboot the STB
    I wait until stb is up and running

I power cycle the STB for stability
    [Documentation]    do a powercycle , wait 4m
    power cycle    ${STB_SLOT}    ${STB_PDU_SLOT}
    ${INITIAL_CHECK_FOR_REMOTE_PAIRING_TIPS_SCREEN}    Set Variable    ${CHECK_FOR_REMOTE_PAIRING_TIPS_SCREEN}
    ${INITIAL_CHECK_FOR_REMOTE_PAIRING_REQ_POPUP}    Set Variable    ${CHECK_FOR_REMOTE_PAIRING_REQ_POPUP}
    Set Suite Variable    ${CHECK_FOR_REMOTE_PAIRING_TIPS_SCREEN}    ${True}
    Set Suite Variable    ${CHECK_FOR_REMOTE_PAIRING_REQ_POPUP}    ${True}
    I verify STB is booting up in normal mode
    verify content is valid on the stb with all possible means
    Set Suite Variable    ${CHECK_FOR_REMOTE_PAIRING_TIPS_SCREEN}    ${INITIAL_CHECK_FOR_REMOTE_PAIRING_TIPS_SCREEN}
    Set Suite Variable    ${CHECK_FOR_REMOTE_PAIRING_REQ_POPUP}    ${INITIAL_CHECK_FOR_REMOTE_PAIRING_REQ_POPUP}

There is no unlock history    #USED
    [Documentation]    Do a Standby cycle of 10sec and check content is available or not
    I put stb in standby to clear unlock history
    I wait for 1 second
    I put stb out of standby to clear unlock history

I reboot the STB    #USED
    [Documentation]    Power cycles the STB
    ${status}    run keyword and return status    power cycle    ${STB_SLOT}    ${STB_PDU_SLOT}
    run keyword if    '${status}' == 'False'    I power cycle the STB through SSH

#I power cycle the STB through SSH
#    [Documentation]    The keyword is used to reboot the box the thorugh SSH
#    ${ssh_handle}    Remote.open connection    ${STB_IP}
#    Remote.login    ${STB_IP}    ${ssh_handle}
#    ${output}    Remote.execute_command    ${STB_IP}    ${ssh_handle}    /sbin/reboot&
#    Remote.close connection    ${STB_IP}    ${ssh_handle}

I power cycle the STB through Serial
    [Documentation]    The keyword is used to reboot the box thorugh Serial
    run keyword if    '${SERIALCOM}' == 'False'    fail test    Serial Port is not opened
#    Drop input buffer and send command    /sbin/reboot

Make sure that STB is active    #USED
    [Documentation]    Keyword to make sure that STB is actve(i.e FTI state is completed) and not in standby mode by making use of XAP
    ...    Obelix check is used to confirm that Obelix is working
#    ${status}    run keyword and return status    Try to verify that FTI state is completed
#    run keyword if    '${status}'!='True'    Power cycle and make sure that STB is active
    Make sure that STB is not in standby
    #Run keyword if    '${OBELIX}' == 'True'    Make sure that Obelix is available

Power cycle and make sure that STB is active    #USED
    [Documentation]    To be called when XAP is not available because the Set-top Box is not reachable
    ...    (i.e. Lukewarm stand-by).
    ...    It includes a sleep for the reboot, as we know it will not be available for the first 40 seconds.
    I reboot the STB
    I wait until stb is up and running

I wait until stb is up and running    #USED
    [Documentation]    From powercycle, wait until STB is up and running
    Run keyword if    '${OBELIX}' == 'True'    I verify STB is booting up in normal mode
    ...    ELSE    Sleep    2 minute
    Try to verify that FTI state is completed

Make sure that STB is not in standby    #USED
    [Documentation]    Get Standby mode eventually bring the Set-top Box out of standby.
    ...    This does not guarantee that content is available, nor that UI JSON state can be retrieved.
    return from keyword if    ${IS_SELENE_SWITCH_IMAGE}
    ${power_state}    run keyword and continue on failure    Get current power state via AS
    return from keyword if    '${power_state}'=='${Operational_Powerstate}'
    ${status}    run keyword and return status    I put stb out of standby
    run keyword unless    ${status}    Make sure that STB is out of standby via IR

Power cycle to apply localization settings
    [Arguments]    ${country}=${COUNTRY}    ${language_code}=${OSD_LANGUAGE}
    [Documentation]    Keyword to apply changes on country code and OSD language and
    ...    verify that STB is running with country code BE and OSD language English after the reboot
    Power cycle and make sure that STB is active
    ${country}    convert to lowercase    ${country}
    Validate applied country settings    ${STB_IP}    ${CPE_ID}    ${country}    xap=${XAP}

Workaround Set hot standby
    [Documentation]    Try to set standby setting to ActiveStandby
    Set standby setting    ActiveStandby

Make sure that STB is out of standby via IR    #USED
    [Documentation]    Keyword makes sure that STB is out of standby via IR
    I send IR key    POWER
    wait until keyword succeeds    4times    10s    Verify that STB is not in standby mode

I put STB in hot standby mode
    [Documentation]    This keyword set STB in hot standby mode
    I set standby mode to    ActiveStandby
    I put stb in standby

I put STB out of hot standby mode in ${time} minutes after starting of the event
    [Documentation]    This keyword wait for ${time} minutes after event starts and put STB out of hot standby mode
    ${standby_length}    evaluate    ${time} + ${TIME_TILL_EVENT_START}
    Should Not Be True    ${standby_length} > 15    We can`t wait more then 15 minutes
    I wait for ${standby_length} minutes
    I put stb out of standby

Make sure the STB is not in cold standby
    [Documentation]    This keyword bring the stb if its in cold standby using IR remote
    # TODO - This keyword is ussing the serial and it should not use it
#    ${status}    run keyword and return status    Make sure serial is responding for inputs
#    return from keyword if    ${status}
    I power cycle the STB
    I wait for 90 seconds
#    ${status}    run keyword and return status    Make sure serial is responding for inputs
#    return from keyword if    ${status}
    I send IR key    POWER
#    wait until keyword succeeds    3x    30s    Make sure serial is responding for inputs
