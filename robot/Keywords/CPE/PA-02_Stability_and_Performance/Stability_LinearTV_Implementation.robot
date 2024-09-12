*** Settings ***
Documentation     Stability Linear TV keyword definitions

*** Keywords ***
Get Linear Details Page for next event in current channel
    [Documentation]    Get linear details page for next event in current channel
    Press key    RIGHT
    I Press    INFO

Stability Get Linear Details from Channel Bar
    [Arguments]    ${remote_key}    ${repeat_num}    ${gap}
    [Documentation]    Get Linear Details page after pressing ${remote_key} with ${gap} for ${repeat_num} times
    Press key    OK
    I wait for 500 ms
    : FOR    ${_}    IN RANGE    1    ${repeat_num}
    \    Press key    ${remote_key}
    \    I wait for 500 ms
    \    Press key    OK
    \    I wait for 2 seconds
    \    Get Linear Details Page for next event in current channel
    \    I wait for ${gap} seconds
    I Press    BACK
    Run Keyword And Continue On Failure    video output is not blackscreen

Perform zap by pressing '${remote_key}' key '${repeat_num}' times waiting '${wait_time}' between each key press
    [Documentation]    Perform zap by pressing '${remote_key}' key '${repeat_num}' times waiting '${wait_time}' between each key press.
    ...    Then checks that video output is not blackscreen.
    : FOR    ${_}    IN RANGE    1    ${repeat_num}
    \    Press key    ${remote_key}
    \    I wait for ${wait_time} ms
    Conditional Channel Content Check

Close live tv popup
    [Documentation]    Handle Watch popup and make sure Live TV is tuned. Does screen compare for 2 different
    ...    screen templates, and makes the decision to move to the required tab and applies that setting by pressing OK.
    ...    If not found, this keyword would fail.
    ${is_watch_popup}    is watch live tv popup    ${STB_SLOT}
    return from keyword if    ${is_watch_popup}
    ${play_from_start_popup}    is recording play from start popup    ${STB_SLOT}
    run keyword if    ${play_from_start_popup}    run keywords    I press    UP
    ...    AND    I wait for 2 second
    ${live_tv_popup}    run keyword and return status    is watch live tv selected    ${STB_SLOT}
    run keyword if    ${live_tv_popup}    I press    OK
    ...    ELSE    fail    Failed to focus Watch Live TV button

Set Good Channels List Lineup Length
    [Documentation]    This keyword gets all entitled good linear channel id list via AS
    ...    then gets total channels number and sets it as ${LINEUP_LENGTH} variable.
    ${channel_id_list}    Get all good entitled linear channel id list via as    ${STB_IP}    ${CPE_ID}    xap=${XAP}
    ${total_number_of_channels}    get length    ${channel_id_list}
    ${total_number_of_channels}    Evaluate    ${total_number_of_channels} + ${1}
    Set Suite variable    ${LINEUP_LENGTH}    ${total_number_of_channels}
