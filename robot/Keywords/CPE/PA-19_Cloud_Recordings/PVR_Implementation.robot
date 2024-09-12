*** Settings ***
Documentation     Cloud Recordings Implementation keywords
Resource          ../Common/Common.robot
Resource          ../CommonPages/Modal_Implementation.robot
Resource          ../VisualRegression/VisualRegression_Keywords.robot
Resource          ../PA-05_Linear_TV/Subtitles_Keywords.robot
Library           Libraries.MicroServices.ContinueWatchingService.ContinueWatchingService

*** Variables ***
${TOAST_MSG_MAX_WAIT_TIME}    60s
${PARTIALLY_WATCHED_TILE_FONT}    InterstatePro

*** Keywords ***
Reset All Recordings
    [Documentation]    This keyword performs a call to app services and resets all recordings
    ...    in order to delete all recordings
    wait until keyword succeeds    3 times    1 sec    Reset All Recordings Via As    ${STB_IP}    ${CPE_ID}    xap=${XAP}

Reset All Continue Watching Events
    [Documentation]    This keyword performs calls to the Continue Watching Service and Bookmark Service
    ...    in order to delete all Continue Watching and event Bookmark data from the current profile
    ${profile}    Get Current Profile Id Via As    ${STB_IP}    ${CPE_ID}    xap=${XAP}
    wait until keyword succeeds    3 times    1 sec    Delete All Items From Continue Watching List    ${profile}
    wait until keyword succeeds    3 times    1 sec    Delete profile Bookmarks via CS    ${profile}

