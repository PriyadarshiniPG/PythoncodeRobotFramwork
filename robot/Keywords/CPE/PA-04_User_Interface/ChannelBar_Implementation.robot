*** Settings ***
Documentation     Channel bar implementation keywords
Resource          ../Common/Common.robot
Resource          ../PA-18_Replay_TV/ReplayTV_Implementation.robot
Library           Libraries.MicroServices.LinearService.LinearService

*** Keywords ***
get channel lcn for channel id    #USED
    [Arguments]    ${channel_id}
    [Documentation]    This keyword gets the channel number for the provided channel Id
    ${channel_number}    get channel number by id    ${CITY_ID}    ${channel_id}    ${OSD_LANGUAGE}    ${CPE_PRODUCT_CLASS}
    [Return]    ${channel_number}

Get Channel Name For Channel Id    #USED
    [Arguments]    ${channel_id}
    [Documentation]    This keyword gets the channel name for the provided channel Id
    ${channel_name}    Get Channel Name By Id    ${CITY_ID}    ${channel_id}    ${OSD_LANGUAGE}    ${CPE_PRODUCT_CLASS}
    [Return]    ${channel_name}

Get current channel number    #USED
    [Documentation]    This keyword gets the current channel number to which the STB is tuned
    ${is_channelbar_present}     Run Keyword And Return Status    I expect page contains 'id:NowAndNext.View'
    ${ui_json}    Get Ui Json
    Run Keyword If    not ${is_channelbar_present}    Run Keywords    I Press    OK    AND    Assert Json Changed    ${ui_json}
#    Wait Until Keyword Succeeds And Verify Status    20x    0s    'Channel bar is not displayed'    I expect page contains 'id:NowAndNext.View'
    ${channel_id}    get main session ref id via vldms    ${STB_IP}    ${CPE_ID}
    Log   VLDMS - Current channel_id: ${channel_id}
    ${channel_id_exist}    run keyword and return status    should not be empty    ${channel_id}
    ${json_object}    run keyword if    '${channel_id_exist}' == '${False}' and '${IS_STABILITY_TEST}' == '${False}'    Get Ui Json
    ${channel_number}    run keyword if    '${channel_id_exist}' == '${False}' and '${IS_STABILITY_TEST}' == '${False}'    Extract Value For Key    ${json_object}    id:nnchannelNumber    textValue
    ...    ${True}
    ...    ELSE    get channel lcn for channel id    ${channel_id}
#    ${channel_number}    get channel lcn for channel id    ${channel_id}
    [Return]    ${channel_number}

Next programme is focused implementation
    [Documentation]    This keyword asserts next programme is focused
    ${json_object}    Get Ui Json
    ${id_now}    Extract Value For Key    ${json_object}    textValue:NOW    id
    ${id}    Replace String    ${id_now}    nowBox    ${EMPTY}
    ${id}    Convert To Integer    ${id}
    ${id_next}    Evaluate    0 if ${id+1} == 5 else ${id+1}
    ${focused_element}    I retrieve json ancestor of level '1' for element 'id:titleText${id_next}'
    ${color}    set variable    ${focused_element['textStyle']['color']}
    Should Be Equal    ${color}    ${HIGHLIGHTED_NAVIGATION_COLOUR}    Next event is not focused

Previous programme is focused implementation
    [Documentation]    This keyword asserts previous programme is focused
    ${json_object}    Get Ui Json
    ${id_now}    Extract Value For Key    ${json_object}    textValue:NOW    id
    ${id}    Replace String    ${id_now}    nowBox    ${EMPTY}
    ${id}    Convert To Integer    ${id}
    ${id_previous}    Evaluate    4 if ${id-1} == -1 else ${id-1}
    ${focused_element}    I retrieve json ancestor of level '1' for element 'id:titleText${id_previous}'
    ${color}    set variable    ${focused_element['textStyle']['color']}
    Should Be Equal    ${color}    ${HIGHLIGHTED_NAVIGATION_COLOUR}    Previous event is not focused

Event is started
    [Documentation]    Checks if a given event is started
    ${event_container}    I retrieve json ancestor of level '2' for element 'textValue:${event_name}'
    ${event_is_started}    Is In Json    ${event_container}    ${EMPTY}    textKey:DIC_GENERIC_AIRING_TIME_NOW
    Should Be True    ${event_is_started}

I tune up to a non-UHD channel
    [Documentation]    This keyword tunes to non-UHD channel
    I press    CHANNELUP
    Skip UHD channels via CHANNELUP
    Skip Error popup
    I Press    BACK

Skip UHD channels via ${remote_key}
    [Documentation]    This keyword skip the UHD channels by pressing a remote key
    : FOR    ${i}    IN RANGE    ${10}
    \    ${is_uhd_channel}    Run keyword and return status    Is UHD channel
    \    Exit For Loop If    ${is_uhd_channel} == ${False}
    \    I press    ${remote_key}
    Should not be True    ${is_uhd_channel}    UHD channel still present after 10 remote key press

