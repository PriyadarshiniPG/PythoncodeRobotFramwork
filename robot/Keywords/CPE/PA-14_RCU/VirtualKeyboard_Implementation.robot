*** Settings ***
Documentation     Virtual Keyboard Implementation keywords
Resource          ../Common/Stbinterface.robot
Variables         ../../../Libraries/Stb/VirtualKeyboard.py

*** Variables ***
${ROWS_ON_KEYBOARD}    12
${CURRENT_KB_MODE}    ${KeyboardMode.CHAR}
${CURRENT_KB_IS_CAPS}    ${True}
${KEYBOARD_KEY_NODE_ID_PATTERN}    id:keyboard-key-\\d+-\\d+-OnScreenKeyboardPanelLayout\\w+$

*** Keywords ***
I switch Virtual Keyboard selection mode to Normal
    [Documentation]    Keyword switches keyboard to normal mode. It does not check if Flo mode was enabled before.
    ...    It should be done before this keyword
    ${position}    get position of keyboard character    123
    ${focused_character}    Get Focused Character
    Iterate Over Keyboard In Order To Select Character    123    ${position}    ${True}    ${True}
    Iterate keyboard 1 times in LEFT direction
    ${ancestor}    I retrieve json ancestor of level '1' in element 'id:keyboard-key-1-0-OnScreenKeyboardPanelLayout\\w+$' for element 'id:keyboardKeyInner' using regular expressions
    should be true    "${ancestor['background']['color']}" == "${INTERACTION_COLOUR}"    failed to focus ∞ character
    I press    OK
    ${normal_mode}    I check if Virtual Keyboard is in Normal mode
    Should Be True    ${normal_mode}    Keyboard is not in normal mode

I check if Virtual Keyboard is in Normal mode
    [Documentation]    Verify the virtual keyboard is in normal mode
    ${json_object}    Get UI Json
    ${count}          Set Variable    ${0}
    @{section_json}    Extract Value For Key    ${json_object}    id:OnScreenKeyboardPanelLayoutInputFieldOnScreenKeyboardPanel    children    ${FALSE}
    :FOR    ${item}    IN    @{section_json}
    \    ${status}    Is In Json    ${item}    ${EMPTY}    color:${INTERACTION_COLOUR}
    \    ${count}     Set Variable If    ${status}    ${count+1}    ${count}
    ${normal_mode}    Evaluate    True if ${count}<3 else False
    [Return]    ${normal_mode}

I check if Virtual Keyboard is in Flo mode
    [Documentation]    Verify the virtual keyboard is in Flo mode
    ${json_object}    Get UI Json
    ${count}          Set Variable    ${0}
    @{section_json}    Extract Value For Key    ${json_object}    id:OnScreenKeyboardPanelLayoutInputFieldOnScreenKeyboardPanel    children    ${FALSE}
    :FOR    ${item}    IN    @{section_json}
    \    ${status}    Is In Json    ${item}    ${EMPTY}    color:${INTERACTION_COLOUR}
    \    ${count}     Set Variable If    ${status}    ${count+1}    ${count}
    ${flo_mode}    Evaluate    True if ${count}>1 else False
    [Return]    ${flo_mode}

Get '${character_to_check}' focus
    [Documentation]    Verifies if key on keyboard is focused
    ${character_locator_id} =    Get '${character_to_check}' locator
    ${character_element}    I retrieve value for key 'background' in element '${character_locator_id}' using regular expressions
    ${character_focus}    Evaluate    True if "${character_element['color']}" == "${INTERACTION_COLOUR}" else False
    [Return]    ${character_focus}

Get '${keyboard_cell}' text value
    [Documentation]    Gets text value for key with ID passed as parameter
    ${character_element}    I retrieve value for key 'textValue' in element '${keyboard_cell}' using regular expressions
    [Return]    ${character_element}

Get '${character}' locator
    [Documentation]    Get the locator for the specified character
    ${character} =    Convert To Uppercase    ${character}
    ${character_locator}    Set Variable If    "${character}" == "Y"    id:keyboard-key-0-7-OnScreenKeyboardPanelLayout\\w+$    "${character}" == "H"    id:keyboard-key-1-7-OnScreenKeyboardPanelLayout\\w+$    "${character}" == "N"
    ...    id:keyboard-key-2-7-OnScreenKeyboardPanelLayout\\w+$
    [Return]    ${character_locator}

Set suite variables based on view layout of the virtual keyboard
    [Documentation]    Return properties of the current view of the virtual keyboard
    Wait Until Keyword Succeeds    5 times    0 sec    I expect page contains 'id:OnScreenKeyboardPanel*' using regular expressions
    ${row_0}    Get 'id:keyboard-key-0-1-OnScreenKeyboardPanelLayout\\w+$' text value
    ${row_1}    Get 'id:keyboard-key-1-1-OnScreenKeyboardPanelLayout\\w+$' text value
    ${row_2}    Get 'id:keyboard-key-2-1-OnScreenKeyboardPanelLayout\\w+$' text value
    ${is_caps}    Set Variable If    '${row_1}'=='123' and '${row_0}'=='Aa'    ${True}    '${row_1}'=='ABC' and '${row_0}'=='Aa'    ${True}    '${row_1}'=='123' and '${row_0}'=='aA'
    ...    ${False}    ${False}
    ${is_caps_final}    Set Variable If    ${is_caps} or ('${row_2}'=='ÜÉÏ' and '${row_0}'=='Aa')    ${True}    ${False}
    ${current_kb_mode}    Set Variable If    ('${row_0}'=='Aa' or '${row_0}'=='aA') and ('${row_1}'=='123') and ('${row_2}'=='ÜÉÏ' or '${row_2}'=='üéï')    ${KeyboardMode.CHAR}    '${row_1}'=='abc' or '${row_1}'=='ABC'    ${KeyboardMode.DIGIT}    '${row_1}'=='123' and ('${row_2}'=='UEI' or '${row_2}'=='uei')
    ...    ${KeyboardMode.SPECIAL}
    Set Suite Variable    ${CURRENT_KB_MODE}    ${current_kb_mode}
    Set Suite Variable    ${CURRENT_KB_IS_CAPS}    ${is_caps_final}

