*** Settings ***
Documentation     Keywords concerning audio settings and functionality
Resource          ../PA-05_Linear_TV/AudioSelection_Implementation.robot

*** Keywords ***
I set the Audio Language to '${new_language}' via Action Menu
    [Documentation]    This keyword sets the audio language via Action Menu
    ${new_language}    convert to lowercase    ${new_language}
    ${default_audio_language_textkey}    Get audio language
    return from keyword if    '${default_audio_language_textkey}' == '${${new_language}}'
    repeat keyword    3 times    I Press    UP
    LOG    ${${new_language}}
    Move Focus to Option in Value Picker    textKey:${${new_language}}    DOWN    4
    I Press    OK
    ${default_language}    Get audio language
    I Press    OK
    ${ancestor}    I retrieve json ancestor of level '1' for element 'textValue:${default_language}'
    ${default_audio_language_textkey}    Set Variable    ${ancestor['textKey']}
    repeat keyword    4 times    I Press    BACK
    run keyword unless    '${default_audio_language_textkey}' == '${${new_language}}'    fail test    New set audio language not reflected in Linear Detail Page menu

I tune to audio selection test channel
    [Documentation]    This keyword tunes to audio test channel and checks the audio is playing
    tune to channel ${AUDIO_TEST_CHANNEL}
    wait until keyword succeeds    5 times    2s    audio playing

There is a audio test channel with configuration
    [Arguments]    ${Config}
    [Documentation]    Start the playout and activate configuration needed for the test
    load vsm configuration    ${VSM_User}    ${VSM_Password}    ${TS_ID_AUDIO}    ${Config}

Audio language '${audio_lang}' is highlighted in the Action Menu
    [Documentation]    This keyword retrieves the default language ${default_audio_language} in the language options of Linear Detail Page (Action/Info Menu)
    ...    then compares default language with passed argument ${audio_lang} and expects those values to be the same.
    ...    Pre-reqs: 'Language Settings' window that contains audio language data for current soundtrack should be opened.
    ${audio_lang}    convert to lowercase    ${audio_lang}
    ${default_audio_language}    Get audio language
    Run keyword unless    '${default_audio_language}' == '${${audio_lang}}'    fail test    Expected audio language in Linear detail page:${${audio_lang}}, actual:${default_audio_language}

Audio Language '${Default_Lang}' is active in config '${Config}'
    [Documentation]    Using the name of the active configuration file the requested language code is mapped with a
    ...    position on the stream. Later this is compared with the active track.
    ...    ARRISEOS_AUDIO_GER_FRA_ENG --> GER = 1, FRA = 2, ENG = 3
    LOG    Error on retrieving the Audio level from Obelix    WARN
    log    ${Config}
    LOG    ${Default_Lang}
    I play LIVE TV
    ${project_feature}    ${1_pos}    ${2_pos}    ${3_pos}    split string from right    ${Config}    _
    ...    3
    Run Keyword if    '${Default_Lang}' == '${1_pos}'    set test variable    ${position}    1
    Run Keyword if    '${Default_Lang}' == '${2_pos}'    set test variable    ${position}    2
    Run Keyword if    '${Default_Lang}' == '${3_pos}'    set test variable    ${position}    3
    ${ActiveTrack}    Get Active Audio_track
    run keyword unless    '${ActiveTrack}' == '${position}'    fail    Expected audio track for ${${position}__pos} but stb playing ${${ActiveTrack}__pos}

I set audio language of the stb to ${audio_lang}
    [Documentation]    This keyword sets the default audio language ${audio_lang} through 'SETTINGS' > 'PREFERENCES'.
    ${audio_lang}    convert to lowercase    ${audio_lang}
    ${current_audio_lang}    I open 'PROFILES' to get current audio language
    Run keyword unless    '${current_audio_lang}' == '${${audio_lang}}'    I set audio language to    ${audio_lang}

I set Dolby Digital to ${new_dolby_setting}
    [Documentation]    This keyword sets DOLDBY DIGITAL setting to on or off
    ${current_dolby_setting}    Get current Dolby Digital setting
    return from keyword if    '${current_dolby_setting}' == '${new_dolby_setting}'
    send key    OK
    wait until keyword succeeds    ${JSON_MAX_RETRIES}    ${JSON_RETRY_INTERVAL}    I expect page element 'id:settingFieldValueText_3' contains 'textValue:^.+$' using regular expressions
    ${current_dolby_setting}    I retrieve value for key 'textValue' in element 'id:settingFieldValueText_3'
    run keyword unless    '${current_dolby_setting}' == '${new_dolby_setting}'    fail test    Changed dolby settings not reflected in UI

I set Audio Description to ${new_audio_desc}
    [Documentation]    This keyword sets the audio desciption
    ${current_audio_desc}    Get current Audio Description setting
    return from keyword if    '${current_audio_desc}' == '${new_audio_desc}'
    send key    OK
    wait until keyword succeeds    ${JSON_MAX_RETRIES}    ${JSON_RETRY_INTERVAL}    I expect page element 'id:settingFieldValueText_5' contains 'textValue:^.+$' using regular expressions
    ${current_audio_desc}    I retrieve value for key 'textValue' in element 'id:settingFieldValueText_5'
    run keyword unless    '${current_audio_desc}' == '${new_audio_desc}'    fail test    Changed Audio Description settings not reflected in UI

Preferred Audio Language is
    [Arguments]    ${audio_lang}
    [Documentation]    This keyword will verify that the preferred audio language is ${audio_lang}, if not it will set ${audio_lang} as
    ...    the preferred audio language via application services
    ${current_audio_lang}    get application service setting    profile.audioLang
    Run keyword unless    '${current_audio_lang}' == '${audio_lang}'    Set value via application services    profile.audioLang    ${audio_lang}

I verify preferred Audio Language is
    [Arguments]    ${audio_language}
    [Documentation]    This keyword will verify that the preferred audio language of STB is set to ${audio_language}
    ${current_audio_lang}    I open 'PROFILES' to get current audio language
    should be equal    ${current_audio_lang}    ${${audio_language}}    Preferred audio language is not ${audio_language}

OSD Language Specific Audio Stream Teardown
    [Arguments]    ${lang}
    [Documentation]    This keyword sets a particular OSD language and then does Audio Stream Teardown
    I set osd language from appservices to ${lang}
    Audio Stream Test TearDown

Audio Language Specific Audio Stream Teardown
    [Arguments]    ${lang}
    [Documentation]    This keyword sets a particular OSD language and then does Audio Stream Teardown
    I set audio language of the stb to ${lang}
    Audio Stream Test TearDown

Audio Stream Test Suite Setup
    [Documentation]    Setup steps for Audio Stream related tests
    [Timeout]    ${DEFAULT_SUITE_SETUP_TIMEOUT}
    Default Suite Setup
    Acquire Audio Stream Player

Audio Stream Test TearDown
    [Documentation]    Teardown steps for Audio Stream related tests
    Release Audio Stream Player
    Default Suite Teardown

Audio Language Suite Setup
    [Documentation]    Setup steps for Audio Language related tests
    Default Suite Setup
    ${audio_lang}    get application service setting    profile.audioLang
    set suite variable    ${CURRENT_AUDIO_LANG}    ${audio_lang}

Audio Language Suite Teardown
    [Documentation]    Teardown steps for Audio Language related tests
    ${audio_lang_exist}    Run Keyword And Return Status    variable should exist    ${CURRENT_AUDIO_LANG}    audio language is not set
    run keyword if    '${audio_lang_exist}' == '${True}'    Set value via application services    profile.audioLang    ${CURRENT_AUDIO_LANG}
    Default Suite Teardown
