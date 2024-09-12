*** Settings ***
Documentation     Subtitles implementation keywords
Resource          ../Common/Common.robot
Resource          ../CommonPages/ValuePicker_Implementation.robot
Resource          ../PA-05_Linear_TV/LinearDetailsPage_Keywords.robot
Resource          ../PA-05_Linear_TV/Favourites_Keywords.robot

*** Variables ***
${VSM_User}       alberto
${VSM_Password}    \#AcreSa6
${TS_ID_SUBTITLE}    COMPONENT_SELECTION_TS42_CH3
${Max_Subtitle_Lang}    33
@{SUBTITLE_PIG_PLAYBACK_GREY_REGION}    1750    850    40    100
@{SUBTITLE_RECORDED_EVENT_GREY_REGION}    1500    200    100    100

*** Keywords ***
Get hard of hearing id for language
    [Arguments]    ${language}
    [Documentation]    This keyword returns the Closed Caption/Hard of Hearing id and textKey of the language from language options in action menu
    ${json_object}    Get Ui Json
    : FOR    ${i}    IN RANGE    5
    \    ${status}    Is In Json    ${json_object}    id:picker-item-text-${i}    textKey:DIC_ACTIONS_LANGUAGE_OPTIONS_AUDIO_HARD_HEARING
    \    continue for loop if    ${status}==${False}
    \    ${substitutionKeys}    Extract Value For Key    ${json_object}    id:picker-item-text-${i}    substitutionTextKeys
    \    return from keyword if    '@{substitutionKeys}[0]' == '${${language}}'    picker-item-text-${i}
    run keyword    fail    Language Option not found in the list

I read default subtitle language textkey in Linear Detail Page
    [Documentation]    Returns the default Subtitles language value set in the UI
    I open Language Options from Linear Details Page
    wait until keyword succeeds    ${JSON_MAX_RETRIES}    ${JSON_RETRY_INTERVAL}    I expect page element 'id:settingFieldValueText_undefined' contains 'textKey:^.+$' using regular expressions
    ${default_language_key}    i retrieve value for key 'textKey' in element 'id:settingFieldValueText_undefined'
    ${text_key}    run keyword if    '${default_language_key}'=='DIC_ACTIONS_LANGUAGE_OPTIONS_AUDIO_HARD_HEARING'    i retrieve value for key 'substitutionTextKeys' in element 'id:settingFieldValueText_undefined'
    ${text_key}    set variable if    '${default_language_key}'=='DIC_ACTIONS_LANGUAGE_OPTIONS_AUDIO_HARD_HEARING'    @{text_key}[0]    ${default_language_key}
    I Press    OK
    [Return]    ${text_key}

Check subtitle is
    [Arguments]    ${Colour}
    [Documentation]    This keyword checks the proper subtitle is shown
    I query screenshot from stb via Obelix
    ${Status}    is subtitles background color    ${Colour}    ${LAST_SCREENSHOT_PATH}
    Run Keyword if    '${Status}' == 'False'    fail test    Expected subtitle not found in the screen

I set options to '${option}' in subtitle Options window
    [Documentation]    This keyword sets subtitle options to standard/closed captions/Off
    Press Key    OK
    repeat keyword    4 times    Press Key    UP
    ${option}    convert to lowercase    ${option}
    run keyword if    '${option}'=='off'    Move Focus to Option in Value Picker    id:picker-item-text-0    DOWN    6
    ...    ELSE    Move Focus to Option in Value Picker    textKey:${${option}}    DOWN    6
    I Press    OK
    ${status}    wait until keyword succeeds    ${JSON_MAX_RETRIES}    ${JSON_RETRY_INTERVAL}    Check if subtitle options are set to    ${option}

Check if subtitle options are set to
    [Arguments]    ${option}
    [Documentation]    This keyword verifies the subtitle option via appService with the passed argument
    ${new_value}    I get subtitle option of the stb via AS
    ${new_value}    convert to lowercase    ${new_value}
    run keyword if    '${new_value}' != '${option}'    fail test    Newly set Subtitle options not reflected in Preferences

I set subtitle language of the stb via AppService to
    [Arguments]    ${lang}
    [Documentation]    This keyword sets the default subtitle language of stb AppService
    ${lang}    convert to lowercase    ${lang}
    ${sub_lang}    get application service setting    profile.subLang
    return from keyword if    '${sub_lang}' == '${lang}'
    ${sub_lang}    Set value via application services    profile.subLang    ${lang}
    Run keyword if    '${sub_lang}' != '${lang}'    fail    set new subtitle language through appservices failed

I get subtitle option of the stb via AS
    [Documentation]    This keyword gets the subtitle options of stb through AS
    ${current_subtitle_control}    get application service setting    profile.subControl
    ${current_subtitle_hard_of_hearing}    get application service setting    profile.subHardOfHearing
    ${ui_value}    Run keyword if    '${current_subtitle_control}' == 'True' and '${current_subtitle_hard_of_hearing}' == 'False'    set variable    Standard
    ...    ELSE IF    '${current_subtitle_control}' == 'True' and '${current_subtitle_hard_of_hearing}' == 'True'    set variable    Closed captions
    ...    ELSE    set variable    Off
    [Return]    ${ui_value}

Acquire Subtitle Stream Player
    [Documentation]    Locks Subtitle stream player
    Acquire Lock    SUBTITLESTREAM_Lock

Release Subtitle Stream Player
    [Documentation]    Release Subtitle Stream Player
    Release Lock    SUBTITLESTREAM_Lock

I set subtitle options of the stb via AS to
    [Arguments]    ${targeted_value}
    [Documentation]    This keyword is used to set the subtitle options via AS
    Set Application Services Setting    profile.subControl    ${targeted_value}
    ${get_current_value}    Get application service setting    profile.subControl
    should be equal as strings    '${get_current_value}'    '${targeted_value}'    Failed to set to subtitle options via AS

Blue background DVB subtitles present
    [Documentation]    This keyword verifies that the subtitles with blue background are present on a previously taken screenshot
    I query screenshot from stb via Obelix
    is subtitles background color    BLUE    ${LAST_SCREENSHOT_PATH}