Is UHD channel    #USED
    [Documentation]    This keyword checks UHD channel is focused and returns the result
    wait until keyword succeeds    5 times    200 ms    I expect page element 'id:RcuCue' contains 'textKey:DIC_RC_CUE_UHD_INCOMPATIBLE'

Channel Bar Specific Teardown
    [Documentation]    If we've unlocked any channels due to soft-zapping and tuning, we need to undo this.
    I put stb in standby cycle
    Default Suite Teardown

Get STB time from channel bar masthead
    [Documentation]    This keyword opens the channel bar, reads the channel bar masthead time and returns this value
    I open Channel Bar
    ${json_object}    Get Ui Json
    ${masthead_time}    Extract Value For Key    ${json_object}    id:mastheadTime    textValue
    [Return]    ${masthead_time}

Press BACK until the current channel view is present    #USED
    [Documentation]    This keyword presses BACK until the current channel view is present
    ...    The keyword checks for not entitled, locked, unsubscribed and UHD(where the TV/video card has no support for UHD) channels and
    ...    takes no action, but if the channel does not match one of these states, it will check that fullscreen is shown
    ${is_current_channel_view}    set variable    ${False}
    : FOR    ${_}    IN RANGE    ${15}
    \    I Press    BACK
    \    ${is_channel_not_entitled}    run keyword and return status    Channel is not Entitled
    \    ${is_locked_channel}    run keyword and return status    Channel Is Locked
    \    ${is_event_locked}    run keyword and return status    Event Is Locked
    \    ${is_unsubscribed_channel}    run keyword and return status    Unsubscribed RC CUE is shown
    \    ${is_uhd_channel}    run keyword and return status    Is UHD channel
    \    ${is_full_screen_view}    run keyword and return status    Fullscreen is shown
    \    ${is_channel_off_air}    run keyword and return status    Channel Is Off Air
    \    ${is_current_channel_view}    Evaluate    (${is_locked_channel} or ${is_event_locked} or ${is_unsubscribed_channel} or ${is_uhd_channel} or ${is_channel_not_entitled} or ${is_full_screen_view} or ${is_channel_off_air})
    \    Exit For Loop If    ${is_current_channel_view}
    should be true    ${is_current_channel_view}    Current channel view is not shown

Channel is not Entitled    #USED
    [Documentation]    Checks if the Channel is not Entitled by checking the content unavailability
    ...    The channel bar will always be present for a channel that's not entitled and the splashContainer text will be empty
    ${json_object}    Get Ui Json
    ${is_splash_container}    run keyword and return status    Is In Json    ${json_object}    ${EMPTY}    id:splashContainer
    ${splash_container_text}    run keyword if    ${is_splash_container}    I retrieve value for key 'textValue' in element 'id:splashContainer'
    should be empty    ${splash_container_text}    The splash container text value is not empty: ${splash_container_text}
    ${is_content_unavailable}    run keyword and return status    content unavailable
    ${is_channel_bar_present}    run keyword and return status    channel bar is present
    should be true    ${is_content_unavailable} and ${is_channel_bar_present}    The channel is entitled

Verify That Adult Channel Is Tuned    #USED
    [Documentation]    This keyword verifies that adult channel is tuned to.
    [Arguments]    ${after_unlock}
    ${ui_json}  Get Ui Json
    ${splash_container}    Is In Json    ${ui_json}    id:splashContainer    iconKeys:TRIPLE_X
    Should Be True    ${splash_container}    Splash container for adult channel not present
    ${lock_icon}    Is In Json    ${ui_json}    id:channelBarLockIconTag    iconKeys:LOCK
    Should Be True    ${lock_icon}    lock icon not displayed for adult channel
    ${adult_channel_text}    Is In Json    ${ui_json}    textKey:DIC_ADULT_CHANNEL    textValue:Adult channel
    Run Keyword If    ${after_unlock}    Should Not Be True    ${adult_channel_text}    adult channel text displayed for adult channel after unlock
    ...    ELSE    Should Be True    ${adult_channel_text}    adult channel text not displayed for adult channel
    ${event_details_locked}    Is In Json    ${ui_json}    id:NowAndNext.View    viewStateValue:Adult channel ||DIC_ADULT_CHANNEL||
    Run Keyword If    ${after_unlock}    Should Not Be True    ${event_details_locked}    Event details are not displayed after an locked channel was unlocked
    ...    ELSE    Should Be True    ${event_details_locked}    Event details are displayed for an adult channel
    ${unlock_message}    Extract Value For Key    ${ui_json}    id:RcuCue    dictionnaryValue
    ${match}    Run Keyword If    ${after_unlock}    Get Regexp Matches    ${unlock_message}    Press .*Ok.* to unlock this programme
    ...    ELSE    Get Regexp Matches    ${unlock_message}    Press .*Ok.* to unlock this channel
    Should Be Equal As Strings    ${match[0]}    ${unlock_message}    Unlock message not displayed
    Run Keyword If    ${after_unlock}    Verify Current Running Programme In Channel Bar

