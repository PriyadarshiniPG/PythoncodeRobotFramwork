*** Settings ***
Documentation     TV Guide Implementation keywords
Resource          ../Common/Common.robot
Resource          ../CommonPages/ValuePicker_Implementation.robot
Resource          ../PA-04_User_Interface/ChannelBar_Keywords.robot
Resource          ../PA-04_User_Interface/MainMenu_Keywords.robot
Resource          ../PA-05_Linear_TV/LinearDetailsPage_Keywords.robot
Resource          ../PA-05_Linear_TV/TeleText_Keywords.robot
Library           Libraries.MicroServices.LinearService.LinearService

*** Variables ***
${PIG_PLAYER_WIDTH}    320

*** Keywords ***
Get Focused Guide Programme Cell Details
    [Documentation]    Keyword retrieves details (event_text, event_id) for highlighted event
    ${focus_json}    Get Ui Focused Elements
    ${event_id}    Extract Value For Key    ${focus_json}    id:block_\\d+_event_\\d+_\\d+    id    ${True}
    Should not be Empty    ${event_id}    Could not find the details of the focused Programme
    ${event_text}    Extract Value For Key    ${focus_json}    id:${event_id}    textValue
    &{highlighted_event}    Create Dictionary    event_text=${None}    event_id=${None}
    Set To Dictionary    ${highlighted_event}    event_text    ${event_text}
    Set To Dictionary    ${highlighted_event}    event_id    ${event_id}
    [Return]    ${highlighted_event}

Get Focused Guide Programme Cell Channel Number    #USED
    [Documentation]    Retrieves the channel of the currently focused event
    ${focus_json}    Get Ui Focused Elements
    ${focused_channel_block}    Extract Value For Key    ${focus_json}    id:block_\\d+_channel_\\d+    id    ${True}
    ${json_object}    Get Ui Json
    ${channel_number}    Extract Value For Key    ${json_object}    id:${focused_channel_block}_text    textValue
    Should not be Empty    ${channel_number}    Could not find the channel of the focused Programme
    [Return]    ${channel_number}

Get Focused Guide Programme Cell Channel Logo    #USED
    [Documentation]    Retrieves the channel logo of the currently focused event
    ${focus_json}    Get Ui Focused Elements
    ${focused_channel_block}    Extract Value For Key    ${focus_json}    id:block_\\d+_channel_\\d+    id    ${True}
    ${json_object}    Get Ui Json
    ${channel_logo}    Extract Value For Key    ${json_object}    id:${focused_channel_block}_logo    url
    Should not be Empty    ${channel_logo}    Could not find the channel logo of the focused Programme
    [Return]    ${channel_logo}

Verify Title Of Unsubscribed Event Shown In EPG Info Panel   #USED
    [Documentation]    This keyword verifies title is shown in EPG info panel
    ${title_shown}  Run keyword and return status    Wait Until Keyword Succeeds    10 times    1 s    I expect page element 'id:gridInfoTitle' contains 'textValue:^.+$' using regular expressions
    Should be True    ${title_shown}    Title shown in EPG info panel

Verify Synopsis Of Unsubscribed Event Not Shown In EPG Info Panel  #USED
    [Documentation]    This keyword verifies synopsis is shown in EPG info panel
     ${synopsis_shown}    Run keyword and return status    Wait Until Keyword Succeeds    10 times    1 s    I expect page element 'id:gridInfoSynopsis' contains 'textValue:^.+$' using regular expressions
    Should Not Be True    ${synopsis_shown}    Synopsis shown in EPG info panel

Verify Primary Metadata Of Unsubscribed Event Shown In EPG Info Panel  #USED
    [Documentation]    This keyword verifies primary metadata of unsubscribed event shown in EPG info panel
    ${ui_json}    Get Ui Json
    ${info_panel}    Extract Value For Key    ${ui_json}    id:gridInfoPanel    children
    ${validator_1}   Is In Json    ${info_panel}    id:rcuCueGuide    textKey:DIC_RC_CUE_SUBSCRIBE_CHANNEL
    ${validator_2}   Is In Json    ${info_panel}    id:rcuCueGuide    iconKeys:OK
    ${validated}    Set Variable If    ${validator_1} and ${validator_2}    True    False
    Should Be True    ${validated}    unlock text is not shown

I retrieve Info panel title element    #USED
    [Documentation]    This keyword retrieves the grid Info panel title element text value and returns it
    wait until keyword succeeds    ${JSON_MAX_RETRIES}    ${JSON_RETRY_INTERVAL}    I expect page element 'id:guideInfoPanelTitle' contains 'textValue:^.+$' using regular expressions
    ${grid_info_title_element}    I retrieve value for key 'textValue' in element 'id:guideInfoPanelTitle'
    [Return]    ${grid_info_title_element}

