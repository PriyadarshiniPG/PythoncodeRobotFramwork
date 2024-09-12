*** Settings ***
Documentation     TV Guide Keywords
Resource          ../PA-06_TV_Guide/TVGuide_Implementation.robot

*** Keywords ***
Event Metadata Is shown In Guide    #USED
    [Documentation]    Check if the programme details are shown in Guide listings
    ${page_json}    Get Ui Json
    ${json_string}    Read Json As String    ${page_json}
    @{collection}    get regexp matches    ${json_string}    .*DIC_DETAIL_EVENT_NO_INFO.*
    # Noticed 'block_0_event_1_0' always shows textKey:DIC_DETAIL_EVENT_NO_INFO, so excluding this from comparison
    ${count}    Get Length    ${collection}
    Should be true    ${count}<=1    Events with missing metadata detected in Guide listings

Metadata is shown for tuned channel in Guide    #NOT_USED
    [Documentation]    Check if current tuned programme details are shown in Guide
    ${channel_number}    Get current channel number
    Guide Info Panel Has Correct Metadata For Channel    ${channel_number}

I open Guide through the remote button
    [Documentation]    Opens Guide through the remote button after bringing up the channel bar
    I open Channel Bar
    I Press    GUIDE
    Guide is shown
    ${TUNED_CHANNEL_NUMBER}    Get current channel
    set test variable    ${TUNED_CHANNEL_NUMBER}
    ${channel_id}    I retrieve value for key 'id' in element 'textValue:${TUNED_CHANNEL_NUMBER}'
    set test variable    ${TUNED_CHANNEL_ID_GUIDE}    ${channel_id}
    ${current_channel_number}    Get Focused Guide Programme Cell Channel Number
    Set Suite Variable    ${current_channel_number}

I focus Day Filter
    [Documentation]    Focuses the Day Filter by pressing the main menu button
    I Press    MENU
    Day filter is focused

Guide is not shown in offline mode
    [Documentation]    Checks that the guide is not shown on the page in offline mode
    wait until keyword succeeds    ${JSON_MAX_RETRIES}    ${JSON_RETRY_INTERVAL}    I expect page element 'id:Guide.View' contains 'viewStateKey:Error'

Current event is focused
    [Documentation]    Checks if Current event is focused
    wait until keyword succeeds    ${JSON_MAX_RETRIES}    ${JSON_RETRY_INTERVAL}    I expect page element 'id:watchingNow' contains 'textKey:DIC_HEADER_SOURCE_LIVE'
    ${highlighted_event}    I retrieve Info panel title element
    ${json_object}    Get Ui Json
    ${header}    Extract Value For Key    ${json_object}    id:watchingNow    textValue
    ${header_string}    Extract Value For Key    ${json_object}    id:watchingNow    dictionnaryValue
    ${remove_string}    Catenate    SEPARATOR=    ${header_string}    :
    ${header}    Remove String    ${header}    ${remove_string}
    ${header}    Strip String    ${header}
    Should Contain    ${highlighted_event}    ${header}    Highlighted event does not contain the expected header

Interactive modal with options 'Watch live TV' and 'Play from start' is shown
    [Documentation]    Checks if Interactive modal with options 'Watch live TV' and 'Play from start' is shown
    Interactive modal is shown
    I expect page contains 'textKey:DIC_ACTIONS_SWITCH_TO_LIVE'
    I expect page contains 'textKey:DIC_ACTIONS_PLAY_FROM_START'

Focus moves one item down
    [Documentation]    Compares the highlighted channel number with the current tuned channel number
    ${currently_tuned}    Get current channel number
    ${channel_number_focused}    Get Focused Guide Programme Cell Channel Number
    Should be true    ${channel_number_focused} > ${currently_tuned}    Failed to focus on the event below

Focus moves one item up
    [Documentation]    Compares the highlighted channel number with the current tuned channel number
    ${currently_tuned}    Get current channel number
    ${channel_number_focused}    Get Focused Guide Programme Cell Channel Number
    Should be true    ${channel_number_focused} < ${currently_tuned}    Failed to focus on the event above

I focus Next event    #USED
    [Documentation]    Keyword focuses next event in Guide
    [Arguments]      ${info_check}=True
    &{highlighted_event}    Get Focused Guide Programme Cell Details
    @{regexp_match}    Get Regexp Matches    &{highlighted_event}[event_id]    (block_\\d+_event_\\d+_)(\\d+)    1    2
    @{match_list}    Set Variable    @{regexp_match}[0]
    ${id_prefix}    Set Variable    @{match_list}[0]
    ${id_suffix}    Set Variable    @{match_list}[1]
    ${id_suffix}    Convert To Integer    ${id_suffix}
    ${future_event_id}    Catenate    SEPARATOR=    ${id_prefix}    ${id_suffix + 1}
    set test variable    ${FUTURE_EVENT_ID}    ${future_event_id}
    : FOR    ${i}    IN RANGE    ${8}
    \    I press    RIGHT
    \    ${is_future_event_id_present}    Run Keyword And Return Status    I expect focused elements contains 'id:${future_event_id}'
    \    Exit For Loop If    ${is_future_event_id_present} == ${True}
    return from keyword if    ${info_check} == ${False}
    wait until keyword succeeds    ${JSON_MAX_RETRIES}    2 sec    I expect focused elements contains 'id:${future_event_id}'
    I Check If EPG Event Info Is Available

Event duration is shown in Info Panel
    [Documentation]    Check event duration is present in info panel
    ...    Precondition: Guide is open
    ${event_time}    Read current event time from Info Panel
    should not be empty    ${event_time}    event_time is empty
    [Return]    ${event_time}

Shown event duration in Panel Info matches metadata
    [Documentation]    Checks event duration shown in panel info matches metadata.
    ...    Precondition: Panel Info in Guide is open
    Compare event duration in 'Info Panel' and traxis metadata

Guide Grid is shown    #USED
    [Documentation]    Checks if Guide Grid is shown
    wait until keyword succeeds    ${JSON_MAX_RETRIES}    ${JSON_RETRY_INTERVAL}    I expect page contains 'id:gridContainer'

Info Panel is shown
    [Documentation]    Checks if Info Panel is shown
    wait until keyword succeeds    ${JSON_MAX_RETRIES}    ${JSON_RETRY_INTERVAL}    I expect page contains 'id:gridInfoPanel'

The same page is shown in the TV Guide
    [Documentation]    Checks that TV guide page stays on the same page during channel numbers navigation in EPG Area
    ...    NOTE: This should not be used during Suite Setup or Teardown.
    ...    Pre-reqs: Test vars LAST_FOCUSED_GUIDE_BLOCK should be set before
    ...    this keyword is called
    Variable should exist    ${LAST_FOCUSED_GUIDE_BLOCK}    Test var LAST_FOCUSED_GUIDE_BLOCK has not previously been set
    ${guide_block_id}    Get guide block ID
    ${is_same_page}    Evaluate    '${guide_block_id}'=='${LAST_FOCUSED_GUIDE_BLOCK}'
    should be true    ${is_same_page}    The TV Guide is showing a different page than the previous one

Channel ${channel_number} is focused in the guide
    [Documentation]    Checks if channel with given number is focused in the guide
    &{highlighted_event}    Get Focused Guide Programme Cell Details
    @{regexp_match}    Get Regexp Matches    &{highlighted_event}[event_id]    (block_\\d+_event_\\d+_)(\\d+)    1
    ${replaced}    Replace String Using Regexp    @{regexp_match}[0]    event    channel
    ${channel_text_id}    Set Variable    ${replaced}text
    ${json_object}    Get Ui Json
    ${highlighted_channel_number_value}    Extract Value For Key    ${json_object}    id:${channel_text_id}    textValue
    ${highlighted_channel_number_style}    Extract Value For Key    ${json_object}    id:${channel_text_id}    textStyle
    Should Be Equal    ${highlighted_channel_number_value}    ${channel_number}    Highlighted channel number and channel_number are not equal

