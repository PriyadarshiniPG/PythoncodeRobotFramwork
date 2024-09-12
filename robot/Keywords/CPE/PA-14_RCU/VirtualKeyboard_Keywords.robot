*** Settings ***
Documentation     Virtual Keyboard keywords
Resource          ../Common/Stbinterface.robot
Resource          ../PA-14_RCU/VirtualKeyboard_Implementation.robot
Library           Libraries.Stb.VirtualKeyboard.Keyboard

*** Variables ***
&{POSITION_DICTIONARY}    ÜÉÏ=(2,0)    üéï=(2,0)    Aa=(0,0)    123=(1,0)    aA=(0,0)    abc=(1,0)    ABC=(1,0)
...               €=(2,12)    £=(2,13)    ź=(2,12)    ż=(2,13)    Ź=(2,12)    Ż=(2,13)    ±=(2,11)    ${SPACE}=(2,11)    BACKSPACE=(0,11)    uei=(2,0)    UEI=(2,0)

*** Keywords ***
Virtual Keyboard is shown    #USED
    [Documentation]    Verify virtual keyboard is shown
    wait until keyword succeeds    3times    1s    I expect page contains 'id:OnScreenKeyboardPanel*' using regular expressions

Virtual Keyboard is not shown
    [Documentation]    Verify virtual keyboard is not shown
    I do not expect page contains 'id:OnScreenKeyboardPanel'

I set Virtual Keyboard selection mode to Normal
    [Documentation]    Set the virtual keyboard to normal mode
    ${flo_mode}    I check if Virtual Keyboard is in Flo mode
    Run Keyword If    ${flo_mode}    I switch Virtual Keyboard selection mode to Normal

Get position of Go character in current layout
    [Documentation]    Return position of Go character in current layout
    ${status}    run keyword and return status    dictionary should contain key    ${GO_ACTION_POSITION}    ${CURRENT_KB_MODE}
    ${position}    set variable if    '${CURRENT_KB_MODE}'=='${KeyboardMode.CHAR}'    (1,11)    '${CURRENT_KB_MODE}'=='${KeyboardMode.DIGIT}'    (1,13)    (1,13)
    [Return]    ${position}

Get position of keyboard character    #USED
    [Arguments]    ${character}
    [Documentation]    Return the position of keyboard character. Here, special characters like
    ...    'Go', 'ÜÉÏ', 'üéï', 123', 'Aa', 'aA', 'abc', 'ABC', '€', '£', '±', '${SPACE}', 'BACKSPACE' are handled.
    ...    Also, '±' is used as replacement for ' ' in Search.
    ${character}    Convert To String    ${character}
    ${is_character_go}    Run Keyword And Return Status    Should Be Equal As Strings    ${character}    Go
    Run Keyword If    ${is_character_go}    Run Keyword And Return    Get position of Go character in current layout
    ${status}    Run Keyword And Return Status    Dictionary Should Contain Key    ${POSITION_DICTIONARY}    ${character}
    ${position}    run keyword if    ${status}    Get From Dictionary    ${POSITION_DICTIONARY}    ${character}
    ...    ELSE    get position of character    ${character}
    [Return]    ${position}

I focus '${character}' on the Virtual Keyboard
    [Documentation]    Focus the specified character on the virtual keyboard
    ${position}    get position of keyboard character    ${character}
    Iterate Over Keyboard In Order To Select Character    ${character}    ${position}

'${text}' is shown in the Search input field
    [Documentation]    Verify the specified text is shown in the Search input field
    ${input_text}    I retrieve value for key 'textValue' in element 'id:InputFieldTextsearchInputField'
    ${expected_text}    Catenate    SEPARATOR=    ${text}
    Should Be Equal    ${text}    ${expected_text}

I switch and press '${key}' on the Virtual Keyboard
    [Documentation]    Switch the keyboard mode and send the specified key
    switch virtual keyboard mode as required for the character    ${key}
    I focus '${key}' on the Virtual Keyboard
    I press    OK

I press '${key}' on the Virtual Keyboard
    [Documentation]    Send the specified key on the virtual keyboard
    I focus '${key}' on the Virtual Keyboard
    I press    OK

Move keyboard to required capital mode    #USED
    [Arguments]    ${input_character}
    [Documentation]    move keyboard to capital mode. Currently supported only for characters mode
    ${is_capital}    Run Keyword    Is '${input_character}' capital
    Return From Keyword If    ${is_capital}==${CURRENT_KB_IS_CAPS}
    Run Keyword If    ${is_capital}==${False} and ${CURRENT_KB_IS_CAPS}==${True}    I press 'Aa' on the Virtual Keyboard
    ...    ELSE IF    ${is_capital}==${True} and ${CURRENT_KB_IS_CAPS}==${False}    I press 'aA' on the Virtual Keyboard
    Set Suite Variable    ${CURRENT_KB_IS_CAPS}    ${is_capital}