I Retrieve Synopsis From EPG Info Panel    #USED
    [Documentation]    This keyword retrieves the synopsis from EPG info panel
    Wait Until Keyword Succeeds And Verify Status    ${JSON_MAX_RETRIES}    ${JSON_RETRY_INTERVAL}    Synopsis is not present in EPG Info Panel    I expect page element 'id:gridInfoSynopsis' contains 'textValue:^.+$' using regular expressions
    ${grid_info_synopsis}    I retrieve value for key 'textValue' in element 'id:gridInfoSynopsis'
    Should Not Be Empty    ${grid_info_synopsis}    Synopsis is empty in EPG Info Panel
    [Return]    ${grid_info_synopsis}

Get focused event hours in the tv guide
    [Documentation]    This keyword returns the hours for the focused guide event
    ${json_object}    Get Ui Json
    ${ancestor}    Get Enclosing Json    ${json_object}    ${EMPTY}    id:detailedInfogridPrimaryMetadata    ${1}
    @{regexp_match}    Get Regexp Matches    ${ancestor['textValue']}    ^.*(\\d{2}:\\d{2} ?- ?\\d{2}:\\d{2}).*$    1
    ${hours}    Set Variable    ${regexp_match[0]}
    [Return]    ${hours}

Get current hours in the tv guide
    [Documentation]    This keyword returns the current hours value from the clock in the tv guide
    ${hours}    I retrieve value for key 'textValue' in element 'id:mastheadTime'
    [Return]    ${hours}

Get currently tuned and focused channel numbers
    [Documentation]    Checks that TV guide page changes for CH(- or +)x1 for channel numbers navigation in EPG Area
    ${currently_tuned}    Get current channel number
    ${channel_number_focused}    Get Focused Guide Programme Cell Channel Number
    @{regexp_match}    Get Regexp Matches    ${currently_tuned}    (\\d+)
    ${currently_tuned}    Convert To Integer    ${currently_tuned}
    ${currently_tuned}    Set Variable    @{regexp_match}
    @{regexp_match}    Get Regexp Matches    ${channel_number_focused}    (\\d+)
    ${channel_number_focused}    Convert To Integer    ${channel_number_focused}
    ${channel_number_focused}    Set Variable    @{regexp_match}
    [Return]    ${currently_tuned}    ${channel_number_focused}

I open Day Filter from Guide
    [Documentation]    Open the guide then open the Day Filter
    I open Guide through the remote button
    I open Day Filter

I open Day Filter
    [Documentation]    Focus the day filter then open it
    I focus Day Filter
    I press    OK
    Day Filter list is shown

Day Filter list is shown
    [Documentation]    Check that the day filter is present on screen
    wait until keyword succeeds    ${JSON_MAX_RETRIES}    ${JSON_RETRY_INTERVAL}    I expect page element 'id:picker-item-text-\\\\d+' contains 'textKey:DIC_GENERIC_AIRING_DATE_.*' using regular expressions

Day filter is focused
    [Documentation]    Checks if Day filter is focused
    wait until keyword succeeds    ${JSON_MAX_RETRIES}    ${JSON_RETRY_INTERVAL}    I expect page element 'id:gridNavigation_filterButton_0' contains 'color:${INTERACTION_COLOUR}'

Read current event time from Info Panel
    [Documentation]    Returns the time information of current event.
    ...    Precondition: Info Panel is open
    wait until keyword succeeds    ${JSON_MAX_RETRIES}    ${JSON_RETRY_INTERVAL}    I expect page element 'id:detailedInfogridPrimaryMetadata' contains 'textValue:^.+$' using regular expressions
    ${event_info}    I retrieve value for key 'textValue' in element 'id:detailedInfogridPrimaryMetadata'
    @{event_info}    split string    ${event_info}    •
    ${event_info}    strip string    @{event_info}[0]
    [Return]    ${event_info}

I Check If EPG Event Info Is Available    #USED
    [Documentation]    Checks if event info is on screen by called EPG Event Info Is Available
    wait until keyword succeeds    3times    2 sec    EPG Event Info Is Available

Guide has moved horizontally
    [Documentation]    This keyword check if the guide moved horizontally (on the right or on the left)
    ...    The test looks if any Guide grid block moved horizontally
    ...    Precondition: It needs ${PREVIOUS_GRID_EVENT_BLOCK} variable to be initialised by the keyword calling it
    Variable should exist    ${PREVIOUS_GRID_EVENT_BLOCK}    Test var PREVIOUS_GRID_EVENT_BLOCK has not previously been set
    ${current_grid_event_block}    Get current grid events block
    ${result}    Evaluate    True if '${current_grid_event_block}' != '${PREVIOUS_GRID_EVENT_BLOCK}' else False
    set test variable    ${PREVIOUS_GRID_EVENT_BLOCK}    ${current_grid_event_block}
    [Return]    ${result}

