*** Settings ***
Documentation     Replay TV Implementation keywords
Resource          ../PA-04_User_Interface/MainMenu_Keywords.robot
Resource          ../PA-15_VOD/Saved_Keywords.robot
Resource          ../PA-19_Cloud_Recordings/PVR_Keywords.robot
Resource          ../../MicroServices/ReplayCatalogService/ReplayCatalogService_Keywords.robot
Resource          ../../MicroServices/BookmarkService/BookmarkService_Keywords.robot


*** Variables ***
${max_assets_in_replay_tv}    50
${replay_asset_duration}      900
${long_duration_event}        14400

*** Keywords ***
Get Random Replay Channel Number    #USED
    [Documentation]    This keyword retrieves ID List of Replay TV Channels, select one randomly and retrieves the
    ...    Channel Number of that random Channel ID selected
    ...    [Return]   Channel Number of a random Replay TV Channel
    ${replay_channels}    I Fetch All Replay Channels From Linear Service
    Log    Replay TV - replay_channels List: ${replay_channels}
    ${channel_id}    Get Random Element From Array    ${replay_channels}
    Log    Replay TV - channel_id: ${channel_id}
    ${channel_number}    get channel number by id    ${CITY_ID}    ${channel_id}    ${OSD_LANGUAGE}    ${CPE_PRODUCT_CLASS}
    Log    Replay TV - channel_number: ${channel_number}
    [Return]    ${channel_number}

Get Random Replay Channel Number Without Planned Blacklisted Recording And Minimum Starting Time '${remaining_time_limit}'   #USED
    [Documentation]    This keyword retrieves ID List of Replay TV Channels, from the replay channels removes the
    ...    channels which has planned recordings and which are blacklisted. Select one replay channel randomly and
    ...    retrieves the Channel Number of that random Channel ID selected
    ...    [Return]   Channel Number of a random Replay TV Channel which are not Blacklisted and has no Planned Recordings
    ${replay_channels}    I Fetch All Replay Channels From Linear Service
    ${recording_blacklisted_channels}    I Fetch All Recording Blacklisted Channels From Linear Service
    ${planned_recording_channels}    Get List Of Channel ID With Planned Recording From BO
    :FOR  ${channel}  IN   @{planned_recording_channels}
    \   Remove Values From List   ${replay_channels}    ${channel}
    :FOR  ${channel}  IN   @{recording_blacklisted_channels}
    \   Remove Values From List   ${replay_channels}    ${channel}
    ${random_replay_channel_number}    Run Keyword If    '${remaining_time_limit}' != 'Any'    Filter Channels Based On Remaining Time Of The Program   ${replay_channels}    ${remaining_time_limit}
    ...    ELSE    Get Random Element From Array    ${channel_number_list}
    [Return]    ${random_replay_channel_number}

Validate that episode is relevant
    [Arguments]    ${episode_index}
    [Documentation]    This keyword retrieves and then validates duration from current episode and time format for the scheduled episode.
    ...    Episode index is passed as ${episode_index} argument.
    ${current_episode_duration}    Get Episode duration or time data    ${episode_index}
    Check episode duration for correct format    ${current_episode_duration}
    ${scheduled_episode_time}    Get Episode duration or time data    ${episode_index+1}
    Run Keyword If    '${scheduled_episode_time}' != '${None}'    Check episode scheduled time for correct date format    ${scheduled_episode_time}

Get Episode duration or time data
    [Arguments]    ${episode_index}
    [Documentation]    This keyword returns episode duration/start-end time from JSON object.
    ...    Episode index is passed as ${episode_index} argument.
    ...    Pre-reqs: UI state from 'ALL EPISODES' page should be available in ${LAST_FETCHED_JSON_OBJECT} variable as JSON.
    ${episode_duration}    Extract Value For Key    ${LAST_FETCHED_JSON_OBJECT}    id:durationNodeepisode_item_${episode_index}    textValue
    ${episode_duration}    Run Keyword If    '${episode_duration}' == ${None}    Extract Value For Key    ${LAST_FETCHED_JSON_OBJECT}    id:nowIconNodeepisode_item_${episode_index}    textValue
    ...    ELSE    set variable    ${episode_duration}
    [Return]    ${episode_duration}

Check episode duration for correct format
    [Arguments]    ${episode_duration}
    [Documentation]    This keyword validates if passed episode duration in ${episode_duration} matches correct duration format.
    ...    Value for argument ${REPLAY_SERIES_DURATION_TIME} is set in implementation.robot
    Should Match Regexp    ${episode_duration}    (${REPLAY_SERIES_DURATION_TIME}|NOW)    Episode duration has incorrect format.

Check episode scheduled time for correct date format
    [Arguments]    ${episode_time}
    [Documentation]    This keyword validates if passed episode time in ${episode_time} matches correct date format (21:00 for example).
    Should Match Regexp    ${episode_time}    [0-9]+:[0-9]+    Episode scheduled time has incorrect date format.

