*** Settings ***
Documentation     Keywords for ReplayCatalogService
Resource          ./LinearService_Implementation.robot


*** Keywords ***
I Fetch All IP Channels
    [Documentation]    This keyword returns the list of all ip channels.
    ${response}    Get All Channels Via LinearService
    ${ip_channels}    Return List Of IP Channels    ${response}
    ${failedReason}    Set Variable If    ${ip_channels}    ${EMPTY}    Unable to get all the ip channels
    Should Be Empty    ${failedReason}
    [Return]    ${ip_channels}

I Fetch Linear Channel List    #USED
    [Documentation]    This keyword fetches the all linear channels as a list
    ${linear_channels}    Get List Of Linear Channel Numbers Via Linear Service
    [Return]    ${linear_channels}

I Fetch Linear Channel List Filtered    #USED
    [Documentation]    This keyword fetches the all linear channels filtered by arguments as a list
    ...    By default NO radio, 4k, app or adult channels will by returned
    ...    ${type} can be 'id' or 'logicalChannelNumber' or 'name' so it will return the Channel ID or Channel Number
    ...    Example: I Fetch Linear Channel List Filtered    'name'
    [Arguments]    ${type}='id'    ${radio}=False    ${4k}=False    ${adult}=False    ${app}=False    ${resolution}=Any    ${is_subscribed}=True    ${is_replay}=${False}
    ${filtered_channel_list}    Get List Of Linear Channel Key Via Linear Service With Filters   ${type}    ${radio}    ${4k}    ${adult}    ${app}    ${resolution}    ${is_subscribed}    ${is_replay}
    [Return]    ${filtered_channel_list}

I Fetch Linear Channel Number List Filtered For Zapping    #USED
    [Documentation]    This keyword fetches the all linear channels with the next filter:
    ...    NO: radio, 4k, app or adult channels will by returned and Stored on Suite var: ${FILTERED_CHANNEL_LIST}
    ...    ${type} should be 'logicalChannelNumber'
    ${filtered_channel_list}    Get List Of Linear Channel Key Via Linear Service With Filters   'logicalChannelNumber'    radio=False    4k=False    adult=False    app=False
    ...    is_subscribed=True
    Set Suite Variable    ${FILTERED_CHANNEL_LIST}    ${filtered_channel_list}

I Fetch HD Linear Channel Number List Filtered For Zapping    #USED
    [Documentation]    This keyword fetches the all linear channels with the next filter:
    ...    NO: radio, 4k, app or adult channels will by returned and Stored on Suite var: ${FILTERED_CHANNEL_LIST}
    ...    ${type} should be 'logicalChannelNumber'
    ${filtered_channel_list}    Get List Of Linear Channel Key Via Linear Service With Filters   'logicalChannelNumber'    radio=False    4k=False    adult=False    app=False
    ...    resolution=HD    is_subscribed=True
    set suite variable    ${FILTERED_CHANNEL_LIST}    ${filtered_channel_list}

I Fetch One Random Linear Channel Number From List Filtered For Zapping    #USED
    [Documentation]    This keyword fetch ONE Random linear channel filtered
    ...   Prerequisites: I Fetch Linear Channel Number List Filtered For Zapping needs to be run first
    ...   so ${FILTERED_CHANNEL_LIST} exist
    variable should exist    ${FILTERED_CHANNEL_LIST}    FILTERED_CHANNEL_LIST variable should be passed as suite var
    ${channel_number}    Get Random Element From Array    ${FILTERED_CHANNEL_LIST}
    [Return]     ${channel_number}

I Fetch All Replay Channels From Linear Service    #USED
    [Documentation]    This keyword returns list of all replay enabled channels which aren't 4K, App bound, Adult or Radio.
    [Arguments]    ${replay_source}=cloud
    ${response}    Get All Channels Via LinearService
    ${replay_channels}    Get All Replay Channels Via Linear Service    ${response}    True    ${True}    ${replay_source}
    ${failedReason}    Set Variable If    ${replay_channels}    ${EMPTY}    Unable to get replay channels from linear service
    Should Be Empty    ${failedReason}
    set suite variable    ${ALL_REPLAY_CHANNELS}    ${replay_channels}
    [Return]    ${replay_channels}

I Fetch All 4K Channels From Linear Service
    [Documentation]    This keyword returns list of all 4K channels.
    ${response}    Get All Channels Via LinearService
    ${4K_channels}    Get All 4K Channels From Linear Service    ${response}
    ${failedReason}    Set Variable If    ${4K_channels}    ${EMPTY}    Unable to get 4K channels from linear service
    Should Be Empty    ${failedReason}
    [Return]    ${4K_channels}