I focus future event in the tv guide after scroll
    [Documentation]    This keyword focuses on a future event that is not yet visible on screen
    ...    It then waits for the Guide to scroll horizontally
    ${PREVIOUS_GRID_EVENT_BLOCK}    Get current grid events block
    set test variable    ${PREVIOUS_GRID_EVENT_BLOCK}
    : FOR    ${index}    IN RANGE    30
    \    I Press    RIGHT
    \    Wait Until Keyword Succeeds    10    200ms    Assert Json changed    ${LAST_FETCHED_JSON_OBJECT}
    \    ${moved_horizontally}    Guide has moved horizontally
    \    Exit for loop if    ${moved_horizontally}
    Should be True    ${moved_horizontally}    We have not moved horizontally

Get current grid events block
    [Documentation]    This keyword gets the id of current grid events block present in Guide view
    ...    Precondition: Should be in Guide view
    ${focused_element}    Get Ui Focused Elements
    ${focused_event_id}    Extract Value For Key    ${focused_element}    id:block_\\d+_event_\\d+_\\d+    id    ${True}
    ${json_object}    Get Ui Json
    ${ancestor}    Get Enclosing Json    ${json_object}    ${EMPTY}    id:${focused_event_id}    ${2}    ${EMPTY}
    ${current_grid_event_block}    Extract Value For Key    ${ancestor}    id:gridEventsBlock\\d+    id    ${True}
    [Return]    ${current_grid_event_block}

PiG is available    #USED
    [Documentation]    This keyword verifies that the PIG Area is available when EPG is invoked
    ...    Check for nonexistence of element 'id:GuideMiniTVLockIcon' within 'id:GuideMiniTVPanel' and we can deduce
    ...    that PiG is playing some content. If 'id:GuideMiniTVLockIcon' is present, then it means PiG is tuned to a locked channel
    ${player_json}    Get Player Json
    ${json_object}    Get Ui Json
    ${player_width}    Extract Value For Key    ${player_json}    ${EMPTY}    width
    ${miniTV_is_present}    Evaluate    ${player_width} == ${PIG_PLAYER_WIDTH}
    ${pig_content_is_locked}    Is In Json    ${json_object}    id:GuideMiniTVPanel    id:GuideMiniTVLockIcon    ${EMPTY}
    should be true    ${miniTV_is_present}    PiG is not playing
    should be true    ${pig_content_is_locked}==${False}    PiG content is locked

Metadata in Guide highlighted programme cell is correct for channel
    [Arguments]    ${channel_in_use}
    [Documentation]    Verifies that what's being displayed in the highlighted program cell matches traxis metadata
    Current event is focused
    ${highlighted_event}    Get Focused Guide Programme Cell Details
    ${highlighted_event_title}    convert to lowercase    ${highlighted_event['event_text']}
    ${channel_id}    Get channel ID using channel number    ${channel_in_use}
    @{event_info}    get current event    ${channel_id}    ${CPE_ID}
    ${event_info_details}    Split string    ${event_info[0]}    ,
    ${event_id}    set variable    ${event_info_details[0]}
    ${event_details}    get traxis event details    ${event_id}
    ${event_details_json}    evaluate    json.loads('''${event_details}''')    json
    ${event_title_traxis}    set variable    ${event_details_json['Title']['Name'].strip()}
    ${event_title_traxis}    convert to lowercase    ${event_title_traxis}
    Should be equal    ${highlighted_event_title}    ${event_title_traxis}    The displayed title doesn't match what Traxis is returning

Metadata In Guide Highlighted Channel Cell Is Correct For Channel    #USED
    [Arguments]    ${channel_in_use}
    [Documentation]    Verifies that what's being displayed in the highlighted channel
    ${displayed_channel_number}    Get Focused Guide Programme Cell Channel Number
    Should be equal as integers    ${displayed_channel_number}    ${channel_in_use}    The displayed channel number and the channel in use are not equal

