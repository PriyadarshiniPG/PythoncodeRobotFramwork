*** Settings ***
Documentation     Radio Keywords
Resource          ../PA-28_Radio/Radio_Implementation.robot

*** Variables ***
${num_of_radio_station_in_row}    4

*** Keywords ***
I focus Radio Portal tile    #USED
    [Documentation]    This keyword focuses the Radio Portal tile when Main menu is open and TV guide is focused
    Radio Portal Tile Is Present
    Dismiss Channel Failed Error Pop Up
    Error popup is not shown
    Move Focus to direction and assert    DOWN    3
    First tile in contextual main menu is focused
    ${radio_node_id}    Get Radio tile id
    Move to element assert focused elements    id:${radio_node_id}    7    RIGHT

Radio Portal Tile Is Present    #USED
    [Documentation]    This keyword checks if Radio Portal tile is present in the current view
    ${is_radio_tile_present}    Run Keyword And Return Status    Wait Until Keyword Succeeds    ${JSON_MAX_RETRIES}    ${JSON_RETRY_INTERVAL}    I expect page contains 'textKey:DIC_CONTEXTUAL_MAIN_MENU_RADIO'
    Should Be True    ${is_radio_tile_present}    Radio Portal Tile is not present

Radio Portal is shown    #USED
    [Documentation]    This keyword checks if Radio Portal and it's elements are shown
    ${is_radio_portal}    Run Keyword And Return Status    Wait Until Keyword Succeeds    5 times    1s    I expect page contains 'id:RadioPortal.View'
    Should Be True    ${is_radio_portal}    Radio Portal is not shown
    I wait for 2 seconds
    ${json_object}    Get Ui Json
    ${radio_header}    Is In Json    ${json_object}    ${EMPTY}    textKey:DIC_RADIO_INFO
    ${radio_grid}    Is In Json    ${json_object}    ${EMPTY}    id:.*CollectionsBrowser    ${EMPTY}    ${True}
    ${radio_tiles}    Is In Json    ${json_object}    ${EMPTY}    id:.*CollectionsBrowser_collection_.*_tile_.*    ${EMPTY}    ${True}
    ${radio_portal_presence}    Evaluate    True if (${radio_header} and ${radio_grid} and ${radio_tiles}) else False
    Should Be True    ${radio_portal_presence}    msg=One or more radio portal elements are not present

I open Radio Portal    #USED
    [Documentation]    This keyword opens the Radio Portal from Main Menu TV guide section
    I open Main Menu
    I focus Radio Portal tile
    I press    OK
    Radio Portal is shown

'${ordinal}' radio grid tile is focused    #USED
    [Documentation]    This keyword verifies if ${ordinal} grid tile is focused on Radio Portal's Grid page. (e.g: 1st, 2nd, 5th, XXth, etc...).
    ${tile_index}    Remove String Using Regexp    ${ordinal}    \\D+
    ${focused_elements}    Get Ui Focused Elements
    ${grid_page_data}    Extract Value For Key    ${focused_elements}    id:.*CollectionsBrowser    data    ${True}
    ${tile_id}    Set Variable    ${grid_page_data[${tile_index}-1]['id']}
    Wait Until Keyword Succeeds    ${JSON_MAX_RETRIES}    ${JSON_RETRY_INTERVAL}    Tile is Focused    ${tile_id}    id

'${ordinal}' radio grid tile is not focused    #USED
    [Documentation]    This keyword verifies if ${ordinal} grid tile is not focused on Radio Portal's Grid page. (e.g: 1st, 2nd, 5th, XXth, etc...).
    ${tile_index}    Remove String Using Regexp    ${ordinal}    \\D+
    ${focused_elements}    Get Ui Focused Elements
    ${is_grid_focused}    Is In Json    ${focused_elements}    ${EMPTY}    id:.*CollectionsBrowser    ${EMPTY}    ${True}
    Run keyword if    ${is_grid_focused}    '${tile_index}' radio grid tile is not focused when focus is in grid

Grid counter shows '${tile_index}' / total number of radio channels    #USED
    [Documentation]    This keyword verifies if Grid counter shows the correct numbers on Radio Portal's Grid page.
    ${focused_elements}    Get Ui Focused Elements
    ${grid_page_data}    Extract Value For Key    ${focused_elements}    id:.*CollectionsBrowser    data    ${True}
    ${total_channel_count}    Get Length    ${grid_page_data}
    Wait Until Keyword Succeeds    ${JSON_MAX_RETRIES}    ${JSON_RETRY_INTERVAL}    I expect page element 'id:gridNavigation_gridCounter' contains 'textValue:${tile_index} / ${total_channel_count}'

Radio Header is shown    #USED
    [Documentation]    This keyword verifies radio header is shown
    ${json_object}    Get Ui Json
    ${is_title_present}    Is In Json    ${json_object}    id:mastheadScreenTitle    textKey:DIC_RADIO_INFO
    ${is_time_present}    Is In Json    ${json_object}    id:mastheadTime    textValue:^[0-2][0-9]:[0-9][0-9]$    ${EMPTY}    ${True}
    ${is_nowtv_present}    Is In Json    ${json_object}    id:watchingNow    textKey:DIC_HEADER_SOURCE_LIVE
    Should Be True    ${is_title_present} and ${is_nowtv_present} and ${is_time_present}    one of the required elements Title or Time or NowOnTv is missing

