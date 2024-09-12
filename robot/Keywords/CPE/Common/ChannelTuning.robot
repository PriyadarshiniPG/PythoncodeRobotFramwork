*** Settings ***
Documentation     Channel tuning related keywords

*** Keywords ***
STB is tuned to last tuned channel
    [Documentation]    Verify that STB is tuned to ${TUNED_CHANNEL_NUMBER}, the last tuned channel
    ${channel_number}    Get current channel number
    should not be empty    ${channel_number}    Error in getting tuned channel
    should be equal as strings    ${TUNED_CHANNEL_NUMBER}    ${channel_number}    Channel is not tuned to expected channel

Tune to channel for setup    #USED
    [Arguments]    ${channel_number}
    [Documentation]    This keywords tunes STB to a particular channel number. Channel number is sent directly to AS without splitting into digits
    ...    and Checking not Error Popup is present (getting error code to print it)
    ...    and prevent Channel Bar Disappear and reading event details
    I Press    ${channel_number}
    I wait for 100 ms
    ${tune_to_channel_status}    run keyword and return status     I expect page element 'id:toast.message' contains 'textKey:DIC_CONFIRM_MESSAGE_TUNE_TO_CHANNEL'
    run keyword if    ${tune_to_channel_status}   I press    OK
    I wait for 5 seconds
    Make sure that channel tuned to    ${channel_number}
    #run keyword if    ${RF_FEED_PRESENT}    Error popup is not shown
    ${status}   Run Keyword If    not ${RF_FEED_PRESENT}    Run Keyword And Return Status   Wait Until Keyword Succeeds    3 times    10 ms    Error screen 'CS2004' is shown
    Run Keyword If   not ${RF_FEED_PRESENT} and ${status}   I Press  BACK
    prevent channel bar from disappearing
    I Ensure Channel Is Unlocked From Channel Bar
    Set current lineup variables

Make sure that channel tuned to    #USED
    [Arguments]    ${channelnumber}
    [Documentation]    This keyword make sure that STB tuned to a particular channel number.
    Wait Until Keyword Succeeds    60s    100ms    Verify that channel tuned to    ${channelnumber}

Verify that channel tuned to    #USED
    [Arguments]    ${channel_number}
    [Documentation]    This keyword verifies that that STB tunes to the given channel number.
    I Press    ${channel_number}
    ${tuned_channel_number}    Get current channel number
    Should Be Equal    ${tuned_channel_number}    ${channel_number}    Channel actually tuned to:${tuned_channel_number}, expected:${channel_number}

Verify STB is tuned to personal channel
    [Arguments]    ${channel_number}
    [Documentation]    This keyword verifies that STB tunes to a channel in the personal channel line-up.
    ${current_profile_name}    get current profile name via as    ${STB_IP}    ${CPE_ID}    xap=${XAP}
    ${personal_line_up}    get favourite channels Via Personalization Service    ${LAB_CONF}    ${CUSTOMER_ID}    ${current_profile_name}    xap=${XAP}
    ${index}    convert to integer    ${channel_number}
    ${personal_channel_id}    set variable    ${personal_line_up[${index}-1]}
    ${tuned_personal_channel}    get channel lcn for channel id    ${personal_channel_id}
    ${channel_tuned}    Get current channel number
    should be equal as strings    ${tuned_personal_channel}    ${channel_tuned}    Channel is not tuned to a channel in personal channel line-up
    set suite variable    ${TUNED_CHANNEL_NUMBER}    ${channel_tuned}

I tune to channel    #USED
    [Arguments]    ${channelnumber}
    [Documentation]    This keywords tunes STB to a particular channel number and sets the test variable with lcn. Hence, this keyword should not be used by suite setups or teardowns
    tune to channel for setup    ${channelnumber}
#    ${channel_tuned}    check if channel is tuned    ${channelnumber}
    set suite variable    ${TUNED_CHANNEL_NUMBER}    ${channelnumber}

