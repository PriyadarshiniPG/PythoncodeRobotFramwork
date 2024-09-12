*** Settings ***
Documentation     Common keywords for navigation in Vod/Saved/Apps
Resource          ../Common/Common.robot

*** Variables ***
${GRID_PAGE_NODE_ID_PATTERN}    id:.*CollectionsBrowser
${GRID_LINK_NODE_ID_PATTERN}    id:.+gridEntryTile
${GRID_TILE_NODE_ID_PATTERN}    id:.*CollectionsBrowser_collection_.*_tile_.*
${NB_TILES_PER_GRID_ROW}    7

*** Keywords ***
Grid Page is opened
    [Documentation]    Wait for the Grid page to be open & loaded
    wait until keyword succeeds    ${JSON_MAX_RETRIES}    ${JSON_RETRY_INTERVAL}    I expect page contains 'id:VodGrid.View'

Grid Tile is Focused
    [Documentation]    Return ${True} if a non empty grid tile is focused
    wait until keyword succeeds    ${JSON_MAX_RETRIES}    ${JSON_RETRY_INTERVAL}    I expect focused elements contains '${GRID_TILE_NODE_ID_PATTERN}' using regular expressions

Get Tile Position in Grid Page
    [Arguments]    ${tile}    ${key}=id    ${current_row}=${0}
    [Documentation]    Get the position of a tile, identified by the ${tile_id_or_name} argument in a Grid Page.
    ...    The second argument ${key} (id by default) specifies which Tile property to look for (ex: title).
    ${tiles}    I retrieve value for key 'items' in focused element '${GRID_PAGE_NODE_ID_PATTERN}' using regular expressions
    ${position}    Set Variable    ${0}
    : FOR    ${current_tile}    IN    @{tiles}
    \    LOG    ${position}
    \    ${value}    Extract Value For Key    ${current_tile}    ${EMPTY}    ${key}
    \    ${need_load_more}    Evaluate    "${value}" == "${None}"
    \    Exit For Loop If    ${need_load_more}
    \    Return From Keyword if    "${value}" == "${tile}"    ${position}    ${current_row}
    \    ${position}    Set Variable    ${position + 1}
    Should be True    ${need_load_more}    Could not find the position of the tile ${key}:${tile}
    Move Focus to direction and assert    DOWN
    Move Focus to direction and assert    DOWN
    ${current_row}    Set Variable    ${current_row + 2}
    ${position}    ${current_row}    Get Tile Position in Grid Page    ${tile}    ${key}    ${current_row}
    [Return]    ${position}    ${current_row}

Move Focus to Grid Link    #USED
    [Documentation]    Move the focus to the Grid Link Tile of the focused Grid Collection
    Move to element assert focused elements using regular expression    ${GRID_LINK_NODE_ID_PATTERN}    ${MAX_TILES_PER_COLLECTION}    LEFT

Move Focus to Grid Link and open Grid Page
    [Documentation]    Move the focus to the Grid Link Tile of the focused Grid Collection and open its Grid Page
    Move Focus to Grid Link
    Send Key    OK
    Grid Page is opened

Move Focus to Tile Position in Grid Page
    [Arguments]    ${position}    ${current_row}=${0}
    [Documentation]    Move the focus to the position specified by the ${position} argument within the Grid Page
    ${position_col}    Evaluate    (${position} % ${NB_TILES_PER_GRID_ROW})
    ${position_row}    Evaluate    ((${position} - ${position_col}) / ${NB_TILES_PER_GRID_ROW} ) - ${current_row}
    : FOR    ${_}    IN RANGE    ${position_row}
    \    Move Focus to direction and assert    DOWN    ${2}
    : FOR    ${_}    IN RANGE    ${position_col}
    \    Move Focus to direction and assert    RIGHT    ${2}

Move Focus to Tile in Grid Page
    [Arguments]    ${tile}    ${key}=id
    [Documentation]    Move the focus to a Tile identified by the ${tile} argument in the Grid Page
    ...    The second argument ${key} (id by default) specifies which Tile property to look for (ex: title).
    ${grid_tile_is_focused}    run keyword and return status    Grid Tile is Focused
    Run Keyword if    ${grid_tile_is_focused} == ${False}    Move Focus to direction and assert    DOWN
    wait until keyword succeeds    ${JSON_MAX_RETRIES}    ${JSON_RETRY_INTERVAL}    I expect focused elements contains 'id:.*CollectionsBrowser_collection_.*_tile_.*' using regular expressions
    ${grid_page_data}    Extract Value For Key    ${LAST_FETCHED_FOCUSED_ELEMENTS}    ${GRID_PAGE_NODE_ID_PATTERN}    data    ${True}
    ${no_available_data}    Run Keyword And Return Status    Should Be Equal    ${grid_page_data}    ${None}
    Run keyword if    ${no_available_data} == ${True}    Run keywords    Move to element assert focused elements    ${key}:${tile}    70    RIGHT
    ...    AND    return from keyword
    ${position}    ${current_row}    Get Tile Position in Grid Page    ${tile}    ${key}
    Move Focus to Tile Position in Grid Page    ${position}    ${current_row}

Open Grid And Move Focus to Tile Position
    [Arguments]    ${tile_position}    ${current_row}=${0}
    [Documentation]    Open Grid of current collection & Move the focus to a tile identified by the ${tile_position} argument
    Move Focus to Grid Link and open Grid Page
    Move Focus to Tile Position in Grid Page    ${tile_position}    ${current_row}
