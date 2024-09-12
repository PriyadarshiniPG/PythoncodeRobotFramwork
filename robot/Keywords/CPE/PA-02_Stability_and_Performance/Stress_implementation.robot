*** Settings ***
Documentation     Stress testing keyword definitions

*** Keywords ***
Perform TV Guide Stress test tuning for '${repeat_num}' times with '${interval}' interval on '${channel_number}' channel
    [Documentation]    This keyword Performs Stress test that does tv channel tuning from within the guide for '${times}' times
    Tune for '${repeat_num}' times between channels with '${interval}' sec interval from TVGuide starting on channel '${channel_number}'
    Press 'BACK' for '6' times then tune to '${channel_number}'

Perform Stress testing Get Linear Details for '${repeat_num}' times with '${interval}' interval on '${channel_number}' channel
    [Documentation]    This keyword Performs Stress test that Gets Linear Details for '${repeat_num}' times with '${interval}' interval on '${channel_number}' channel
    Stability Get Linear Details from Channel Bar    UP    ${repeat_num}    ${interval}
    Press 'BACK' for '6' times then tune to '${channel_number}'
    Stability Get Linear Details from Channel Bar    DOWN    ${repeat_num}    ${interval}
    Press 'BACK' for '6' times then tune to '${channel_number}'

Perform Stress testing of channel bar available data on '${channel_number}' channel
    [Documentation]    This keyword Performs Stress test of channel bar available data on '${channel_number}' channel
    Stability Set Event Reminders from Channel Bar    40
    Press 'BACK' for '6' times then tune to '${channel_number}'
    Stability Set Event Reminders from Channel Bar    40
    Press 'BACK' for '6' times then tune to '${channel_number}'

Perform Zap stress test on channel '${channel_name}' with '${wait_time}' ms for '${repeat_num}' times
    [Documentation]    This keyword Performs Zap stress test on channel '${channel_name}' with '${wait_time}' for '${repeat_num}' times.
    Press 'BACK' for '6' times then tune to '${channel_name}'
    Perform zap by pressing 'CHANNELUP' key '${repeat_num}' times waiting '${wait_time}' between each key press
    Perform zap by pressing 'CHANNELDOWN' key '${repeat_num}' times waiting '${wait_time}' between each key press
    Press 'BACK' for '6' times then tune to '${channel_name}'

Performs Fast Zap stress test with '${interval}' interval for retrieved channel zap list
    [Documentation]    This keyword retrieves zap list and performs fast zapping using this list with ${interval} time interval between zapping.
    ${city_id}    Get Customer City Id    ${LAB_TYPE}    ${CPE_ID}    ${CA_ID}
    ${is_ip_lineup}    run keyword and return status    List should contain value    ${IP_LINEUP_CITY_IDS}    ${city_id}
    @{zap_list}    run keyword if    ${is_ip_lineup}    copy list    ${ZAP_IP_CHANNEL_LIST}
    ...    ELSE    copy list    ${ZAP_CHANNEL_LIST}
    Stability Channel Zapping with Numeric Keys every    ${interval}    ${zap_list}
    Press 'BACK' for '6' times then tune to '${FREE_CHANNEL_1}'

Perform Reminders stress test for '${repeat_num}' times on '${channel_number}' channel
    [Documentation]    This keyword Performs Reminders stress test for '${repeat_num}' times on '${channel_number}' channel.
    Stability Set Event Reminders from Channel Bar    ${repeat_num}
    Press 'BACK' for '6' times then tune to '${channel_number}'
    Stability Set Event Reminders from Channel Bar    ${repeat_num}
    Press 'BACK' for '6' times then tune to '${channel_number}'

Perform Recording Events Stress testing for '${repeat_num}' times on '${channel_number}' channel
    [Documentation]    This keyword Performs Recording Events Stress test for '${repeat_num}' times on '${channel_number}' channel.
    Stability Record Series Events From Channel Bar    ${repeat_num}
    Press 'BACK' for '6' times then tune to '${channel_number}'
    Stability Record Single Events From Channel Bar    ${repeat_num}
    Press 'BACK' for '6' times then tune to '${channel_number}'
    Stability Record Series Events From Guide    ${repeat_num}
    Press 'BACK' for '6' times then tune to '${channel_number}'
    Stability Record Single Events From Guide    ${repeat_num}
    Press 'BACK' for '6' times then tune to '${channel_number}'

Stress testing Stability Setup
    [Documentation]    Suite Setup for Stress testing.
    [Timeout]    ${STABILITY_SUITE_SETUP_TIMEOUT}
    Stability Suite Setup
    Stability Reset Recordings

Stress testing Stability Teardown
    [Documentation]    Suite Teardown for Stress testing.
    [Timeout]    ${TIMEOUT_20_MINUTES}
    Conditional Channel Content Check
    Stability Reset Recordings
    Stability Suite Teardown

Perform Open VOD Details Page Stress testing '${repeat_num}' times with a delay of '${wait_time}' seconds
    [Documentation]    This keyword performs 'Open VOD Details Page' stress test for ${repeat_num} times with a delay of '${wait_time}' seconds.
    Stability Open VOD
    : FOR    ${_}    IN RANGE    1    ${repeat_num}
    \    Press key    RIGHT
    \    I wait for 500 ms
    \    I open and close the details page    2    ${wait_time}
    I Press    BACK
    I wait for 1 second
    I Press    BACK
    I wait for 1 second
    Run Keyword And Continue On Failure    video output is not blackscreen