Get episode name from 'INFO' page
    [Documentation]    Gets name of current episode from 'INFO' page, combines name and episode number, removes extra spaces and returns the result.
    ...    Pre-reqs: 'INFO' page should be opened.
    ${episode_name}    I retrieve value for key 'textValue' in element 'id:seriesInfo'
    @{array_with_season_and_episode_names}    Split String    ${episode_name}    ,${SPACE}
    ${episode_name}    Replace String    @{array_with_season_and_episode_names}[1]    Ep${SPACE}    Ep
    [Return]    ${episode_name}

Compare focused episode name from 'ALL EPISODES' page with episode from 'INFO' page
    [Documentation]    Gets focused episode name from current 'ALL EPISODES' page,
    ...    compares episode names from 'INFO' page with current focused episode.
    ...    Pre-reqs: 'ALL EPISODES' page should be opened. Variable ${EPISODE_NAME_ON_INFO_PAGE} should contain episode name from episode info page.
    ...    UI state from 'ALL EPISODES' page should be available in ${LAST_FETCHED_JSON_OBJECT} variable as JSON.
    ${element_children}    Extract Value For Key    ${LAST_FETCHED_JSON_OBJECT}    id:subTitleContainer-ItemDetails    children
    ${focused_episode_in_all_episodes}    Extract Value For Key    ${element_children}    ${EMPTY}    textValue
    Should Be Equal As Strings    '${focused_episode_in_all_episodes}'    '${EPISODE_NAME_ON_INFO_PAGE}'    Focused Episode does not equal Episode from Info

Get default Audio language textkey from Linear Detail Page
    [Documentation]    Returns the default Audio language textkey from Linear Detail Page
    I open Language Options from Linear Details Page
    'Audio' action is shown
    ${ancestor}    I retrieve json ancestor of level '2' for element 'textKey:DIC_ACTIONS_LANGUAGE_OPTIONS_AUDIO'
    ${default_audio_language_key}    Extract Value For Key    ${ancestor}    id:settingFieldValueText_undefined    textKey
    [Return]    ${default_audio_language_key}

Fetch Replay Catalogue Program   #USED
    [Arguments]    ${asset_type}    ${page}
    [Documentation]    This keyword fetch replay event from replay catalog based on type of asset e.g. asset/show.
    ...    param: ${asset_type} : possible values : asset/show
    ...    param: ${page} : page number e.g. 1, 2, etc.
    ${profile_id}    Get Current Profile Id
    ${replay_channels}    I Fetch All Replay Channels From Linear Service
    ${response}    Get Replay Catalog Programs   ${LAB_CONF}    ${profile_id}    ${OSD_LANGUAGE}    ${CITY_ID}    ${page}
    ${response_data}    set variable    ${response.json()}
    @{replay_assets_list}    Create List
    :FOR    ${asset}    IN     @{response_data['replayPrograms']}
    \    ${replay_asset}    Set Variable If   '${asset['type']}'=='${asset_type}' and (not ${asset['isAdult']})    ${asset}
    \    Continue For Loop If    ${replay_asset}==None
    \    ${is_valid_replay_event}    Run Keyword And Return Status    List Should Contain Value    ${replay_channels}    ${asset['channelId']}
    \    Run Keyword If    ${is_valid_replay_event}    Append To List    ${replay_assets_list}    ${replay_asset}
    ${is_not_empty}    Run Keyword And Return Status    Should Not Be Empty    ${replay_assets_list}
    Return From Keyword If    ${is_not_empty}==False    ${EMPTY}
    ${random_replay_asset}    Get Random Element From Array    ${replay_assets_list}
    [Return]   ${random_replay_asset}

I Get Replay Catalogue Program  #USED
    [Arguments]    ${asset_type}
    [Documentation]    This keyword fetch program tile from replay catalog based on type of asset e.g. asset/show.
    :FOR    ${page}     IN RANGE    1    100
    \    ${replay_event}    Fetch Replay Catalogue Program    ${asset_type}    ${page}
    \    ${is_not_empty}    Run Keyword And Return Status    Should Not Be Empty    ${replay_event}
    \    Exit For Loop If     ${is_not_empty}
    ${failedReason}    Set Variable If    ${replay_event}    ${EMPTY}    Unable to fetch replay asset title from Replay Catalog Service.
    Should Be Empty    ${failedReason}
    [Return]   ${replay_event}