I Fetch All Adult Channels From Linear Service
    [Documentation]    This keyword returns list of all Adult channels.
    ${response}    Get All Channels Via LinearService
    ${adult_channels}    Get All Adult Channels From Linear Service    ${response}
    ${failedReason}    Set Variable If    ${adult_channels}    ${EMPTY}    Unable to get adult channels from linear service
    Should Be Empty    ${failedReason}
    [Return]    ${adult_channels}

I Fetch All Watershed Compliant Channels From Linear Service    #USED
    [Documentation]    This keyword returns list of all Watershed Compliant channels.
    ${response}    Get All Channels Via LinearService
    ${watershed_compliant_channels}    Get All Watershed Compliant Channels From Linear Service    ${response}
    ${failedReason}    Set Variable If    ${watershed_compliant_channels}    ${EMPTY}    Unable to get watershed_compliant_channels from linear service
    Should Be Empty    ${failedReason}
    [Return]    ${watershed_compliant_channels}

I Fetch All Autostart App Bound Channels From Linear Service    #USED
    [Documentation]    This keyword returns list of all Autostart App Bound channels id or logicalChannelNumber.
    ...    ${type} can be 'id' or 'logicalChannelNumber'
    [Arguments]    ${type}='id'
    ${response}    Get All Channels Via LinearService
    ${app_bound_autostart_channels}    Get All Autostart App Bound Channels From Linear Service    ${response}    ${type}
    ${failedReason}    Set Variable If    ${app_bound_autostart_channels}    ${EMPTY}    Unable to get App Bound Autostart channels from linear service
    Should Be Empty    ${failedReason}
    set suite variable    ${APP_BOUND_AUTOSTART_CHANNELS}    ${app_bound_autostart_channels}
    [Return]    ${app_bound_autostart_channels}

I Fetch All C2A App Bound Channels From Linear Service
    [Documentation]    This keyword returns list of all Call to Action App Bound channels.
    [Arguments]    ${type}='id'
    ${response}    Get All Channels Via LinearService
    ${app_bound_c2a_channels}    Get All C2A App Bound Channels From Linear Service    ${response}    ${type}
    ${failedReason}    Set Variable If    ${app_bound_c2a_channels}    ${EMPTY}    Unable to get app bound c2a channels from linear service
    Should Be Empty    ${failedReason}
    [Return]    ${app_bound_c2a_channels}

I Fetch All Radio Channels From Linear Service    #USED
    [Documentation]    This keyword returns list of all Radio channels.
    ${response}    Get All Channels Via LinearService
    ${radio_channels}    Get All Radio Channels From Linear Service    ${response}
    ${failedReason}    Set Variable If    ${radio_channels}    ${EMPTY}    Unable to get radio channels from linear service
    Should Be Empty    ${failedReason}
    [Return]    ${radio_channels}

I Fetch All Unsubscribed Channels   #USED
    [Documentation]  The keyword gets all the unsubscribed channels via linear service
    ${filtered_channel_list}    Get List Of Linear Channel Key Via Linear Service With Filters   'logicalChannelNumber'    radio=False    4k=False    adult=False    app=False
    ...    resolution=Any    is_subscribed=False
    [Return]    ${filtered_channel_list}

I Tune To Random Linear Channel     #USED
     [Documentation]    This keyword tunes to a random linear channel.
     I Fetch Linear Channel Number List Filtered For Zapping
     ${channel_number}       I Fetch One Random Linear Channel Number From List Filtered For Zapping
     I Tune To Channel    ${channel_number}

I Fetch Linear Channel Number List Filtered For EPG From Linear Service    #USED
    [Documentation]    This keyword fetches the all linear channels with the next filter:
    ...    NO: radio, 4k, app or adult channels will by returned and Stored on Suite var: ${FILTERED_CHANNEL_LIST}
    ...    ${type} should be 'logicalChannelNumber'
    ${filtered_channel_list}    Get List Of Linear Channel Key Via Linear Service With Filters   'logicalChannelNumber'    False    True    True    True
    ${FILTERED_CHANNEL_LIST}    Remove Duplicates   ${filtered_channel_list}
    Set Suite Variable    ${FILTERED_CHANNEL_LIST}    ${FILTERED_CHANNEL_LIST}
    log   FILTERED_CHANNEL_LIST:\n${FILTERED_CHANNEL_LIST}