Switch to character mode    #USED
    [Arguments]    ${input_character}
    [Documentation]    switch to character mode. Currently supported only from Number to characters mode
    ${is_capital}    Run Keyword    Is '${input_character}' capital
    Run Keyword If    '${CURRENT_KB_MODE}'=='${KeyboardMode.CHAR}'    run keywords    return from keyword if    ${is_capital} == ${CURRENT_KB_IS_CAPS}
    ...    AND    Run Keyword And Return    move keyboard to required capital mode    ${input_character}
    Run Keyword If    ${CURRENT_KB_IS_CAPS} and '${CURRENT_KB_MODE}'=='${KeyboardMode.SPECIAL}'    I press 'UEI' on the Virtual Keyboard
    ...    ELSE IF    ${CURRENT_KB_IS_CAPS}==${False} and '${CURRENT_KB_MODE}'=='${KeyboardMode.SPECIAL}'    I press 'uei' on the Virtual Keyboard
    Run Keyword If    ${CURRENT_KB_IS_CAPS} and '${CURRENT_KB_MODE}'=='${KeyboardMode.DIGIT}'    I press 'ABC' on the Virtual Keyboard
    ...    ELSE IF    ${CURRENT_KB_IS_CAPS}==${False} and '${CURRENT_KB_MODE}'=='${KeyboardMode.DIGIT}'    I press 'abc' on the Virtual Keyboard
    Set Suite Variable    ${CURRENT_KB_MODE}    ${KeyboardMode.CHAR}
    move keyboard to required capital mode    ${input_character}

Switch To Special Character Mode    #USED
    [Arguments]    ${input_character}
    [Documentation]    switch to special character mode. Currently supported only from Number to characters mode
    ${is_capital}    Run Keyword    Is '${input_character}' capital
    Run Keyword If    '${CURRENT_KB_MODE}'=='${KeyboardMode.SPECIAL}'    Run Keywords    Return From Keyword If    ${is_capital} == ${CURRENT_KB_IS_CAPS}
    ...    AND    Run Keyword And Return    move keyboard to required capital mode    ${input_character}
    Run Keyword If    ${CURRENT_KB_IS_CAPS} and '${CURRENT_KB_MODE}'!='${KeyboardMode.SPECIAL}'    I press 'ÜÉÏ' on the Virtual Keyboard
    ...    ELSE IF    ${CURRENT_KB_IS_CAPS}==${False} and '${CURRENT_KB_MODE}'!='${KeyboardMode.SPECIAL}'    I press 'üéï' on the Virtual Keyboard
    Set Suite Variable    ${CURRENT_KB_MODE}    ${KeyboardMode.SPECIAL}
    move keyboard to required capital mode    ${input_character}

Switch to numbers mode    #USED
    [Documentation]    switch to numbers mode. Currently supported only from characters to numbers mode
    Run Keyword If    '${CURRENT_KB_MODE}'!='${KeyboardMode.DIGIT}'    I press '123' on the Virtual Keyboard
    Set Suite Variable    ${CURRENT_KB_MODE}    ${KeyboardMode.DIGIT}

Switch virtual keyboard mode as required for the character    #USED
    [Arguments]    ${input_character}
    [Documentation]    Identify the character and switch the virtual keyboard mode suitably
    ${virtual_mode_required}    Run Keyword If    '${input_character}'=='±' or '${input_character}'=='Go'    Set Variable    ${KeyboardMode.CHAR}
    ...    ELSE    get mode for character    ${input_character}
    Set suite variables based on view layout of the virtual keyboard
    Run Keyword If    '${virtual_mode_required}'=='${KeyboardMode.CHAR}'    switch to character mode    ${input_character}
    ...    ELSE IF    '${virtual_mode_required}'=='${KeyboardMode.DIGIT}'    run keywords    return from keyword if    '${CURRENT_KB_MODE}'=='${KeyboardMode.DIGIT}'
    ...    AND    switch to numbers mode
    ...    ELSE IF    '${virtual_mode_required}'=='${KeyboardMode.SPECIAL}'    Switch To Special Character Mode    ${input_character}

I type "${string_to_type}" on the Virtual Keyboard    #USED
    [Documentation]    Types the specified string
    I set Virtual Keyboard selection mode to Normal
#    ${normal_mode}    I check if Virtual Keyboard is in Normal mode
#    Should Be True    ${normal_mode}    Keyboard is not in normal mode when it should be
    ${modified_string}    Replace String    ${string_to_type}    ±    ${SPACE}
    @{string}    split string to characters    ${modified_string}
    : FOR    ${char}    IN    @{string}
    \    I switch and press '${char}' on the Virtual Keyboard

I search for '${key}' using Virtual keyboard    #USED
    [Documentation]    Searches for the given key using virtual keyboard.
    ...    This keyword cannot be used in Setups and Teardowns as it uses a test variable
    I type "${key}" on the Virtual Keyboard
    set test variable    ${SEARCH_QUERY}    ${key}

I choose GO action on Virtual keyboard
    [Documentation]    Selects Go on the virtual keyword
    I press 'Go' on the Virtual Keyboard

I search for digits using Virtual keyboard
    [Documentation]    Performs a search using digits only
    I search for '${SEARCH_DIGITS_ONLY}' using Virtual keyboard

Digits are shown in the search input field
    [Documentation]    Verifies that the digits entered in the search are shown in the search input field
    '${SEARCH_DIGITS_ONLY}' is shown in the Search input field

Radio channel is shown in the search input field
    [Documentation]    Verifies that the Radio channel query text is shown in the search input field
    '${RADIO_CHANNEL_SEARCH_QUERY}' is shown in the Search input field

Dismiss virtual keyboard if visible
    [Documentation]    In order to select a search result if Go isn't pressed, the virtual keyboard needs to be dismissed.
    ...    Check if the the virtual keyboard is present and dismiss it with the BACK key if it is.
    ${status}    run keyword and return status    Virtual Keyboard is shown
    run keyword if    ${status}    I press    BACK