Guide Info Panel Has Correct Metadata For Channel    #USED
    [Arguments]    ${channel_in_use}
    [Documentation]    Verifies that what's being displayed in the info panel matches traxis metadata
    I Check If EPG Event Info Is Available
    ${adult_event}    Check EPG Adult Channel or Programme
    run keyword if   ${adult_event}    log    WARN: Info Panel Data NOT present as: Adult Channel/Programme Found - channel: ${channel_in_use} - Continue
    Return From Keyword If    ${adult_event}    Adult Channel/Programme Found so EPG No Info Panel Check - Continue
    ${app_channel}    I Check If Channel Number Is Autostart App Bound Channel From Linear Service    ${channel_in_use}    ${APP_BOUND_AUTOSTART_CHANNELS}
    run keyword if   ${app_channel}    log    WARN: Info Panel Data NOT present as: APP Channel Found: ${channel_in_use} - Continue
    Return From Keyword If    ${app_channel}    APP Channel so EPG No Info Panel Check - Continue
    ${unsubscribe_channel}    Check EPG Unsubscribed Channel
    run keyword if   ${unsubscribe_channel}    log    WARN: Info Panel Data NOT present as: Unsubscribed Channel Found - channel: ${channel_in_use} - Continue
    Return From Keyword If    ${unsubscribe_channel}    Unsubscribed Channel Found so EPG No Info Panel Check - Continue
    ${json_object}    Get Ui Json
    ${ancestor_title}    Get Enclosing Json    ${json_object}    ${EMPTY}    id:gridInfoTitle    ${1}
    ${displayed_title}    Set Variable    ${ancestor_title['textValue']}
    log    epeg_event_gridpanel_displayed_title: ${displayed_title}
    ${ancestor_detailed_primary_metadata}    Get Enclosing Json    ${json_object}    ${EMPTY}    id:detailedInfogridPrimaryMetadata    ${1}
    ${ancestor_synopsis}    Get Enclosing Json    ${json_object}    ${EMPTY}    id:gridInfoSynopsis    ${1}
    ${displayed_detailed_primary_metadata}    Set Variable    ${ancestor_detailed_primary_metadata['textValue']}
    @{displayed_start_end_time}    Get Regexp Matches    ${displayed_detailed_primary_metadata}    (\\d{2}:\\d{2}) ?- ?(\\d{2}:\\d{2})    1    2
    ${displayed_synopsis}    Set Variable    ${ancestor_synopsis['textValue']}
    ${channel_id}    Get channel ID using channel number    ${channel_in_use}
    ${timestamp}    Get Current Time In Epoch
    @{event_info}    get current event via as    ${STB_IP}    ${CPE_ID}    ${channel_id}    ${timestamp}    xap=${XAP}
    ${epg_event_info}    get event details from epg service    ${LAB_CONF}    ${COUNTRY}    ${OSD_LANGUAGE}    ${event_info[0]}    ${event_info[1]}    ${channel_id}
    ${epg_event_title}    Set variable    ${epg_event_info['title']}
    ${epg_event_start_time_epoch}    Set variable    ${epg_event_info['startTime']}
    ${epg_event_start_time_converted}    robot.libraries.DateTime.Convert Date    ${epg_event_start_time_epoch}
    @{epg_event_start_time}    Get Regexp Matches    ${epg_event_start_time_converted}    (\\d{2}:\\d{2}):00.000    1
    ${epg_event_end_time_epoch}    Set variable    ${epg_event_info['endTime']}
    ${epg_event_end_time_converted}    robot.libraries.DateTime.Convert Date    ${epg_event_end_time_epoch}
    @{epg_event_end_time}    Get Regexp Matches    ${epg_event_end_time_converted}    (\\d{2}:\\d{2}):00.000    1
    ${epg_event_short_description}    Set variable    ${epg_event_info['shortDescription']}
    Should Contain    ${displayed_title}    ${epg_event_title}    Displayed title doesn't match metadata
    Should be equal    @{displayed_start_end_time[0]}[0]    @{epg_event_start_time}[0]    Displayed start time doesn't match metadata
    Should be equal    @{displayed_start_end_time[0]}[1]    @{epg_event_end_time}[0]    Displayed end time doesn't match metadata
    Should be equal    ${displayed_synopsis}    ${epg_event_short_description}    Displayed synopsis doesn't match metadata

#Channel Is Focused In Guide    #USED
#    [Arguments]    ${channel_number}
#    [Documentation]    Checks that channel_number is focused in the guide
#    ${node_id}    I retrieve value for key 'id' in focused element 'id:block_.*_channel_.*' using regular expressions
#    ${json_object}    Get Ui Json
#    ${tv_guide_focus}    Extract Value For Key    ${json_object}    id:${node_id}_text    textValue
#    #${tv_guide_focus}    Extract Value For Key    ${json_object}    id:guideChannelNumber    textValue
#    Should be true    ${tv_guide_focus} == ${channel_number}    Error Focused TV Guide Channel Number not as expected: ${tv_guide_focus} is not ${channel_number}

Channel Is Focused In Guide    #USED
    [Arguments]    ${channel_number}
    [Documentation]    Checks that channel_number is focused in the guide
    ${node_id}    I retrieve value for key 'id' in focused element 'id:block_.*_channel_.*' using regular expressions
    Should Not Be Equal As Strings    ${node_id}    None    Channel Block element is not present in Guide focused Json
    ${children}    I retrieve value for key 'children' in element 'id:${node_id}'
    ${tv_guide_focus}    Extract Value For Key    ${children}    id:guideChannelNumber   textValue
    Should be true    ${tv_guide_focus} == ${channel_number}    Error Focused TV Guide Channel Number not as expected: ${tv_guide_focus} is not ${channel_number}

