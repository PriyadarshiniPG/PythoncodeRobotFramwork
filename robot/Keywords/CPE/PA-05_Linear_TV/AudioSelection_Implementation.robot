*** Settings ***
Documentation     Keywords concerning audio settings implementations
Resource          ../Common/Common.robot
Resource          ../CommonPages/ValuePicker_Implementation.robot
Resource          ../PA-05_Linear_TV/LinearDetailsPage_Keywords.robot

*** Variables ***
${VSM_User}       alberto
${VSM_Password}    \#AcreSa6
${TS_ID_AUDIO}    COMPONENT_SELECTION_TS42_CH1
${MAX_AUDIO_LANG}    33

*** Keywords ***
Get audio language
    [Documentation]    This keyword retrieves and returns audio language setting ${audio_lang}.
    ...    Pre-reqs: Page that contains audio language data should be opened. (for example 'PREFERENCES' page or 'Language Settings' window)
    ${audio_lang}    I retrieve value for key 'textKey' in element 'textKey:DIC_SETTINGS_LANG_.+$' using regular expressions
    [Return]    ${audio_lang}

Get Active Audio_track
    [Documentation]    Get the audio level of the active track and map it with the index of the active track
    ${Audiolevel}    get audio level    ${STB_SLOT}
    Run Keyword if    ${Audiolevel} > ${7000}    set test variable    ${INDEX}    1
    Run Keyword if    ${Audiolevel} <= ${7000} and ${Audiolevel} >= ${3000}    set test variable    ${INDEX}    2
    Run Keyword if    ${Audiolevel} < ${3000}    set test variable    ${INDEX}    3
    [Return]    ${INDEX}

Acquire Audio Stream Player
    [Documentation]    Locks Audio stream player
    Acquire Lock    AUDIOSTREAM_Lock

Release Audio Stream Player
    [Documentation]    Release Audio Stream Player
    Release Lock    AUDIOSTREAM_Lock

I open 'PROFILES' to get current audio language
    [Documentation]    This keywords opens 'SETTINGS' > 'PREFERENCES' to get and return current audio language setting ${audio_lang}.
    I open Profiles through Settings
    I focus Audio Language
    ${audio_lang}    Get audio language
    [Return]    ${audio_lang}

I set audio language to
    [Arguments]    ${audio_lang}
    [Documentation]    This keyword opens Audio window then moves to the top and then starts to go down while trying to find and select ${audio_lang} audio language.
    ...    ${MAX_AUDIO_LANG} value is set in AudioSelection_Implementation.robot
    ...    Pre-reqs: 'PREFERENCES' page should be opened, and 'Audio' setting should be focused.
    I Press    OK
    Repeat keyword    ${MAX_AUDIO_LANG} times    I Press    UP
    Move Focus to Option in Value Picker    textKey:${${audio_lang}}    DOWN    ${MAX_AUDIO_LANG}
    I Press    OK

I focus Dolby Digital
    [Documentation]    This keyword focuses Dolby Digital in Image and Sound screen in Settings
    Move to element and assert    textKey:DIC_SETTINGS_DOLBI_DIGITAL_LABEL    color    ${INTERACTION_COLOUR}    8    DOWN

I focus Audio Description
    [Documentation]    This keyword focuses Audio Description in Preferences screen in Settings
    Move to element and assert    textKey:DIC_SETTINGS_AUDIO_DESCRIPTION_LABEL    color    ${INTERACTION_COLOUR}    8    DOWN

Get current Dolby Digital setting
    [Documentation]    Read current Dolby Digital setting in stb
    I open SOUND&IMAGE through Settings
    I focus Dolby Digital
    wait until keyword succeeds    ${JSON_MAX_RETRIES}    ${JSON_RETRY_INTERVAL}    I expect page element 'id:settingFieldValueText_3' contains 'textValue:^.+$' using regular expressions
    ${value}    I retrieve value for key 'textValue' in element 'id:settingFieldValueText_3'
    [Return]    ${value}

Get current Audio Description setting
    [Documentation]    Read current Dolby Digital setting in stb
    I open Profiles through Settings
    I focus Audio Description
    wait until keyword succeeds    ${JSON_MAX_RETRIES}    ${JSON_RETRY_INTERVAL}    I expect page element 'id:settingFieldValueText_5' contains 'textValue:^.+$' using regular expressions
    ${value}    I retrieve value for key 'textValue' in element 'id:settingFieldValueText_5'
    [Return]    ${value}

I set the audio track via 'Contextual key menu' to Audio Description
    [Documentation]    This keyword sets the audio track of the playing content to the 'Audio Description' option,
    ...    if present. If the content doesn't have any option for audio description, the keyword fails
    ${channel_bar_is_visible}    run keyword and return status    Channel Bar is shown
    run keyword if    ${channel_bar_is_visible}    I press    BACK
    Wait until keyword succeeds    ${JSON_MAX_RETRIES}    ${JSON_RETRY_INTERVAL}    I expect page contains 'id:(Player|FullScreen).View' using regular expressions
    I Press    CONTEXT
    I select the 'Audio' action
    wait until keyword succeeds    ${JSON_MAX_RETRIES}    ${JSON_RETRY_INTERVAL}    I expect page contains 'textKey:DIC_ACTIONS_LANGUAGE_OPTIONS_AUDIO_BLIND'
    Move Focus to Option in Value Picker    textKey:DIC_ACTIONS_LANGUAGE_OPTIONS_AUDIO_BLIND    DOWN    5
    I press    OK

Audio Description is active
    [Documentation]    This keyword checks that the Audio Description audio track is selected for the current content
    ...    via application services.
    ${sessions_info_json}    get tuner details via vldms    ${STB_IP}    ${CPE_ID}
    ${ref_id}    Extract Value For Key    ${sessions_info_json}    type:main    refId
    ${property_list}    Create list    audTracks    audTrackSelected
    ${retrieved_audio_tracks_json}    get player session property via vldms    ${STB_IP}    ${CPE_ID}    ${ref_id}    ${property_list}
    ${selected_audio_track_name}    Extract Value For Key    ${retrieved_audio_tracks_json}    ${EMPTY}    audTrackSelected
    ${selected_audio_track}    Get Enclosing Json    ${retrieved_audio_tracks_json}    ${EMPTY}    desc:${selected_audio_track_name}    ${1}
    Should be equal as strings    ${selected_audio_track['type']}    da    Selected audio track '${selected_audio_track_name}' is not an Audio Description track

Audio Description is not active
    [Documentation]    This keyword checks that the Audio Description audio track is not selected for the current content
    ...    via application services.
    ${audio_description_is_active}    run keyword and return status    Audio Description is active
    Should not be true    ${audio_description_is_active}    Selected audio track is an Audio Description track
