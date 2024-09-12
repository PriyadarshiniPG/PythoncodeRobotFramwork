*** Settings ***
Documentation     Degraded Mode keywords
Resource          ../Common/Stbinterface.robot
Resource          ../Json/Json_handler.robot
Resource          ../PA-13_Degraded_mode/DegradedMode_Implementation.robot
Resource          ../PA-06_TV_Guide/TVGuide_Keywords.robot

*** Keywords ***
Generic degraded mode message is shown
    [Documentation]    This keyword verifies that the generic degraded mode message is shown.
    wait until keyword succeeds    ${JSON_MAX_RETRIES}    ${JSON_RETRY_INTERVAL}    I expect page element 'id:rightErrorCode' contains 'textValue:CS9994'
    ${error_message}    Is In Json    ${LAST_FETCHED_JSON_OBJECT}    ${EMPTY}    textKey:DIC_ERROR_9994_MESSAGE
    ${interactive_popup}    Is In Json    ${LAST_FETCHED_JSON_OBJECT}    ${EMPTY}    id:interactiveModalPopupBody
    Should Be True    ${error_message} or ${interactive_popup}    Degraded mode error message popup is not shown

Generic degraded mode message is not shown
    [Documentation]    This keyword verifies that the generic degraded mode message is not shown.
    wait until keyword succeeds    ${JSON_MAX_RETRIES}    ${JSON_RETRY_INTERVAL}    I do not expect page element 'id:rightErrorCode' contains 'textValue:CS9994'

I invoke degraded mode via SSH with verification
    [Documentation]    This keyword invokes degraded mode via SSH, modifying firewall rules via iptables to drop
    ...    UDP packets on port 53, and to drop all packets from the STB to the 172.30.187.227 IP address,
    ...    and verifies the STB is in degraded mode.
    ${sshhandle}    Remote.open connection    ${ROUTER_PC}
    Remote.login    ${ROUTER_PC}    ${sshhandle}    ${ROUTER_PC_USER}    ${ROUTER_PC_PWD}
    Remote.execute_command    ${ROUTER_PC}    ${sshhandle}    sudo iptables -A FORWARD -s ${STB_IP} -d 172.30.187.227 -j DROP
    Remote.execute_command    ${ROUTER_PC}    ${sshhandle}    sudo iptables -A OUTPUT -s ${STB_IP} -d 172.30.187.227 -j DROP
    Remote.execute_command    ${ROUTER_PC}    ${sshhandle}    sudo iptables -A FORWARD -s ${STB_IP} -p udp --dport 53 -j DROP
    Remote.execute_command    ${ROUTER_PC}    ${sshhandle}    sudo iptables -A INPUT -s ${STB_IP} -p udp --dport 53 -j DROP
    Remote.execute_command    ${ROUTER_PC}    ${sshhandle}    sudo iptables -A OUTPUT -s ${STB_IP} -p udp --dport 53 -j DROP
    ${out}    Remote.execute_command    ${ROUTER_PC}    ${sshhandle}    sudo iptables -L --line-number
    ${count}    Get count    ${out}    ${STB_IP}
    Should Be True    ${count}==5    All IP Rules havent been set, count should be 5
    Remote.close_connection    ${ROUTER_PC}    ${sshhandle}
    Setup XAP for degraded mode test
    I wait for 60 seconds
    wait until keyword succeeds    7times    20sec    STB is in degraded mode

I enable IP return path connectivity
    [Documentation]    This keyword puts the box out of degraded mode by deleting the iptables rules,
    ...    and sets the ${DegradedMode} variable to False.
    delete iptables rules    ${ROUTER_PC}    ${ROUTER_PC_USER}    ${ROUTER_PC_PWD}    ${STB_IP}
    Setup XAP for degraded mode test    ${False}

Setup XAP for degraded mode test
    [Arguments]    ${DegradedMode}=${True}
    [Documentation]    This keyword saves the value of the ${DegradedMode} argument to a global variable and
    ...    creates a XAP Session by checking XAP connection details and the XAP connection are in degraded mode,
    ...    then loads the Remote library.
    set global variable    ${DegradedMode}
    Run Keyword If    ${XAP} == ${True}    Run Keywords    Set XAP connection details    xap_degraded_session
    ...    AND    Check XAP Connection    xap_degraded_session
    load remote library

Check the Degraded Mode Status via Application Services
    [Documentation]    This keyword checks the degraded mode status via app services and returns the result.
    ${ret}    get application services utilities via as    ${STB_IP}    ${CPE_ID}    isDegradedMode    xap=${XAP}
    [Return]    ${ret}

STB is not in degraded mode
    [Documentation]    This keyword verifies that the box is not in degraded mode via app services.
    ...    Meant to be used in Common Suite Setup
    ${ret}    Check the Degraded Mode Status via Application Services
    should not be true    ${ret}    "isDegradedMode" is True, the box is in degraded mode

