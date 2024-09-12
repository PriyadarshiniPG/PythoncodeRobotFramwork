*** Settings ***
Documentation     Keywords concerning the behavior and settings of locked channels, but not general Parental Controls functionality
Resource          ../PA-09_Parental_Control/Locked_Implementation.robot

*** Keywords ***
I add Channel ${channel_number} to the Locked channels list    #USED
    [Documentation]    Add channel to locked channel list
    on list tune to channel ${channel_number}
    I Wait For 2 seconds
    ${is_locked}    I check if channel ${channel_number} has lock icon
    Run Keyword If    ${is_locked} == ${False}    I press    OK

I tune to an Operator locked channel
    [Documentation]    This keyword tunes to an operator locked channel
    I tune to channel    ${OPERATOR_LOCKED_CHANNEL}
    ${ancestor}    I retrieve json ancestor of level '2' in element 'id:titleText\\d' for element 'color:${HIGHLIGHTED_NAVIGATION_COLOUR}' using regular expressions
    @{regexp_match}    Get Regexp Matches    ${ancestor['id']}    ^.*(\\d+)$    1
    ${id}    Set Variable    ${regexp_match[0]}
    I expect page element 'id:titleText${id}' contains 'id:channelBarLockIconTag'

I tune to an Age rated channel
    [Documentation]    This keyword tunes to an age rated channel
    I tune to channel    ${LOCKED_EVENT_CHANNEL}
    Wait Until Keyword Succeeds    10 times    300 ms    I expect page element 'id:RcuCue' contains 'textKey:^DIC_RC_CUE_UNLOCK_(PROGRAM|CHANNEL)$' using regular expressions

I tune to an Operator Locked event
    [Documentation]    This keyword tunes to an operator locked event
    I tune to channel    ${OPERATOR_LOCKED_EVENT}
    Wait Until Keyword Succeeds    10 times    300 ms    I expect page element 'id:splashContainer' contains 'iconKeys:LOCK'

I tune to an Adult Locked event
    [Documentation]    This keyword tunes to an adult locked event
    I tune to channel    ${ADULT_LOCKED_EVENT_CHANNEL}
    Wait Until Keyword Succeeds    10 times    300 ms    I expect page element 'id:RcuCue' contains 'textKey:^DIC_RC_CUE_UNLOCK_(PROGRAM|CHANNEL)$' using regular expressions

Clear Locked Channel List In Teardown    #USED
    [Documentation]    Clears Locked channel list first through UI and then through AppService if fails
    [Timeout]    10 minutes
    ${status}    Run Keyword And Return Status    I Clear Locked channel list
    Run Keyword Unless    ${status}    Clear Locked Channel List Via Rebooting STB

I Tune To An User Locked IP Channel    #USED
    [Documentation]    This keyword tunes to an User Locked IP channel which is not a 4k, radio or app.
    ${filtered_list}    I Fetch Linear Channel List Filtered
    ${length}    Get Length    ${filtered_list}
    ${ip_channel}    Set Variable    ${None}
    :FOR    ${index}    IN RANGE    ${length}
    \    ${ip_channel}    Get Random IP Channel Number
    \    ${channel_id}    Get channel ID using channel number    ${ip_channel}
    \    ${is_channel_present}    Run Keyword and Return status    Should Contain    ${filtered_list}    ${channel_id}
    \    Exit For Loop If    ${is_channel_present}
    Should Not Be Equal    ${ip_channel}    ${None}    Unable to find an IP Channel
    I set channel ${ip_channel} as User Locked
    I tune to channel    ${ip_channel}

I tune to an Operator Locked event on the IP channel
    [Documentation]    This keyword tunes to an operator locked IP channel
    I tune to channel    ${OPERATOR_LOCKED_IP_CHANNEL}
    Wait Until Keyword Succeeds    10 times    300 ms    I expect page contains 'textKey:DIC_LOCKED_CHANNEL'