I tune to ${channel_number} in the tv guide    #USED
    [Documentation]    This keyword tunes to a channel in the guide
    I press    ${channel_number}
    Wait Until Keyword Succeeds And Verify Status    10 times    200 ms    Channel is not focused in Guide    Channel Is Focused In Guide    ${channel_number}

I Tune The Focused ${channel_number} In The Tv Guide   #USED
    [Documentation]  The keyword tunes to a channel which is focused in tv guide
    ...    Precondition : The specified channel should be focused
    I Ensure Channel Is Unlocked From TV Guide
    I Press   OK
    ${is_cw_found}   Run Keyword And Return Status    'Continue Watching' popup is shown
    Run Keyword If  '${is_cw_found}'=='True'   I select 'Watch live TV'
    ${pin_entry_present}    Run Keyword And Return Status    Pin Entry popup is shown
    Run Keyword If    ${pin_entry_present}    I Enter A Valid Pin
    Make sure that channel tuned to    ${channel_number}

I focus past event in the tv guide    #USED
    [Documentation]    This keyword focuses a past event in the TV guide
    I focus current event in the tv guide
    I press LEFT 3 times
    I wait for ${MOVE_ANIMATION_DELAY} ms
    Previous event is focused on TV Guide

I focus future event in the tv guide
    [Documentation]    This keyword focuses a future event in the TV guide
    I focus current event in the tv guide
    I focus Next event

Next event is focused on TV Guide
    [Documentation]    This keyword focuses on the NEXT event on the TV guide grid
    ${current_hours}    Get current hours in the tv guide
    ${focused_hours}    Get focused event hours in the tv guide
    @{regexp_match_current}    Get Regexp Matches    ${current_hours}    (\\d{2}):(\\d{2})    1    2
    @{regexp_match_focused}    Get Regexp Matches    ${focused_hours}    (\\d{2}):(\\d{2}) ?- ?\\d{2}:\\d{2}    1    2
    ${current_hour}    Convert To Integer    @{regexp_match_current[0]}[0]
    ${focus_hour}    Convert To Integer    @{regexp_match_focused[0]}[0]
    ${hour_replace_value}    set variable if    ${current_hour} > 12 and ${focus_hour} == 00    24    00
    ${current_hours}    Set Variable If    ${current_hour} == 00    ${hour_replace_value}@{regexp_match_current[0]}[1]    @{regexp_match_current[0]}[0]@{regexp_match_current[0]}[1]
    ${current_hours}    Convert To Integer    ${current_hours}
    ${focused_hours}    Set Variable If    ${focus_hour} == 00    ${hour_replace_value}@{regexp_match_focused[0]}[1]    @{regexp_match_focused[0]}[0]@{regexp_match_focused[0]}[1]
    ${focused_hours}    Convert To Integer    ${focused_hours}
    Run Keyword If    ${focused_hours} < ${current_hours}    Fail    Failed to focus current event in the tv guide

Previous event is focused on TV Guide
    [Documentation]    This keyword focuses on the Previous event on the TV guide grid
    ${current_hours}    Get current hours in the tv guide
    ${focused_hours}    Get focused event hours in the tv guide
    @{regexp_match_current}    Get Regexp Matches    ${current_hours}    (\\d{2}):(\\d{2})    1    2
    @{regexp_match_focused}    Get Regexp Matches    ${focused_hours}    \\d{2}:\\d{2} ?- ?(\\d{2}):(\\d{2})    1    2
    ${current_hour}    Convert To Integer    @{regexp_match_current[0]}[0]
    ${focus_hour}    Convert To Integer    @{regexp_match_focused[0]}[0]
    ${hour_replace_value}    set variable if    ${focus_hour} > 12 and ${current_hour} == 00    24    00
    ${current_hours}    Set Variable If    ${current_hour} == 00    ${hour_replace_value}@{regexp_match_current[0]}[1]    @{regexp_match_current[0]}[0]@{regexp_match_current[0]}[1]
    ${current_hours}    Convert To Integer    ${current_hours}
    ${focused_hours}    Set Variable If    ${focus_hour} == 00    ${hour_replace_value}@{regexp_match_focused[0]}[1]    @{regexp_match_focused[0]}[0]@{regexp_match_focused[0]}[1]
    ${focused_hours}    Convert To Integer    ${focused_hours}
    Run Keyword If    ${focused_hours} > ${current_hours}    Fail    Failed to focus current event in the tv guide

I focus current event in the tv guide    #USED
    [Documentation]    This keyword focuses current event in the TV guide
    : FOR    ${i}    IN RANGE    20
    \    ${is_current_event}    Run Keyword And Return Status    Now Line Is Shown
    \    Exit For Loop If    ${is_current_event} == ${True}
    \    I Press    RIGHT
    \    I Wait For 200 ms
    Run Keyword If    ${is_current_event} != ${True}    Fail    Failed to focus current event in the tv guide

Now Line Is Shown    #USED
    [Documentation]    This keyword verifies that on the TV Guide EPG page, the NOW line text is Shown
    wait until keyword succeeds    ${JSON_MAX_RETRIES}    ${JSON_RETRY_INTERVAL}    I expect page element 'id:infoPanel_now' contains 'textKey:DIC_GENERIC_AIRING_TIME_NOW'

Day Picker is shown
    [Documentation]    This keyword verifies that on the TV Guide EPG page, the DAY PICKER is Shown
    I expect page element 'id:gridNavigation_filterButton_\\d+' contains 'textKey:DIC_GENERIC_AIRING_DATE_(TODAY|YESTERDAY|TOMORROW|FULL_DATE)' using regular expressions

Day Picker can be modified
    [Documentation]    This keyword verifies that on the TV Guide EPG page, the DAY PICKER can be
    ...    changed to a different day
    I open Day Filter from Guide
    Move Focus to Option in Value Picker    textKey:DIC_GENERIC_AIRING_DATE_TOMORROW    DOWN    3
    I press    OK
    wait until keyword succeeds    ${JSON_MAX_RETRIES}    ${JSON_RETRY_INTERVAL}    I expect page element 'id:gridNavigation_filterButton_\\\\d+' contains 'textKey:DIC_GENERIC_AIRING_DATE_TOMORROW' using regular expressions

MiniTV is shown
    [Documentation]    This keyword verifies that on the TV Guide EPG page, MiniTV(PIG) is displayed
    pig is available

Current channel event is displayed in PiG
    [Documentation]    This keyword verifies that MiniTV(PIG) is playing for a specific channel
    Header Is Shown For Linear Player
    pig is available
    ${json_object}    Get Ui Json
    ${is_source_live}    Is In Json    ${json_object}    ${EMPTY}    textKey:DIC_HEADER_SOURCE_LIVE    ${EMPTY}
    should be true    ${is_source_live}    PiG is not playing current live channel event

Next page is shown in the TV guide
    [Documentation]    Checks that TV guide page changes for CH- x1 for channel numbers navigation in EPG Area
    ${currently_tuned}    ${channel_number_focused}    Get currently tuned and focused channel numbers
    Should Be True    ${channel_number_focused} >= ${currently_tuned}    Failed to focus on NEXT page in the tv guide

Previous page is shown in TV Guide
    [Documentation]    Checks that TV guide page changes for CH+ x1 for channel numbers navigation in EPG Area
    ${currently_tuned}    ${channel_number_focused}    Get currently tuned and focused channel numbers
    Should Be True    ${channel_number_focused} <= ${currently_tuned}    Failed to focus on Previous page in the tv guide