Get highlighted event time data
    [Documentation]    This keyword returns all time related data for the currently highlighted guide event
    ...    excluding the year (if present).
    ...    It stores the start and end times in test variables LAST_EVENT_START_TIME and LAST_EVENT_END_TIME.
    wait until keyword succeeds    ${JSON_MAX_RETRIES}    ${JSON_RETRY_INTERVAL}    I expect page element 'id:detailedInfogridPrimaryMetadata' contains 'textValue:.*(\\\\d{2}):(\\\\d{2}) ?- ?(\\\\d{2}):(\\\\d{2})*' using regular expressions
    ${primary_metadata}    Extract Value For Key    ${LAST_FETCHED_JSON_OBJECT}    id:detailedInfogridPrimaryMetadata    textValue
    @{event_time}    Get Regexp Matches    ${primary_metadata}    (\\d{2}):(\\d{2}) ?- ?(\\d{2}):(\\d{2})
    ${event_time}    split string    ${event_time[0]}    -
    ${event_start_time}    Set variable    ${event_time[0]}
    ${event_start_time}    strip string    ${event_start_time}
    ${event_end_time}    Set variable    ${event_time[1]}
    ${event_end_time}    strip string    ${event_end_time}
    set test variable    ${LAST_EVENT_START_TIME}    ${event_start_time}
    set test variable    ${LAST_EVENT_END_TIME}    ${event_end_time}
    ${day_time}    split string    ${primary_metadata}    ,
    ${part_of_day}    Set variable    ${day_time[0]}
    [Return]    ${part_of_day}    ${event_start_time}    ${event_end_time}

Get guide block ID
    [Documentation]    This keyword returns the block id of current displayed Guide page
    ...    Precondition: Should be in Guide view
    ${focus_elements}    Get Ui Focused Elements
    ${guide_block_id}    Extract Value For Key    ${focus_elements}    id:block_\\d+_event_\\d+_\\d+    id    ${True}
    ${guide_block_id}    Fetch From Left    ${guide_block_id}    _event
    [Return]    ${guide_block_id}

Get '${coordinate}' position of gridNowLine
    [Documentation]    This keyword will returns the current ${coordinate} position of gridNowLine in the EPG.
    ...    Precondition: guide is shown
    ${grid_line_current_position}    I retrieve value for key '${coordinate}' in element 'id:gridNowLine'
    [Return]    ${grid_line_current_position}

EPG Event Info Is Available    #USED
    [Documentation]    Checks if event info is on screen by checking for gridInfoPanel
    ...    We also check that the epg data is present so we dont have 'No info available' shown on the UI
    wait until keyword succeeds    ${JSON_MAX_RETRIES}    ${JSON_RETRY_INTERVAL}    I expect page contains 'id:guideInfoPanel'
    ${actual_focused_epg_channel_number}    Get Focused Guide Programme Cell Channel Number
    ${info_title_text_value}    I retrieve Info panel title element
    Should Not Be Empty    ${info_title_text_value}    gridInfoTitle textValue is empty - for channel: ${actual_focused_epg_channel_number}
    ${epg_info_available_for_event}    Check EPG Info Panel has Info Available
    run keyword if   not ${epg_info_available_for_event}    log    No Info for actual event - Info Panel contains: ${info_title_text_value} - channel: ${actual_focused_epg_channel_number}
    Should Be True    ${epg_info_available_for_event}    No info available Found - No current event data on EPG for channel: ${actual_focused_epg_channel_number}

Check EPG Valid Channel Event Information For Highlighted '${channel_number}' Logo '${logo_check}' Poster '${poster_check}' Metadata '${metadata_check}'  #USED
    [Documentation]    Checks the metadata, logo, poster if the checks vars are True if not we will skip the specific check
    Metadata In Guide Highlighted Channel Cell Is Correct For Channel    ${channel_number}
    run keyword if    ${logo_check}    Check Channel Logo URL EPG Highlighted Channel Available     ${channel_number}    ${4K_SUPPORT}
    ...   ELSE    Log    Logo Check is Disable
    run keyword if    ${poster_check}    Check Event Poster URL EPG Panel Info Available    ${channel_number}
    ...   ELSE    Log     Poster Check is Disable
    run keyword if    ${metadata_check}    Guide Info Panel Has Correct Metadata For Channel    ${channel_number}
    ...   ELSE    Log     Metadata Check is Disable

Check EPG Info Panel has Info Available    #USED
    [Documentation]    Checks if the channel is unsubscribe on EPG Info Panel
    ${epg_info_available_for_event}    run keyword and return status    I do not expect page element 'id:guideInfoPanelTitle' contains 'textKey:DIC_DETAIL_EVENT_NO_INFO' using regular expressions
    [Return]    ${epg_info_available_for_event}

