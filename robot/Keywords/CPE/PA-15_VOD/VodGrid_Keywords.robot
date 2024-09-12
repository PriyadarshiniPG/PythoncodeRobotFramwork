*** Settings ***
Documentation     Keywords for grid functionality
Resource          ../PA-15_VOD/VodGrid_Implementation.robot

*** Keywords ***
I focus Non-entitled asset
    [Documentation]    This keyword opens the 'Movie' VOD section in the On Demand screen, saves the
    ...    title of a non-entitled asset in the ${ASSET_TITLE} variable and focuses the tile with that name.
    ...    Precondition: On Demand screen should be open.
    I open 'Movies'
    ${cpe_profile_id}    Get Current Profile Id Via As    ${STB_IP}    ${CPE_ID}    xap=${XAP}
    ${movies_details}    Get Content    ${LAB_CONF}    Movies    ASSET    ${COUNTRY}    ${OSD_LANGUAGE}    ${cpe_profile_id}
    ...    ${CUSTOMER_ID}    all
    ${movie_title}    Get TVOD non-entitled asset title    ${movies_details}
    set test variable    ${ASSET_TITLE}    ${movie_title}
    I press    DOWN
    I focus '${ASSET_TITLE}' tile

I open a second level grid screen
    [Documentation]    This keyword opens a second level grid screen in the 'Providers' VOD category
    ...    and sets the ${SECOND_LEVEL_GRID} variable to True.
    ...    Precondition: On Demand screen should be open.
    I open 'Providers'
    Move Focus to direction and assert    DOWN
    I focus 'National Geographic' in providers section
    I press    OK
    VOD Grid Screen is shown
    Set Test Variable    ${SECOND_LEVEL_GRID}    ${True}
    Dismiss Tips and Tricks screen

I focus non-entitled multi-offers asset
    [Documentation]    This keyword opens the 'Movies' category and focuses the tile of the asset with multiple
    ...    rent offers saved in the ${MULTIOFFERS_TVOD_ASSET} variable.
    ...    Precondition: On Demand screen should be open.
    I open 'Movies'
    I wait for ${ONDEMAND_TAB_LOAD_TIME} seconds
    I navigate to all genres vod screen
    I focus '${MULTIOFFERS_TVOD_ASSET}' tile

I select the 'Info' action
    [Documentation]    This keyword focuses the 'Info' action in the Contextual Menu and selects it
    ...    Precondition: A Contextual Menu popup should be open.
    I focus the 'Info' action
    I press    OK

I select the 'Subtitle' action
    [Documentation]    This keyword focuses the 'Subtitle' action in the Contextual Menu and selects it
    ...    Precondition: A Contextual Menu popup should be open.
    I focus the 'Subtitle' action
    I press    OK

I select the 'Audio' action
    [Documentation]    This keyword focuses the 'Audio' action in the Contextual Menu and selects it
    ...    Precondition: A Contextual Menu popup should be open.
    I focus the 'Audio' action
    I press    OK

I focus the '${ordinal}' grid tile
    [Documentation]    This keyword focuses the ${ordinal} grid tile. (e.g: 1st, 2nd, 5th, XXth, etc...)
    ${num}    Remove String Using Regexp    ${ordinal}    \\D+
    ${json_object}    Get Ui Focused Elements
    ${grid_page_data}    Extract Value For Key    ${json_object}    id:^.*CollectionsBrowser$    items    ${True}
    ${tile_name}    Set Variable    ${grid_page_data[${num}-1]['title']}
    Move Focus to Tile in Grid Page    ${tile_name}    title
    Tile is Focused    ${tile_name}    title

'${column_ordinal}' tile of grid '${row_ordinal}' row is focused
    [Documentation]    This keyword verifies if ${column_ordinal} tile of grid's ${row_ordinal} row is focused.
    ${column_num}    Remove String Using Regexp    ${column_ordinal}    \\D+
    ${row_num}    Remove String Using Regexp    ${row_ordinal}    \\D+
    ${tile_num}    Evaluate    ${column_num} + 7 * (${row_num} - 1)
    Wait until keyword succeeds    ${JSON_MAX_RETRIES}    ${JSON_RETRY_INTERVAL}    I expect page contains 'id:^.*CollectionsBrowser' using regular expressions
    ${json_object}    Get Ui Focused Elements
    ${grid_page_data}    Extract Value For Key    ${json_object}    id:^.*CollectionsBrowser$    items    ${True}
    ${tile_name}    Set Variable    ${grid_page_data[${tile_num}-1]['title']}
    Tile is Focused    ${tile_name}    title

Grid navigation is available
    [Documentation]    This keyword verifies if the Grid Navigation component is available on the screen.
    Wait Until Keyword Succeeds    ${JSON_MAX_RETRIES}    ${JSON_RETRY_INTERVAL}    I expect page contains 'id:shared-GridNavigation'

Search icon in grid navigation is focused
    [Documentation]    This keyword verifies if the Search icon is focused in Grid Navigation component.
    Wait Until Keyword Succeeds    ${JSON_MAX_RETRIES}    ${JSON_RETRY_INTERVAL}    I expect focused elements contains 'iconKeys:SEARCH'

#*************************************CPE PERFORMANCE*******************************************************
Is in Collection Browser
    [Documentation]  This keyword verifies if the current focus is on collection browser
    Get Ui Focused Elements
    ${result}    Is In JSON    ${LAST_FETCHED_FOCUSED_ELEMENTS}    ${EMPTY}    id:shared-CollectionsBrowser
    Should be true    ${result}

