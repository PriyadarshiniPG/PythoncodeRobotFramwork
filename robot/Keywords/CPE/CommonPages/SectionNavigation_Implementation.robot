*** Settings ***
Documentation     Common keywords for navigation in Vod/Saved/Apps
Resource          ../Common/Common.robot

*** Variables ***
${SECTION_NAVIGATION_ITEM_ID_PATTERN}    id:(saved/.+|SectionNavigationListItem-.+)
#${SECTION_NAVIGATION_LIST_ID_PATTERN}    (^SectionNavigationList.*|^crid.*)
${SECTION_NAVIGATION_LIST_ID_PATTERN}    (^SectionNavigationList.*|^scCo_.*)

*** Keywords ***
Get Focused Sections Json Data
    [Documentation]    Returns the sections data if available
    ${focused_elements}    Get Ui Focused Elements
    ${has_sections}    Is In Json    ${focused_elements}    ${EMPTY}    id:${SECTION_NAVIGATION_LIST_ID_PATTERN}    ${EMPTY}    ${True}
    Should be True    ${has_sections}    Section data not found. Section Navigation probably not focused: ${focused_elements}
    : FOR    ${element}    IN    @{focused_elements}
    \    ${found}    run keyword and return status    Should Match Regexp    ${element['id']}    ${SECTION_NAVIGATION_LIST_ID_PATTERN}
    \    Exit For Loop If    ${found}
    \    ${previous}    Set Variable    ${element}
    ${sections}    Extract Value For Key    ${previous}    ${EMPTY}    data
    Should not be Empty    ${sections}    Sections not found in focused elements: ${focused_elements}
    [Return]    ${sections}

Get Focused Sections Json Data for app
    [Documentation]    Returns the sections data if available
    ${focused_elements}    Get Ui Focused Elements
    ${has_sections}    Is In Json    ${focused_elements}    ${EMPTY}    id:shared-SectionNavigation   ${EMPTY}    ${True}
    Should be True    ${has_sections}    Section data not found. Section Navigation probably not focused: ${focused_elements}
    ${temp_dict}    Get from list   ${focused_elements}   ${0}
    ${temp_list}    get from dictionary  ${temp_dict}   data
    : FOR    ${element}    IN    @{temp_list}
    \    ${found}    run keyword and return status    Should Match Regexp    ${element['id']}    id:.*
    \    Exit For Loop If    ${found}
    \    ${previous}    Set Variable    ${element}
    ${sections}    create list
    append to list  ${sections}  ${previous}
    Should not be Empty    ${sections}    Sections not found in focused elements: ${focused_elements}
    [Return]    ${sections}

Get Current Sections
    [Documentation]    Returns the sections of the current menu and how many they are
    ${sections}    wait until keyword succeeds    5 times    500 ms    Get Focused Sections Json Data
    ${number_of_sections}    Get Length    ${sections}
    [Return]    ${sections}    ${number_of_sections}

Get Current Sections for app
    [Documentation]    Returns the sections of the current menu and how many they are
    ${sections}    wait until keyword succeeds    5 times    500 ms    Get Focused Sections Json Data for app
    ${number_of_sections}    Get Length    ${sections}
    [Return]    ${sections}    ${number_of_sections}

Get Focused Section Position
    [Arguments]    ${focused_elements}=${None}
    [Documentation]    Returns the focused section position
    ${focused_elements}    Run Keyword If    ${focused_elements} == ${None}    Get Ui Focused Elements
    ...    ELSE    Set Variable    ${focused_elements}
    ${node_id}    Extract Value For Key    ${focused_elements}    ${SECTION_NAVIGATION_ITEM_ID_PATTERN}    id    ${True}
    ${item_prefix}    ${focused_position}    split string    ${node_id}    -
    ${focused_position}    Convert To Integer    ${focused_position}
    [Return]    ${focused_position}

Move Focus to the top level Section Navigation
    [Documentation]    This keyword moves the focus to the navigation section list at the top of the screen by
    ...    pressing the MENU key if it is not already focused.
    ${top_level_is_focused}    run keyword and return status    I expect focused elements contains 'title:DIC_SETTINGS_.*' using regular expressions
    return from keyword if    ${top_level_is_focused}
    I press    MENU
    wait until keyword succeeds    ${JSON_MAX_RETRIES}    ${JSON_RETRY_INTERVAL}    I expect focused elements contains 'title:DIC_SETTINGS_.*' using regular expressions
