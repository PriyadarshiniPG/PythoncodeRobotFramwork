*** Settings ***
Documentation     Locked channel and events keyword implementation
Resource          ../Common/Common.robot
Resource          ../CommonPages/Modal_Implementation.robot
Resource          ../PA-08_Settings/Preferences_Keywords.robot

*** Keywords ***
Manage locked channels is shown
    [Documentation]    This keyword asserts that manage locked channels window is shown
    wait until keyword succeeds    ${JSON_MAX_RETRIES}    ${JSON_RETRY_INTERVAL}    I expect page contains 'textKey:DIC_LOCKED_HEADER'

Manage Locked empty channels is shown
    [Documentation]    This keyword asserts that empty locked channels list is shown
    wait until keyword succeeds    ${JSON_MAX_RETRIES}    ${JSON_RETRY_INTERVAL}    I expect page contains 'textKey:DIC_LOCKED_LIST_EMPTY'

I check if channel ${channel_number} has lock icon    #USED
    [Documentation]    This keyword returns a boolean value stating if channel has a lock icon shown in the list
    ${json_object}    Get Ui Json
    : FOR    ${index}    IN RANGE    ${0}    ${14}
    \    ${icon_lock}    Set Variable    False
    \    ${ancestor}    Get Enclosing Json    ${json_object}    ${EMPTY}    id:item-check-icon-${index}    ${1}
    \    ${length}    Get Length    ${ancestor}
    \    Continue For Loop If   ${length} == 0
    \    ${icon_lock}    Set Variable    ${ancestor['textValue']}
    \    ${ancestor}    Get Enclosing Json    ${json_object}    ${EMPTY}    id:item-prefix-text-${index}    ${1}
    \    ${retrieved_channel_number}    Set Variable    ${ancestor['textValue']}
    \    Exit For Loop If    '${retrieved_channel_number}' == '${channel_number}'
    ${is_has_lock_icon}    Evaluate    True if "${icon_lock}" == "J" else False
    [Return]    ${is_has_lock_icon}

I Clear Locked channel list    #USED
    [Documentation]    This keyword clears all the locked channels from the locked channel list and navigates back to
    ...    Channel locking option in settings
    I open Lock Channels through Parental Control
    I enter a valid pin
    ${status}    run keyword and return status    wait until keyword succeeds    10 times    2s    verify clear locked list is present
    run keyword if    ${status}    I choose Clear list on Manage Locked channels
    ...    ELSE    LOG    "List is empty"
    I press    BACK

Check if clear locked list is present
    [Documentation]    This keyword checks the clear locked list button is present or not
    ${json_object}    Get Ui Json
    ${clear_list_present}    Is In Json    ${json_object}    ${EMPTY}    textKey:DIC_LOCKED_MENU_CLEAR
    [Return]    ${clear_list_present}

verify clear locked list is present
    [Documentation]    This keyword verifies that the clear locked list button is present
    ${clear_list_present}    Check if clear locked list is present
    should be true    ${clear_list_present}    clearlocked list is not present

I choose Clear List on Manage Locked channels
    [Documentation]    This keyword verifies that the manage locked channels list is empty
    Manage locked channels is shown
    I focus 'Clear list' for locked
    I press    OK
    Clear Locked channels list is shown
    I focus Clear Locked channels
    I press    OK
    wait until keyword succeeds    3times    2 sec    Manage Locked empty channels is shown

I focus Clear Locked channels
    [Documentation]    This keyword focuses clear locked channels button in the modal window
    Move Focus to Button in Interactive Modal    textKey:DIC_MODEL_BUTTON_CLEAR_LOCKED_LIST    UP    3

Clear Locked channels list is shown
    [Documentation]    This keyword asserts that the Clear Locked channels list is shown
    wait until keyword succeeds    ${JSON_MAX_RETRIES}    ${JSON_RETRY_INTERVAL}    I expect page contains 'textKey:DIC_MODEL_HEADER_CLEAR_LOCKED_LIST'

I set channel ${channel} as User Locked    #USED
    [Documentation]    Sets given channel as user locked
    I open Lock Channels through Parental Control
    I enter a valid pin
    Pin Entry popup is not shown
    I open 'Add channels' for Locked
    I add Channel ${channel} to the Locked channels list
    ${is_locked}    I check if channel ${channel} has lock icon
    Should Be True    ${is_locked}
    I open Channel Bar

Clear locked channel list via AS restart UI    #USED
    [Documentation]    This keyword clears the locked channel list and restarts UI in order to reflect the changes
    Reset Channels    LOCKED
    Restart UI via command over SSH

Clear Locked Channel List Via Rebooting STB    #USED
    [Documentation]    This keyword clears the locked channel list and reboot the STB
    Reset Channels    LOCKED
    Reboot CPE
    Get Power State of CPE
    Should Be Equal    ${power_state}    Operational    Unable to reboot the CPE
    ${is_now_and_next_visible}    Run Keyword And Return Status    Wait Until Keyword Succeeds    40 times    500 ms    I expect page contains 'id:NowAndNext.View'
    Should Be True    ${is_now_and_next_visible}    Channel bar is not displayed after rebooting the CE

I open Lock channels with valid pin
    [Documentation]    This keyword opens locked channels through parental control and enters valid pin
    I open Lock Channels through Parental Control
    Pin Entry popup is shown
    I enter a valid pin

Manage locked channels is not shown
    [Documentation]    This keyword asserts manage locked channels window is not shown
    I do not expect page contains 'textKey:DIC_LOCKED_HEADER'