I Tune To Random Replay Channel    #USED
    ${channel_number}    Get Random Replay Channel Number
    I tune to channel    ${channel_number}

I tune to channel preceeding netflix channel in lineup
    [Documentation]    This keywords tunes STB to a particular channel number. Channel number is sent directly to AS without splitting into digits
    ${channel_number}    get from referenced channel    ${NETFLIX_CHANNEL}    ${CPE_ID}    -1
    I tune to channel    ${channel_number}

I tune to channel next to netflix channel in lineup
    [Documentation]    This keywords tunes STB to a particular channel number. Channel number is sent directly to AS without splitting into digits
    ${channel_number}    get from referenced channel    ${NETFLIX_CHANNEL}    ${CPE_ID}    +1
    I tune to channel    ${channel_number}

tune to channel ${channelnumber}
    [Documentation]    This keywords tunes STB to a particular channel number . Internal keyword .Should not be used from Tests
    I tune to channel    ${channelnumber}

I tune to personal channel ${channel_number}
    [Documentation]    This keywords tunes STB to a personal channel number
    I open Channel Bar
    I press    ${channel_number}
    Verify STB is tuned to personal channel    ${channel_number}

I tune to stability test channel
    [Arguments]    ${channel_number}
    [Documentation]    This keywords tunes STB to a particular channel number without using JSON
    I press    ${channel_number}
    Make sure that channel tuned to    ${channel_number}

Channel ${channel_number} is tuned
    [Documentation]    Asserts given channel is tuned
    ${actual_channel}    Read channel number from channel bar data
    Should Be Equal    ${channel_number}    ${actual_channel}

on list tune to channel ${channel_number}
    [Documentation]    This keywords tunes STB to a particular channel number on list
    I Press    ${channel_number}
    Wait Until Keyword Succeeds    10 times    300 ms    I expect page contains 'textValue:${channel_number}'

Tune To A Random Channel From Channel Lineup    #USED
    [Documentation]    Tunes to one random channel from channel line up
    Numeric Channel Zapping

tune to free channel and check content    #NOT_USED
    [Documentation]    Tunes to free channel and tries to check content
    I tune to channel    ${FREE_CHANNEL_2}
    content available

tune to scrambled channel and check content
    [Documentation]    Tunes to list of known working channels and tries to check content
    @{channels}    Create List    ${SD_SCRAMBLED_CHANNEL}    ${HD_ALL_SERVICE}    ${HD_ALL_CHANNEL}    ${HIGH_BITRATE_HD_SERVICE}
    : FOR    ${channel_number}    IN    @{channels}
    \    I tune to stability test channel    ${channel_number}
    \    ${status}    run keyword and return status    content available
    \    return from keyword if    ${status}
    fail    content available check failed on selected channels

I Tune To Next Channel    #USED
    [Documentation]    Tune to next channel
    ${TUNED_CHANNEL_NUMBER}    Get current channel number
    set suite variable    ${TUNED_CHANNEL_NUMBER}    ${TUNED_CHANNEL_NUMBER}
    I press    CHANNELUP
    Next Channel is tuned

I Tune To Previous Channel    #USED
    [Documentation]    Tune to previous channel
    ${TUNED_CHANNEL_NUMBER}    Get current channel number
    set suite variable    ${TUNED_CHANNEL_NUMBER}    ${TUNED_CHANNEL_NUMBER}
    I press    CHANNELDOWN
    Previous Channel Is Tuned

'${channel_number}' channel is tuned to
    [Documentation]    Verifies whether the channel is tuned to the given channel
    wait until keyword succeeds    ${CHANNEL_QUERY_TIMEOUT}    2s    check if channel is tuned    ${channel_number}

check if channel is tuned    #USED
    [Arguments]    ${channel_number}
    [Documentation]    Checks if a channel is tuned properly
    ${channel_tuned}    Get current channel number
    should be equal as strings    ${channel_tuned}    ${channel_number}    Channel is not tuned to correct channel
    [Return]    ${channel_tuned}