I Check If Channel Number Is Autostart App Bound Channel From Linear Service   #USED
    [Arguments]    ${channel_number}    ${app_bound_autostart_channels}=${APP_BOUND_AUTOSTART_CHANNELS}
    [Documentation]    Verifies that The channel number is a app or not app channel
    ${is_app_channel}    Check Element Present In List    ${channel_number}    ${app_bound_autostart_channels}
    run keyword if   ${is_app_channel}    log    APP channel Found - channel: ${channel_number}
    [Return]    ${is_app_channel}

I Tune To Random Adult Channel    #USED
    [Documentation]    This keyword tunes to a random adult channel
    ${adult_channels}    I Fetch All Adult Channels From Linear Service
    ${channel_visited}    Run Keyword And Return Status    Variable Should Exist    ${LAST_VISITED_ADULT_CHANNEL}
    Run Keyword If    ${channel_visited}    Remove Values From List    ${adult_channels}    ${LAST_VISITED_ADULT_CHANNEL}
    ${adult_channel_to_tune}    Get Random Element From Array    ${adult_channels}
    ${adult_channel_to_tune}  Convert To String  ${adult_channel_to_tune}
    I Tune To Channel    ${adult_channel_to_tune}
    Set Suite Variable    ${LAST_VISITED_ADULT_CHANNEL}    ${adult_channel_to_tune}

I Tune To Random Linear Channel With Genre And Subgenre    #USED
     [Documentation]    This keyword tunes to a random linear channel which plays an event that has genre and subgenre.
     I Fetch Linear Channel Number List Filtered For Zapping
     @{relevent_channel_list}    Create List
     :FOR    ${channel}   IN    @{FILTERED_CHANNEL_LIST}
     \    ${channel_id}    Get channel ID using channel number    ${channel}
     \    @{current_event}    Get current channel event via as    ${channel_id}
     \    ${current_event_details}    Get Details Of An Event Based On Event ID    ${current_event[0]}
     \    ${asset_genres}    Extract value for key    ${current_event_details}    ${EMPTY}    genres
     \    ${number_of_genres}    Get Length    ${asset_genres}
     \    Run Keyword If       ${number_of_genres}>1        Append To List    ${relevent_channel_list}    ${channel}
    Log     ${relevent_channel_list}
    Set Suite Variable    ${FILTERED_CHANNEL_LIST}    ${relevent_channel_list}
    ${channel_number}       I Fetch One Random Linear Channel Number From List Filtered For Zapping
    I tune to channel    ${channel_number}

I Select A Channel With Genre    #USED
    [Documentation]    This keyword selects a random channel from a list of channels with genre and set the genre of selected
    ...    channel as suite variable
    ${channels_with_genre}    Get All Channels With Genre
    Should Be True      len(${channels_with_genre})>${0}    No channel with genre found
    ${selected_channel_with_genre}    Evaluate  random.choice(${channels_with_genre})  random
    ${genre}    Evaluate  random.choice(${selected_channel_with_genre['genre']})  random
    Set Suite Variable    ${genre}    ${genre}
    Set Suite Variable    ${selected_channel_with_genre}    ${selected_channel_with_genre['logicalChannelNumber']}
    Log    ${selected_channel_with_genre}

I Fetch Current Event Title Of A Random 4K Channel    #USED
    [Documentation]    This keyword fetches current event title of a random 4K channel.
    ${channels}    I Fetch All 4K Channels From Linear Service
    ${channel}    Get Random Element From Array    ${channels}
    ${data}   Get current channel event via as    ${channel}
    ${current_event_details}    Get Details Of An Event Based On Event ID    ${data[0]}
    Set Suite Variable     ${LAST_FETCHED_DETAILS_PAGE_DETAILS}    ${current_event_details}
    [Return]    ${current_event_details}

I Get All Genres Of Available TV Channels    #USED
    [Documentation]    This keyword gets the list of all genres of the available tv channels from backend and return it
    ${channels_with_genre}    Get All Channels With Genre
    ${genres_and_their_corresponding_channels}    Get All Genres And Their Corresponding Channels    ${channels_with_genre}
    ${all_genres_from_backend}    Get Dictionary Keys    ${genres_and_their_corresponding_channels}
    [Return]    ${all_genres_from_backend}