Event above is focused on TV Guide
    [Documentation]    This keyword verifies that the event ABOVE comes into focus on the TV GUIDE
    ${currently_tuned}    ${channel_number_focused}    Get currently tuned and focused channel numbers
    Should Be True    ${channel_number_focused} < ${currently_tuned}    Failed to focus on the above event

Event below is focused on TV Guide
    [Documentation]    This keyword verifies that the event below comes into focus on the TV GUIDE
    ${currently_tuned}    ${channel_number_focused}    Get currently tuned and focused channel numbers
    Should be true    ${channel_number_focused} > ${currently_tuned}    Failed to focus on the event below

PiG is playing Linear TV
    [Documentation]    This keyword uses Obelix 4.x region comaparison feature to check the PiG Area when EPG is invoked
    ...    that live AV is playing
    Header Is Shown For Linear Player
    PiG is available
    log    Not implemented yet. Intentionally kept empty to maintain the basic structure of Setup as it can be implemented in future    WARN

Aspect Ratio is preserved
    [Documentation]    This keyword uses Obelix 4.x region comaparison feature to check the PiG Area when EPG is invoked that live AV is playing
    log    Not implemented yet. Intentionally kept empty to maintain the basic structure of Setup as it can be implemented in future

I tune to TEXT test channel
    [Documentation]    This keyword SPECIFICALLY tunes to a TELETEXT channel
    I tune to channel    ${TELETEXT_CHANNEL}

I launch Teletext through contextual key menu
    [Documentation]    This launches teletext through contextual key menu
    I Press    CONTEXT
    wait until keyword succeeds    ${JSON_MAX_RETRIES}    ${JSON_RETRY_INTERVAL}    Layer is not empty    CURRENT_POPUP_LAYER    ${False}
    I expect page contains 'textKey:DIC_ACTIONS_TELETEXT'
    Move Focus to Option in Value Picker    textKey:DIC_ACTIONS_TELETEXT    DOWN
    I expect page contains 'textKey:DIC_ACTIONS_TELETEXT'
    I Press    OK

Teletext is displayed in Opaque mode
    [Documentation]    This verifies that teletext is displayed on the screen in opaque mode
    I verify Teletext is displayed

I tune to channel with Aspect Ratio 4:3
    [Documentation]    Tune to a channel that has Aspect Ration 4:3
    I tune to channel    ${ASPECT_RATIO_4_BY_3_CHANNEL}

Metadata in Guide highlighted programme cell is correct for an unlocked channel
    [Documentation]    Verifies that what's being displayed in the highighted program cell
    ...    matches traxis metadata for an unlocked channel
    Metadata in Guide highlighted programme cell is correct for channel    ${UNLOCKED_CHANNEL}

Metadata in Guide highlighted channel cell is correct for an unlocked channel
    [Documentation]    Verifies that what's being displayed in the highlighted channel cell
    ...    matches traxis metadata for an unlocked channel
    Metadata In Guide Highlighted Channel Cell Is Correct For Channel    ${UNLOCKED_CHANNEL}

Guide Info panel has correct metadata for an unlocked channel
    [Documentation]    Verifies that what's being displayed in the info panel matches traxis metadata for an unlocked channel
    Guide Info Panel Has Correct Metadata For Channel    ${UNLOCKED_CHANNEL}

Only one channel number is shown in the grid for SD HD Substitution
    [Documentation]    verifies that specified channel is focused and only one channel is shown in grid
    Channel ${SD_HD_SERVICE} is focused in the guide
    ${channels_list}    get channel lineup via as    ${STB_IP}    ${CPE_ID}    xap=${XAP}
    ${channel_numbers_list}    get dictionary keys    ${channels_list}
    @{list}    Create List
    : FOR    ${channel}    IN    @{channel_numbers_list}
    \    run keyword if    ${channel} == ${SD_HD_SERVICE}    append to list    ${list}    ${channel}
    ${count}    Get Length    ${list}
    Should Be Equal As Integers    1    ${count}    Same LCN repeated for multiple times

I select 'Set reminder' from contextual pop up modal
    [Documentation]    Keyword setting an event reminder from contextual pop up modal
    'SET REMINDER' action is shown
    Move Focus to Option in Value Picker    textKey:DIC_ACTIONS_SET_REMINDER    DOWN    5
    I Press    OK

Reminder appears for highlighted event in TV Guide
    [Documentation]    Verifies that reminder is set and reminder icon appears in the guide view
    ...    on the highlighted event
    ...    Pre-reqs: Test var FUTURE_EVENT_ID should be set before this keyword is called
    Variable should exist    ${FUTURE_EVENT_ID}    Test var FUTURE_EVENT_ID has not previously been set
    Toast message is shown containing 'Reminder is set'
    &{highlighted_event}    Get Focused Guide Programme Cell Details
    Should Match Regexp    &{highlighted_event}[event_text]    ^.*>P .*$    Reminder icon is not focused in the guide

Adult event is locked in the Guide
    [Documentation]    Keyword verifies that focused Adult event is locked in the Guide
    &{highlighted_event}    Get Focused Guide Programme Cell Details
    Should Contain    &{highlighted_event}[event_text]    J    Highlighted Adult event event text does not contain the locked icon

PIG is playing the recorded item
    [Documentation]    This keyword verifies that PIG is playing for a recorded item
    Guide is shown
    I wait for 3 second
    pig is available
    ${json_object}    Get Ui Json
    ${is_source_recording}    Is In Json    ${json_object}    ${EMPTY}    textKey:DIC_HEADER_SOURCE_RECORDINGS    ${EMPTY}
    should be true    ${is_source_recording}    PiG is not playing the recorded event
    Screenshot has the given background color    GREY    ${SUBTITLE_PIG_PLAYBACK_GREY_REGION}

Metadata Is Hidden For Operator Locked Event In 'TV GUIDE' View    #USED
    [Documentation]    Keyword verifies that metadata for Operator Locked event is not shown
    ...    Precondition: You should be on TVGuide view
    I do not expect page contains 'id:gridPrimaryMetadata'

Locked Image Is Shown In PIG    #USED
    [Documentation]    Keyword verifies that a locked image is shown in PIG for Operator Locked events
    ${json_object}    Get Ui Json
    ${miniTV_is_present}    Is In Json    ${json_object}    ${EMPTY}    id:(GuideMiniTV|gridMiniTVPanelWrap)    ${EMPTY}    ${True}
    ${pig_content_is_locked}    Is In Json    ${json_object}    id:^(grid|Guide)MiniTVPanel    id:^(grid|Guide)MiniTVLockIcon    ${EMPTY}    ${True}
    should be true    ${miniTV_is_present}    PiG is not available
    should be true    ${pig_content_is_locked}    PIG is not showing locked image

Age rating image is shown in PIG    #USED
    [Documentation]    Keyword verifies that an age rating image is shown in PIG
    ${json_object}    Get Ui Json
    ${miniTV_is_present}    Is In Json    ${json_object}    ${EMPTY}    id:(GuideMiniTV|gridMiniTVPanelWrap)    ${EMPTY}    ${True}
    ${age_rating_content_is_locked}    Is In Json    ${json_object}    id:^(grid|Guide)MiniTVPanel    iconKeys:PARENTAL_RATING_\\d+    ${EMPTY}    ${True}
    should be true    ${miniTV_is_present}    PiG is not available
    should be true    ${age_rating_content_is_locked}    PIG is not showing age rating icon

Guide channel cells are shown
    [Documentation]    This keyword checks that there are guide channel cells present in the guide
    ...    Pre-reqs: The guide is displayed
    wait until keyword succeeds    ${JSON_MAX_RETRIES}    ${JSON_RETRY_INTERVAL}    I expect page contains 'id:block_(\\\\d)_channel_(\\\\d)' using regular expressions

