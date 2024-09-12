*** Settings ***
Documentation     Common keywords for Collection navigation in Vod/Saved/Apps
Resource          ./CollectionBrowser_Implementation.robot

*** Variables ***
${MAX_NUMBER_OF_COLLECTIONS}    30

*** Keywords ***
Move Focus to Collection with tile type
    [Arguments]    ${tile_type}
    [Documentation]    Move the focus to a collection identified by the ${tile_type} id pattern
    ${down_status}    Run keyword and return status    Move to element assert focused elements    id:${tile_type}_0    10    DOWN
    ${up_status}    Run keyword if    ${down_status} == ${False}    Run keyword and return status    Move to element assert focused elements    id:${tile_type}_0    10
    ...    UP
    Should be true    ${down_status} or ${up_status}    could not find a Collection with tile type

Move Focus to Collection named    #USED
    [Arguments]    ${collection_name}
    [Documentation]    Move the focus to a collection identified by the ${collection_name} attribute
    Move Focus to Collection Browser
    ${position}    Get Collection Position in Collection Browser    ${collection_name}    title
    Move Focus to Collection Position    ${position}

Move Focus to Collection Position
    [Arguments]    ${position}
    [Documentation]    Move the focus to a specific collection position identified by the ${position} argument.
    ...    The Collection Browser component first be focused (via `Move Focus to Collection Browser`).
    ${focused_position}    Get Focused Collection Position
    Return from Keyword if    ${position} == ${focused_position}
    ${distance}    Evaluate    abs(${position} - ${focused_position})
    ${arrow}    Set Variable If    ${position} > ${focused_position}    DOWN    UP
    : FOR    ${_}    IN RANGE    ${distance}
    \    Move Focus to direction and assert    ${arrow}

Move Focus to Grid Collection
    [Documentation]    Move the focus the first found Grid collection in a collection browser
    Move Focus to Collection Browser
    : FOR    ${_}    IN RANGE    ${NUMBER_OF_LAST_FETCHED_FOCUSED_COLLECTIONS}
    \    Get Current Collection Tiles
    \    Return From Keyword if    ${IS_GRID_COLLECTION}
    \    Move Focus to direction and assert    DOWN    ${5}
    FAIL    Grid Collection not found

Move Focus to Editorial Collection
    [Documentation]    Move the focus the first found Grid collection in a collection browser
    Move Focus to Collection Browser
    : FOR    ${_}    IN RANGE    ${NUMBER_OF_LAST_FETCHED_FOCUSED_COLLECTIONS}
    \    Get Current Collection Tiles
    \    Return From Keyword if    ${IS_EDITORIAL_TILE}
    \    Move Focus to direction and assert    DOWN    ${5}
    FAIL    Editorial Collection not found

Move Focus to Collection with Tile    #USED
    [Arguments]    ${tile}    ${key}=id
    [Documentation]    Move the focus to a collection containing a Tile identified by the ${tile} argument
    ...    The second argument ${key} (id by default) specifies which Tile property to look for (ex: title).
    ${is_age_rated_vod}    Run Keyword And Return Status    Variable Should Exist    ${NAVIGATE_TO_AGE_RATED_VOD_ASSET}
    ${total_collections}    Set Variable    ${0}
    ${is_navigation_bar_focused}    Run Keyword And Return Status    I expect focused elements contains 'id:shared-SectionNavigation'
    Run Keyword If    ${is_navigation_bar_focused}    I Press    DOWN
    ${is_promos_focused}    Run Keyword And Return Status    I expect focused elements contains 'id:shared-CollectionsBrowser_promotionalCollection_0'
    Run Keyword If    ${is_promos_focused}    I Press    DOWN
    ${is_collection_focused}    Run Keyword And Return Status    I expect focused elements contains 'id:shared-CollectionsBrowser'
    ${collections_list}    Run Keyword If    ${is_collection_focused}    I retrieve value for key 'items' in focused element 'id:shared-CollectionsBrowser'
    ${total_collections}    Run Keyword If    ${collections_list}    get length    ${collections_list}
    ${number_of_collections}    Set Variable If    ${total_collections}    ${total_collections}    ${MAX_NUMBER_OF_COLLECTIONS}
    ${is_target_collection_focused}    Run Keyword And Return Status    Move to collection with element assert focused elements    ${key}    ${tile}    ${number_of_collections}    DOWN    ${is_age_rated_vod}
    Return From Keyword If    ${is_target_collection_focused}
    ${is_target_collection_focused}    Run Keyword And Return Status    Move to collection with element assert focused elements    ${key}    ${tile}    ${number_of_collections}    UP    ${is_age_rated_vod}
    Should be True    ${is_target_collection_focused}    No Collection found with Tile ${tile} in current section

#***********************************CPE PERFORMANCE******************************************************
Navigate To Filter    #USED
    [Documentation]    Navigates to given filter option
    [Arguments]     ${filter}
    :FOR    ${i}    IN RANGE    0    10
    \    ${focused_element}    Get Ui Focused Elements
    \    ${filter_present}    is in json    ${focused_element}    ${EMPTY}    textKey:${filter}    ${EMPTY}    ${False}
    \    Run Keyword If    '${filter_present}' == 'False'    I Press    RIGHT
    \    Exit For Loop If    ${filter_present}
    Should Be True    ${filter_present}    'sort button not found'