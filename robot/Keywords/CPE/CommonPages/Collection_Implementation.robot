*** Settings ***
Documentation     Common keywords for navigation within Vod/Saved/Apps/DP Collections
Resource          ./GridPage_Implementation.robot

*** Variables ***
${COLLECTION_NODE_ID_HIGH_PATTERN}    id:.+(aSpotCollection|promotionalCollection|collection_\\\\d+)$
${COLLECTION_NODE_ID_LOW_PATTERN}    id:.+(aSpotCollection|promotionalCollection|collection_\\d+|promotionalCollection_\\d+)$
${TILE_NODE_ID_PATTERN}    id:.+(gridEntryTile|tile_\\\d+|((tile|_grid|_gridLandscape|appGrid)_\\d+))$
${TILE_NODE_ID_HIGH_PATTERN}    id:.+(gridEntryTile|((tile|_grid|_gridLandscape|appGrid)_\\\\d+))$
${GRID_TILE_COUNT_NODE_ID_PATTERN}    gridEntryTile_item_count
${MAX_TILES_PER_COLLECTION}    17

*** Keywords ***
Get Focused Collection data
    [Documentation]    Returns the data of the focused collection
    ${collection_data}    I retrieve value for key 'data' in focused element '${COLLECTION_NODE_ID_LOW_PATTERN}' using regular expressions
    [Return]    ${collection_data}

Get Focused Collection Position
    [Documentation]    Returns the focused collection position in the current collection browser
    ${focused_elements}    Get Ui Focused Elements
    ${data}    Extract Value For Key    ${focused_elements}    ${COLLECTION_NODE_ID_LOW_PATTERN}    data    ${True}
    ${position}    Get Collection Position in Collection Browser    ${data['id']}    id
    [Return]    ${position}

Get Current Collection Tiles
    [Documentation]    Returns a list of the tiles id/title tuples for the current collection
    ...    as well as the number of them.
    ...    The list is also stored in the ${LAST_FETCHED_FOCUSED_TILES}, ${LAST_EVALUATED_TOTAL_TILES_NUMBER},
    ...    ${IS_GRID_COLLECTION}, and ${IS_EDITORIAL_TILE} test variable
    ${collection_data}    Get Focused Collection data
    ${tiles}    Extract Value For Key    ${collection_data}    ${EMPTY}    items
    ${collection_node_id}    Extract Value For Key    ${LAST_FETCHED_FOCUSED_ELEMENTS}    ${COLLECTION_NODE_ID_LOW_PATTERN}    id    ${True}
    ${grid_count}    I retrieve value for key 'textValue' in element 'id:${collection_node_id}_${GRID_TILE_COUNT_NODE_ID_PATTERN}' using regular expressions
    ${is_grid_collection}    Evaluate    '${grid_count}' != '${None}'
    ${total_number_of_tiles}    Run Keyword if    ${is_grid_collection}    Set Variable    ${grid_count}
    ...    ELSE    Get Length    ${tiles}
    ${is_editorial}    Run Keyword if    ${is_grid_collection}    Set Variable    ${False}
    ...    ELSE    Is In Json    ${LAST_FETCHED_FOCUSED_ELEMENTS}    ${TILE_NODE_ID_PATTERN}    items:    ${EMPTY}
    ...    ${True}
    Set Test Variable    ${LAST_FETCHED_FOCUSED_TILES}    ${tiles}
    Set Test Variable    ${LAST_EVALUATED_TOTAL_TILES_NUMBER}    ${total_number_of_tiles}
    Set Test Variable    ${IS_GRID_COLLECTION}    ${is_grid_collection}
    Set Test Variable    ${IS_EDITORIAL_TILE}    ${is_editorial}
    [Return]    ${tiles}    ${total_number_of_tiles}