I Get All Channels Of A Genre    #USED
    [Documentation]    This keyword gets dictionary of genres and their corresponding channels and selects a random genre
    ...    and its corresponding channels and return genre and channels
    ${channels_with_genre}    Get All Channels With Genre
    ${genres_and_their_corresponding_channels}    Get All Genres And Their Corresponding Channels    ${channels_with_genre}
    ${genres_list}    Get Dictionary Keys    ${genres_and_their_corresponding_channels}
    ${genre}    Evaluate  random.choice(${genres_list})  random
    ${channels_of_genre}    Get From Dictionary    ${genres_and_their_corresponding_channels}    ${genre}
    ${channels_of_genre}    Remove Duplicates     ${channels_of_genre}
    [Return]    ${genre}    ${channels_of_genre}

I Get A Random Adult Channel    #USED
    [Documentation]    This Keyword Gets An Adult Channel From Linear Service
    ${adult_channels}    I Fetch All Adult Channels From Linear Service
    ${adult_channel}    Get Random Element From Array    ${adult_channels}
    ${adult_channel_in_string}    Convert To String    ${adult_channel}
    Should Not Be Empty    ${adult_channel_in_string}    Unable To Get An Adult Channel From Linear Service
    [Return]    ${adult_channel}

I Get A Random Radio Channel    #USED
    [Documentation]    This keyword retrieves list of ID and name of Radio Channels, select one randomly and retrieves the
    ...    Channel Number of that random Channel ID selected
    ...    [Return]   Channel Number of a random Radio Channel
    ${radio_channels}    I Fetch All Radio Channels From Linear Service
    @{radio_channel_ids}    Get Dictionary Keys    ${radio_channels}
    Should Not Be Empty    ${radio_channel_ids}    Unable To Get A Radio Channel From Linear Service
    ${channel_id}    Get Random Element From Array     ${radio_channel_ids}
    ${channel_number}    Get Channel Number By Id    ${CITY_ID}    ${channel_id}    ${OSD_LANGUAGE}    ${CPE_PRODUCT_CLASS}
    [Return]    ${channel_number}

I Fetch Random Watershed Compliant Channel With Filters    #USED
    [Documentation]    This keyword returns list of all Watershed Compliant channels with filters.
    ${watershed_compliant_channels}    I Fetch All Watershed Compliant Channels From Linear Service
    ${filtered_channels}    Get List Of Linear Channel Key Via Linear Service With Filters    'logicalChannelNumber'
    @{filtered_channel_numbers}    Create List
    :FOR    ${channel}    IN    @{filtered_channels}
    \    ${channel_num}   Convert To Integer    ${channel}
    \    ${status}    Run Keyword And Return Status    List Should Contain Value    ${watershed_compliant_channels}    ${channel_num}
    \    Run Keyword If   ${status}    Append To List    ${filtered_channel_numbers}    ${channel}
    ${failedReason}    Set Variable If    ${filtered_channel_numbers}    ${EMPTY}    Unable to get watershed_compliant_channels from linear service with filters
    Should Be Empty    ${failedReason}
    ${random_channel_number}    Get Random Element From Array    ${filtered_channel_numbers}
    [Return]    ${random_channel_number}

I Check If Channel Is Watershed Compliant    #USED
    [Documentation]  This keyword checks if the given channel is watershed compliant or not
    [Arguments]    ${channel_id}
    ${is_watershed_compliant}    Check If Channel Is Watershed Compliant    ${channel_id}
    [Return]    ${is_watershed_compliant}

I Assess Appearance Of Age Lock And Pin Entry Popup According To Watershed Implementation    #USED
    [Documentation]    This keyword checks whether pin entry popup and age lock will be shown for events with a channel ID
    ...    For watershed compliant channels, linear events never require PIN or show age lock. For other features except replay over VOD
    ...    event broadcast time (here given by event_start_time in HH:MM format) watershed lane is compared to current (UK) time watershed lane.
    ...    Pin entry and age lock are shown only when current watershade lane is less than broadcast time watershed lane.
    ...    For watershed non-compliant channels, current watershed age rating is compared with asset age rating.
    ...    If current watershed lane is BTS4 (22.00-5.29), no assets will show age rating. Applies for all features
    ...    For tenants other than GB, this keyword will have no effect.
    [Arguments]    ${asset_type}    ${channel_id}    ${event_start_time}    ${event_age_rating}
    Assess Appearance Of Age Lock And Pin Entry Popup According To Watershed Implementation    ${asset_type}
    ...    ${channel_id}    ${event_start_time}    ${event_age_rating}

