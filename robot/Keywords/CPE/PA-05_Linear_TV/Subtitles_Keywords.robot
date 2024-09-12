*** Settings ***
Documentation     Subtitles Keywords
Resource          ../PA-05_Linear_TV/Subtitles_Implementation.robot

*** Keywords ***
I tune to subtitle test channel
    [Documentation]    This keyword tunes to subtitle test channel and verifies that audio/video is playing
    I play LIVE TV
    I tune to channel    ${SUBTITLE_TEST_CHANNEL}
    wait until keyword succeeds    5 times    2s    audio playing
    wait until keyword succeeds    5 times    2s    video output is not blackscreen

There is a subtitle test channel with configuration
    [Arguments]    ${Config}
    [Documentation]    Start the playout and activate configuration needed for the test
    load vsm configuration    ${VSM_User}    ${VSM_Password}    ${TS_ID_SUBTITLE}    ${Config}

I tune to an subtitle test channel with '${languages}' subtitle options
    [Documentation]    Start the playout and activate configuration needed for the test and tunes to the test channel
    @{language_list}    Split String    ${languages}    separator=,
    ${subtitle_stream}    set variable    ARRISEOS_SUBTL
    ${count}    set variable    0
    : FOR    ${language}    IN    @{language_list}
    \    ${count}    Evaluate    ${count} + 1
    \    ${language}    Convert To uppercase    ${language.strip()}
    \    ${subtitle_stream}    Catenate    SEPARATOR=_    ${subtitle_stream}    ${language[0:3]}
    ${none_set}    Evaluate    3 - ${count}
    : FOR    ${i}    IN RANGE    ${none_set}
    \    ${subtitle_stream}    Catenate    SEPARATOR=_    ${subtitle_stream}    NONE
    Log    ${subtitle_stream}
    set test variable    ${test_subtitle_stream}    ${subtitle_stream}
    There is a subtitle test channel with configuration    ${subtitle_stream}
    I tune to subtitle test channel

I set the subtitle language in the Action Menu to
    [Arguments]    ${subtitle_language}
    [Documentation]    This keyword sets the Subtitle language to ${subtitle_language} via Action Menu
    ${subtitle_language}    convert to lowercase    ${subtitle_language}
    ${is_hoh}    run keyword and return status    should contain    ${subtitle_language}    hoh
    @{temp}    run keyword if    ${is_hoh}    Split String    ${subtitle_language}    separator=hoh
    ${new_language}    set variable if    ${is_hoh}    @{temp}[0]    ${subtitle_language}
    ${default_Subtitle_language_textkey}    I read default subtitle language textkey in Linear Detail Page
    return from keyword if    '${default_Subtitle_language_textkey}' == '${${${subtitle_language}}}'
    ${hoh_id}    run keyword if    ${is_hoh}    Get hard of hearing id for language    ${new_language}
    repeat keyword    4 times    I Press    UP
    ${textKey_value}    set variable if    '${new_language}'=='off'    DIC_DISABLED    ${${${subtitle_language}}}
    ${nav_key}    set variable if    ${is_hoh}    id:${hoh_id}    textKey:${textKey_value}
    ${is_focused}    run keyword and return status    Move Focus to Option in Value Picker    ${nav_key}    DOWN    5
    run keyword unless    ${is_focused}    Move Focus to Option in Value Picker    ${nav_key}    UP    6
    I Press    OK
    ${default_Subtitle_language_textkey}    I read default subtitle language textkey in Linear Detail Page
    run keyword if    '${default_Subtitle_language_textkey}' != '${textKey_value}'    fail test    Newly set Subtitle language not reflected in Linear Detail Page

Subtitle language '${Install_language}' is highlighted in the Action Menu
    [Documentation]    Read the default language in the language options of Linear Detail Page (Action/Info Menu)
    ${Install_language}    convert to lowercase    ${Install_language}
    ${is_hoh}    run keyword and return status    should contain    ${Install_language}    hoh
    @{temp}    run keyword if    ${is_hoh}    Split String    ${Install_language}    separator=hoh
    ${Install_language}    set variable if    ${is_hoh}    @{temp}[0]    ${Install_language}
    ${default_Subtitle_language_textKey}    I read default subtitle language textkey in Linear Detail Page
    run keyword if    ${is_hoh}    I expect page element 'id:settingFieldValueText_undefined' contains 'textKey:DIC_ACTIONS_LANGUAGE_OPTIONS_AUDIO_HARD_HEARING'
    repeat keyword    4 times    I Press    BACK
    ${textKey_value}    run keyword if    '${Install_language}'=='off'    set variable    DIC_DISABLED
    ...    ELSE    set variable    ${${Install_language}}
    run keyword unless    '${default_Subtitle_language_textKey}' == '${textKey_value}'    fail test    expected subtitle language in Linear detail page:${textKey_value}, actual:${default_Subtitle_language_textKey}