Is '${character}' capital
    [Documentation]    is the character capital or not
    ${status}    Run Keyword And Return Status    Should Be Uppercase    ${character}
    ${is_capital}    Evaluate    ${True} if ${status} else ${False}
    ${is_capital}    set variable if    '${character}'=='±'    ${True}    '${character}'=='${SPACE}'    ${CURRENT_KB_IS_CAPS}    '${character}'=='Go'
    ...    ${CURRENT_KB_IS_CAPS}    ${is_capital}
    [Return]    ${is_capital}

Handle Keyboard Icon Exit
    [Documentation]    Handle Exit icon on the keyboard
    I Press    RIGHT
    ${new_column_index}    Set Variable    ${1}
    [Return]    ${new_column_index}

Get Focused Character
    [Documentation]    Get currently focused key on keyboard
    ${ancestor}    I retrieve json ancestor of level '2' in element '${KEYBOARD_KEY_NODE_ID_PATTERN}' for element 'color:${INTERACTION_COLOUR}' using regular expressions
    ${focused_character}    Set Variable    ${ancestor['textValue']}
    ${modified_character}    Replace String    ${focused_character}    ±    ${SPACE}
    [Return]    ${modified_character}

verify focused character is same as search character
    [Arguments]    ${character_to_select}
    [Documentation]    Verifies focused character is same as searched character
    ${focused_character}    Get Focused Character
    Should Be Equal    ${focused_character}    ${character_to_select}    Focused character and search character not the same

Iterate Over Keyboard In Order To Select Character
    [Arguments]    ${character_to_select}    ${position}    ${skip_vertical_steps}=${False}    ${skip_validation}=${False}
    [Documentation]    Iterates over the keyboard to select the specified character
    ${focused_key_id}    Get focused key id
    @{regexp_match}    Get Regexp Matches    ${focused_key_id}    keyboard-key-(\\d+)-(\\d+)-OnScreenKeyboardPanelLayout\\w+$    1    2
    @{match_list}    Set Variable    @{regexp_match}[0]
    ${row_index}    Set Variable    @{match_list}[0]
    ${column_index}    Run Keyword If    '${row_index}' == '1' and '@{match_list}[1]' == '0'    Handle Keyboard Icon Exit
    ...    ELSE    Set Variable    @{match_list}[1]
    ${column_index}=    convert to integer    ${column_index}
    ${column_index}=    set variable    ${column_index - 1}
    ${row_index}=    convert to integer    ${row_index}
    ${row_index}=    set variable    ${row_index}
    ${row_diff}    evaluate    ${row_index} - ${position}[0]
    ${column_diff}    evaluate    ${column_index} - ${position}[1]
    ${row_count}    set variable if    ${row_diff} < 0    ${row_diff.__abs__()}    ${row_diff}
    ${column_count}    set variable if    ${column_diff} < 0    ${column_diff.__abs__()}    ${column_diff}
    ${horizontal_key}    set variable if    ${column_diff} < 0    RIGHT    LEFT
    ${vertical_key}    set variable if    ${row_diff} < 0    DOWN    UP
    run keyword if    ${skip_vertical_steps} == ${False}    Iterate keyboard ${row_count} times in ${vertical_key} direction
    Iterate keyboard ${column_count} times in ${horizontal_key} direction
    run keyword if    ${skip_validation} == {False}    verify focused character is same as search character    ${character_to_select}

Iterate keyboard ${count} times in ${key} direction
    [Documentation]    Do key presses in ${key} direction for ${count} times
    : FOR    ${index}    IN RANGE    ${count}
    \    ${json_object}    Get Ui Json
    \    send key    ${key}
    \    wait until keyword succeeds    10 times    1s    Assert json changed    ${json_object}

Get focused key id
    [Documentation]    This keyword searches for the currently focused key and returns the id for that key, taking into
    ...    account a JSON change means that some special keyboard characters must be handled in a different way.
    ${id_text}    Set Variable    ${None}
    ${json_object}    Get Ui Json
    ${ancestor}    Get Enclosing Json    ${json_object}    ${KEYBOARD_KEY_NODE_ID_PATTERN}    color:${INTERACTION_COLOUR}    ${2}    ${EMPTY}
    ...    ${True}
    ${higher_ancestor}    Get Enclosing Json    ${json_object}    id:keyboardKeyInner    color:${INTERACTION_COLOUR}    ${3}    ${EMPTY}
    ...    ${True}
    ${higher_ancestor_length}    Get Length    ${higher_ancestor}
    ${id_text}    Set Variable If    ${higher_ancestor_length} > 0    ${higher_ancestor['id']}    ${ancestor['id']}
    [Return]    ${id_text}