Read channel number from channel bar data    #USED
    [Documentation]    Reads channel number from channel bar data
    wait until keyword succeeds    ${JSON_MAX_RETRIES}    ${JSON_RETRY_INTERVAL}    I expect page element 'id:nnchannelNumber' contains 'textValue:^\\\\d+$' using regular expressions
    ${actual_channel}    I retrieve value for key 'textValue' in element 'id:nnchannelNumber'
    Should Be True    '${actual_channel}' != '${None}'
    [Return]    ${actual_channel}

I play LIVE TV
    [Documentation]    This keyword will switch to LIVE TV
    : FOR    ${i}    IN RANGE    15
    \    ${json_object}    Get Ui Json
    \    ${is_full_screen_present}    Is In Json    ${json_object}    ${EMPTY}    id:FullScreen.View
    \    ${is_channel_bar}   Is In Json    ${json_object}    ${EMPTY}    id:NowAndNext.View
    \    Exit For Loop If    ${is_full_screen_present} or ${is_channel_bar}
    \    I Press    BACK
    Run Keyword If  ${is_channel_bar}   I Ensure Event Is Unlocked From Channel Bar
    Dismiss Channel Failed Error Pop Up
    Error popup is not shown
    Wait Until Keyword Succeeds  5x  1s   I expect page contains 'id:FullScreen.View'

Get current channel
    [Documentation]    Get the current channel via application service
    ${channelId} =    get current channel via as    ${STB_IP}    ${CPE_ID}    xap=${XAP}
    [Return]    ${channelId}

Channel '${channel_number}' is available
    [Documentation]    Checks if the channel is available
    ${search_result}    Search channel in list    ${channel_number}
    should be true    ${search_result}    Channel is not available

Channel '${channel_number}' is not available
    [Documentation]    Checks if the channel is not available
    ${search_result}    Search channel in list    ${channel_number}
    should not be true    ${search_result}    Channel is available

Search channel in list
    [Arguments]    ${channel_number}
    [Documentation]    Searches for a channel in the list of available channels
    ${channels_list}    get channel lineup via as    ${STB_IP}    ${CPE_ID}    xap=${XAP}
    ${is_channel_found}    Run Keyword And Return Status    dictionary should contain key    ${channels_list}    ${channel_number}
    [Return]    ${is_channel_found}

I press one digit number
    [Documentation]    This keyword tunes to a single digit channel number by pressing a one digit number on RCU
    I Press    ${ONE_DIGIT_CHANNEL}

I press two digit number
    [Documentation]    This keyword tunes to a double digit channel number by pressing a two digits number on RCU
    I Press    ${TWO_DIGIT_CHANNEL}

Get channel ID using channel number    #USED
    [Arguments]    ${channel_number}
    [Documentation]    Get the channel ID using channel number
    ${channel_id}    get channel id via as    ${STB_IP}    ${CPE_ID}    ${channel_number}    xap=${XAP}
    [Return]    ${channel_id}

i get current event name on
    [Arguments]    ${channel_number}
    [Documentation]    Gets currently running event name for given channel
    I tune to channel    ${channel_number}
    ${event_name}    I retrieve value for key 'viewStateValue' in element 'viewStateKey:selectedProgramme'
    [Return]    ${event_name}

The channel named '${channel_name}' is tuned
    [Documentation]    Gets the current channel number and looks up the channel name for it, then checks that
    ...    the channel name given in the ${channel_name} parameter is contained in the retrieved name.
    ${channel_number}    Read channel number from channel bar data
    ${current_channel_name}    lookup channelname for    ${channel_number}
    should contain    ${current_channel_name}    ${channel_name}    msg='${channel_name}' is not tuned    ignore_case=True

Previously watched channel is tuned
    [Documentation]    Gets the current channel number and compares it with the channel saved in the
    ...    ${PREVIOUS_CHANNEL_NUMBER} variable, failing if they differ.
    ...    Precondition: PREVIOUS_CHANNEL_NUMBER should be available in the current scope.
    variable should exist    ${PREVIOUS_CHANNEL_NUMBER}    Previously tuned channel number was not saved. PREVIOUS_CHANNEL_NUMBER does not exist.
    ${current_channel_number}    Read channel number from channel bar data
    should be equal as numbers    ${current_channel_number}    ${PREVIOUS_CHANNEL_NUMBER}