The '${language}' option is focused in action menu
    [Documentation]    Read the default language in the language options of Linear Detail Page (Action/Info Menu)
    ${language}    convert to lowercase    ${language}
    Subtitle language '${${language}}' is highlighted in the Action Menu
    Log    This keyword directly makes use of another keyword -> Subtitle language __ is highlighted in the Action Menu . Hence, Duplicate    WARN

Subtitle Language '${Default_Lang}' is active in config '${Config}'
    [Documentation]    Using the name of the active configuration file the requested language code is mapped with a
    ...    position on the stream. Later this is compared with the active colour code.
    ...    ARRISEOS_SUBTL_DUT_FRA_ENG --> DUT = RED, FRA = BLUE, ENG = GREEN
    LOG    ${Config}
    LOG    ${Default_Lang}
    I play LIVE TV
    ${project_feature}    ${1_pos}    ${2_pos}    ${3_pos}    split string from right    ${Config}    _
    ...    3
    ${position}    Set Variable If    '${Default_Lang}' == '${1_pos}'    1    '${Default_Lang}' == '${2_pos}'    2    '${Default_Lang}' == '${3_pos}'
    ...    3
    Run Keyword if    '${position}' == '1'    wait until keyword succeeds    50 sec    10s    Check subtitle is    RED
    ...    ELSE IF    '${position}' == '2'    wait until keyword succeeds    50 sec    10s    Check subtitle is
    ...    GREEN
    ...    ELSE IF    '${position}' == '3'    wait until keyword succeeds    50 sec    10s    Check subtitle is
    ...    BLUE
    ...    ELSE    fail    Found subtitles do not match

The subtitle language of the current channel is '${language}'
    [Documentation]    Using the name of the active configuration file the requested language code is mapped with a
    ...    position on the stream. Later this is compared with the active colour code.
    ...    ARRISEOS_SUBTL_DUT_FRA_ENG --> DUT = RED, FRA = GREEN, ENG = BLUE
    ${language}    convert to uppercase    ${language}
    Subtitle Language '${language[0:3]}' is active in config '${test_subtitle_stream}'

I set subtitle language of the stb to
    [Arguments]    ${lang}
    [Documentation]    This keyword sets the default subtitle language of stb either via UI or AppService
    I set subtitle language of the stb via AppService to    ${lang}

I set the subtitle language in Settings to '${language}'
    [Documentation]    This keyword sets the default subtitle language of stb either via AppService
    ${language}    convert to lowercase    ${language}
    I set subtitle language of the stb to    ${${language}}
    Log    This keyword directly makes use of another keyword -> I set subtitle language of the stb to. Hence, Duplicate    WARN

I set subtitle options of the stb to
    [Arguments]    ${value}
    [Documentation]    This keyword sets the default subtitle options of stb through preference settings
    ${current_subtitle_options}    I get subtitle option of the stb via AS
    I open Profiles through Settings
    I focus Subtitle Options
    Run keyword unless    '${current_subtitle_options}' == '${value}'    I set options to '${value}' in subtitle Options window

I set the subtitle options in Settings to '${option}'
    [Documentation]    This keyword sets the default subtitle options of stb through preference settings
    I set subtitle options of the stb to    ${option}
    Log    This keyword directly makes use of another keyword -> I set the subtitle options in Settings to . Hence, Duplicate    WARN

Subtitle Stream Test Suite SetUp
    [Documentation]    Set up steps for Subtitle Stream related tests
    [Timeout]    ${DEFAULT_SUITE_SETUP_TIMEOUT}
    Default Suite Setup
    Acquire Subtitle Stream Player

Subtitle Stream Test TearDown
    [Documentation]    Teardown steps for Subtitle Stream related tests
    Release Subtitle Stream Player
    I set subtitle options of the stb via AS to    ${False}
    Default Suite Teardown

DVB subtitles are displayed
    [Documentation]    Plays live TV and waits until DVB subtitles are displayed
    I play LIVE TV
    wait until keyword succeeds    10times    5s    Blue background DVB subtitles present

