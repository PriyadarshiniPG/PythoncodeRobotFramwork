*** Settings ***
Resource          ../Common/Stbinterface.robot
Resource          ../PA-05_Linear_TV/LinearDetailsPage_Keywords.robot
Resource          ../PA-01_HW_and_Platform_Support/Platform_Keywords.robot

*** Variables ***
&{STANDBY_POWER_LEVEL}    Quick start=24.8    Normal start=17.3
${Operational_Powerstate}    Operational

*** Keywords ***
verify network interface is
    [Arguments]    ${network_status}
    [Documentation]    Check if network interface is active by sending a ip key to stb
    ...    Takes argument as 'Active' or 'Inactive'
    ${network_status}    convert to lowercase    ${network_status}
    ${status}    run keyword and return status    I Press    OK
    run keyword if    '${network_status}' == 'active'    should be true    ${status}    Network interface is not active
    ...    ELSE    should not be true    ${status}    Network interface is active

verify storage devices are
    [Arguments]    ${status}    ${ssh_handle}
    [Documentation]    Check storage device status. For Arris/Humax, HDD is not mandatory but SD card is.
    ...    But some slots on C3 Arris rack dont have SD cards. So, cant enfore this condition.
    ...    For Selene, HDD is mandatory but SD card is not.
    ${sd_mount_status}    get device mount status    sd    ${ssh_handle}
    ${hdd_mount_status}    get device mount status    hdd    ${ssh_handle}
    run keyword if    '${status}'=='active'    should be true    ${sd_mount_status} or ${hdd_mount_status}    None of the storage devices are active
    ...    ELSE    should be false    ${sd_mount_status} and ${hdd_mount_status}    Some or all storage devices are active

verify Front panel keys are
    [Arguments]    ${ssh_handle}    ${status}
    [Documentation]    Check Front panel keys state
    ${led_regex_string}    set variable if    '${status}'=='active'    dsMgrMain.*LED.*0.*color is changed to colorIndex.*15138815    dsMgrMain.*LED.*0.*color is changed to colorIndex.*9871510
    ${output}=    Remote.execute_command    ${STB_IP}    ${ssh_handle}    journalctl -b -a | grep -i "${led_regex_string}"
    should not be empty    ${output}    No LED state changes were recorded in the log

verify IR-RF4CE receiver is
    [Arguments]    ${ssh_handle}    ${state}
    [Documentation]    Check IR-RF4CE receiver state
    Clear all logs on STB via Serial
    I press    OK
    ${log_regex_string}    set variable    COMCAST IR Key.*From Remote Device received
    ${output}=    Remote.execute_command    ${STB_IP}    ${ssh_handle}    journalctl -b -a | grep -i '${log_regex_string}'|wc -l
    ${number}    convert to integer    ${output}
    run keyword if    '${state}'=='active'    should be true    ${number}>0    No key presses received
    ...    ELSE    should be true    ${number}==0    Key presses received when not expected

verify Video Processor is in
    [Arguments]    ${ssh_handle}    ${status}
    [Documentation]    Check Video Processor status. Currently only working for Arris/Humax.
    return from keyword if    '${PLATFORM}'=='SMT-G7401' or '${PLATFORM}'=='SMT-G7400'
    ${status_string}    set variable if    '${status}'=='active'    started    stopped
    ${output}=    Remote.execute_command    ${STB_IP}    ${ssh_handle}    cat /proc/brcm/video_decoder | grep ': codec=2' |awk -F: '{print $1}'
    ${matches}    Get Regexp Matches    ${output}    ${status_string}
    Should Not Be Empty    ${matches}    Video processor state not as expected

verify DVB-C Tuners are
    [Arguments]    ${status}
    [Documentation]    Check DVB-C Tuners state
    ${total_free_tuners}    Get Number Of Available Tuners
    run keyword if    '${status}'=='active'    should be true    ${total_free_tuners}>${0}    No tuners are available
    ...    ELSE    should be true    ${total_free_tuners}==${0}    Free tuners available when none were expected