Verify Unlocked Adult Channel With Events Unlocked    #USED
    [Documentation]    This keyword verifies that adult channel is unlocked.
    ${ui_json}  Get Ui Json
    ${splash_container}    Is In Json    ${ui_json}    id:splashContainer    iconKeys:TRIPLE_X
    Should Not Be True    ${splash_container}    Splash container for adult channel not present
    ${adult_channel_text}    Is In Json    ${ui_json}    textKey:DIC_ADULT_CHANNEL    textValue:Adult channel
    Should Not Be True    ${adult_channel_text}    adult channel text displayed for unlocked channel
    ${unlock_icon}    Is In Json    ${ui_json}    id:channelBarLockIconTag    iconKeys:OPEN_LOCK
    Should Be True    ${unlock_icon}    open lock icon not displayed for age locked channel
    Verify Current Running Programme In Channel Bar

Verify Current Running Programme In Channel Bar    #USED
    [Documentation]    This keyword compares program name in header and event details in channelbar
    ...    Precondition: channel bar is open
    ${ui_json}  Get Ui Json
    ${header}    Extract Value For Key    ${ui_json}  id:watchingNow    textValue
    @{header}    split string    ${header}    :    1
    ${header_event}    Strip String    @{header}[1]
    ${event_details_list}    Extract Value For Key    ${ui_json}    id:NowAndNext.View    viewState
    ${channelbar_event}    Extract Value For Key    ${event_details_list[1]}    ${EMPTY}    viewStateValue
    Should Contain    ${header_event}    ${channelbar_event}    Current event title cannot be verified

I Fetch Past Replay Event Title From Channel Bar    #USED
	[Documentation]    This keyword fetches the tiltle of the previous, selected and next replay event in the channel bar.
	I Press    LEFT
    I wait for 3 seconds
	Set current lineup variables


Channel Zapping - Channel UP    #USED
    [Documentation]    This keyword Performs Channel Zapping Channel UP.
    ${INITAIL_CHANNEL}    Get current channel number
    Log    Initially Tuned Channel ${INITAIL_CHANNEL}
    I press    CHANNELUP
    Sleep  2s
    ${CHANNEL_AFTER_ZAPPING}     Get current channel number
    Sleep  2s
    Log    Channel After Zapping ${CHANNEL_AFTER_ZAPPING}
    ${INITAIL_CHANNEL}    Convert To Integer    ${INITAIL_CHANNEL}
    ${CHANNEL_AFTER_ZAPPING}    Convert To Integer    ${CHANNEL_AFTER_ZAPPING}
    Should Be True    ${INITAIL_CHANNEL} < ${CHANNEL_AFTER_ZAPPING}

Channel Zapping - Channel DOWN    #USED
    [Documentation]    This keyword Performs Channel Zapping Channel DOWN.
    ${INITAIL_CHANNEL}    Get current channel number
    Log    Initially Tuned Channel ${INITAIL_CHANNEL}
    I press    CHANNELDOWN
    Sleep  2s
    ${CHANNEL_AFTER_ZAPPING}     Get current channel number
    Sleep  2s
    ${INITAIL_CHANNEL}    Convert To Integer    ${INITAIL_CHANNEL}
    ${CHANNEL_AFTER_ZAPPING}    Convert To Integer    ${CHANNEL_AFTER_ZAPPING}
    Log    Channel After Zapping ${CHANNEL_AFTER_ZAPPING}
    Should Be True    ${INITAIL_CHANNEL} > ${CHANNEL_AFTER_ZAPPING}

I Verify Age Rating Is Not Shown For The Focussed Event In Channel Bar   #USED
    [Documentation]    This keyword verifies age rating is not shown for the currently focussed event in channel bar
    ...    Precondition: channel bar is open
    ${json_object}    Get Ui Json
    ${ancestor}    I retrieve json ancestor of level '2' in element 'id:topLine\\d' for element 'color:${INTERACTION_COLOUR}' using regular expressions
    @{regexp_match}    Get Regexp Matches    ${ancestor['id']}    ^.*(\\d+)$    1
    ${id}    Set Variable    ${regexp_match[0]}
    ${status}    Run Keyword And Return Status    Wait Until Keyword Succeeds    ${JSON_MAX_RETRIES}    ${JSON_RETRY_INTERVAL}    I expect page element 'id:titleTextIcons${id}' contains 'iconKeys:.*PARENTAL_RATING_\\\\d+.*' using regular expressions
    Should Not Be True    ${status}    Age Rating is shown
#********************************CPE PERFORMANCE********************************
Get current channel name    #USED
    [Documentation]    This keyword gets the current channel number to which the STB is tuned
    ${channel_id}    get main session ref id via vldms    ${STB_IP}    ${CPE_ID}
    ${response}    Get All Channels Via LinearService
    ${channel_name}   extract value for key    ${response}   id:${channel_id}    name
    [Return]    ${channel_name}