Selected subtitles are present
    [Documentation]    This keyword checks that selected subtitles are present in player session and in subtitles list via vldms.
    ${sessions_info_json}    get tuner details via vldms    ${STB_IP}    ${CPE_ID}
    ${ref_id}    Extract Value For Key    ${sessions_info_json}    type:main    refId
    ${property_list}    Create list    subTracks    subTrackSelected
    ${retrieved_subtitles_json}    get player session property via vldms    ${STB_IP}    ${CPE_ID}    ${ref_id}    ${property_list}
    ${selected_subtitles}    Extract Value For Key    ${retrieved_subtitles_json}    ${EMPTY}    subTrackSelected
    ${result}    Is In Json    ${retrieved_subtitles_json}    ${EMPTY}    desc:${selected_subtitles}
    Should not be empty    ${selected_subtitles}    Selected subtitles '${selected_subtitles}' are empty
    Should Be True    ${result}    Selected subtitles '${selected_subtitles}' were not found

Recording Subtitle Suite TearDown
    [Documentation]    Teardown steps for recording with subtitles related tests
    Release Subtitle Stream Player
    I set subtitle options of the stb via AS to    ${False}
    Recordings Specific Teardown

Selected subtitles are present on the recorded event
    [Documentation]    This keyword checks that selected subtitles are present in recorded event and in subtitles list via application services.
    Selected subtitles are present

I set the subtitle language via 'Contextual key menu' to
    [Arguments]    ${sub_language}
    [Documentation]    This keyword sets the Subtitle language 'Contextual key menu' to ${sub_language}.
    ...    Subtitle language should be passed as argument ${sub_language}
    ...    Pre-reqs: Player or Live TV has to be present.
    ${channel_bar_is_visible}    run keyword and return status    Channel Bar is shown
    run keyword if    ${channel_bar_is_visible}    I press    BACK
    Wait until keyword succeeds    ${JSON_MAX_RETRIES}    ${JSON_RETRY_INTERVAL}    I expect page contains 'id:(Player|FullScreen).View' using regular expressions
    ${sub_language}    Convert To uppercase    ${sub_language}
    I Press    CONTEXT
    I select the 'Subtitle' action
    wait until keyword succeeds    ${JSON_MAX_RETRIES}    ${JSON_RETRY_INTERVAL}    I expect page contains 'textKey:DIC_SETTINGS_LANG_${sub_language}'
    Move Focus to Option in Value Picker    textKey:DIC_SETTINGS_LANG_${sub_language}    DOWN    5
    I press    OK

I tune to channel with subtitles
    [Documentation]    This keyword tunes to the channel with subtitles on all events, saved in the
    ...    ${IP_CHANNEL_WITH_SUBTITLES} variable.
    I tune to channel    ${IP_CHANNEL_WITH_SUBTITLES}

I set the subtitle language via 'Contextual key menu' to 'Off'
    [Documentation]    This keyword sets the Subtitle language 'Contextual key menu' to 'Off'.
    ...    Pre-reqs: Player has to be present.
    ${channel_bar_is_visible}    run keyword and return status    Channel Bar is shown
    run keyword if    ${channel_bar_is_visible}    I press    BACK
    Wait until keyword succeeds    ${JSON_MAX_RETRIES}    ${JSON_RETRY_INTERVAL}    I expect page contains 'id:(Player|FullScreen).View' using regular expressions
    I Press    CONTEXT
    I select the 'Subtitle' action
    wait until keyword succeeds    ${JSON_MAX_RETRIES}    ${JSON_RETRY_INTERVAL}    I expect page contains 'textKey:DIC_DISABLED'
    Move Focus to Option in Value Picker    textKey:DIC_DISABLED    UP    5
    I press    OK

No subtitles are present
    [Documentation]    This keyword verifies no subtitles are present in the current player session via vldms
    ${sessions_info_json}    get tuner details via vldms    ${STB_IP}    ${CPE_ID}
    ${ref_id}    Extract Value For Key    ${sessions_info_json}    type:main    refId
    ${property_list}    Create list    subTrackSelected
    ${retrieved_subtitles_json}    get player session property via vldms    ${STB_IP}    ${CPE_ID}    ${ref_id}    ${property_list}
    ${selected_subtitles}    Extract Value For Key    ${retrieved_subtitles_json}    ${EMPTY}    subTrackSelected
    Should be empty    ${selected_subtitles}    The '${selected_subtitles}' subtitles are active

The '${language}' Subtitle language is focused
    [Documentation]    This keyword verifies that the given subtitle language is set for the channel
    'Subtitle' action is shown
    ${ancestor}    I retrieve json ancestor of level '2' for element 'textKey:DIC_ACTIONS_LANGUAGE_OPTIONS_SUBTITLES'
    ${present_subtitle_language}    Extract Value For Key    ${ancestor}    id:settingFieldValueText_undefined    dictionnaryValue
    Should Be Equal As Strings    '${present_subtitle_language}'    '${language}'    Newly set Subtitle language is not reflected in Linear Detail Page