Get Focused Tile    #USED
    [Arguments]    ${key}=id
    [Documentation]    Returns the title or id of the focused tile.
    ...    The argument ${key} (default to id) specifies which property to look for (ex: title)
    Wait until keyword succeeds    ${JSON_MAX_RETRIES}    ${JSON_RETRY_INTERVAL}    I expect page contains 'id:^.*CollectionsBrowser' using regular expressions
    Get Ui Focused Elements
    ${is_focused_grid_link}    Is In Json    ${LAST_FETCHED_FOCUSED_ELEMENTS}    ${EMPTY}    ${GRID_LINK_NODE_ID_PATTERN}    ${EMPTY}    ${True}
    Return from Keyword if    ${is_focused_grid_link}    GridLink
    Log    ${TILE_NODE_ID_PATTERN}
    ${tile_data}    Extract Value For Key    ${LAST_FETCHED_FOCUSED_ELEMENTS}    ${TILE_NODE_ID_PATTERN}    data    ${True}
    ${is_editorial}    Is In Json    ${tile_data}    ${EMPTY}    items:    ${EMPTY}    ${True}
    Set Test Variable    ${IS_EDITORIAL_TILE}    ${is_editorial}
    ${key}    Set Variable If    ${is_editorial}    title    ${key}
    ${tile_id_or_name}    Extract Value For Key    ${tile_data}    ${EMPTY}    ${key}
    Should be True    """${tile_id_or_name}""" != '${None}'    Could not find Focused Tile Name
    [Return]    ${tile_id_or_name}

Get Focused Tile Position
    [Documentation]    Get the position of the focused tile in its collection
    ${tile_id}    Get Focused Tile
    ${tiles}    ${total_number_of_tiles}    Get Current Collection Tiles
    ${number_of_tiles}    Evaluate    min([${total_number_of_tiles}, ${MAX_TILES_PER_COLLECTION}])
    ${number_of_tiles}    Set Variable If    ${IS_GRID_COLLECTION}    ${number_of_tiles + 1}    ${number_of_tiles}
    Set Test Variable    ${LAST_EVALUATED_TILES_NUMBER}    ${number_of_tiles}
    Return from Keyword if    '${tile_id}' == 'GridLink'    ${0}
    ${focused_position}    Get Tile Position in Collection    ${tile_id}
    [Return]    ${focused_position}

Get Tile Position in Collection
    [Arguments]    ${tile_id_or_name}    ${key}=${EMPTY}
    [Documentation]    Get the position of a tile, identified by the ${tile_id_or_name} argument in a collection.
    ...    The second argument ${key} (id by default or title if editorial tile) specifies which Tile property to look for (ex: title).
    ${tiles}    ${total_number_of_tiles}    Get Current Collection Tiles
    ${position}    Set Variable If    ${IS_GRID_COLLECTION}    ${1}    ${0}
    Should be True    '${IS_EDITORIAL_TILE}' == '${False}' or '${key}' == 'title' or '${key}' == '${EMPTY}'    Wrong identifier for Editorial Tile (supports only title)
    ${key}    Set Variable If    ${IS_EDITORIAL_TILE}    title    ${key}
    ${key}    Set Variable If    '${key}' == '${EMPTY}'    id    ${key}
    : FOR    ${current_tile}    IN    @{LAST_FETCHED_FOCUSED_TILES}
    \    ${value}    Extract Value For Key    ${current_tile}    ${EMPTY}    ${key}
    \    ${found}    Run Keyword And Return Status    Should Be Equal As Strings    ${value}    ${tile_id_or_name}
    \    Return From Keyword if    ${found}    ${position}
    \    ${position}    Set Variable    ${position + 1}
    Should be True    ${found}    Could not find the position of the tile ${tile_id_or_name}

Grid Entry Tile is Focused
    [Documentation]    Check if the focused tile is a grid entry tile
    wait until keyword succeeds    ${JSON_MAX_RETRIES}    ${JSON_RETRY_INTERVAL}    I expect focused elements contains '${GRID_LINK_NODE_ID_PATTERN}' using regular expressions

Grid Entry Tile is not Focused
    [Documentation]    Check if the focused tile is a grid entry tile
    wait until keyword succeeds    ${JSON_MAX_RETRIES}    ${JSON_RETRY_INTERVAL}    I do not expect focused elements contain '${GRID_LINK_NODE_ID_PATTERN}' using regular expressions

Skip grid entry tiles
    [Documentation]    This keyword skips grid entry tiles by pressing RIGHT if a grid entry tile is focused.
    ${grid_link_focused}    Run keyword and return status    Grid Entry Tile is Focused
    Run Keyword If    ${grid_link_focused}    Run keywords    I press    RIGHT
    ...    AND    Wait Until Keyword Succeeds    ${JSON_MAX_RETRIES}    ${JSON_RETRY_INTERVAL}    Grid Entry Tile is not Focused