Rented Specific Teardown    #NOT_USED
    [Documentation]    Contains teardown steps for Rented related tests
    ${city_id}    Get Customer City Id    ${LAB_TYPE}    ${CPE_ID}    ${CA_ID}
    ${is_customer_id}    set variable if    ${city_id} != ${None}    ${True}    ${False}
    Make sure OSD Language is set to    ${LANGUAGE_ENGLISH}
    ${deleted_customer_id}    run keyword if    ${is_customer_id}    Delete CPE Profile    ${LAB_TYPE}    ${CPE_ID}
    ...    ELSE    Log    Failed to fetch customer city id, skipping profile deletion    WARN
    I wait for 10 seconds
    ${is_profile_active}    run keyword and return status    Get Customer City Id    ${LAB_TYPE}    ${CPE_ID}    ${CA_ID}
    ${is_profile_deleted}    set variable if    '${deleted_customer_id}' != '${None}' or ${is_profile_active} == ${False}    ${True}    ${False}
    ${is_customer_in_traxis}    run keyword and return status    get customer id    ${CPE_ID}
    run keyword if    ${is_profile_deleted} and ${is_customer_in_traxis}    delete customer from traxis    ${CPE_ID}
    ${exact_platform}    Get Exact Platform    ${RACK_SLOT_ID}
    ${created_customer_id}    run keyword if    ${is_profile_deleted}    Create CPE Profile    ${city_id}    ${LAB_TYPE}    ${CPE_ID}
    ...    ${CA_ID}    ${exact_platform}
    ...    ELSE    Log    Profile not deleted, skipping new profile creation    WARN
    I wait for 10 seconds
    ${is_customer_created}    set variable if    '${created_customer_id}' != '${None}'    ${True}    ${False}
    ${device_storage_type}    Get device storage type
    run keyword if    ${is_profile_deleted} and ${is_customer_created} and '${device_storage_type}' == 'CLOUD'    should not be equal    ${deleted_customer_id}    ${created_customer_id}    msg=Deleted and newly created profile ids are equal!
    ${restart_command}    Run keyword If    ${LIGHT_RESTART}    Set Variable    systemctl restart lgias
    ...    ELSE    Set Variable    /sbin/reboot&
    ${ssh_handle}    Remote.open connection    ${STB_IP}
    Remote.login    ${STB_IP}    ${ssh_handle}    ${username}    ${password}
    ${output}    Remote.execute_command    ${STB_IP}    ${ssh_handle}    rm -rf /mnt/app_services/data/auth/*
    Remote.execute_command    ${STB_IP}    ${ssh_handle}    ${restart_command}
    Remote.close connection    ${STB_IP}    ${ssh_handle}
    Run keyword If    ${LIGHT_RESTART} == ${False}    I wait for 2 minutes
    Wait Until Keyword Succeeds    6 min    0 s    Get Ui Json
    Default Suite Teardown

Move Focus to Reccording Row Position
    [Arguments]    ${position}
    [Documentation]    Navigate in reccording list to the reccording at the list position ${position}
    Move to element assert focused elements using regular expression    textKey:DIC_FILTER_(PLANNED_RECORDINGS|RECORDED)    18    UP
    ${max_move}    Evaluate    ${position} +1
    : FOR    ${_}    IN RANGE    ${max_move}
    \    Move Focus to direction and assert    DOWN

Pending recording icon is shown implementation
    [Documentation]    This keyword checks if pending recording icon is shown
    ${id}    Get Current Id
    wait until keyword succeeds    ${JSON_MAX_RETRIES}    ${JSON_RETRY_INTERVAL}    I expect page element 'id:recIcon${id}' contains 'iconKeys:RECORDING_SCHEDULED'

Currently recording icon is shown implementation
    [Documentation]    This keyword checks if currenty recording icon is shown on the current event
    ${id}    Get Current Id
    I expect page element 'id:recIcon${id}' contains 'iconKeys:RECORDING_CURRENT'

Get Current Id
    [Documentation]    This keyword returns an ID of currently focused event,
    ...    so it can be used for dynamically checking state of the future or past events
    &{ancestor}    I retrieve json ancestor of level '2' in element 'id:nnHlist' for element 'color:${INTERACTION_COLOUR}'
    @{regexp_match}    Get Regexp Matches    &{ancestor}[id]    ^.+(\\d+)$    1
    ${id}    Set Variable    ${regexp_match[0]}
    ${id}    Convert to integer    ${id}
    [Return]    ${id}

I focus 'Record' option
    [Documentation]    This keyword focuses the 'Record' option in modal popup window
    wait until keyword succeeds    ${JSON_MAX_RETRIES}    ${JSON_RETRY_INTERVAL}    I expect page contains 'textKey:DIC_NPVR_RECORD_BUTTON_SINGLE'
    Move Focus to Button in Interactive Modal    textKey:DIC_NPVR_RECORD_BUTTON_SINGLE    DOWN    8

I focus 'Stop recording' option
    [Documentation]    This keyword puts focus on the 'Stop recording' option in the modal popup window
    Move Focus to Button in Interactive Modal    textKey:DIC_INTERACTIVE_MODAL_BUTTON_STOP_RECORDING    DOWN    4

I focus 'Stop & Delete Recording' option
    [Documentation]    This keyword puts focus on the 'Stop and Delete Recording' button in the modal popup window
    Move Focus to Button in Interactive Modal    textKey:DIC_INTERACTIVE_MODAL_BUTTON_STOP_DELETE_RECORDING    DOWN    4

I focus 'Cancel recording' option    #USED
    [Arguments]    ${single_or_episode_or_fullserie}=${SINGLE_OR_EPISODE_OR_FULLSERIE}
    [Documentation]    This keyword puts focus on the 'Cancel recording' option in the modal popup window - use for: single, episode or fullserie
    variable should exist    ${SINGLE_OR_EPISODE_OR_FULLSERIE}    The type of recording has not been set. SINGLE_OR_EPISODE_OR_FULLSERIE does not exist
    run keyword if    '${SINGLE_OR_EPISODE_OR_FULLSERIE}' == 'episode'    Move Focus to Button in Interactive Modal    textKey:DIC_INTERACTIVE_MODAL_BUTTON_CANCEL_SINGLE_REC    DOWN    2
    ...    ELSE IF    '${SINGLE_OR_EPISODE_OR_FULLSERIE}' == 'single'    Move Focus to Button in Interactive Modal    textKey:DIC_INTERACTIVE_MODAL_BUTTON_CANCEL_SINGLE_REC    UP    2
    ...    ELSE IF    '${SINGLE_OR_EPISODE_OR_FULLSERIE}' == 'fullserie'    I focus 'Cancel series recording'

I focus 'Cancel series recording'    #USED
    [Documentation]    This keyword focuses the 'Cancel series recording' option on the interactive modal
    Wait Until Keyword Succeeds    10 times    200 ms    I expect page contains 'textKey:DIC_INTERACTIVE_MODAL_BUTTON_CANCEL_RECORDING_SERIES'
    Move Focus to Button in Interactive Modal    textKey:DIC_INTERACTIVE_MODAL_BUTTON_CANCEL_RECORDING_SERIES    UP    3

I focus Planned Recordings section
    [Documentation]    This keyword focuses the 'Scheduled recordings' section
    I focus planned recording collection

I focus 'Delete recording'
    [Documentation]    Focus button 'Delete recording' for an episode
    ...    Pre-reqs: Deletion modal is open with highlight on the first option
    variable should exist    ${SINGLE_OR_EPISODE_OR_FULLSERIE}    The type of recording has not been set. SINGLE_OR_EPISODE does not exist
    run keyword if    '${SINGLE_OR_EPISODE_OR_FULLSERIE}' == 'episode'    Move Focus to Button in Interactive Modal    textKey:DIC_INTERACTIVE_MODAL_BUTTON_DELETE_EPISODE    DOWN    2
    ...    ELSE IF    '${SINGLE_OR_EPISODE_OR_FULLSERIE}' == 'single'    Move Focus to Button in Interactive Modal    textKey:DIC_INTERACTIVE_MODAL_BUTTON_DELETE_RECORDING_YES    DOWN    2

I focus the Retention period checkbox in the Series recording modal
    [Documentation]    Focus the 'Keep longer than' retention checkbox in the Series recording modal
    Interactive modal is shown
    Wait Until Keyword Succeeds    ${JSON_MAX_RETRIES}    ${JSON_RETRY_INTERVAL}    I expect page contains 'textKey:DIC_DAYS_RETENTION_PERIOD_SERIES'
    Move Focus to Checkbox in Modal    textKey:DIC_DAYS_RETENTION_PERIOD_SERIES    DOWN    5

I focus 'Stop recording' action
    [Documentation]    This keyword focus stop recording
    Wait Until Keyword Succeeds    10 times    200 ms    I expect page contains 'textKey:DIC_ACTIONS_STOP_RECORDING'
    Move Focus to Section    DIC_ACTIONS_STOP_RECORDING    textKey

Focus partially or fully recorded tile
    [Documentation]    This keyword focuses a partially or fully recorded event
    Wait Until Keyword Succeeds    5 times    1 s    I expect page contains '${COLLECTION_NODE_ID_HIGH_PATTERN}' using regular expressions
    I expect page contains 'iconKeys:.*(RECORDING_PARTIAL|RECORDING_SUCCESS|BULLET).*' using regular expressions
    ${json_object}    Get Ui Json
    ${tile_to_focus}    Extract Value For Key    ${json_object}    iconKeys:.*(RECORDING_PARTIAL|RECORDING_SUCCESS|BULLET).*    id    ${True}
    ${tile_to_focus}    Replace String    ${tile_to_focus}    _secondaryTitle    ${EMPTY}
    Move to element assert focused elements    id:${tile_to_focus}    5    RIGHT

Focus partially watched tile
    [Documentation]    This keyword focuses a partially watched event
    : FOR    ${_}    IN RANGE    ${5}
    \    ${json_object}    Get Ui Json
    \    ${tile_id}    Extract Value For Key    ${json_object}    textValue:.*color=.*${HIGHLIGHTED_OPTION_COLOUR}.*    id    ${True}
    \    ${focused_string}    Extract Value For Key    ${json_object}    textValue:.*color=.*${HIGHLIGHTED_OPTION_COLOUR}.*    textValue    ${True}
    \    ${tile_title}    remove html tag from string    ${focused_string}
    \    ${progress_indication}    Is In Json    ${json_object}    id:Tile_poster_${tile_id}    id:Tile_watch_indicator_${tile_id}_progressbar    ${EMPTY}
    \    ...    ${False}
    \    ${found_match}    Evaluate    True if ${progress_indication} else False
    \    exit for loop if    ${found_match}
    \    I press    RIGHT
    \    wait until keyword succeeds    2s    100ms    Assert json changed    ${json_object}
    should be true    ${found_match}    Could not focus any partially watched tile

Focus currently recording tile
    [Documentation]    This keyword focuses the currently recording tile
    ...    Pre-reqs: Assumes the highlight is on 'Show all' under 'Recorded' on the Saved page
    Wait Until Keyword Succeeds    5 times    1 s    I expect page contains '${COLLECTION_NODE_ID_HIGH_PATTERN}' using regular expressions
    I expect page contains 'textKey:DIC_GENERIC_AIRING_TIME_REC'
    ${tile_to_focus}    Extract Value For Key    ${LAST_FETCHED_JSON_OBJECT}    textKey:DIC_GENERIC_AIRING_TIME_REC    id
    ${tile_to_focus}    Replace String    ${tile_to_focus}    _secondaryTitle    ${EMPTY}
    Move to element assert focused elements    id:${tile_to_focus}    5    RIGHT

Partial recording icon in Recordings is shown implementation
    [Documentation]    This keyword verifies if a Partial recording icon in Recordings is shown - implementation
    Wait Until Keyword Succeeds    10 times    1 s    I expect page contains 'iconKeys:.*RECORDING_PARTIAL.*' using regular expressions

I check if recording finished
    [Documentation]    This keyword checks if a recording is finished
    Move Focus to Section    DIC_SECTION_NAV_WATCHLIST    textKey
    I wait for 1 second
    Move Focus to Section    DIC_SECTION_NAV_RECORDINGS    textKey
    I wait for 1 second
    Wait Until Keyword Succeeds    5 times    1 s    I expect page contains 'iconKeys:.*(RECORDING_PARTIAL|RECORDING_SUCCESS|BULLET).*' using regular expressions

'Play from start' action is shown       #USED
    [Documentation]    This keyword verifies the 'Play from start' action is shown in contextual menu.
    ${action_found}    Run Keyword And Return Status    wait until keyword succeeds    ${JSON_MAX_RETRIES}    ${JSON_RETRY_INTERVAL}    I expect page contains 'textKey:DIC_ACTIONS_PLAY_FROM_START'
    Should Be True    ${action_found}    Unable to Find 'Play from start' action in Interctive Modal Popup

'Play from start' action is focused
    [Documentation]    This keyword verifies that the 'Play from start' action is focused in contextual menu.
    Option is Focused in Value Picker    textKey:DIC_ACTIONS_PLAY_FROM_START

'WATCH' action is shown
    [Documentation]    This keyword verifies the 'WATCH' action is shown.
    wait until keyword succeeds    ${JSON_MAX_RETRIES}    ${JSON_RETRY_INTERVAL}    I expect page contains 'textKey:DIC_ACTIONS_WATCH'

Ongoing Recordings Specific Test Teardown
    [Documentation]    Teardown steps to reset all recordings and Bookmarks. Will reset even ongoing recordings.
    ${json_object}    Get Ui Json
    ${is_player_turned_on}    Is In Json    ${json_object}    ${EMPTY}    id:Player.View
    Run Keyword If    '${is_player_turned_on}' == '${True}'    Run Keywords    Hide Video Player bar
    ...    AND    I Press    LIVETV
    Reset All Recordings
    Reset All Continue Watching Events

Adult Ongoing Recordings Specific Suite Teardown
    [Documentation]    Contains teardown steps for Ongoing Adult Recordings related tests.
    Ongoing Recordings Specific Test Teardown
    Restart UI via command over SSH by invoking /sbin/reboot
    Default Suite Teardown

Determine already scheduled recording event type from modal popup    #USED
    [Documentation]    This keyword return the type of event for an already scheduled recording
    ...    Pre: The modal popup to Cancel Recoding or Recordings options needs to be open
    ...    [return] ${SINGLE_OR_EPISODE_OR_FULLSERIE}: [single, episode, fullserie]
    Interactive modal is shown
    ${single_event_present}    run keyword and return status    Interactive modal with options 'Cancel recording' and 'Close' is shown
    ${episode_event_present}    run keyword and return status    Interactive modal with options 'Record complete series' and 'Cancel Recording' is shown
    ${full_serie_event_present}    run keyword and return status    Interactive modal with options 'Cancel Series Recording' and 'Close' is shown
    ${SINGLE_OR_EPISODE_OR_FULLSERIE}    Set Variable If    ${single_event_present}    single    ${episode_event_present}    episode    ${full_serie_event_present}    fullserie
    set suite variable    ${SINGLE_OR_EPISODE_OR_FULLSERIE}
    Should Not Be Equal    ${SINGLE_OR_EPISODE_OR_FULLSERIE}   ${NONE}
    [Return]    ${SINGLE_OR_EPISODE_OR_FULLSERIE}

Determine recording event type from modal popup    #USED
    [Documentation]    This keyword return the type of event for a recording
    ...    Pre: The modal popup to Cancel Recoding or Recordings options needs to be open
    ...    [return] ${SINGLE_OR_EPISODE_OR_FULLSERIE}: [single, episode]
    ${single_event_present}    Run Keyword And Return Status     Interactive modal is not shown
    ${episode_event_present}    Run Keyword And Return Status    Interactive modal with options 'Record complete series' and 'Record this Episode' is shown
    ${ch_single_event_present}    Run Keyword And Return Status    Interactive modal with options 'Record' and 'Close' is shown
    ${SINGLE_OR_EPISODE_OR_FULLSERIE}    Set Variable If    ${episode_event_present}    episode    ${ch_single_event_present}       single_ch
    ...     ${single_event_present}    single
    Run Keyword If    '${SINGLE_OR_EPISODE_OR_FULLSERIE}'==${NONE} and not ${single_event_present}     Interactive modal is not shown
    Set Suite Variable    ${SINGLE_OR_EPISODE_OR_FULLSERIE}
    [Return]    ${SINGLE_OR_EPISODE_OR_FULLSERIE}

Get First Asset Title from Recording List on Planned
    [Documentation]    This keyword get the asset title for first asset in the List of Planned recordings on Saved
    ...    reading the UI to get the information
    ${scheduled_recording}    I retrieve value for key 'textValue' in element 'id:listItemPrimaryInfo-ListItem'

Get Assets Details from Recording List on Planned    #USED
    [Documentation]    This keyword get the asset title and duration for the List of Planned recordings on Saved
    ...    reading the UI to get the information
    ...    [Return]    ${recording_list_asset_details_dict}  List with a dict with title and duration of the assets on the list
    : FOR    ${INDEX}    IN RANGE    0    5
    \    ${recording_list_element}    I retrieve json ancestor of level '1' for element 'id:recordingList'
    \    ${status}    Run Keyword And Return Status    Should Not Be Empty    ${recording_list_element}
    \    Run Keyword If    ${status}    Exit For Loop
    Should Not Be Empty    ${recording_list_element}    Recording list is empty
    ${recording_list_element}   set variable    ${recording_list_element['children'][0]['children']}
    ${recording_list_count}    Get Length    ${recording_list_element}
    @{recording_list_asset_titles}    Create List
    @{recording_list_asset_details_dict}    Create List
    : FOR    ${index}    IN RANGE    ${0}    ${recording_list_count}
    \    ${children_id}    set variable    ${recording_list_element[${index}]['id']}
    \    ${children_node}    Get Enclosing Json    ${recording_list_element}    id:${children_id}    id:listItemPrimaryInfo-ListItem    ${1}
    \    ${asset_title}    set variable    ${children_node['textValue']}
    \    ${children_node}    Get Enclosing Json    ${recording_list_element}    id:${children_id}    id:listItemDuration-ListItem    ${1}
    \    ${asset_duration}    set variable    ${children_node['textValue']}
    \    Append To List    ${recording_list_asset_titles}    ${asset_title}
    \    ${asset_details_dict}    Create_Dictionary    title=${asset_title}	duration=${asset_duration}
    \    Append To List    ${recording_list_asset_details_dict}    ${asset_details_dict}
    [Return]    ${recording_list_asset_details_dict}

Check If '${asset_title}' Is In '${asset_details_dict}' List Of Dicts For Assets Details    #USED
    [Documentation]    This keyword check if the asset title is on the List of Dicts
    ...    We check all the titles on ${asset_details_dict} and we check that one contains ${asset_title}
    ...    We saw that the text dont exactly match so that why we use the contains (evaluate)
    Log    asset_title: ${asset_title} to check if present in ${asset_details_dict}
     ${asset_details_dict_count}    Get Length    ${asset_details_dict}
     ${asset_title_is_present}      Set Variable        False
    : FOR    ${index}    IN RANGE    ${0}    ${asset_details_dict_count}
    \    ${single_asset_details_dict}    set variable    ${asset_details_dict[${index}]}
    \    Check Element In Dictionary    ${single_asset_details_dict}    title
    \    ${asset_title_is_present}    Run Keyword And Return Status     Should Contain    ${single_asset_details_dict['title']}     ${asset_title}
    \    Exit For Loop If    ${asset_title_is_present}
    [Return]    ${asset_title_is_present}

Navigate To Row In Specific Section Of Recordings With Given Title    #USED
    [Documentation]    This Keyword Navigates to the Specific Row inside complete recorded recordings list UI Or
    ...    Complete Planned recordings list UI based on the recording section and title of the selected asset.
    ...    param : section  - Two Possible for this variable Values 'Recorded' & 'Planned'
    ...    param : title  -   Title from the event details
    [Arguments]    ${section}    ${title}    ${MAX_ACTIONS}
    Run Keyword If    ${section} == 'Recorded'    I open Recording list
    ...    ELSE    I open Planned Recordings List through Saved
    ${title}    Regexp Escape    ${title}
    Move To Element Assert Provided Element Is Highlighted    textValue:^.*${title}.*    ${MAX_ACTIONS}    DOWN

I Navigate to Recording With Title '${recording_title}'      #USED
    [Documentation]    This Keyword Navigates to the Specific Row inside complete recorded recordings list UI Or
    ...    Complete Planned recordings list UI based on title of the selected asset.
    ...    param : title  -   Title from the event details
    ...    prerequisite :   Should be in recorded recordings list UI Or Complete Planned recordings list UI. Suite variable
    ...     ${MAX_ACTIONS} should exist
    Move To Element Assert Provided Element Is Highlighted    textValue:^.*${recording_title}.*    ${MAX_ACTIONS}    DOWN

I Select A Planned '${event_type}' Recording From BO    #USED
    [Documentation]    This keyword gets all the planned recordings from backend and selects a '${event_type}' event from the list,
    ...    if the planned '${event_type}' event is not present, it will schedule a '${event_type}' event
    ${planned_recordings}    I Get All Planned Recording Assets From BO
    ${planned_series_recordings}    Create List
    Log    ${planned_recordings}
    @{recording_data}    Set Variable    ${planned_recordings['data']}
    Log    ${recording_data}
    : FOR    ${index}    IN RANGE    len(@{recording_data})
    \    ${recording_details}    Set Variable    ${recording_data[${index}]}
    \    Continue For Loop If   '${event_type}' != 'single' and '${recording_details['type']}'=='single'
    \    ${title}     Extract Value For Key   ${recording_details}    ${EMPTY}    title
    \    Append To List    ${planned_series_recordings}    ${recording_details}
    ${scheduled_recording}    Run Keyword If    len(${planned_series_recordings})!=0    Get Random Element From Array    ${planned_series_recordings}
    ...     ELSE    Schedule A '${event_type}' Recording
    [return]    ${scheduled_recording}    len(@{recording_data})+1

Schedule A '${event_type}' Recording    #USED
    [Documentation]    This keyword selects a future '${event_type}' event and schedule recording for the event
    ${event}   ${channel_id}    ${max_actions}    I Select A Next Day '${event_type}' Event From BO
    I Schedule Recording For The Given Asset    ${channel_id}    ${event['id']}
    [Return]    ${event}