Guide channel list is sorted by channel number
    [Documentation]    This keyword checks that the channels displayed in the guide channel cells increase as cells are
    ...    displayed from top to bottom in the guide
    ...    Pre-reqs: The guide is displayed and channel cells are present
    ${json_object}    Get Ui Json
    ${json_string}    Read Json As String    ${json_object}
    @{block_channel_text_collection}    get regexp matches    ${json_string}    block_(\\d+)_channel_(\\d+)_text
    @{chan_cell_numbers}    Create List
    : FOR    ${_}    IN    @{block_channel_text_collection}
    \    ${channel_number_value}    Extract Value For Key    ${json_object}    id:${_}    textValue
    \    ${channel_number_value}    convert to integer    ${channel_number_value}
    \    append to list    ${chan_cell_numbers}    ${channel_number_value}
    ${chan_cell_count}    Get Length    ${chan_cell_numbers}
    : FOR    ${i}    IN RANGE    ${chan_cell_count - 1}
    \    should be true    @{chan_cell_numbers}[${i}] < @{chan_cell_numbers}[${i+1}]    Channel cell number @{chan_cell_numbers}[${i}] is not less than channel cell number @{chan_cell_numbers}[${i+1}]

'Tomorrow' is shown in the Day Picker
    [Documentation]    This keyword verifies that the Day picker in the TV Guide shows the value for
    ...    'Tomorrow'
    wait until keyword succeeds    ${JSON_MAX_RETRIES}    ${JSON_RETRY_INTERVAL}    I expect page element 'id:gridNavigation_filterButton_\\\\d+' contains 'textKey:DIC_GENERIC_AIRING_DATE_TOMORROW' using regular expressions

Season number of the current focused event is shown in the TV Guide
    [Documentation]    This keyword expects that current focused event in the TV Guide has season number.
    ...    Pre-reqs: TV Guide page should be opened.
    Wait until keyword succeeds    ${JSON_MAX_RETRIES}    ${JSON_RETRY_INTERVAL}    I expect page element 'textKey:DIC_GENERIC_EPISODE_FULL' contains 'textValue:^.*(S\\\\d+, Ep\\\\d+)' using regular expressions