Check EPG Unsubscribed Channel    #USED
    [Documentation]    Checks if the channel is unsubscribe on EPG Info Panel
    ${unsubscribe_channel}    run keyword and return status    I expect page element 'id:rcuCueGuide' contains 'textKey:DIC_RC_CUE_SUBSCRIBE_CHANNEL' using regular expressions
    [Return]    ${unsubscribe_channel}

Check EPG Locked Channel    #USED
    [Documentation]    Checks if the channel is locked on EPG Info Panel
    ${locked_channel}    run keyword and return status    I expect page element 'id:lockIcongridPrimaryMetadata' contains 'iconKeys:LOCK' using regular expressions
    [Return]    ${locked_channel}

Check EPG Adult Channel or Programme   #USED
    [Documentation]    Checks if Adult channel or Adult programme on EPG Info Panel
    #other Option: "id": "gridInfoTitle"."textKey": "DIC_ADULT_CHANNEL"
    ${adult_channel}    run keyword and return status    I expect page element 'id:rcuCueGuide' contains 'textKey:DIC_RC_CUE_UNLOCK_CHANNEL' using regular expressions
    ${adult_programme}    run keyword and return status    I expect page element 'id:rcuCueGuide' contains 'textKey:DIC_RC_CUE_UNLOCK_PROGRAM' using regular expressions
    ${is_adult}    set variable if    ${adult_channel} or ${adult_programme}    ${True}    ${False}
    [Return]    ${is_adult}

Get Event Poster URL EPG Panel Info   #USED
    [Documentation]    Get the Poster URL for the EPG Info Panel Event
    ...    Poster will not be present if the channel/event is Adult Locked or APP channel or No info available for that event
    [Arguments]    ${epg_highligthed_channel}
    ${is_adult_event}    Check EPG Adult Channel or Programme
    Variable should exist    ${APP_BOUND_AUTOSTART_CHANNELS}    APP_BOUND_AUTOSTART_CHANNELS should exist for Get Event Poster URL EPG Panel Info
    ${is_app_channel}    I Check If Channel Number Is Autostart App Bound Channel From Linear Service    ${epg_highligthed_channel}    ${APP_BOUND_AUTOSTART_CHANNELS}
    ${epg_info_available_for_event}    Check EPG Info Panel has Info Available
    Return From Keyword If    ${is_app_channel} or ${is_adult_event} or not ${epg_info_available_for_event}    ${EMPTY}
    ${json_object}    Get Ui Json
    ${poster_event_info}    Get Enclosing Json    ${json_object}    ${EMPTY}    id:gridInfoPoster    ${1}
    dictionary should contain key    ${poster_event_info}    background    id:gridInfoPoster not contain expected: background
    dictionary should contain key    ${poster_event_info['background']}    url     id:gridInfoPoster[backgraound] not contain expected: url
    ${poster_event_info_url}    Set Variable    ${poster_event_info['background']['url']}
    [Return]    ${poster_event_info_url}

Check Event Poster URL EPG Panel Info Available   #USED
    [Documentation]    Check the Poster URL for the EPG Info Panel Event on CDN - HTTP/s Request
    [Arguments]    ${epg_highligthed_channel}
    ${poster_event_info_url}    Get Event Poster URL EPG Panel Info    ${epg_highligthed_channel}
    run keyword if    '${poster_event_info_url}' == '${EMPTY}'    log    WARN: Poster EPG Info Panel NOT present as: Adult Channel/Programme Or APP Channel Or No Info Available Found on Channel: ${epg_highligthed_channel} - continue
    return from keyword if    '${poster_event_info_url}' == '${EMPTY}'    WARN: Poster EPG Info Panel NOT present as: Adult Channel/Programme Or APP Channel Or No Info Available Found on Channel: ${epg_highligthed_channel} - continue
    ${response}    Evaluate    requests.get("${poster_event_info_url}", headers={})    requests
    log    Request: ${poster_event_info_url} - Status Code: ${response.status_code}
    ${failedReason}    Set Variable If    ${response.status_code} != 200    Getting ${response.reason} status with ${response.status_code} code when send ${response.request.method} to ${response.url}    ${EMPTY}
    Should Be Empty    ${failedReason}    The Poster Event Poster URL EPG Panel Info Is Not Available 

Check Channel Logo URL EPG Highlighted Channel Available    #USED
    [Arguments]    ${epg_highligthed_channel}        ${4k_support}=${4K_SUPPORT}
    [Documentation]    Verifies logo URL is present  for highlighted channel
    ${logo_url_ls}   Get Logo URL For Channel Number From Linear Service    ${epg_highligthed_channel}    ${4k_support}
    log   LOGO - logo_url: ${logo_url_ls}
    Should Not Be Equal    ${logo_url_ls}    ${None}    The Channel ${epg_highligthed_channel} Logo Linear Service retrive is None - 4K support: ${4k_support}
    ${channel_logo_ui}    Get Focused Guide Programme Cell Channel Logo
    log  UI LOGO - channel_logo_ui: ${channel_logo_ui}
    Should Contain    ${channel_logo_ui}    ${logo_url_ls}    The displayed UI logo doesn't match with the returned logo from Linear Service
    Check Is Logo For Channel Number From Linear Service    ${epg_highligthed_channel}    ${4k_support}

