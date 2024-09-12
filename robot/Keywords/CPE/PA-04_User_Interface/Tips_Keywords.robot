*** Settings ***
Documentation     Keywords covering functions of the Tips
Resource          ../Common/Common.robot

*** Keywords ***
The Tips feature is available
    [Documentation]    Activates the Tips & Tricks feature
    # Given Prerequisites
    Set TipsAndTricks Ui Config to true

"${tips_type}" Tips message has never been shown
    [Documentation]    Reset the shown tips counters
    ...    tips_type is only here to allow explicit keywords
    ...    it might be used if per tips type counters are introduced
    Reset Application Services Setting    profile.tipsAndTricks
    ${is_shown}    Page contains Tips "GOT IT" Button
    Run Keyword If    ${is_shown}    I press    OK
    ${is_shown}    Page contains Tips "GOT IT" Button
    Run Keyword If    ${is_shown}    I press    BACK

The limit of daily Tip messages is not reached
    [Documentation]    Make sure there was no more than 3 Tips shown in the day
    # Currently handled by the global resetSetting on profile.tipsAndTricks
    Log    'TBD - Implementation of JSON AS request will be implemented in dedicated PR'

The limit of daily Tip messages for '${view}' area is not reached
    [Documentation]    Make sure there was no more than 1 Tips shown in this area
    Log    'TBD - Implementation of JSON AS request will be implemented in dedicated PR'

"${tips_type}" have already been shown days before
    [Documentation]    Define tips as already shown in the past via app service
    ${key}    Set Variable if    '${tips_type}' == 'play immediately'    PLAY_IMMEDIATELY    '${tips_type}' == 'back to tv'    BACK_TO_TV    ${EMPTY}
    Should not Be Empty    ${key}
    ${body}    Set Variable    {"ids":["${key}"], "timestamps":[0]}
    Set application services setting as JSON    profile.tipsAndTricks    ${body}

"menu go to top" Tips have been shown
    [Documentation]    Shows "menu go to top" Tips
    The Tips feature is available
    "menu go to top" Tips message has never been shown
    The limit of daily Tip messages is not reached
    The limit of daily Tip messages for 'Guide' area is not reached
    I tune to channel    ${TWO_DIGIT_CHANNEL}
    I open Channel Bar
    I open guide '6' times
    I wait for 5 seconds
    I press UP 5 times
    "menu go to top" Tips are shown

"menu go to top" Tips are shown
    [Documentation]    validates that "menu go to top" Tips are shown
    wait until keyword succeeds    ${JSON_MAX_RETRIES}    ${JSON_RETRY_INTERVAL}    I expect page contains 'textKey:DIC_TIP_RCU_MENU'
    Page Tips "GOT IT" Button should be    shown

"menu go to top" Tips are not shown
    [Documentation]    validates that "menu go to top" Tips are NOT shown
    wait until keyword succeeds    ${JSON_MAX_RETRIES}    ${JSON_RETRY_INTERVAL}    I do not expect page contains 'textKey:DIC_TIP_RCU_MENU'
    Page Tips "GOT IT" Button should be    hidden

"Play immediately" Tips are shown
    [Documentation]    validates that "Play immediately" Tips are shown
    wait until keyword succeeds    ${JSON_MAX_RETRIES}    ${JSON_RETRY_INTERVAL}    I expect page contains 'textKey:DIC_TIP_PLAY'
    Page Tips "GOT IT" Button should be    shown

"Play immediately" Tips are not shown
    [Documentation]    validates that "Play immediately" Tips are NOT shown
    wait until keyword succeeds    ${JSON_MAX_RETRIES}    ${JSON_RETRY_INTERVAL}    I do not expect page contains 'textKey:DIC_TIP_PLAY'
    Page Tips "GOT IT" Button should be    hidden

"epg day skip" Tips are shown
    [Documentation]    validates that "epg day skip" Tips are shown
    wait until keyword succeeds    ${JSON_MAX_RETRIES}    ${JSON_RETRY_INTERVAL}    I expect page contains 'textKey:DIC_TIP_EPG_DAY_SKIP'
    Page Tips "GOT IT" Button should be    shown

"epg day skip" Tips are not shown
    [Documentation]    validates that "epg day skip" Tips are NOT shown
    wait until keyword succeeds    ${JSON_MAX_RETRIES}    ${JSON_RETRY_INTERVAL}    I do not expect page contains 'textKey:DIC_TIP_EPG_DAY_SKIP'
    Page Tips "GOT IT" Button should be    hidden

"Voice" Tips have been shown
    [Documentation]    Shows "Voice" Tips
    The Tips feature is available
    "Voice" Tips message has never been shown
    The limit of daily Tip messages is not reached
    The limit of daily Tip messages for 'current' area is not reached
    I open Channel Bar
    I open voice '6' times
    I wait for 5 seconds
    "Voice" Tips are shown

