*** Settings ***
Documentation     Common keywords for navigation in Vod/Saved/Apps
Resource          ./Collection_Implementation.robot

*** Keywords ***
Poster tile is focused
    [Documentation]    This keyword verifies if any type of poster tile is focused.
    wait until keyword succeeds    ${JSON_MAX_RETRIES}    ${JSON_RETRY_INTERVAL}    I expect focused elements contains '${TILE_NODE_ID_HIGH_PATTERN}' using regular expressions

Tile is Focused
    [Arguments]    ${tile}    ${key}=id
    [Documentation]    Assert if the tile identified by the ${tile} argument is focused
    ...    The second argument ${key} (id by default) specifies which Tile property to look for (ex: title).
    ${focused_tile}    Get Focused Tile    ${key}
    Should Be Equal    ${focused_tile}    ${tile}    The tile ${tile} is not focused

Move Focus to Tile
    [Arguments]    ${tile}    ${key}=id
    [Documentation]    Move the focus to a Tile identified by the ${tile} argument
    ...    The second argument ${key} (id by default) specifies which Tile property to look for (ex: title).
    ${tile_position}    Get Tile Position in Collection    ${tile}    ${key}
    ${focused_position}    Get Focused Tile Position
    Return from keyword if    ${focused_position} == ${tile_position}
    wait until keyword succeeds    20times    3s    Make sure that Focus is on Tile    ${tile}    ${key}

Move Focus to Tile Position
    [Arguments]    ${tile_position}
    [Documentation]    Move the focus to a tile identified by ths ${tile_position} argument
    ${focused_position}    Get Focused Tile Position
    Return from keyword if    ${focused_position} == ${tile_position}
    Run Keyword If    ${tile_position} > ${MAX_TILES_PER_COLLECTION}    Run Keywords    Open Grid And Move Focus to Tile Position    ${tile_position-1}
    ...    AND    Return From Keyword
    ${distance_without_loop}    Evaluate    abs(${tile_position} - ${focused_position})
    ${distance_with_loop}    Evaluate    abs(${LAST_EVALUATED_TILES_NUMBER} + ${focused_position} - ${tile_position})
    ${left_distance}    Set Variable If    ${tile_position} < ${focused_position}    ${distance_without_loop}    ${distance_with_loop}
    ${right_distance}    Set Variable If    ${tile_position} > ${focused_position}    ${distance_without_loop}    ${distance_with_loop}
    ${distance}    Evaluate    min([${left_distance}, ${right_distance}])
    ${arrow}    Set Variable If    ${left_distance} > ${right_distance}    RIGHT    LEFT
    : FOR    ${_}    IN RANGE    ${distance}
    \    Move Focus to direction and assert    ${arrow}    ${5}

Make sure that Focus is on Tile
    [Arguments]    ${tile}    ${key}=id
    [Documentation]    Move the focus to a Tile identified by the ${tile} argument
    ...    The second argument ${key} (id by default) specifies which Tile property to look for (ex: title).
    I Press   RIGHT
    Tile is Focused    ${tile}    ${key}

Move Focus to Tile Position in Replay Catalog    #USED
    [Arguments]    ${tile_position}
    [Documentation]    Move the focus to a tile identified by ths ${tile_position} argument
    ${focused_position}    Get Focused Tile Position
    Return from keyword if    ${focused_position} == ${tile_position}
    Run Keyword If    ${tile_position} > ${MAX_TILES_PER_COLLECTION}    Run Keywords    Open Grid And Move Focus to Tile Position    ${tile_position-1}
    ...    AND    Return From Keyword
    ${distance_without_loop}    Evaluate    abs(${tile_position} - ${focused_position})
    ${distance_with_loop}    Evaluate    abs(${LAST_EVALUATED_TILES_NUMBER} + ${focused_position} - ${tile_position})
    ${distance}    Set Variable If    ${tile_position} > ${focused_position}    ${distance_without_loop}    ${distance_with_loop}
    : FOR    ${_}    IN RANGE    ${distance}
    \    Move Focus to direction and assert    RIGHT    ${5}