*** Settings ***
Documentation     Performance Bootup keyword definitions

*** Keywords ***
I perform power cycle for '${repeat_num}' times
    [Documentation]    Perform power cycle given number of times, measures time of appearance: 'welcome', 'no signal' and 'please wait' screens and bootup time till full screen is present.
    ...    Then sets suite variables for &{DICT_REBOOT_DATA}
    ${timeout}    Set Variable    120
    ${welcome_screen_appear_list}    Create List
    ${no_signal_screen_appear_list}    Create List
    ${wait_screen_appear_list}    Create List
    ${audio_playing_time_list}    Create List
    : FOR    ${_}    IN RANGE    ${repeat_num}
    \    I reboot the STB immediately
    \    ${start_time}    Get Current Date
    \    I wait until initial welcome screen is shown    ${timeout}
    \    ${welcome_screen_appear}    Get time from start    ${start_time}
    \    Append To List    ${welcome_screen_appear_list}    ${welcome_screen_appear}
    \    I wait until no signal screen is shown    ${timeout}
    \    ${no_signal_screen_appear}    Get time from start    ${start_time}
    \    Append To List    ${no_signal_screen_appear_list}    ${no_signal_screen_appear}
    \    I wait until please wait screen is shown    ${timeout}
    \    ${wait_screen_appear}    Get time from start    ${start_time}
    \    Append To List    ${wait_screen_appear_list}    ${wait_screen_appear}
    \    wait until keyword succeeds    ${timeout} times    1s    audio is present
    \    ${audio_playing_time}    Get time from start    ${start_time}
    \    Append To List    ${audio_playing_time_list}    ${audio_playing_time}
    &{dict}    Create Dictionary    welcome_screen_time=${welcome_screen_appear_list}    no_signal_screen_time=${no_signal_screen_appear_list}    wait_screen_time=${wait_screen_appear_list}    audio_playing_time=${audio_playing_time_list}
    Set Suite Variable    &{DICT_REBOOT_DATA}    &{dict}

Get time from start
    [Arguments]    ${time}
    [Documentation]    Calculates time between ${time} and current time
    ${current_time}    Get Current Date
    ${calculated_time}    Subtract Date From Date    ${current_time}    ${time}    exclude_millis=False
    [Return]    ${calculated_time}

I present bootup performance test data
    [Documentation]    Presents bootup performance test statistical data.
    ...    Pre-reqs: ${DICT_REBOOT_DATA} variable should exist.
    Variable should exist    ${DICT_REBOOT_DATA}    Variable ${DICT_REBOOT_DATA} has not been set.
    ${results}    get results    ${DICT_REBOOT_DATA}
    log    ${results}