Get Event Metadata Segment For Yesterday And Today    #USED
    [Documentation]    This keyword returns the event metadata segment and channel number (hash value).
    ...    This keyword ensures that the channel is trickplay enabled and epg data is also available for the same.
    [Arguments]    ${replay_source}=cloud
    ${replay_channels}    I Fetch All Replay Channels From Linear Service    ${replay_source}
    :FOR    ${channel}    IN    @{replay_channels}
    \    ${channel_id}    Get Random Element From Array    ${replay_channels}
    \    ${is_trickplay_enabled}    Check Linear Channel Is Trickplay Enabled    ${channel_id}
    \    Continue For Loop If    not ${is_trickplay_enabled}
    \    Exit For Loop If    ${is_trickplay_enabled}
    ${replay_channel_number}    Get Channel Number By Id    ${CITY_ID}    ${channel_id}    ${OSD_LANGUAGE}    ${CPE_PRODUCT_CLASS}
    ${epg_index}    Get Index Of Event Metadata Segments
    ${epg_data}    Set Variable    ${epg_index.json()}
    @{hash_list}    Create List
    :FOR   ${entries}    IN    @{epg_data['entries']}
    \    ${channel}    Set Variable    ${entries['channelIds'][0]}
    \    Continue For Loop If    '${channel}' != '${channel_id}'
    \    Append To List    ${hash_list}    ${entries['segments'][7]}    ${entries['segments'][6]}
    \    Exit For Loop If    ${hash_list}
    [Return]    ${hash_list}    ${replay_channel_number}

Get Details Of Past Replay Events    #USED
    [Documentation]    This keyword fetches the list of past replay events
    ...   This keyword take an argument: events.
    ...   events: Events List from keyword:Get Event Metadata For A Particular Segment
    ...   This Keyword will return the list of past replay events
    [Arguments]    ${events}
    ${current_epoch_time}    Get Current Epoch Time
    @{past_replay_events}     Create List
    :FOR    ${event}    IN    @{events}
    \    ${end_time}    Get From Dictionary    ${event}    endTime
    \    ${is_past_event}    Set Variable If    ${end_time} < ${current_epoch_time}     ${True}    ${False}
    \    Exit For Loop If    not ${is_past_event}
    \    ${hasReplayTV}    Evaluate    ${event}.get("hasReplayTV", 'REPLAY')
    \    ${hasStartOver}    Evaluate    ${event}.get("hasStartOver", 'REPLAY')
    \    Continue For Loop If    '${hasReplayTV}' != 'REPLAY' or '${hasStartOver}' != 'REPLAY'
    \    Append To List    ${past_replay_events}    ${event}
    [Return]    ${past_replay_events}

Get Replay Event Details Based On Filters    #USED
    [Documentation]    This keyword fetches the list of past replay events based on the filters provided
    ...   This keyword take three argument: events, age_rated and duration
    ...   events: Events List from keyword:Get Event Metadata For A Particular Segment
    ...   age_rated: True/False
    ...   duration: duration of the replay event
    ...   This Keyword will return the list of past replay events
    [Arguments]    ${events}    ${age_rated}=False    ${duration}=600
    ${past_replay_events}    Get Details Of Past Replay Events    ${events}
    ${get_age}    Get application service setting    profile.ageLock
    Reverse List    ${past_replay_events}
    ${filtered_replay_event}    Set Variable    ${None}
    :FOR    ${event}    IN      @{past_replay_events}
    \    ${start_time}    Get From Dictionary    ${event}    startTime
    \    ${end_time}    Get From Dictionary    ${event}    endTime
    \    ${event_duration}    Evaluate    ${end_time} - ${start_time}
    \    Continue For Loop If    ${event_duration} < ${duration} or ${event_duration} > ${long_duration_event}
    \    ${isAdult}    Evaluate    ${event}.get("isAdult", False)
    \    Continue For Loop If    ${isAdult}!= False
    \    ${minimumAge}    Evaluate    ${event}.get("minimumAge", '0')
    \    Run Keyword If    '${age_rated}'=='True'    Continue For Loop If    '${minimumAge}'=='0' and '${minimumAge}' < '${get_age}'
    \    ${filtered_replay_event}    Set Variable    ${event}
    \    Exit For Loop If    ${filtered_replay_event}
    [Return]    ${filtered_replay_event}

Get Replay Event Metadata And Channel Number    #USED
    [Documentation]    This keyword returns the replay events and channel number and set the suite variable MAX_EVENT_LENGTH with length of events
    [Arguments]    ${age_rated}=False    ${duration}=600    ${replay_source}=cloud
    ${hash_list}    ${replay_channel}    Get Event Metadata Segment For Yesterday And Today    ${replay_source}
    ${max_event_length}    Set Variable    ${0}
    :FOR    ${hash}    IN    @{hash_list}
    \    ${epg_segment}    Get Event Metadata For A Particular Segment    ${hash}
    \    ${event_list}    Set Variable    ${epg_segment.json()['entries'][0]['events']}
    \    ${event_list_length}    Get Length    ${event_list}
    \    ${max_event_length}    Evaluate    ${max_event_length} + ${event_list_length}
    \    ${past_replay_event}    Get Replay Event Details Based On Filters    ${event_list}    ${age_rated}    ${duration}
    \    Exit For Loop If    ${past_replay_event}
    Set Suite Variable    ${MAX_EVENT_LENGTH}    ${max_event_length}
    [Return]    ${past_replay_event}    ${replay_channel}