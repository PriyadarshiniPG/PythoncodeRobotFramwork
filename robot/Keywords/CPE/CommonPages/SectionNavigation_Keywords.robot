*** Settings ***
Documentation     Common keywords for navigation in Vod/Saved/Apps
Resource          ./SectionNavigation_Implementation.robot

*** Keywords ***
Move Focus to Section    #USED
    [Arguments]    ${value}    ${key}=id    ${max_number_of_sections}=20
    [Documentation]    Move the focus to the section which data property ${key} (id by default) has for value ${value}
    ...    It requires a section navigation component to be focused.
    ${key_is_not_id}    Evaluate    '${key}' != 'id'
    ${key_is_not_title}    Evaluate    '${key}' != 'title'
    Run keyword if    ${key_is_not_id} and ${key_is_not_title}    Run keywords    Move to element assert focused elements    ${key}:${value}    ${max_number_of_sections}    RIGHT
    ...    AND    Return From Keyword
    ${sections}    ${number_of_sections}    Get Current Sections
    ${focused_position}    Get Focused Section Position    ${LAST_FETCHED_FOCUSED_ELEMENTS}
    ${position}    Set Variable    ${-1}
    : FOR    ${current_section}    IN    @{sections}
    \    ${position}    Set Variable    ${position + 1}
    \    ${found}    Evaluate    '${current_section['${key}']}' == '${value}'
    \    Return From Keyword if    ${found} and ${position} == ${focused_position}
    \    Exit For Loop If    ${found}
    Should be True    ${found}    Section '${value}' not found in ${sections}
    Move Focus to Section Position    ${position}    ${number_of_sections}
    Section is Focused    ${value}    ${key}

Move Focus to Section for app    #USED
    [Arguments]    ${value}    ${key}=id    ${max_number_of_sections}=8
    [Documentation]    Move the focus to the section which data property ${key} (id by default) has for value ${value}
    ...    It requires a section navigation component to be focused.
    ${key_is_not_id}    Evaluate    '${key}' != 'id'
    ${key_is_not_title}    Evaluate    '${key}' != 'title'
    Run keyword if    ${key_is_not_id} and ${key_is_not_title}    Run keywords    Move to element assert focused elements    ${key}:${value}    ${max_number_of_sections}    RIGHT
    ...    AND    Return From Keyword
    ${sections}    ${number_of_sections}    Get Current Sections for app
    ${focused_position}    set variable  ${0}
    ${position}    Set Variable    ${-1}
    : FOR    ${current_section}    IN    @{sections}
    \    ${position}    Set Variable    ${position + 1}
    \    ${found}    Evaluate    '${current_section['${key}']}' == '${value}'
    \    Return From Keyword if    ${found} and ${position} == ${focused_position}
    \    Exit For Loop If    ${found}
    Should be True    ${found}    Section '${value}' not found in ${sections}
    Move Focus to Section Position    ${position}    ${number_of_sections}
    Section is Focused    ${value}    ${key}

Move Focus to Section Position
    [Arguments]    ${position}    ${number_of_sections}=${None}
    [Documentation]    Move the focus to a specific section position if a section navigation component is focused.
    ${focused_position}    Get Focused Section Position    ${LAST_FETCHED_FOCUSED_ELEMENTS}
    Return from Keyword if    ${position} == ${focused_position}
    ${sections}    ${number_of_sections}    Run keyword If    ${number_of_sections} == ${None}    Get Current Sections
    ...    ELSE    Set Variable    ${None}    ${number_of_sections}
    ${distance_without_loop}    Evaluate    abs(${position} - ${focused_position})
    ${distance_with_loop}    Evaluate    abs(${number_of_sections} + ${focused_position} - ${position})
    ${left_distance}    Set Variable If    ${position} < ${focused_position}    ${distance_without_loop}    ${distance_with_loop}
    ${right_distance}    Set Variable If    ${position} > ${focused_position}    ${distance_without_loop}    ${distance_with_loop}
    ${distance}    Evaluate    min([${left_distance}, ${right_distance}])
    ${arrow}    Set Variable If    ${left_distance} > ${right_distance}    RIGHT    LEFT
    : FOR    ${_}    IN RANGE    ${distance}
    \    Move Focus to direction and assert    ${arrow}    ${5}
    Error popup is not shown
    Section Position is Focused    ${position}