"Voice" Tips are shown
    [Documentation]    validates that "Voice" Tips are shown
    wait until keyword succeeds    ${JSON_MAX_RETRIES}    ${JSON_RETRY_INTERVAL}    I expect page contains 'textKey:DIC_TIP_VOICE_BUTTON'
    ${json_object}    Get Ui Json
    ${voice4_is_shown}    Is In Json    ${json_object}    ${EMPTY}    textKey:DIC_TIP_VOICE_4
    ${voice3_is_shown}    Is In Json    ${json_object}    ${EMPTY}    textKey:DIC_TIP_VOICE_3
    ${voice2_is_shown}    Is In Json    ${json_object}    ${EMPTY}    textKey:DIC_TIP_VOICE_2
    ${voice1_is_shown}    Is In Json    ${json_object}    ${EMPTY}    textKey:DIC_TIP_VOICE_1
    Should Be True    ${voice4_is_shown} and ${voice3_is_shown} and ${voice2_is_shown} and ${voice1_is_shown}
    Page Tips "GOT IT" Button should be    shown

"Voice" Tips are not shown
    [Documentation]    validates that "Voice" Tips are NOT shown
    wait until keyword succeeds    ${JSON_MAX_RETRIES}    ${JSON_RETRY_INTERVAL}    I do not expect page contains 'textKey:DIC_TIP_VOICE_BUTTON'
    ${json_object}    Get Ui Json
    ${voice4_is_shown}    Is In Json    ${json_object}    ${EMPTY}    textKey:DIC_TIP_VOICE_4
    ${voice3_is_shown}    Is In Json    ${json_object}    ${EMPTY}    textKey:DIC_TIP_VOICE_3
    ${voice2_is_shown}    Is In Json    ${json_object}    ${EMPTY}    textKey:DIC_TIP_VOICE_2
    ${voice1_is_shown}    Is In Json    ${json_object}    ${EMPTY}    textKey:DIC_TIP_VOICE_1
    Should Be True    ${voice4_is_shown} == ${False} and ${voice3_is_shown} == ${False} and ${voice2_is_shown} == ${False} and ${voice1_is_shown} == ${False}
    Page Tips "GOT IT" Button should be    hidden

"back to tv" Tips are shown
    [Documentation]    validates that "back to tv" Tips are shown
    wait until keyword succeeds    ${JSON_MAX_RETRIES}    ${JSON_RETRY_INTERVAL}    I expect page contains 'textKey:DIC_TIP_BACK_TO_TV'
    Page Tips "GOT IT" Button should be    shown

"back to tv" Tips are not shown
    [Documentation]    validates that "back to tv" Tips are shown
    wait until keyword succeeds    ${JSON_MAX_RETRIES}    ${JSON_RETRY_INTERVAL}    I do not expect page contains 'textKey:DIC_TIP_BACK_TO_TV'
    Page Tips "GOT IT" Button should be    hidden

Page contains Tips "GOT IT" Button
    [Documentation]    returns if "Got It" button is shown or not shown
    ...    Via the DIC_TIP_BTN_GOT_I translated text
    ...    Or via the alternative image button (temporary)
    ${json_object}    Get Ui Json
    ${as_text}    Is In Json    ${json_object}    ${EMPTY}    textKey:DIC_TIP_BTN_GOT_IT
    ${as_image}    Is In Json    ${json_object}    ${EMPTY}    image:.*tips_and_tricks-button.*    ${EMPTY}    ${True}
    ${is_shown}    Evaluate    ${as_text} or ${as_image}
    [Return]    ${is_shown}

"Anow moment" Tips are shown
    [Documentation]    validates that "anow moment" Tips are shown
    wait until keyword succeeds    ${JSON_MAX_RETRIES}    ${JSON_RETRY_INTERVAL}    I expect page contains 'textKey:DIC_TIP_RCU_EPG_WITHIN_EPG'
    Page Tips "GOT IT" Button should be    shown

"Anow moment" Tips are not shown
    [Documentation]    validates that "anow moment" Tips are not shown
    wait until keyword succeeds    ${JSON_MAX_RETRIES}    ${JSON_RETRY_INTERVAL}    I do not expect page contains 'textKey:DIC_TIP_RCU_EPG_WITHIN_EPG'
    Page Tips "GOT IT" Button should be    hidden

Page Tips "GOT IT" Button should be
    [Arguments]    ${shown_status}
    [Documentation]    validates that "Got It" button is shown or hidden
    ...    Via the DIC_TIP_BTN_GOT_I translated text
    ...    Or via the alternative image button (temporary)
    ${is_shown}    Page contains Tips "GOT IT" Button
    ${expect_shown}    Evaluate    '${shown_status}'=='shown' and ${is_shown}
    ${expect_hidden}    Evaluate    '${shown_status}'=='hidden' and ${is_shown}==${False}
    Should Be True    ${expect_shown} or ${expect_hidden}

Is Tips and Tricks present
    [Documentation]    This keyword checks if Tips and Tricks screen is present and returns the result
    ${tips_tricks_present}    Run Keyword And Return Status    wait until keyword succeeds    10 times    1 sec    I expect page contains 'id:TipsAndTricks.View'
    [Return]    ${tips_tricks_present}

Dismiss Tips and Tricks screen
    [Documentation]    This keyword dismisses Tips and Tricks screen by pressing BACK
    ${tips_tricks_present}    Is Tips and Tricks present
    Run Keyword If    ${tips_tricks_present}    I press    BACK