I have an event that is about to start at [T+${time}]
    [Documentation]    This keyword chooses an event that is about to start in more than ${time} minutes
    I tune to channel with short duration events
    I open Guide through Main Menu
    : FOR    ${_}    IN RANGE    ${5}
    \    I focus Next event
    \    ${time_till_event_start}    Get time when focused event starts
    \    Exit For Loop If    ${time_till_event_start} > ${time}
    Should Not Be True    ${time_till_event_start} > 15    We can`t wait more then 15 minutes for event
    set suite variable    ${TIME_TILL_EVENT_START}
    I press    OK
    Common Details Page elements are shown

Get time when focused event starts
    [Documentation]    This keyword retrieved remaining time to start focused event
    ${current_time}    Get current hours in the tv guide
    ${focused_hours}    Get focused event hours in the tv guide
    @{regexp_match_1}    Get Regexp Matches    ${focused_hours}    (\\d{2}):(\\d{2}) ?- ?(\\d{2}):(\\d{2})    1    2    3
    ...    4
    ${event_time_start_hour}    ${event_time_start_minutes}    Set Variable    @{regexp_match_1[0]}[0]    @{regexp_match_1[0]}[1]
    ${event_time_start_hour}    Convert To Integer    ${event_time_start_hour}
    ${event_time_start_minutes}    Convert To Integer    ${event_time_start_minutes}
    @{regexp_match_2}    Get Regexp Matches    ${current_time}    (\\d{2}):(\\d{2})    1    2
    ${current_time_hour}    ${current_time_minutes}    Set Variable    @{regexp_match_2[0]}[0]    @{regexp_match_2[0]}[1]
    ${current_time_hour}    Convert To Integer    ${current_time_hour}
    ${current_time_minutes}    Convert To Integer    ${current_time_minutes}
    ${same_hour}    Evaluate    ${current_time_hour} == ${event_time_start_hour}
    ${focused_event_duration_left}    Set Variable If    '${same_hour}' == 'False'    ${event_time_start_minutes + (60 - ${current_time_minutes})}    ${event_time_start_minutes - ${current_time_minutes}}
    [Return]    ${focused_event_duration_left}

Grid line in TV Guide is dynamically updated
    [Documentation]    This keyword will verify that the grid line in TV Guide is dynamically updated.
    ...    Precondition: guide is shown
    ${grid_line_initial_position}    Get 'x' position of gridNowLine
    I wait for 30 seconds
    ${grid_line_later_position}    Get 'x' position of gridNowLine
    should not be equal    ${grid_line_initial_position}    ${grid_line_later_position}    the 'x' coordinate position of gridNowLine is unchanged

I Tune To A Channel With Replay Events From TV Guide    #USED
    [Documentation]    This keyword tunes to the replay event from TV Guide.
    [Arguments]    ${replay_source}=cloud
     :FOR    ${next_channel}    IN RANGE    10
    \    ${replay_event}    ${replay_channel}    Get Replay Event Metadata And Channel Number    False    600    ${replay_source}
    \    Exit For Loop If    ${replay_event}
    I tune to ${replay_channel} in the tv guide
    set suite variable    ${tv_guide_replay_channel_tuned}    ${replay_channel}
    [Return]    ${replay_event}    ${replay_channel}

I Tune Replay Channel And Focus Past Replay Event With '${replay_source}' Replay Source In The Tv Guide    #USED
    [Documentation]    This keyword focuses past replay event with given replay source in the tv guide
    I Tune Replay Channel And Focus Past Replay Event In The Tv Guide     ${replay_source}

I Tune Replay Channel And Focus Past Replay Event In The Tv Guide    #USED
    [Documentation]    This keyword focuses past replay event in the tv guide and
    ...   return the name of focussed replay event. It sets the details of past focussed replay event
    ...   to a Suite variable ${FILTERED_REPLAY_EVENT}
    [Arguments]    ${replay_source}=Any
    ${replay_event}    ${replay_channel}    I Tune To A Channel With Replay Events From TV Guide    ${replay_source}
    I Ensure Channel Is Unlocked From TV Guide
    Set Suite Variable    ${FILTERED_REPLAY_EVENT}    ${replay_event}
    Log    Details of replay event: ${FILTERED_REPLAY_EVENT}
    ${season_id}    Extract Value For Key    ${FILTERED_REPLAY_EVENT}    ${EMPTY}    seriesId
    ${show_id}    Extract Value For Key    ${FILTERED_REPLAY_EVENT}    ${EMPTY}    parentSeriesId
    ${seriesName}    Extract Value For Key    ${FILTERED_REPLAY_EVENT}    ${EMPTY}    seriesName
    ${title}    Extract Value For Key    ${FILTERED_REPLAY_EVENT}    ${EMPTY}    title
    ${cws_title}    Set Variable If    "${season_id}" == "${None}" and "${show_id}" == "${None}" and '''${seriesName}''' != "${None}"    ${seriesName}    ${title}
    Set Suite Variable    ${CWS_REPLAY_ASSET_TITLE}    ${cws_title}
    Should Be True    "${title}" != "${None}"   Unable to fetch the title of the replay asset from BO
    :FOR    ${next_channel}    IN RANGE    ${MAX_EVENT_LENGTH}
    \    ${current_event_title}    I retrieve value for key 'textValue' in element 'id:gridInfoTitle'
    \    ${is_replay_event}    Run Keyword And Return status    Should Contain     ${current_event_title}    ${title}
    \    ${not_current}    Run Keyword And Return status    Now Line Is Shown
    \    Exit For Loop If    ${is_replay_event} and (not ${not_current})
    \    Move Focus to direction and assert    LEFT    5
    Should Be True    ${is_replay_event}    Unable to find the replay event (${title}) after 50 retries on channel: ${replay_channel}
    [Return]    ${title}

I Ensure Channel Is Unlocked From TV Guide    #USED
    [Documentation]    This keyword ensures that the channel is unlocked if it is locked already
    ${is_locked_channel}    Run Keyword And Return Status    Metadata Is Hidden For Operator Locked Event In 'TV GUIDE' View
    Run Keyword If    ${is_locked_channel}    I press    OK
    ${pin_entry_present}    Run Keyword And Return Status    Pin Entry popup is shown
    Run Keyword If    ${pin_entry_present}    I Enter A Valid Pin
    Event Metadata Is shown In Guide

I Focus '${option}' From Contextual Key Menu Pop Up    #USED
    [Documentation]  Selects the given option from the Contextual key menu.
    ...   Precondition : Contextual Key Menu Pop up should be visible
    Contextual key menu is shown
    Move Focus to Option in Value Picker  textValue:${option}   DOWN   7
    Option is Focused in Value Picker   textValue:${option}

I Browse All Available Channels Through Contextual Key Menu    #USED
    [Documentation]  All available channels list is shown in TV Guide through Contextual Key Pop up. The list of channels will be shown in TV Guide with the filter 'All Channels'
    I Open Contextual Key Menu Pop Up From TV-Guide
    I Focus 'Browse all available channels' From Contextual Key Menu Pop Up
    I Press  OK
    wait until keyword succeeds    ${JSON_MAX_RETRIES}    ${JSON_RETRY_INTERVAL}    I expect page contains 'textKey:DIC_FILTER_ALL_CHANNELS'

I Open Contextual Key Menu Pop Up From TV-Guide    #USED
    [Documentation]  Open the Contextual Key Pop up from tv guide
    ...   Precondition : TV Guide should be displayed
    Guide is shown
    I Press  CONTEXT
    Contextual key menu is shown

TV Guide Numeric Channel Zapping On Lineup Channels     #USED
    [Documentation]    Tune On TV Guide to a random filtered (NO: app, 4k, adult, radio) channel number and check is tuned
    ${channel_number}   I Fetch One Random Linear Channel Number From List Filtered For Zapping
    I tune to ${channel_number} in the tv guide

Validate CMM For TV Guide    #USED
    [Documentation]    This keyword validates most recently watched event is present in CMM of Guide
    ...    pre-condition: '${EVENT_TITLE}' is a title of the currently tuned linear event,
    ...    this variable is getting set in 'I Tune And Watch Linear Event For '${time}' Seconds'.
    Variable Should Exist    ${EVENT_TITLE}    '${EVENT_TITLE}' didn't exist
    ${most_recently_watched}    Set Variable    ${EVENT_TITLE}
    Wait Until Keyword Succeeds    4 times    300 ms    I expect page element 'id:programme-title-contextualMainMenu-navigationContainer-TVGUIDE_element_\\\\d+' contains 'textValue:${most_recently_watched}' using regular expressions

Check EPG Valid Channel Information On First Channel    #USED
    [Documentation]    This keyword will go to the fisrt lineup channel lineup on EPG and check the data and poster
    ...    Precondition: guide is shown and ${FILTERED_CHANNEL_LIST} exist
    ...    End: ${LENGTH_FILTERED_CHANNEL_LIST} is created for next steps to made the loop of all channels in lineup
    ${first_lineup_channel}    Get Channel Lineup and EPG Tune To First Channel
    Check EPG Valid Channel Event Information For Highlighted '${first_lineup_channel}' Logo '${False}' Poster '${True}' Metadata '${True}'

Check EPG Valid Channel Event Information on Next Channel    #USED
    [Documentation]    Valid Channel Event Information on the next channel
    ...    Precondition: guide is shown and ${FILTERED_CHANNEL_LIST} and ${APP_BOUND_AUTOSTART_CHANNELS} exist
    [Arguments]    ${lineup_check}=${True}
    Check EPG Valid Channel Event Information or Logo on Next Channel Lineup '${lineup_check}' Logo '${False}' Poster '${True}' Metadata '${True}'

Check EPG Valid Channel Event Information or Logo on Next Channel Lineup '${lineup_check}' Logo '${logo_check}' Poster '${poster_check}' Metadata '${metadata_check}'  #USED
    [Documentation]    Valid Channel Event Information on the next channel
    ...    Precondition: guide is shown and ${FILTERED_CHANNEL_LIST} and ${APP_BOUND_AUTOSTART_CHANNELS} exist
    run keyword if    ${lineup_check}    Variable should exist    ${FILTERED_CHANNEL_LIST}    FILTERED_CHANNEL_LIST should exist for Check EPG Valid Channel Information on Next Channel
    run keyword if    ${lineup_check}    Variable should exist    ${APP_BOUND_AUTOSTART_CHANNELS}    APP_BOUND_AUTOSTART_CHANNELS should exist for EPG Valid Channel Information on Next Channel
    ${actual_focused_epg_channel_number}    Get Focused Guide Programme Cell Channel Number
    ${next_lineup_channel}    run keyword if    ${lineup_check}    Find Next Element On List    ${FILTERED_CHANNEL_LIST}    ${actual_focused_epg_channel_number}
    run keyword if    '${next_lineup_channel}'== '-1'    log to console    WARN: No more elements on FILTERED_CHANNEL_LIST - Element: ${actual_focused_epg_channel_number} is the last element of list: ${FILTERED_CHANNEL_LIST}
    return from keyword if    '${next_lineup_channel}'== '-1'
    log    ---------------------------------- next_lineup_channel: ${next_lineup_channel} ----------------------------------
    I press    DOWN
    ${channel_number}    Get Focused Guide Programme Cell Channel Number
    run keyword if    ${lineup_check}    should be equal    ${channel_number}    ${next_lineup_channel}    Channel Focused in EPG is not the same as next Lineup Channel
    Channel Is Focused In Guide    ${channel_number}
    Check EPG Valid Channel Event Information For Highlighted '${channel_number}' Logo '${logo_check}' Poster '${poster_check}' Metadata '${metadata_check}'

Get Channel Lineup and EPG Tune To First Channel    #USED
    [Documentation]    This keyword will go to the fisrt lineup channel lineup on EPG.
    ...    Precondition: guide is shown and ${FILTERED_CHANNEL_LIST} exist
    ...    End: ${LENGTH_FILTERED_CHANNEL_LIST} is created for next steps to made the loop of all channels in lineup
    ...    Return the first lineup channel
    Variable should exist    ${FILTERED_CHANNEL_LIST}    FILTERED_CHANNEL_LIST should exist for EPG Valid Channel Information
    ${first_index}    set variable    0
    #Use Below line for DEBUG
#    ${first_index}    set variable    77
    ${first_lineup_channel}    set variable    ${FILTERED_CHANNEL_LIST[${first_index}]}
    ${length_filtered_channel_list}    Get Length    ${FILTERED_CHANNEL_LIST}
    ${length_filtered_channel_list}    evaluate    ${length_filtered_channel_list}-${first_index}-1
    set suite variable    ${LENGTH_FILTERED_CHANNEL_LIST}    ${length_filtered_channel_list}
    I Fetch All Autostart App Bound Channels From Linear Service    'logicalChannelNumber'
    log    APP_BOUND_AUTOSTART_CHANNELS: ${APP_BOUND_AUTOSTART_CHANNELS}
    I tune to ${first_lineup_channel} in the tv guide
    [Return]    ${first_lineup_channel}

Check EPG Valid Channel Logo On First Channel    #USED
    [Documentation]    This keyword will go to the fisrt lineup channel lineup on EPG and check the Logo
    ...    Precondition: guide is shown and ${FILTERED_CHANNEL_LIST} exist
    ...    End: ${LENGTH_FILTERED_CHANNEL_LIST} is created for next steps to made the loop of all channels in lineup
    ${first_lineup_channel}    Get Channel Lineup and EPG Tune To First Channel
    Check EPG Valid Channel Event Information For Highlighted '${first_lineup_channel}' Logo '${True}' Poster '${False}' Metadata '${False}'

Check EPG Valid Channel Logo On Next Channel    #USED
    [Documentation]    Valid Channel Logo on the next channel
    ...    Precondition: guide is shown and ${FILTERED_CHANNEL_LIST} and ${APP_BOUND_AUTOSTART_CHANNELS} exist
    [Arguments]    ${lineup_check}=True
    Check EPG Valid Channel Event Information or Logo on Next Channel Lineup '${lineup_check}' Logo '${True}' Poster '${False}' Metadata '${False}'

Check Most Watched Event Is Not In CMM For TV Guide    #USED
    [Documentation]    This keyword validates most watched event is not present in CMM of Guide
    ...    pre-condition: '${EVENT_TITLE}' is a title of the currently tuned linear event,
    ...    this variable is getting set in 'I Tune And Watch Linear Event For '${time}' Seconds'.
    Variable Should Exist    ${EVENT_TITLE}    '${EVENT_TITLE}' didn't exist
    ${most_recently_watched}    Set Variable    ${EVENT_TITLE}
    Wait Until Keyword Succeeds    4 times    300 ms    I do not expect page element 'id:programme-title-contextualMainMenu-navigationContainer-TVGUIDE_element_\\\\d+' contains 'textValue:${most_recently_watched}' using regular expressions

Navigate To '${Nth}' Day In Future In TV Guide    #USED
    [Documentation]    This Keyword Navigates To Given Nth Day In Future In TV Guide
    ...    Precondition : TV Guide Should Be Open
    Guide is shown
    I open Day Filter
    I Press DOWN ${Nth} Times
    I Press    OK

Navigate To '${Nth}' Past Day In TV Guide    #USED
    [Documentation]    This Keyword Navigates To Given Nth Day In Past In TV Guide
    ...    Precondition : TV Guide Should Be Open
    Guide is shown
    I open Day Filter
    I Press UP ${Nth} Times
    I Press    OK

Validate EPG Data In TV Guide Across Different Channels    #USED
    [Documentation]    This Keyword Validates EPG Data Across Different Channels In TV Guide
    ...    Precondition : TV Guide Should Be Open
    :FOR    ${index}    IN RANGE    0    10
    \    I Press DOWN 2*${index} + 1 Times
    \    Check EPG Info Panel has Info Available
    :FOR    ${index}    IN RANGE    0    10
    \    I Press UP 2*${index} Times
    \    Check EPG Info Panel has Info Available

I Tune To Focused IP Channel In TV Guide    #USED
    [Documentation]    This keyword gets the random IP Channel and tunes to that channel in the guide
    ${filtered_list}    I Fetch Linear Channel List Filtered
    ${length}    Get Length    ${filtered_list}
    ${ip_channel}    Set Variable    ${None}
    ${is_channel_present}    Set Variable    ${None}
    :FOR    ${index}    IN RANGE    ${length}
    \    ${ip_channel}    Get Random IP Channel Number
    \    ${channel_id}    Get channel ID using channel number    ${ip_channel}
    \    ${is_channel_present}    Run Keyword and Return status    Should Contain    ${filtered_list}    ${channel_id}
    \    Exit For Loop If    ${is_channel_present}
    Should Be True    ${is_channel_present}    IP channel is not present which is not adult, 4k.
    I tune to ${ip_channel} in the tv guide
    I Tune The Focused ${ip_channel} In The Tv Guide
    ${is_channel_failed}    Run Keyword And Return Status    Error popup is not shown
    Run Keyword If    not ${is_channel_failed}    I Press    BACK

I Filter Channels With Genre '${genre}' In TV Guide    #USED
    [Documentation]    This keyword navigates to the channel filter in TV Guide and selects the given genre from the
    ...    drop down list of genres
    ...    Precondition: TV Guide must be launched
    I Select Channel Filter In TV Guide
    Navigate To '${genre}' Genre In Channel Filter Drop Down
    I Press    OK
    Wait Until Keyword Succeeds And Verify Status    ${JSON_MAX_RETRIES}    ${JSON_RETRY_INTERVAL}    ${genre} genre is not focused in channel filter    I expect focused elements contains 'textValue:${genre}'

I verify EPG Info Panel Details of Locked Age Rated Event    #USED
    [Documentation]    This keyword verifies the lock icon, title, synopsis and poster of age rated event in EPG Info panel
    ${ui_json}    Get Ui Json
    ${info_panel}    Extract Value For Key    ${ui_json}    id:gridInfoPanel    children
    ${lock_icon_present}    Is In Json    ${info_panel}    id:lockIcongridPrimaryMetadata    iconKeys:LOCK
    Should Be True    ${lock_icon_present}    Lock icon not present
    ${title}    Is In Json    ${info_panel}    id:gridInfoTitle    textValue:^.+$    ${EMPTY}    ${True}
    Should Be True    ${title}    Title is not present
    ${synopsis}    Is In Json    ${info_panel}    id:gridInfoSynopsis    textValue:^.+$    ${EMPTY}    ${True}
    Should Be True    ${synopsis}    Synopsis is not present
    ${poster_json}    Extract Value For Key    ${info_panel}    id:gridInfoPoster    background
    ${default_poster_shown}    Is In Json    ${poster_json}    ${EMPTY}    image:.*default_posters.*    ${None}    ${True}
    Should Not Be True    ${default_poster_shown}    Default poster is shown

I Tune To Unsubscribed Event  #USED
    [Documentation]    This keyword tunes to unsubscribed event
    ${filtered_channel_list}    I Fetch All Unsubscribed Channels
    Should Not Be Empty    ${filtered_channel_list}    unable to get unsubscribed channels
    ${channel_number}    Get Random Element From Array    ${filtered_channel_list}
    I Open Guide Through Main Menu
    I Tune To ${channel_number} In The Tv Guide

I Select Channel Filter In TV Guide    #USED
    [Documentation]    This keyword navigates to channel filter in TV Guide and verify if the drop down is shown
    ...    Precondition: TV Guide must be launched
    I Press    MENU
    Day filter is focused
    Move Focus to direction and assert    RIGHT    5
    Channel Filter Is Focused
    I Press    OK
    Channel Filter Drop Down Is Shown

I Verify Options Of Channel Filter In TV Guide    #USED
    [Documentation]    This keyword verifies that all the genres from backend and the genres in TV Guide channel filter are same
    ...    In addition verifies 'All channels' and 'Profile Lineup' options in channel filter
    ...    Precondition: Selected Profile should be a created custom profile
    ...    Precondition: TV Guide must be launched
    ${genres_from_backend}    I Get All Genres Of Available TV Channels
    ${genres_in_ui}    Create List
    ${genre_keys}    Create List
    I Select Channel Filter In TV Guide
    Move Focus to First Option in Value Picker
    I Press    OK
    Option is Focused in Value Picker    textKey:DIC_FILTER_ALL_CHANNELS
    :FOR    ${i}    IN RANGE    len(${genres_from_backend})+3
    \   ${json_focused}    Get Ui Focused Elements
    \   ${genre}    Extract Value For Key    ${json_focused}    id:gridNavigation_filterButton_1    textValue    ${False}
    \   ${key}    Extract Value For Key    ${json_focused}    id:gridNavigation_filterButton_1    textKey    ${False}
    \   Append To List    ${genres_in_ui}    ${genre}
    \   Append To List    ${genre_keys}    ${key}
    \   I Press    OK
    \   Verify Value Picker Is Present On Screen
    \   I Press    DOWN
    \   I Press    OK
    \   Verify Value Picker Is Not Present On Screen
    ${genres_in_ui}    Remove Duplicates     ${genres_in_ui}
    Should Be Equal    ${genre_keys[0]}    DIC_FILTER_ALL_CHANNELS    'All channels' option is not present in channel filter
    Should Be Equal    ${genre_keys[1]}    DIC_GUIDE_GENRE_PROFILE_LINE_UP    'Profile line-up' is not present on screen
    Lists Should Be Equal    ${genres_from_backend}    ${genres_in_ui[2:]}    Mismatch in the display of Channels in Ui '${genres_in_ui}' with the channel list from backend '${genres_from_backend}'

I Verify Channels Displayed In TV Guide Is Same As Channels Obtained From Backend For A Genre   #USED
    [Documentation]    This keyword gets a genre and its corresponding channels from backend and verifies the same
    ...    channels are displayed in Tv Guide when filtered with the selected genre
    ...    Precondition: TV Guide must be launched
    ${genre}    ${channels_of_genre}    I Get All Channels Of A Genre
    I Filter Channels With Genre '${genre}' In TV Guide
    ${first_channel}    Convert To String    ${channels_of_genre[0]}
    I tune to ${first_channel} in the tv guide
    ${channels_in_ui}    Create List
    :FOR    ${i}    IN RANGE    len(${channels_of_genre})+1
    \    ${channel_number}    Get Focused Guide Programme Cell Channel Number
    \    ${channel_number}    Convert To Integer    ${channel_number}
    \    Append To List    ${channels_in_ui}    ${channel_number}
    \    ${status}    Run Keyword And Return Status    Move Focus to direction and assert    DOWN    5
    \    Exit For Loop If    not ${status}
    Lists Should Be Equal    ${channels_of_genre}    ${channels_in_ui}    Mismatch in the display of Channels in Ui '${channels_in_ui}' with the channel list from backend '${channels_of_genre}' for genre '${genre}'

I Tune To A Random Adult Channel In TV Guide    #USED
    [Documentation]    This keyword fetches a random adult channel and tunes to it in TV Guide.
    ${random_adult_channel}    I Get A Random Adult Channel
    ${channel_number}    Convert To String    ${random_adult_channel}
    I Open Guide Through Main Menu
    I Tune To ${channel_number} In The Tv Guide

I Tune To '${event_type}' Event In TV Guide    #USED
    [Documentation]    This keyword finds a single event and navigate to that event in TV Guide
    ${event}    ${channel_id}    ${length_of_events}    I Select A Next Day '${event_type}' Event From BO
    Set Suite Variable    ${SELECTED_EVENT}    ${event}
    ${max_actions}    Evaluate    5*${length_of_events}
    Set Suite Variable    ${MAX_ACTIONS}    ${max_actions}
    ${channel_number}    Get Channel Lcn For Channel Id    ${channel_id}
    I Open Guide Through Main Menu
    I Tune To ${channel_number} In The Tv Guide
    I Focus The Selected Next Day Event In TV Guide

I Focus The Selected Next Day Event In TV Guide    #USED
    [Documentation]    This keyword focus the selected next day event in tv guide with the details from suite variable SELECTED_EVENT
    :FOR     ${index}    IN RANGE    ${MAX_ACTIONS}
    \    Move to element assert focused elements    textValue:${SELECTED_EVENT['title']}    ${MAX_ACTIONS}    RIGHT
    \    ${json_object}    Get Ui Json
    \    ${primary_metadata_value}    Extract Value For Key    ${json_object}    id:detailedInfogridPrimaryMetadata    textValue
    \    ${day}    Extract Value For Key    ${json_object}    id:detailedInfogridPrimaryMetadata    textKey
    \    @{displayed_event_start_end_time}    Get Regexp Matches    ${primary_metadata_value}    (\\d{2}:\\d{2}) ?- ?(\\d{2}:\\d{2})    1    2
    \    ${backend_event_start_time_converted}    robot.libraries.DateTime.Convert Date    ${SELECTED_EVENT['startTime']}
    \    @{backend_event_start_time}    Get Regexp Matches    ${backend_event_start_time_converted}    (\\d{2}:\\d{2}):00.000    1
    \    ${same_start_time}    Run Keyword And Return Status    Should Be Equal    @{displayed_event_start_end_time[0]}[0]    @{backend_event_start_time}[0]
    \    Exit For Loop If    ${same_start_time} and '${day}' == 'DIC_GENERIC_AIRING_DATE_TOMORROW'
    \    Move Focus to direction and assert    RIGHT

I Select A Next Day '${event_type}' Event From BO    #USED
    [Documentation]    This keyword finds a '${event_type}' Event From BO
    ${http_response}    Get Index Of Event Metadata Segments
    ${epg_index_json}    Set Variable    ${http_response.json()}
    @{entries}    Create List    @{epg_index_json['entries']}
    ${length}    Get Length    ${entries}
    ${is_history_present}    run keyword and return status    variable should exist  ${event_history}
    @{empty_list}    Create List
    run keyword if   not ${is_history_present}    set suite variable  ${event_history}    ${empty_list}
    Log    ${event_history}
    ${channel_lineup_response}    get all channels via linearservice
    @{blacklisted_channels}    get all recording blacklisted channels via linear service    ${channel_lineup_response}
    ${unsubscribed_channel_list}    Get List Of Linear Channel Key Via Linear Service With Filters   'id'    radio=False    4k=False    adult=False    app=False
    ...    resolution=Any    is_subscribed=False
    log    ${unsubscribed_channel_list}
    :FOR     ${index}    IN RANGE    ${length}
    \    ${channel_id}    Set Variable    ${entries[${index}]['channelIds'][0]}
    \    Continue For Loop If    '${channel_id}' in ${blacklisted_channels}
    \    Continue For Loop If    '${channel_id}' in ${unsubscribed_channel_list}
    \    ${channel_number}    Get Channel Number By Id    ${CITY_ID}    ${channel_id}    ${OSD_LANGUAGE}    ${CPE_PRODUCT_CLASS}
    \    Continue For Loop If    ${channel_number}==None
    \    Log    ${entries[${index}]['segments'][8]}
    \    ${event_hash}    Set Variable    ${entries[${index}]['segments'][8]}
    \    ${epg_segment}    Get Event Metadata For A Particular Segment    ${event_hash}
    \    ${event_list}    Set Variable    ${epg_segment.json()['entries'][0]['events']}
    \    ${event}    Get A Next Day Event Of Given Type From All Events Of The Hash    ${event_type}   ${event_list}
    \    ${event_availability}    Run Keyword And Return Status    Should Not Be Equal As Strings    '${event}'    '${None}'
    \    Continue For Loop If    ${event_availability}==${False}
    \    Log   ${event}
    \    ${is_series}    evaluate   'seriesId' in ${event}
    \    ${recording_status}    run keyword if  ${is_series}   Check If Series Recording Exist  ${channel_id}   ${event}
    \    ...   ELSE   Check If Single Recording Exist   ${event}
    \    ${history_check}    evaluate    '&{event}[id]' in ${event_history}
    \    continue for loop if    ${history_check}
    \    Exit For Loop If    not ${recording_status}
    Append To List    ${event_history}    &{event}[id]
    Set Suite Variable  ${event_history}    ${event_history}
    [Return]     ${event}    ${channel_id}    len(${event_list})


I Tune To A Random Radio Channel In TV Guide    #USED
    [Documentation]    This keyword fetches a random radio channel and tunes to it in TV Guide.
    ${random_radio_channel}    I Get A Random Radio Channel
    ${channel_number}    Convert To String    ${random_radio_channel}
    Set Suite Variable    ${CHANNEL_NUMBER}    ${channel_number}
    I Open Guide Through Main Menu
    I press    ${CHANNEL_NUMBER}

I Verify Channel Is Not Tuned In TV Guide    #USED
    [Documentation]    This keyword verifies the channel set in suite variable CHANNEL_NUMBER is not tuned in TV Guide after pressing the channel number.
    ${is_tuned}    Run Keyword And Return Status    Wait Until Keyword Succeeds    10 times    200 ms    Channel Is Focused In Guide    ${CHANNEL_NUMBER}
    Should Not Be True    ${is_tuned}    Radio Channel is Listed in TV Guide

I Ensure Adult Event Is Unlocked From The TV Guide    #USED
    [Documentation]    This keyword verifies whether the current tuned event in Guide is adult or not,
    ...    if the tuned event is adult it unlocks it from guide and comes back to guide
    ${ui_json}    Get Ui Json
    Log    ${ui_json}
    ${info_panel}    Extract Value For Key    ${ui_json}    id:gridInfoPanel    children
    ${adult_channel_text_present}    Is In Json    ${info_panel}    id:gridInfoTitle    textKey:DIC_ADULT_PROGRAMME
    Run Keyword If    ${adult_channel_text_present}    I press    OK
    ${pin_entry_present}    Run Keyword And Return Status    Pin Entry popup is shown
    Run Keyword If    ${pin_entry_present}    I Enter A Valid Pin
    Run Keyword If    ${adult_channel_text_present}    I open Guide through Main Menu
    Run Keyword If    ${adult_channel_text_present}    Event Metadata Is shown In Guide

#*************CPE Performance Testing******************

Validate TVGuide Is loaded
    [Documentation]  This keyword validates the following when TV guide is launched
    ...    1. Guide header is shown
    ...    2. Event Metadata is shown
    ...    3. Current Event is focused
    ...    4. Event duration is shown in panel
    ...    5. Channel cells in guide are shown
    ${json_object}    Get Ui Json
    #Verify guide programme cell data is loaded
    ${programme_cell_value}    Extract Value For Key    ${json_object}    id:block_\\d+_event_.*    textValue    ${True}
    should not be equal as strings    ${programme_cell_value}    None    Guide programme cell data is not loaded
    #Guide channel cells are shown
    ${guide_channel}    Is In Json    ${json_object}    ${EMPTY}    id:block_(\\d)_channel_(\\d)    ${EMPTY}    ${True}
    Should Be True    ${guide_channel}    Guide channel cells are not shown
    #Guide Grid is shown
    ${guide_grid}    Is In Json    ${json_object}    ${EMPTY}    id:gridContainer
    Should Be True    ${guide_grid}    Guid grid is not shown
    #Event metadata is shown in Guide
    ${grid_info_title}    Is In Json    ${json_object}    id:guideInfoPanelTitle    textValue:^.+$    ${EMPTY}    ${True}
    Should Be True    ${grid_info_title}    Event title not found in panel
#    ${grid_info_synopsis}    Is In Json    ${json_object}    id:guideInfoPanelSynopsis    textValue:^.+$    ${EMPTY}    ${True}
#    Should Be True    ${grid_info_synopsis}    Event title not found in panel
    #Event duration is shown in panel
    ${detailed_infogrid_primary_metadata}    Is In Json    ${json_object}    id:infoPanel_primaryMetadata    textValue:^.+$    ${EMPTY}    ${True}
    Should Be True    ${detailed_infogrid_primary_metadata}    Item textValue was not found in id:infoPanel_primaryMetadata
    ${event_info}    Extract Value For Key    ${json_object}    id:infoPanel_airingTime    textValue
    @{event_info}    split string    ${event_info}    •
    ${event_info}    strip string    @{event_info}[0]
    should not be empty    ${event_info}    event duration is not shown
    #${highlighted_event}    I retrieve Info panel title element
    #${highlighted_event}    Extract Value For Key    ${json_object}    id:guideInfoPanelTitle    textValue
    #${header}    Extract Value For Key    ${json_object}    id:mastheadNowPlaying    textValue
    #${header_string}    Extract Value For Key    ${json_object}    id:mastheadNowPlaying    dictionnaryValue
    #${remove_string}    Catenate    SEPARATOR=    ${header_string}    :
    #${header}    Remove String    ${header}    ${remove_string}
    #${header}    Strip String    ${header}
    #Should Contain    ${highlighted_event}    ${header}    Highlighted event does not contain the expected header
    #Guide is shown
    ${guide_view}    Is In Json    ${json_object}    ${EMPTY}    id:Guide.View
    Should Be True    ${guide_view}    TV Guide view is not loaded
    #TV Guide Header is shown
    #${watching_now}    Is In Json    ${json_object}    id:mastheadNowPlaying    textKey:DIC_HEADER_SOURCE_LIVE
    #Should Be True    ${watching_now}    TV Guide Header is shown


I focus previous event in the tv guide
    [Documentation]    This keyword focuses a future event in the TV guide
    I focus current event in the tv guide
    : FOR    ${i}    IN RANGE    ${8}
    \    I press    LEFT
    \    ${is_past_event_id_present}    Run Keyword And Return Status    Previous event is focused on TV Guide
    \    Exit For Loop If    ${is_past_event_id_present} == ${True}

Go to given past event in TV Guide
    [Documentation]    Nagivate to the specified past content in the tv guide
    ...    Preconditions: Already on the the required channel in tv guide
    [Arguments]    ${program_name}    ${max_iterations}=30
    ${current_title}    set variable     ${EMPTY}
     :FOR    ${i}    IN RANGE    0    ${max_iterations}
    \    I press    LEFT
    \    I wait for 2 seconds
    \    Get Ui Json
    \    ${current_title}    Extract Value For Key    ${LAST_FETCHED_JSON_OBJECT}    id:guideInfoPanelTitle    textValue
    \    log to console    ${current_title}
    \    exit for loop if    """${current_title}""" == """${program_name}"""
    should be true    """${current_title}""" == """${program_name}"""

I verify future event in tv guide is focused
    [Documentation]    This keyword verifies if future event is focused in tv guide and info is available
    [Arguments]    ${future_event_id}
    ${json_object}    Get Ui Focused Elements
    ${future_event_id_is_focused}    Is In Json    ${json_object}    ${EMPTY}    id:${future_event_id}
    Should Be True    ${future_event_id_is_focused}    ${future_event_id} is not focused

#    ${is_guide_info_panel_shown}    Is In Json    ${json_object}    ${EMPTY}    id:guideInfoPanel
#    Should Be True    ${is_guide_info_panel_shown}    Guide info panel is not present
#
#    ${info_title_text_value}    Extract Value For Key    ${json_object}    textValue    id:guideInfoPanelTitle
#    Should Not Be Empty    ${info_title_text_value}    gridInfoTitle textValue is empty

Validate Profile switch from Tv Guide
    [Documentation]  This keyword validates Profile switch from tv guide
    ${json_object}    Get Ui Json
    #Guide channel cells are shown
    ${toast_popup}    Is In Json    ${json_object}    ${EMPTY}    id:toast.message
    Should Be True    ${toast_popup}    Profie switch toast pop not shown
    #Guide is shown
    ${guide_view}    Is In Json    ${json_object}    ${EMPTY}    id:Guide.View
    Should Be True    ${guide_view}    TV Guide view is not loaded

Validate Profile switch from PHS
    [Documentation]  This keyword validates Profile from PHS
    ${json_object}    Get Ui Json
    #Guide channel cells are shown
    ${toast_popup}    Is In Json    ${json_object}    ${EMPTY}    id:toast.message
    Should Be True    ${toast_popup}    Profie switch toast pop not shown
    #PHS is shown
    ${phs_view}    Is In Json    ${json_object}    ${EMPTY}    id:PersonalHome.View
    Should Be True    ${phs_view}    PHS view is not loaded