Check Section is Focused
    [Arguments]    ${value}    ${key}=id
    [Documentation]    Check if the section which data property ${key} (id by default) has for value ${value} is focused
    ${key_is_not_id}    Evaluate    '${key}' != 'id'
    ${key_is_not_title}    Evaluate    '${key}' != 'title'
    Run keyword if    ${key_is_not_id} and ${key_is_not_title}    Run keywords    I expect focused element '${SECTION_NAVIGATION_ITEM_ID_PATTERN}' contains '${key}:${value}' using regular expressions
    ...    AND    Return From Keyword
    ${sections}    ${number_of_sections}    Get Current Sections
    ${focused_position}    Get Focused Section Position    ${LAST_FETCHED_FOCUSED_ELEMENTS}
    Should be Equal    ${value}    ${sections[${focused_position}]['${key}']}    Section is not focused: ${key}:${value}

Section is Focused
    [Arguments]    ${value}    ${key}=id
    [Documentation]    Check Multiple times if the section which data property ${key} (id by default) has for value ${value} is focused
    wait until keyword succeeds    ${JSON_MAX_RETRIES}    ${JSON_RETRY_INTERVAL}    Check Section is Focused    ${value}    ${key}
    Error popup is not shown

Check Section Position is Focused
    [Arguments]    ${position}
    [Documentation]    Check if the given section position is focused
    ${position}    Convert to Integer    ${position}
    ${focused_position}    Get Focused Section Position
    Should be Equal    ${position}    ${focused_position}    Section ${position} is not focused

Section Position is Focused
    [Arguments]    ${position}
    [Documentation]    Check Multiple times if the given section position is focused
    wait until keyword succeeds    ${JSON_MAX_RETRIES}    ${JSON_RETRY_INTERVAL}    Check Section Position is Focused    ${position}

Focused Section is Highlighted
    [Documentation]    Check if the identified focused section use the right highlighted color
    ${focused_section}    I retrieve json ancestor of level '1' for focused element '${SECTION_NAVIGATION_ITEM_ID_PATTERN}' using regular expressions
    ${text_color}    Extract Value For Key    ${focused_section}    ${EMPTY}    color
    should be equal    ${text_color}    ${HIGHLIGHTED_NAVIGATION_COLOUR}    Focused Section isn't correctly highlighted

Top level Section Navigation is focused
    [Documentation]    Verify the Section Navigation at the top is focused
    wait until keyword succeeds    ${JSON_MAX_RETRIES}    ${JSON_RETRY_INTERVAL}    I expect focused elements contains '${SECTION_NAVIGATION_ITEM_ID_PATTERN}' using regular expressions

#********** CPE PERFORMANCE TESTING**********
I navigate CMM
    [Arguments]    ${value}    ${key}=id
    [Documentation]
    wait until keyword succeeds    10 times    0    Move Focus to Section in CMM    ${value}    ${key}

Move Focus to Section in CMM    #USED
    [Arguments]    ${value}    ${key}=id    ${max_number_of_sections}=8
    [Documentation]    Move the focus to the section which data property ${key} (id by default) has for value ${value}
    ...    It requires a section navigation component to be focused.
    ${key_is_not_id}    Evaluate    '${key}' != 'id'
    ${key_is_not_title}    Evaluate    '${key}' != 'title'
    Run keyword if    ${key_is_not_id} and ${key_is_not_title}    wait until keyword succeeds    10 times    0    Move to element assert focused elements for PHS    ${key}:${value}    ${max_number_of_sections}    RIGHT    0

I navigate PHS rails
    [Arguments]    ${id}
    [Documentation]
    wait until keyword succeeds    10 times    0    Move Focus to Rail in PHS    ${id}