Moved to Named VOD Collection
    [Documentation]  This keyword navigates to the specified named collection in the present vod screen
    ...    Precondition: Already on the required vod screen with first item focussed
    [Arguments]  ${collection_name}
     ${collection_name}=  Convert To Lower Case  ${collection_name}
     Wait Until Keyword Succeeds    ${DEFAULT_RETRY_TIMEOUT}   ${DEFAULT_RETRY_INTERVAL}    Is in Collection Browser
     : FOR    ${Index}    IN RANGE   1    50
     \    Get Ui Focused Elements
     \    ${current_collection_title}    set variable  ${EMPTY}
     \    ${status}     Is in json    ${LAST_FETCHED_FOCUSED_ELEMENTS}   ${EMPTY}   id:shared-CollectionsBrowser_collection_[\\d]$    ${EMPTY}    ${True}
     \    ${current_collection_title}    run keyword if  ${status}    Extract Value For Key    ${LAST_FETCHED_FOCUSED_ELEMENTS}    id:shared-CollectionsBrowser_collection_[\\d]$    title    ${True}
     \    ${current_collection_title}    run keyword if   "${current_collection_title}" != "None"
     \    ...    Convert string to lower case    ${current_collection_title}
     \    ...    ELSE    Set Variable    ${current_collection_title}
     \    Log     ${current_collection_title}
     \    exit for loop if    "${current_collection_title}" == "${collection_name}"
     \    I Press    DOWN
     \    I wait for 2 seconds



Moved to Named Collection
    [Documentation]  This keyword navigates to the specified named collection in the present vod screen
    ...    Precondition: Already on the required vod screen with first item focussed
    [Arguments]  ${collection_name}
     ${collection_name}=  Convert To Lower Case  ${collection_name}
     Wait Until Keyword Succeeds    ${DEFAULT_RETRY_TIMEOUT}   ${DEFAULT_RETRY_INTERVAL}    Is in Collection Browser
     : FOR    ${Index}    IN RANGE   1    50
     \    Get Ui Focused Elements
     \    ${current_collection_title}    set variable  ${EMPTY}
     \    ${status}     Is in json    ${LAST_FETCHED_FOCUSED_ELEMENTS}   ${EMPTY}   id:shared-CollectionsBrowser_collection_[\\d]$    ${EMPTY}    ${True}
     \    ${data}    run keyword if  ${status}    Extract Value For Key    ${LAST_FETCHED_FOCUSED_ELEMENTS}    id:shared-CollectionsBrowser_collection_[\\d]$    data    ${True}
     \    ${current_collection_title}    run keyword if  ${status}    Extract Value For Key    ${data}    ${EMPTY}    id    ${True}
     \    ${current_collection_title}    run keyword if   "${current_collection_title}" != "None"
     \    ...    Convert string to lower case    ${current_collection_title}
     \    ...    ELSE    Set Variable    ${current_collection_title}
     \    Log     ${current_collection_title}
     \    exit for loop if    "${current_collection_title}" == "${collection_name}"
     \    I Press    DOWN
     \    I wait for 2 seconds


Moved to Named Tile in Collection
    [Documentation]  This keyword navigates to the specified named tile in the present collection
    ...    Precondition: Already on the required vod collection
    ...    Set json_index = 1 for search in current row, 0 for entire screen
    [Arguments]  ${title}    ${searchCurrentRow}=${True}
     Wait Until Keyword Succeeds    ${DEFAULT_RETRY_TIMEOUT}   ${DEFAULT_RETRY_INTERVAL}    Is in Collection Browser
     : For    ${Index}    IN RANGE    1    50
     \    Get Ui Focused Elements
     \    ${current_tile_json}    Get From List    ${LAST_FETCHED_FOCUSED_ELEMENTS}    ${-1}
     \    ${current_tile_title}    Extract Value For Key    ${current_tile_json}    ${EMPTY}    title
     \    log to console     ${current_tile_title}
     \    exit for loop if    "${current_tile_title}" == "${title}"
     \    I Press    RIGHT
     \    I wait for 2 seconds

Convert string to lower case
    [Documentation]    Split the Recording name and fetch only Episode part
    [Arguments]    ${string_to_convert}
    log    ${string_to_convert}
    ${string_to_convert}=  Convert To Lower Case  ${string_to_convert}
    [Return]    ${string_to_convert}

Get Title of Tile at Position in Grid
    [Documentation]  This keyword navigates to the specified named tile in the present collection
    ...    Precondition: Already on the required vod collection
    [Arguments]  ${position}
     Wait Until Keyword Succeeds    ${DEFAULT_RETRY_TIMEOUT}   ${DEFAULT_RETRY_INTERVAL}    Is in Collection Browser
     Get Ui Focused Elements
     @{tiles}    Extract Value For Key    ${LAST_FETCHED_FOCUSED_ELEMENTS}    id:shared-CollectionsBrowser    data
     ${title}    Extract Value For Key    @{tiles}[${position}]    ${EMPTY}    title
     [Return]    ${title}

Second Level VOD Screen is Shown
    [Documentation]   Verifies whether the second level VOD Screen is reached
    [Arguments]    ${SCREEN_TITLE}
    Get Ui Json
    #${sub_heading}    extract value for key    ${LAST_FETCHED_JSON_OBJECT}    id:mastheadSecondaryTitle    textValue
    #should be true      """${sub_heading}""" == """${SCREEN_TITLE}"""    Sub section Title is not shown
    ${vod_tile_posters}    Is In Json    ${LAST_FETCHED_JSON_OBJECT}    ${EMPTY}
     ...   id:shared-CollectionsBrowser_collection_[\\d]+_tile_[\\d]+_primaryTitle    ${EMPTY}    ${True}
    should be true    ${vod_tile_posters}    Posters are not shown