Numeric Channel Zapping    #USED
    [Documentation]    Tune to a random filtered (NO: app, 4k, adult, radio) channel number and check is tuned
    ${channel_number}    I Fetch One Random Linear Channel Number From List Filtered For Zapping
    ${status}    Run Keyword And Return Status    I tune to channel    ${channel_number}
    Should Be True    ${status}    Unable to tune to the channel: ${channel_number}

I Tune To Random HD Linear Channel And Play For '${play_out_time}' Seconds     #USED
     [Documentation]    This keyword tunes to a random HD linear channel and plays for 'play_out_time' seconds
     I Fetch HD Linear Channel Number List Filtered For Zapping
     ${channel_number}       I Fetch One Random Linear Channel Number From List Filtered For Zapping
     I tune to channel    ${channel_number}
     Basic Check For Linear TV    ${play_out_time}

Basic Check For Linear TV    #USED
     [Documentation]    This keyword does a basic check after tuning to a channel
     [Arguments]    ${play_out_time}
     I Ensure Channel Is Unlocked From Channel Bar
     I open Channel Bar
     Header Is Shown For Linear Player
     ${status}    Run Keyword And Return Status    Unsubscribed RC CUE is shown
     Should Not Be True    ${status}
     I wait for ${play_out_time} seconds

I Tune To Random Linear Channel And Play For '${play_out_time}' Seconds    #USED
    [Documentation]    This keyword tunes to a random HD linear channel and plays for 'play_out_time' seconds
    I Fetch Linear Channel Number List Filtered For Zapping
    :For    ${index}    IN RANGE    0    10
    \    ${channel_number}       I Fetch One Random Linear Channel Number From List Filtered For Zapping
    \    I tune to channel    ${channel_number}
    \    ${ui_json}    Get Ui Json
    \    ${is_adult_program}    Is In Json    ${ui_json}    id:titleText\\d+    textKey:DIC_ADULT_PROGRAMME    ${EMPTY}    ${True}
    \    Exit For Loop If   not ${is_adult_program}
    I Press    BACK
    Channel Bar is not shown
    Error popup is not shown
    Basic Check For Linear TV    ${play_out_time}

Get '${is_age_rated}' Current '${is_replay}' Event Metadata And Channel Number    #USED
    [Documentation]    This keyword returns the age rated current replay event channel number and metadata.
    ${linear_channels}    Run Keyword If    not ${is_replay}    I Fetch Linear Channel List Filtered
    ${replay_channels}    Run Keyword If    ${is_replay}    I Fetch All Replay Channels From Linear Service
    ${epg_index}    Get Index Of Event Metadata Segments
    ${epg_data}    Set Variable    ${epg_index.json()}
    ${channel_number}    Set Variable    ${None}
    ${current_event}    Set Variable    ${None}
    @{entries}    Create List    @{epg_data['entries']}
    ${length}    Get Length    ${entries}
    :FOR   ${index}    IN RANGE    ${length}
    \    ${entry}    Get Random Element From Array    ${entries}
    \    ${channel_id}    Set Variable    ${entry['channelIds'][0]}
    \    ${is_channel_present}    Run Keyword and Return Status    Should Contain    ${linear_channels}    ${channel_id}
    \    ${is_replay_channel}    Run Keyword and Return Status    Should Contain    ${replay_channels}    ${channel_id}
    \    Run Keyword If    not ${is_replay}    Continue For Loop If    not ${is_channel_present}
    \    Run Keyword If    ${is_replay}    Continue For Loop If    not ${is_replay_channel}
    \    ${is_trickplay_enabled}    Check Linear Channel Is Trickplay Enabled    ${channel_id}
    \    Continue For Loop If    not ${is_trickplay_enabled}
    \    ${channel_number}    Get Channel Number By Id    ${CITY_ID}    ${channel_id}    ${OSD_LANGUAGE}    ${CPE_PRODUCT_CLASS}
    \    ${hash}    Set Variable    ${entry['segments'][7]}
    \    ${epg_segment}    Get Event Metadata For A Particular Segment    ${hash}
    \    ${event_list}    Set Variable    ${epg_segment.json()['entries'][0]['events']}
    \    ${current_event}    Get '${is_age_rated}' Current '${is_replay}' Event From '${event_list}' Based On Filters
    \    Exit For Loop If    ${current_event}
    [Return]    ${channel_number}    ${current_event}