Move Focus to Rail in PHS
    [Documentation]  This keyword navigates to the specified named rail in PHS
    ...    Precondition: Already on PHS
    [Arguments]  ${rail_name}
    ${rail_name}=  Convert To Lower Case  ${rail_name}
    Get Ui Focused Elements
    ${current_rail_title}    set variable  ${EMPTY}
    ${status}     Is in json    ${LAST_FETCHED_FOCUSED_ELEMENTS}   ${EMPTY}   id:shared-CollectionsBrowser_collection_[\\d]$    ${EMPTY}    ${True}
    ${focused_rail_data}    run keyword if  ${status}    Extract Value For Key    ${LAST_FETCHED_FOCUSED_ELEMENTS}    id:shared-CollectionsBrowser_collection_[\\d]$    data    ${True}
    ${focused_rail_events}    run keyword if  ${status}    Extract Value For Key    ${focused_rail_data}    ${EMPTY}    items    ${True} 
    Log     ${focused_rail_events}     
    ${current_rail_title}    run keyword if  ${status}    Extract Value For Key    ${focused_rail_data}    ${EMPTY}    id    ${True}
    Should Not Be Empty    ${focused_rail_events}    Events not loaded in rail ${current_rail_title}
    ${current_rail_title}    run keyword if   "${current_rail_title}" != "None"
    ...    Convert string to lower case    ${current_rail_title}
    ...    ELSE    Set Variable    ${current_rail_title}
    Log     ${current_rail_title}
    Should be True    "${current_rail_title}" == "${rail_name}"   Correct rail not focused

CMM modify textValue
    [Arguments]    ${section_id}
    [Documentation]    Add space for search and settings text value
    ${section_id} =   Catenate    SEPARATOR=    ${section_id}    ${SPACE}
    [Return]    ${section_id}

Move Focus to Section for Saved Search    #USED
    [Arguments]    ${value}    ${key}=id    ${max_number_of_sections}=20
    [Documentation]    Move the focus to the section which data property ${key} (id by default) has for value ${value}
    ...    It requires a section navigation component to be focused.
    ${key_is_not_id}    Evaluate    '${key}' != 'id'
    ${key_is_not_title}    Evaluate    '${key}' != 'title'
    Run keyword if    ${key_is_not_id} and ${key_is_not_title}    Run keywords    Move to element assert focused elements    ${key}:${value}    ${max_number_of_sections}    UP
    ...    AND    Return From Keyword
    ${sections}    ${number_of_sections}    Get Current Sections
    ${focused_position}    Get Focused Section Position    ${LAST_FETCHED_FOCUSED_ELEMENTS}
    ${position}    Set Variable    ${-1}
    : FOR    ${current_section}    IN    @{sections}
    \    ${position}    Set Variable    ${position + 1}
    \    ${found}    Evaluate    '${current_section['${key}']}' == '${value}'
    \    Return From Keyword if    ${found} and ${position} == ${focused_position}
    \    Exit For Loop If    ${found}
    Should be True    ${found}    Section '${value}' not found in ${sections}
    Move Focus to Section Position    ${position}    ${number_of_sections}
    Section is Focused    ${value}    ${key}

Move to element assert focused elements for PHS
    [Arguments]    ${elem}    ${max_range}    ${arrow}    ${delay}=${MOVE_ANIMATION_DELAY}
    [Documentation]    This keyword checks if the given element is part of the focused elements, and tries to navigate
    ...    to it pressing the ${arrow} key a max of ${max_range} times waiting ${delay}ms between key presses.
    ${elem_is_focused}    set variable    ${False}
    : FOR    ${_}    IN RANGE    ${max_range}
    \    I wait for ${delay} ms
#    \    I Press    ${arrow}
    \    ${elem_is_focused}    run keyword and return status    I expect focused elements contains '${elem}'
    \    exit for loop if    ${elem_is_focused}
    should be true    ${elem_is_focused}    Given element '${elem}' is not in focused elements