STB is in degraded offline mode
    [Documentation]    This keyword checks if metadata folders are updated.
    ${sshhandle}    Remote.open connection    ${STB_IP}
    Remote.login    ${STB_IP}    ${sshhandle}
    Remote.execute_command    ${STB_IP}    ${sshhandle}    rm -rf /usr/share/lgias/data/epg/events/*
    ${events_data}    Remote.execute_command    ${STB_IP}    ${sshhandle}    ls -l /usr/share/lgias/data/epg/events/ | wc -l
    should be equal    '${events_data}'    '0'    EPG events are not removed
    Remote.execute_command    ${STB_IP}    ${sshhandle}    rm -rf /usr/share/lgias/data/epg/meta-info/*
    ${metainfo_data}    Remote.execute_command    ${STB_IP}    ${sshhandle}    ls -l /usr/share/lgias/data/epg/meta-info | wc -l
    should be equal    '${metainfo_data}'    '0'    EPG Meta Info data is not removed
    Remote.close connection    ${STB_IP}    ${sshhandle}

I restart UI for degraded offline mode
    [Documentation]    This keyword reboots the box, enters the pin and verifies the box is still in degraded mode.
    ${current_pin}    get pin via personalization service    ${LAB_CONF}    ${CUSTOMER_ID}
    @{master_pin}    Split String To Characters    ${current_pin}
    Restart UI via command over SSH
    wait until keyword succeeds    8 times    5sec    I expect page element 'id:fatalErrorMessage' contains 'textKey:DIC_ERROR_9004_MESSAGE'
    I press    OK
    wait until keyword succeeds    4 times    5sec    Pin Entry popup is shown
    : FOR    ${digit}    IN    @{master_pin}
    \    I Press    ${digit}
    wait until keyword succeeds    4times    2sec    Pin Entry popup is not shown
    I press    GUIDE
    ${setup_successful}    Run Keyword And Return Status    I Check If EPG Event Info Is Available
    Run Keyword If    ${setup_successful}    Fail    Guide shouldn't be shown
    repeat keyword    2times    I press    BACK

STB is in degraded mode
    [Documentation]    This keyword checks that the box is not in degraded mode, via app services.
    ...    Meant to be used in Common Suite Setup.
    ${ret}    Check the Degraded Mode Status via Application Services
    should be true    ${ret}    "isDegradedMode" is False, the box is not in degraded mode

Degraded Mode Specific Suite Teardown
    [Documentation]    Suite teardown that reverts back the degraded mode.
    Wait until keyword succeeds    3times    1s    I enable IP return path connectivity
    Wait until keyword succeeds    3times    5s    stb is not in degraded mode
    Default Suite Teardown

Degraded Mode Recordings Specific Teardown
    [Documentation]    Suite teardown that deletes all recordings and reverts back the degraded mode.
    Reset All Recordings
    Degraded Mode Specific Suite Teardown

Degraded mode Player Specific Teardown
    [Documentation]    Suite teardown that reverts back degraded mode and restart UI to get out of playback
    I enable IP return path connectivity
    Player Specific Teardown

I open Change PIN in degraded mode
    [Documentation]    Navigate down to Change PIN option and selects the option
    ...    Precondition : Parental Control should be open
    I focus Change PIN
    I Press    OK
    Pin Entry popup is not shown

Make sure STB is not in degraded mode
    [Documentation]    This keyword checks the box is not in degraded. If not, reboots the box and verifies the box
    ...    is not in degraded mode.
    ${ret}    Check the Degraded Mode Status via Application Services
    return from keyword if    ${ret} == ${False}
    run keyword if    '${PLATFORM}' != 'SMT-G7400' and '${PLATFORM}' != 'SMT-G7401'    fail test    "isDegradedMode" is True, the box is in degraded mode
    I power cycle the STB through SSH
    Run keyword if    '${OBELIX}' == 'True'    I verify STB is booting up in normal mode
    ...    ELSE    I wait for 3 minutes
    wait until keyword succeeds    6 times    15 sec    STB is not in degraded mode

I verify that the STB is in normal operating mode
    [Documentation]    This keyword verifies that The STB is not in any standby mode and has an ethernet connection.
    verify that stb is not in standby mode
    Ethernet connection detected

I open Guide through Main Menu in offline mode
    [Documentation]    This keyword opens the Guide through Main Menu in offline mode.
    I Press    MENU
    Main Menu is shown
    I focus TV Guide
    I Press    OK
    Wait Until Keyword Succeeds    ${JSON_MAX_RETRIES}    ${JSON_RETRY_INTERVAL}    I expect page element 'id:Guide.View' contains 'viewStateKey:Error'

Iptables Reset Specific Teardown
    [Documentation]    Suite teardown that restores the iptables rules of the STB to their original values
    Reset all created iptables rules
    Default Suite Teardown

Replay TV functionality is not available in Degraded mode
    [Documentation]    This keyword will verify that the Replay TV functionality is not available in Degraded mode.
    Replay icon is not shown in channelbar
    I Press    OK
    Generic degraded mode message is shown

Degraded mode Ongoing Recordings specific Teardown
    [Documentation]    Suite teardown that resets ongoing recordings and reverts back the degraded mode.
    Ongoing Recordings Specific Test Teardown
    Degraded Mode Specific Suite Teardown

I record an ongoing event in degraded mode
    [Documentation]    This keyword records an ongoing single event in degraded mode
    I tune to Single event channel
    Channel Bar is shown
    I press    OK
    Linear Details Page is shown
    ${degraded_mode_message_shown}    Run Keyword And Return Status    Generic degraded mode message is shown
    run keyword if    '${degraded_mode_message_shown}' == '${True}'    I Press    BACK
    I focus record button
    I press    OK
    Interactive modal is shown
    I expect page element 'id:interactiveModalButton0' contains 'textKey:DIC_NPVR_RECORD_BUTTON_SINGLE'
    I press    OK
    Interactive modal is not shown
    Wait Until Keyword Succeeds    20 times    500 ms    I expect page element 'id:recordingTextInfoprimaryMetadata' contains 'textKey:DIC_RECORDING_LABEL_SINGLE_RECORDING_NOW'
