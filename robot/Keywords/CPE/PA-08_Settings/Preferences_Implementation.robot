*** Settings ***
Documentation     Preferences implementation keywords
Resource          ../Common/Common.robot
Resource          ../CommonPages/ValuePicker_Implementation.robot
Resource          ../PA-04_User_Interface/MainMenu_Keywords.robot
#Resource          ../PA-05_Linear_TV/Favourites_Keywords.robot
Resource          ../PA-05_Linear_TV/LinearDetailsPage_Keywords.robot

*** Variables ***
${MAX_MENU_LANG}    6

*** Keywords ***
I focus 'Add channels' for Favourites
    [Documentation]    Favourites: Checks if 'Add channels' focused if list empty
    ...    Or focuses Select channels if list not empty
    # if list empty:
    ${json_object}    Get Ui Json
    ${result}    Is In Json    ${json_object}    ${EMPTY}    textKey:DIC_PROFILE_LINEUP_ADD_CHANNELS
    ${is_focused}    Run Keyword If    '${result}' == 'True'    Favourites Check If 'Add channels' Button Is Focused
    Run Keyword If    '${is_focused}' == 'True'    Return From Keyword
    # if list not empty
    ${result}    Is In Json    ${json_object}    ${EMPTY}    textKey:DIC_FAVOURITES_MENU_SELECT
    Run Keyword If    '${result}' != 'True'    Fail    Select channels is not present
    Favourites Focus 'Select channels' When List Is Not Empty

Favourites Check If 'Add channels' Button Is Focused
    [Documentation]    Favourites: Checks if 'Add channels' button is focused
    ${text_color}    I retrieve json ancestor of level '1' for element 'textKey:DIC_PROFILE_LINEUP_ADD_CHANNELS'
    ${is_focused}    Evaluate    True if '${text_color['textStyle']['color']}' == '${HIGHLIGHTED_OPTION_COLOUR}' else False
    [Return]    ${is_focused}

Favourites Check If 'Select channels' Button Is Focused
    [Documentation]    Favourites: Checks if 'Select channels' button is focused
    ${text_color}    I retrieve json ancestor of level '1' for element 'textKey:DIC_FAVOURITES_MENU_SELECT'
    ${is_focused}    Evaluate    True if '${text_color['textStyle']['color']}' == '${HIGHLIGHTED_OPTION_COLOUR}' else False
    [Return]    ${is_focused}

Favourites Focus 'Select channels' When List Is Not Empty
    [Documentation]    Favourites: Focuses 'Select channels' when list of favourites is not empty
    Move Focus to Option in Value Picker    textKey:DIC_FAVOURITES_MENU_SELECT    UP    4
    : FOR    ${i}    IN RANGE    ${3}
    \    ${is_focused}    Favourites Check If 'Select channels' Button Is Focused
    \    Exit For Loop If    '${is_focused}' == '${True}'
    \    I Press    RIGHT
    Should Be True    ${is_focused}

I focus 'Add channels' for Locked    #USED
    [Documentation]    Focuses 'Add channels' for Locked view
    ${status}    run keyword and return status    wait until keyword succeeds    10 times    2s    verify locked list is empty
    ${is_focused}    Run Keyword If    ${status}    Check If 'Add channels' Button Is Focused
    Run Keyword If    ${is_focused}    Return From Keyword
    Focus 'Add channels' When Locked List Is Not Empty

verify locked list is empty
    [Documentation]    verifies whether the locked channels list is empty
    ${list_empty}    Check if Locked list empty
    should be true    ${list_empty}    locked channel is not empty

Check if Locked list empty
    [Documentation]    Checks if Locked list is empty and returns status
    ${json_object}    Get Ui Json
    ${result}    Is In Json    ${json_object}    ${EMPTY}    textKey:DIC_LOCKED_LIST_EMPTY
    [Return]    ${result}

Focus 'Add channels' When Locked List Is Not Empty
    [Documentation]    Focuses 'Add channels' button when locked channel list is not empty
    Move to element assert focused elements    textKey:DIC_LOCKED_MENU_SELECT    ${3}    RIGHT

Add Channels is shown for Locked    #USED
    [Documentation]    Verifies whether the Add channels pop up is shown
    wait until keyword succeeds    ${JSON_MAX_RETRIES}    ${JSON_RETRY_INTERVAL}    Layer is not empty    CURRENT_POPUP_LAYER    ${False}
    wait until keyword succeeds    ${JSON_MAX_RETRIES}    ${JSON_RETRY_INTERVAL}    I expect page contains 'textKey:DIC_LOCKED_MENU_SELECT'

Read menu language id from Menu Language list
    [Arguments]    ${language}
    [Documentation]    Returns id of new language to be set from Menu Language list
    ${new_menu_language_id}    set variable    ${None}
    LOG    ${language}
    ${json_object}    Get Ui Json
    : FOR    ${i}    IN RANGE    5
    \    ${lang}    Extract Value For Key    ${json_object}    id:picker-item-text-${i}    textValue
    \    LOG    ${lang}
    \    ${new_menu_language_id}    Set Variable If    '${lang}' == '${language}'    ${i}
    \    exit for loop if    '${lang}' == '${language}'
    [Return]    ${new_menu_language_id}

I set to ${lang} in Menu Language window
    [Documentation]    keyword to set lang in Preference screen. Parameter format example: 'English'
    send key    OK
    # to make sure to search for ID from the top since no cyclic rotation possible
    repeat keyword    ${MAX_MENU_LANG} times    send key    UP
    # to find out id of new language
    ${new_menu_language_id}    Read menu language id from Menu Language list    ${lang}
    run keyword if    '${new_menu_language_id}' == '${None}'    fail    menu language to set not available in settings
    log    picker-item-text-${new_menu_language_id}
    Move Focus to Option in Value Picker    id:picker-item-text-${new_menu_language_id}    DOWN    8
    send key    OK
    ${current_menu_lang}    Read Menu language from Preference
    repeat keyword    3 times    I Press    BACK
    Run keyword unless    '${current_menu_lang}' == '${lang}'    fail    New Audio language which is set not reflected in the Preference

Read Menu language from Preference
    [Documentation]    Internal keywords to read menu lang from Preference screen
    wait until keyword succeeds    ${JSON_MAX_RETRIES}    ${JSON_RETRY_INTERVAL}    I expect page element 'id:settingFieldValueText_1' contains 'textValue:^.+$' using regular expressions
    ${menu_lang}    I retrieve value for key 'textValue' in element 'id:settingFieldValueText_1'
    ${menu_lang}    Remove String    ${menu_lang}    >
    ${menu_lang}    Strip String    ${menu_lang}
    [Return]    ${menu_lang}

Get current menu language
    [Documentation]    Read current menu language setting in stb
    I open Profiles through Settings
    I focus Menu Language
    ${aud_lang}    Read Menu language from Preference
    [Return]    ${aud_lang}

Check If 'Add channels' Button Is Focused
    [Documentation]    Checks if 'Add channels' button is focused
    ${is_focused}    run keyword and return status    I expect focused elements contains 'textKey:DIC_LOCKED_MENU_SELECT'
    [Return]    ${is_focused}