Get '${is_age_rated}' Current '${is_replay}' Event From '${events}' Based On Filters    #USED
    [Documentation]    This keyword fetches the current age rated and replay event based on the filters passed and
    ...    returns event details.
    ${current_epoch_time}    Get Current Epoch Time
    ${get_age}    Get application service setting    profile.ageLock
    ${current_event}    Set Variable    ${None}
    :FOR    ${event}    IN    @{events}
    \    ${start_time}    Get From Dictionary    ${event}    startTime
    \    ${end_time}    Get From Dictionary    ${event}    endTime
    \    ${is_current_event}    Set Variable If    ${start_time} <= ${current_epoch_time} and ${current_epoch_time} <= ${end_time}     True    False
    \    Continue For Loop If    not ${is_current_event}
    \    ${time_remaining}    Evaluate    ${end_time} - ${current_epoch_time}
    \    Continue For Loop If    ${time_remaining}<=600
    \    ${minimumAge}    Evaluate    ${event}.get("minimumAge", '0')
    \    Run Keyword If    '${is_age_rated}'=='True'    Continue For Loop If    '${minimumAge}'=='0' and '${minimumAge}' < '${get_age}'
    \    ${hasReplayTV}    Evaluate    ${event}.get("hasReplayTV", 'REPLAY')
    \    ${hasStartOver}    Evaluate    ${event}.get("hasStartOver", 'REPLAY')
    \    Run Keyword If    '${is_replay}'=='True'    Continue For Loop If    '${hasReplayTV}' != 'REPLAY' or '${hasStartOver}' != 'REPLAY'
    \    ${current_event}    Set Variable    ${event}
    \    Exit For Loop If    ${current_event}
    [Return]    ${current_event}

I Tune To Current '${is_age_rated}' And '${is_replay}' Event   #USED
    [Documentation]      This keyword tunes to current age rated event and opens channel bar, returns channel number
    ...    and event details.
    ${channel_number}    ${event_details}     Get '${is_age_rated}' Current '${is_replay}' Event Metadata And Channel Number
    Log    Event Details: ${event_details}
    Should Not Be Equal   ${channel_number}    ${None}    Channel with Age Rating ${is_age_rated} and Replay Event ${is_replay} is not available
    I tune to channel    ${channel_number}
    I Ensure Channel Is Unlocked From Channel Bar
    Dismiss Channel Failed Error Pop Up
    Error popup is not shown
    [Return]      ${channel_number}    ${event_details}

I Tune To Replay Channel Based On Current Event Remaining Time    #USED
    [Documentation]    This keyword filter and tune to a replay channel with current event(non-adult) having remaining time greater than the given time.
    [Arguments]    ${remaining_time}=10
    ${replay_channels}    I Fetch All Replay Channels From Linear Service
    ${length}    Get Length    ${replay_channels}
    :For    ${index}    IN RANGE    0    ${length}
    \    ${channel_number}       Filter Channels Based On Remaining Time Of The Program   ${replay_channels}    ${remaining_time}
    \    I tune to channel    ${channel_number}
    \    ${ui_json}    Get Ui Json
    \    ${is_adult_program}    Is In Json    ${ui_json}    id:titleText\\d+    textKey:DIC_ADULT_PROGRAMME    ${EMPTY}    ${True}
    \    Exit For Loop If   not ${is_adult_program}