verify EMM monitoring is
    [Arguments]    ${ssh_handle}    ${status}
    [Documentation]    Check EMM monitoring status
    I add all CA entitlements
    sleep    1 minute
    ${output}=    Remote.execute_command    ${STB_IP}    ${ssh_handle}    journalctl -b -u jsapp | grep NagraMessages.DomainModel::processPopUp
    ${matches}    Get Regexp Matches    ${output}    NagraMessages.DomainModel::processPopUp
    run keyword if    '${status}'=='active'    Should Not Be Empty    ${matches}    Nagra messages not received when expected
    ...    ELSE    Should Be Empty    ${matches}    Nagra messages received when not expected

Standby warning toast message is present
    [Documentation]    Keyword to verify the toast message for standby is present
    wait until keyword succeeds    ${JSON_MAX_RETRIES}    ${JSON_RETRY_INTERVAL}    I expect page contains 'textKey:DIC_INTERACTIVE_NOTIFICATION_AUTOSTANDBY_MESSAGE1'
    wait until keyword succeeds    ${JSON_MAX_RETRIES}    ${JSON_RETRY_INTERVAL}    I expect page contains 'textKey:DIC_INTERACTIVE_NOTIFICATION_AUTOSTANDBY_BUTTON'

Standby warning toast message is not present
    [Documentation]    Keyword to verify the toast message for standby is not present
    ${status}=    run keyword and return status    Standby warning toast message is present
    should not be true    ${status}    Standby warning toast message should not present

The power consumption in ${standby_mode} is attained
    [Documentation]    Check Power lovel for the given power consumption mode
    ${current_power_level}    get power level    ${STB_SLOT}    ${STB_PDU_SLOT}
    ${current_power_level}    convert to number    ${current_power_level}
    ${expected_power_level}=    Get From Dictionary    ${STANDBY_POWER_LEVEL}    ${standby_mode}
    ${expected_power_level}    convert to number    ${expected_power_level}
    run keyword if    ${current_power_level} > ${expected_power_level}    fail    Power consumption is high

Get current power state via AS
    [Documentation]    Gets the current power state via app services and returns ${current_power_state}
    ${current_power_state}    get current power state from stb via as    ${STB_IP}    ${CPE_ID}    xap=${XAP}
    [Return]    ${current_power_state}

Get current power state with state change reason via AS
    [Documentation]    Gets the current power state with state change reason via app services and returns ${power_state}
    ${power_state}    get power state from stb via as    ${STB_IP}    ${CPE_ID}    xap=${XAP}
    [Return]    ${power_state}

Power Suite Teardown
    [Documentation]    Suite teardown for Power suite operations
    I reboot the STB
    I verify STB is booting up in normal mode
    wait until keyword succeeds    5 times    1 sec    Set standby setting    ActiveStandby
    Default Suite Teardown

Hot Standby Suite Teardown
    [Documentation]    Suite teardown for Hot Standby suite operations
    I put stb out of standby
    I reboot the STB
    I verify STB is booting up in normal mode
    ${power_state_exist}    Run Keyword And Return Status    variable should exist    ${STANDBY_MODE}    power state is not set
    run keyword if    '${power_state_exist}' == '${True}'    Set application services setting    cpe.standByMode    ${STANDBY_MODE}
    Default Suite Teardown

Standby Suite Setup
    [Documentation]    Suite setup for Standby suite operations
    Default Suite Setup
    ${standby_mode}    get application service setting    cpe.standByMode
    set suite variable    ${STB_RETRIEVED_STANDBY_MODE}    ${standby_mode}

Power On Setup
    [Documentation]    Suite setup for power on operation
    Default Suite Setup
    I turn power off
    Stb is turned off

Verify that STB is in standby mode
    [Documentation]    Get STB power state and Verify that STB is in standby mode
    ${power_state}    Get current power state via AS
    should not be equal    ${power_state}    ${Operational_Powerstate}    STB failed to set to standby mode