Validate Last Day Future Epg    #USED
    [Documentation]    This Keyword Validates The EPG Data Till Last Day In Future
    ...    It Gets No Of Days EPG Content Is Available From EPG Service 
    ...    Then Navigates To Given Day In Future And Validates EPG Data
    ...    Precondition : TV Guide Should Be Open
    ${days_of_future_epg}    Get Available Future EPG Index Days
    Check EPG Info Panel has Info Available
    Navigate To '${days_of_future_epg}' Day In Future In TV Guide
    Validate EPG Data In TV Guide Across Different Channels

Channel Filter Is Focused    #USED
    [Documentation]    This keyword checks if channel filter is focused in TV Guide
    Wait Until Keyword Succeeds And Verify Status    ${JSON_MAX_RETRIES}    ${JSON_RETRY_INTERVAL}    Channel Filter is not focused in TV Guide    I expect page element 'id:gridNavigation_filterButton_1' contains 'color:${INTERACTION_COLOUR}'

Channel Filter Drop Down Is Shown    #USED
    [Documentation]    This keyword checks if channel filter drop down list is present in TV Guide
    Wait Until Keyword Succeeds And Verify Status    ${JSON_MAX_RETRIES}    ${JSON_RETRY_INTERVAL}    Channel Filter drop down list is not shown in TV Guide    I expect page element 'id:picker-item-text-\\\\d+' contains 'textKey:DIC_FILTER_ALL_CHANNELS' using regular expressions

Navigate To '${genre}' Genre In Channel Filter Drop Down    #USED
    [Documentation]    This keyword selects the given genre in channel filter drop down list in TV Guide
    ${json_object}    Get Ui Json
    ${genre_details}    Extract Value For Key    ${json_object}    id:value-picker    children
    ${no_of_genres}    Get Length    ${genre_details}
    Move Focus to Option in Value Picker    textValue:${genre}    DOWN     ${no_of_genres}+1

Verify Default Poster Is Shown In EPG Info Panel    #USED
    [Documentation]    This keyword verifies weather the tuned adult channel contains default poster in the EPG info panel.
    ${ui_json}    Get Ui Json
    ${poster_json}    Extract Value For Key    ${ui_json}    id:gridInfoPoster    background
    ${is_poster_shown}    Is In Json    ${poster_json}    ${EMPTY}    image:.*default_posters.*    ${None}    ${True}
    Should Be True    ${is_poster_shown}    Default poster not shown

Verify Synopsis Is Not Shown In EPG Info Panel    #USED
    [Documentation]    This keyword verifies synopsis is not shown in EPG Info panel.
    ${synopsis_shown}    Run Keyword And Return Status    Wait Until Keyword Succeeds    10 times    1 s    I expect page element 'id:gridInfoSynopsis' contains 'textValue:^.+$' using regular expressions
    Should Not Be True    ${synopsis_shown}    Synopsis shown in EPG info panel

Verify Title For An Adult Channel Shown In EPG Info Panel    #USED
    [Documentation]    This keyword verifies title shown for an adult channel in EPG Info panel and checks weather title contains adult channel text and lock icon is shown.
    ${ui_json}    Get Ui Json
    Log    ${ui_json}
    ${info_panel}    Extract Value For Key    ${ui_json}    id:gridInfoPanel    children
    ${adult_channel_text_present}    Is In Json    ${info_panel}    id:gridInfoTitle    textKey:DIC_ADULT_CHANNEL
    Should Be True    ${adult_channel_text_present}    Adult channel text not present
    ${lock_icon_present}    Is In Json    ${info_panel}    id:gridInfoTitle    iconKeys:LOCK
    Should Be True    ${lock_icon_present}    Lock icon not present

Verify Primary Metadata For A Locked Channel Shown In EPG Info Panel    #USED
    [Documentation]    This keyword verifies primary metadata for a locked channel is shown in EPG Info panel.
    ${ui_json}    Get Ui Json
    ${info_panel}    Extract Value For Key    ${ui_json}    id:gridInfoPanel    children
    ${check3}    Is In Json    ${info_panel}    id:rcuCueGuide    textKey:DIC_RC_CUE_UNLOCK_CHANNEL
    ${check4}    Is In Json    ${info_panel}    id:rcuCueGuide    iconKeys:OK
    ${is_unlock_text}    Set Variable If    ${check3} and ${check4}    True    False
    Should Be True   ${is_unlock_text}    Unlock text not shown

