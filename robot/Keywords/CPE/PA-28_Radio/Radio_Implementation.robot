*** Settings ***
Documentation     Radio Implementation Keywords
Resource          ../Common/Common.robot
Resource          ../Common/Stbinterface.robot
Resource          ../PA-04_User_Interface/MainMenu_Keywords.robot

*** Keywords ***
Get Radio tile id
    [Documentation]    This keyword gets the Radio tile id by checking the parent node of DIC_CONTEXTUAL_MAIN_MENU_RADIO
    ${radio_tile_node}    I retrieve json ancestor of level '2' in element 'id:contextualMainMenu-navigationContainer-TVGUIDE_element.*' for element 'textKey:DIC_CONTEXTUAL_MAIN_MENU_RADIO' using regular expressions
    [Return]    ${radio_tile_node['id']}

'${tile_index}' radio grid tile is not focused when focus is in grid
    [Documentation]    This keyword verifies that specified tile is not focused when the focus is in the grid
    ${grid_page_data}    Extract Value For Key    ${LAST_FETCHED_FOCUSED_ELEMENTS}    id:shared-CollectionsBrowser    data
    ${tile_id}    Set Variable    ${grid_page_data[${tile_index}-1]['id']}
    ${status}    run keyword and return status    Tile is Focused    ${tile_id}    id
    Should Not Be True    ${status}    '${tile_index}' radio grid tile is focused