I focus the '${ordinal}' radio tile    #USED
    [Documentation]    This keyword focuses the ${ordinal} grid tile. (e.g: 1st, 2nd, 5th, XXth, etc...)
    ${num}    Remove String Using Regexp    ${ordinal}    \\D+
    ${recently_viewed_status}    Run Keyword And Return Status    I expect page contains 'textKey:DIC_RADIO_SEC_RECENTLY_LISTENED'
    Run Keyword If    ${recently_viewed_status}    I press    DOWN
    ${json_object}    Get Ui Focused Elements
    ${grid_page_data}    Extract Value For Key    ${json_object}    id:.*CollectionsBrowser    data    ${True}
    ${status}    ${tile_name}    Run Keyword And Ignore Error    Set Variable If    ${recently_viewed_status}    ${grid_page_data[${num_of_radio_station_in_row}+${num}]['title']}    ${grid_page_data[${num}-1]['title']}
    Run Keyword And Return If    '${status}'=='FAIL'    Verify Radio Channel Has No Event Info    ${num}    ${recently_viewed_status}    ${grid_page_data}
    Move Focus to Tile in Grid Page    ${tile_name}    title
    Tile is Focused    ${tile_name}    title

Get Total Number Of Radio Channels From Radio Portal UI    #USED
    [Documentation]    This keyword fetched the total number of radio channels are present in radio portal.
    Wait Until Keyword Succeeds    ${JSON_MAX_RETRIES}    ${JSON_RETRY_INTERVAL}    I expect page contains 'id:(gridNavigation_gridCounter|mastheadSecondaryTitle)' using regular expressions
    ${ui_json}    Get Ui Json
    ${grid_page_data}    Extract Value For Key    ${ui_json}    id:(gridNavigation_gridCounter|mastheadSecondaryTitle)    textValue    ${True}
    ${total_channel_count}    Split String    ${grid_page_data}      /
    Should Be True    ${total_channel_count[1]} > 0    Unable to fetch total number of radio channels from radio portal UI
    [Return]    ${total_channel_count[1]}

Validate Radio Channels Number Is Same As In BO    #USED
    [Documentation]    This keyword compares the total radio channels from Radio portal screen with back office data(data fom Linear service)
    ${channels_in_ui}    Get Total Number Of Radio Channels From Radio Portal UI
    ${radio_channels}    I Fetch All Radio Channels From Linear Service
    ${radio_channels_len_from_bo}    Get Length    ${radio_channels}
    Should Be Equal As Numbers   ${channels_in_ui}    ${radio_channels_len_from_bo}    Total Radio channels number is different in UI from Backend.

Move Focus From Radio Tile And Ensure '${radio_grid}' Is Not Focused    #USED
    [Documentation]    This Keyword moves focus from the '${radio_grid}' to other radio tile in radio portal and ensures '${radio_grid}'
    ...    is not focused.
    ${recently_viewed_status}    Run Keyword And Return Status    I expect page contains 'textKey:DIC_RADIO_SEC_RECENTLY_LISTENED'
    ${num}    Remove String Using Regexp    ${radio_grid}    \\D+
    ${radio_grid_index}    Run Keyword If    ${recently_viewed_status}     evaluate    ${num}+${num_of_radio_station_in_row}
    ...    ELSE    Set Variable     ${num}
    ${radio_grid_index}    Set Variable    ${radio_grid_index}+st
    ${children}    I retrieve value for key 'children' in element 'id:shared-CollectionsBrowser'
    ${radio_length}    Get Length    ${children}
    Run Keyword If    ${radio_length} > 1    Move Focus to direction and assert    DOWN    5
    ...    ELSE    Move Focus to direction and assert    RIGHT    5
    '${radio_grid_index}' radio grid tile is not focused

Verify Radio Channel Has No Event Info    #USED
    [Documentation]    This keyword gives details regarding event info in radio channel
    [Arguments]    ${num}    ${recently_viewed_status}    ${grid_page_data}
    ${id}    Set Variable If    ${recently_viewed_status}    ${grid_page_data[${num_of_radio_station_in_row}+${num}]['id']}    ${grid_page_data[${num}-1]['id']}
    @{channel_id_list}    Get Regexp Matches    ${id}    (.*)_0-0    1
    ${channel_id}    Set Variable    @{channel_id_list}[0]
    ${epg_index}    Get Index Of Event Metadata Segments
    ${epg_data}    Set Variable    ${epg_index.json()}
    :FOR   ${entries}    IN    @{epg_data['entries']}
    \    ${channel}    Set Variable    ${entries['channelIds'][0]}
    \    Exit For Loop If    '${channel}' == '${channel_id}'
    ${hash_info}    Set Variable    ${entries['segments'][7]}
    ${epg_segment}    Get Event Metadata For A Particular Segment    ${hash_info}
    ${event_info}    Run Keyword And Return Status    Set Variable    ${epg_segment.json()['entries'][0]['events']}
    Should Be True    not ${event_info}    Event information is present but Title is not shown