Get A Next Day Event Of Given Type From All Events Of The Hash    #USED
    [Documentation]    This keyword selects a ${event_type} event from all the events of a segment hash and return the selected event
    [Arguments]      ${event_type}    ${event_list}
    ${current_epoch_time}    Get Current Epoch Time
    ${current_epoch_time_converted}    robot.libraries.DateTime.Convert Date    ${current_epoch_time}
    ${next_day_time}    robot.libraries.DateTime.Add Time To Date  ${current_epoch_time_converted}    1 days
    @{next_day_epoch_date}    Get Regexp Matches    ${next_day_time}    (\\d{4}-\\d{2}-\\d{2}).*    1
    :FOR    ${event}    IN    @{event_list}
    \   ${is_valid_event}    Set Variable    False
    \   ${is_series}    Extract Value For Key    ${event}    ${EMPTY}    seriesId
    \   Continue For Loop If    '${event_type}' == 'series' and '${is_series}' == 'None'
    \   Continue For Loop If    '${event_type}' == 'single' and '${is_series}' != 'None'
    \   ${event_end_time}    Extract Value For Key    ${event}    ${EMPTY}    endTime
    \   ${event_start_time}    Extract Value For Key    ${event}    ${EMPTY}    startTime
    \   ${event_duration}    Evaluate      ${event_end_time}-${event_start_time}
    \   ${is_small_duration}    Evaluate    ${event_duration}<600
    \   Continue For Loop If    ${is_small_duration}
    \   ${event_start_time_converted}    robot.libraries.DateTime.Convert Date    ${event_start_time}
    \   @{event_epoch_date}    Get Regexp Matches    ${event_start_time_converted}    (\\d{4}-\\d{2}-\\d{2}).*    1
    \   ${is_event_tomorrow}    Run Keyword And Return Status   Should Be Equal    @{next_day_epoch_date}[0]   @{event_epoch_date}[0]
    \   ${is_valid_event}    Run Keyword If    ${is_event_tomorrow}    Set Variable    True
    \   Exit For Loop If    ${is_valid_event}
    ${event}    Run Keyword If    ${is_valid_event}    Set Variable    ${event}
    ...    ELSE    Set Variable    None
    [Return]    ${event}

Verify Primary Metadata Is Shown In EPG Info Panel    #USED
    [Documentation]    This keyword verifies primary metadata is shown in EPG info panel
    Wait Until Keyword Succeeds And Verify Status    ${JSON_MAX_RETRIES}    ${JSON_RETRY_INTERVAL}    Primary Metadata not present in EPG Info Panel    I expect page contains 'id:gridPrimaryMetadata'
    Wait Until Keyword Succeeds And Verify Status    ${JSON_MAX_RETRIES}    ${JSON_RETRY_INTERVAL}    Detailed Info Grid Primary Metadata not present in EPG Info Panel    I expect page element 'id:detailedInfogridPrimaryMetadata' contains 'textValue:^.+$' using regular expressions
    ${event_info}    I retrieve value for key 'textValue' in element 'id:detailedInfogridPrimaryMetadata'
    Should Not Be Empty    ${event_info}    Detailed Primary Metadata is not present in TV Guide Info panel

Verify Poster Is Shown In EPG Info Panel    #USED
    [Documentation]    This keyword verifies poster is shown in EPG info panel
    ${ui_json}    Get Ui Json
    ${poster_json}    Extract Value For Key    ${ui_json}    id:gridInfoPoster    background
    Dictionary Should Contain Key    ${poster_json}    url     Poster is not present in TV Guide Info panel
    ${poster_event_info_url}    Set Variable    ${poster_json['url']}
    Validate Detailpage Poster    ${poster_event_info_url}

Verify '${event_type}' Event Title Is Shown In EPG Info Panel    #USED
    [Documentation]    This keyword verifies title shown in EPG info panel is same as title from the event set in suite variable SELECTED_EVENT
    Run Keyword If    '${event_type}' == 'series'    Generate Asset Title For Single Recording Using Recording Asset Details From BO   ${SELECTED_EVENT}    seriesName    False
    ${title}    I retrieve Info panel title element
    ${backend_title}    Run Keyword If    '${event_type}' == 'series'    Set Variable    ${SELECTED_ASSET_TITLE}
    ...    ELSE    Set Variable   ${SELECTED_EVENT['title']}
    Should Be Equal As Strings    '${title}'    '${backend_title}'    Title present in TV Guide Info panel is not same as title from backend

Verify Synopsis Is Shown In EPG Info Panel    #USED
    [Documentation]    This keyword verifies synopsis shown in EPG info panel is same as synopsis from the event set in suite variable SELECTED_EVENT
    ${synopsis}    I Retrieve Synopsis From EPG Info Panel
    Should Be Equal As Strings    '${synopsis}'    '${SELECTED_EVENT['shortDescription']}'    Synopsis present in TV Guide Info panel is not same as synopsis from backend
    Should Not Be Empty    ${synopsis}    Synopsis is not present in TV Guide Info panel