#***************************CPE PERFORMANCE*****************************************************
I Fetch All App Bound Channels ID From Linear Service    #USED
    [Documentation]    This keyword returns list of all  App Bound channels.
    [Arguments]     ${property}=id
    ${channel_lineup_response}    Get All Channels Via LinearService
    @{app_bound_channels}    Create List

    :FOR    ${channel}    IN    @{channel_lineup_response}
    \    ${app_source}    set variable    ${False}
    \    ${boundApps}    Evaluate    ${channel}.get("boundApps", False)
    \    ${replay_sources}    Extract Value For Key    ${channel}    ${EMPTY}    replaySources
    \    ${app_source}    run keyword if    ${replay_sources}
    \    ...    set variable if     "app" in ${replay_sources}    ${True}    ${False}
    \    ...    ELSE    set variable      ${False}
    \    Continue For Loop If   ${app_source} == False and ${boundApps} == False
    \    ${channel_data}    Extract Value For Key    ${channel}    ${EMPTY}    ${property}
    \    ${channel_data}    convert to string    ${channel_data}
    \    Append To List    ${app_bound_channels}    ${channel_data}
    [Return]    ${app_bound_channels}

I Fetch All Channel ID for given Logical Channel Number
    [Documentation]     Returns all the channel ids matching the given logical channel number
    [Arguments]    ${channel_number}
    @{channel_id_list}    Create List
    ${channel_lineup_response}    Get All Channels Via LinearService
    :FOR    ${channel_json}    IN    @{channel_lineup_response}
    \    ${logicalChannelNumber}    Extract Value For Key    ${channel_json}    ${EMPTY}    logicalChannelNumber
    \    Continue For Loop If    ${logicalChannelNumber} != ${channel_number}
    \    ${channel_id}    Extract Value For Key    ${channel_json}    ${EMPTY}    id
    \    Append To List    ${channel_id_list}    ${channel_id}
    [Return]    ${channel_id_list}

Return List Of QAM Channels
    [Documentation]    This keyword returns list of all QAM channels based on subscription.
    ${channel_lineup_response}    Get All Channels Via LinearService
    ${qam_channel_list}    Get Qam Channel List    ${channel_lineup_response}
    ${qam_channel_list}   Filter Channels Based On Subscription    ${qam_channel_list}    ${channel_lineup_response}
    ...   ${True}    ${False}
    [Return]  ${qam_channel_list}

Get channel with '${event_type}' event
    [Documentation]   Return channel with the given type.
    ...   :@param event_type: 'single' or 'series'
    ${fetch_required}    run keyword and return status    variable should not exist   ${ALL_REPLAY_CHANNELS}
    ${replay_channels}    Run keyword if   ${fetch_required}   I Fetch All Replay Channels From Linear Service
    ...    ELSE    Set Variable    ${ALL_REPLAY_CHANNELS}
    Log   ${replay_channels}
    ${length}    Get Length    ${replay_channels}
    ${timestamp}    robot.libraries.DateTime.get current date    result_format=%Y-%m-%d %H:%M:%S
    ${timestamp}    DateTime.Convert date    ${timestamp}    epoch
    ${timestamp}    Convert to integer    ${timestamp}
    ${channel_found}  set variable  False
    :FOR    ${index}    in RANGE      ${length}
    \    ${channel_id}    Get Random Element From Array    ${replay_channels}
    \    ${events}    Get channel events via As    ${STB_IP}    ${CPE_ID}    ${channel_id}    ${timestamp}    events_before=0
    \    ...    events_after=0    xap=${XAP}
    \    ${channel_event_type}    evaluate   'series' if 'seriesId' in ${events}[0] else 'single'
    \    ${channel_found}  set variable if   '${channel_event_type}'=='${event_type}'   ${channel_id}   False
    \    exit for loop if  '${channel_found}' != 'False'
    should be true  '${channel_found}' != 'False'    No ${event_type} channel found
    ${channel_lcn}    get channel lcn for channel id    ${channel_found}
    [Return]   ${channel_lcn}

I Fetch App Name for given Logical Channel Number
    [Documentation]     Returns all the channel ids matching the given logical channel number
    [Arguments]    ${channel_number}
    ${channel_name}    set variable
    ${channel_lineup_response}    Get All Channels Via LinearService
    :FOR    ${channel_json}    IN    @{channel_lineup_response}
    \    ${logicalChannelNumber}    Extract Value For Key    ${channel_json}    ${EMPTY}    logicalChannelNumber
    \    Continue For Loop If    ${logicalChannelNumber} != ${channel_number}
    \    ${channel_name}    Extract Value For Key    ${channel_json}    ${EMPTY}    name
    \    ${channel_name}    Remove String    ${channel_name}    .
    \    log to console  ${channel_name}
    [Return]    ${channel_name}