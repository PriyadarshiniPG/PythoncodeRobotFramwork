*** Settings ***
Documentation     Stability keyword definitions
Resource          ./Stability_Implementation.robot
Library           robot.libraries.DateTime

*** Keywords ***
Stability test pass rate should be '${expected_pass_rate}'
    [Documentation]    Report the final iteration stats by comparing against expected pass rate of ${expected_pass_rate} percent
    ...    Pre-reqs: ${TEST_PASS_COUNT}, ${TEST_ITERATION_COUNT} and ${TEST_ITERATOR} variables should exist.
    variable should exist    ${TEST_PASS_COUNT}    TEST_PASS_COUNT variable was not saved.
    variable should exist    ${TEST_ITERATION_COUNT}    TEST_ITERATION_COUNT variable was not saved.
    variable should exist    ${TEST_ITERATOR}    TEST_ITERATOR variable was not saved.
    ${TEST_PASS_COUNT}    convert to number    ${TEST_PASS_COUNT}    3
    ${TEST_ITERATION_COUNT}    convert to number    ${TEST_ITERATION_COUNT}    3
    ${pass_ratio}    evaluate    (${TEST_PASS_COUNT}/${TEST_ITERATOR})*100.0
    ${fail_count}    evaluate    (${TEST_ITERATOR}-${TEST_PASS_COUNT})
    ${expected_pass_rate}    convert to number    ${expected_pass_rate}    3
    ${error_msg}    set variable    Pass ratio ${pass_ratio} less than ${expected_pass_rate}%, Pass=${TEST_PASS_COUNT}, Fail=${fail_count}, Iterations ran=${TEST_ITERATOR} vs ${TEST_ITERATION_COUNT}
    Log    Pass = ${TEST_PASS_COUNT}, Fail = ${fail_count}, Pass Ratio = ${pass_ratio}, Iterations = ${TEST_ITERATOR}    WARN
    should be true    ${pass_ratio}>=${expected_pass_rate}    ${error_msg}

Reset STB Logs Via Serial
    [Documentation]    Delete older STB logs and coredumps via serial
    run keyword if    '${SERIALCOM}' == 'True'    Clear journalctl logs then remove core dump files from STB
    ...    ELSE    Log    Reset MW logs and core dumps unimplemented from non-serial/ssh interfaces    WARN

Clear all logs on STB via Serial
    [Documentation]    Clear all logs from STB via serial
    Drop input buffer and verify response
    Send command and verify response    journalctl --vacuum-time=1seconds

powercycle stability test
    [Documentation]    Powercycle stability test related atomic operation
    I power cycle the STB for stability
    wait until keyword succeeds    4times    1m    verify content is valid on the stb with all possible means
    I wait for 10 minutes

Continuous 3-btn factory reset
    [Documentation]    Stability test related to 3-btn factory reset
    Check IR connectivity
    Perform 3 button factory reset and eventually finish FTI
    wait until keyword succeeds    5times    1m    verify content is valid on the stb with all possible means
    ${sleeptime}    Evaluate    random.randint(0, 10)    modules=random
    I wait for ${sleeptime} minutes

powercycle stability test random
    [Documentation]    Powercycle stability test related atomic operation
    I power cycle the STB for stability
    wait until keyword succeeds    5times    1m    verify content is valid on the stb with all possible means
    ${sleeptime}    Evaluate    random.randint(0, 15)    modules=random
    I wait for ${sleeptime} minutes

Perform Stress testing
    [Documentation]    This keyword performs stress testing.
    # 20 soft zaps with 500 ms interval in between each zap
    Perform Zap Stress test on channel '${FREE_CHANNEL_1}' with '500' ms for '10' times
    # 20 tunes from TV Guide
    Perform TV Guide Stress test tuning for '20' times with '4' interval on '${FREE_CHANNEL_1}' channel
    # 10 fast zaps
    Performs Fast Zap stress test with '5000' interval for retrieved channel zap list
    # 10 previous/next Linear Details page listing, from channel bar
    Perform Stress testing Get Linear Details for '10' times with '10' interval on '${FREE_CHANNEL_1}' channel
    # 40 browse to future/past end of channel bar with check for available data
    Perform Stress testing of channel bar available data on '${FREE_CHANNEL_1}' channel
    # Open 20 VOD asset details details pages
    Perform Open VOD Details Page Stress testing '20' times with a delay of '5' seconds
    Press 'BACK' for '6' times then tune to '${FREE_CHANNEL_1}'
    # Change standby settings 3 times
    Log    'Stability Test Change Standby Setting' keyword not implemented yet    WARN
    # Change HDMI resolution 3 times
    Log    'Stability Test Change HDMI resolution' keyword not implemented yet    WARN
    # Fill review buffer and do trick modes
    Log    'Stability Test Review Buffer Trick Modes' keyword not implemented yet    WARN
    # Change HDMI resolution 3 times
    Log    'Stability Test Change HDMI resolution' keyword not implemented yet    WARN
    Log    'Set disk usage to '{value}' percent' keyword not implemented yet    WARN
    # Record series/standalone events from ChannelBar/TVGuide
    Perform Recording Events Stress testing for '5' times on '${FREE_CHANNEL_1}' channel
    # Set/remove 10 reminders
    Perform Reminders stress test for '10' times on '${FREE_CHANNEL_1}' channel
    Press 'BACK' for '6' times then tune to '${FREE_CHANNEL_1}'
    # Play purchased VOD assets
    Log    'Iterative Short Play VOD Assets' keyword not implemented yet    WARN
    # Play 10 PVR assets
    Log    'Iterative Short Play PVR Assets' keyword not implemented yet    WARN
    # Play 30 replay events
    Log    'Stability Play Replay events' keyword not implemented yet    WARN
    # Resume Play of 15 Replay events from last played position
    Log    'Stability Resume Play of Replay events' keyword not implemented yet    WARN
    # Verify EPG is still responsive
    ${content_status}    run keyword and return status    content available
    Log    ${content_status}

Loop over the lineup and check every
    [Arguments]    ${interval}    ${remote_key}=CHANNELUP
    [Documentation]    Zap over channel lineup by pressing ${remote_key} (default is channel up) for ${interval} interval in seconds.
    : FOR    ${_}    IN RANGE    1    ${LINEUP_LENGTH}
    \    Press key    ${remote_key}
    \    I wait for ${interval} seconds
    Conditional Channel Content Check

Guide Open Close every
    [Arguments]    ${interval}
    [Documentation]    Open and Close Guide at regular intervals. ${interval} value is in seconds.
    : FOR    ${_}    IN RANGE    1    50
    \    Press key    GUIDE
    \    I wait for ${interval} seconds
    \    Press key    GUIDE
    \    I wait for ${interval} seconds
    Run Keyword And Continue On Failure    video output is not blackscreen

Tune for '${repeat_num}' times between channels with '${interval}' sec interval from TVGuide starting on channel '${channel_number}'
    [Documentation]    Tune for '${repeat_num}' times between channels with '${interval}' sec interval from TVGuide
    ...    starting on channel ${channel_number}
    ...    Then runs conditional channel content validation and checks that video output is not blackscreen.
    : FOR    ${_}    IN RANGE    1    ${repeat_num}
    \    Press 'BACK' for '6' times then tune to '${channel_number}'
    \    I wait for ${interval} seconds
    \    User press GUIDE for 1 times with delay of ${interval} seconds
    \    User press DOWN for 3 times with delay of ${interval} seconds
    \    Press key    OK
    \    I wait for ${interval} seconds
    \    wait until keyword succeeds    5s    100ms    Close live tv popup
    \    I wait for ${interval} seconds
    \    User press GUIDE for 1 times with delay of ${interval} seconds
    \    User press UP for 2 times with delay of ${interval} seconds
    \    User press OK for 1 times with delay of ${interval} seconds
    \    wait until keyword succeeds    5s    100ms    Close live tv popup
    \    I wait for ${interval} seconds
    \    User press GUIDE for 1 times with delay of ${interval} seconds
    \    User press DOWN for 3 times with delay of ${interval} seconds
    \    User press OK for 1 times with delay of ${interval} seconds
    \    wait until keyword succeeds    5s    100ms    Close live tv popup
    \    I wait for ${interval} seconds
    \    User press GUIDE for 1 times with delay of ${interval} seconds
    \    User press UP for 2 times with delay of ${interval} seconds
    \    User press OK for 1 times with delay of ${interval} seconds
    \    wait until keyword succeeds    5s    100ms    Close live tv popup
    \    I wait for ${interval} seconds
    Conditional Channel Content Check

Navigate within the TVGuide
    [Arguments]    ${down_max}=50    ${right_max}=50    ${up_max}=40    ${left_max}=75
    ...    ${ffwd_max}=24    ${frwd_max}=34    ${ch_down_max}=10    ${ch_up_max}=8
    [Documentation]    This keyword navigates within the TVGuide using
    ...    down, right, up, left, ffwd, frwd, channel down and channel up keys
    ...    then resets the guide highlight to the current programme.
    ...    A channel content check is then performed.
    ...    Pre-condition: UI is on the Guide screen
    : FOR    ${_}    IN RANGE    ${down_max}
    \    Press key    DOWN
    \    I wait for 2 seconds
    : FOR    ${_}    IN RANGE     ${right_max}
    \    Press key    RIGHT
    \    I wait for 2 seconds
    : FOR    ${_}    IN RANGE    ${up_max}
    \    Press key    UP
    \    I wait for 2 seconds
    : FOR    ${_}    IN RANGE    ${left_max}
    \    Press key    LEFT
    \    I wait for 2 seconds
    : FOR    ${_}    IN RANGE    ${ffwd_max}
    \    Press key    FFWD
    \    I wait for 3 seconds
    : FOR    ${_}    IN RANGE    ${frwd_max}
    \    Press key    FRWD
    \    I wait for 3 seconds
    : FOR    ${_}    IN RANGE    ${ch_down_max}
    \    Press key    CHANNELDOWN
    \    I wait for 2 seconds
    : FOR    ${_}    IN RANGE    ${ch_up_max}
    \    Press key    CHANNELUP
    \    I wait for 2 seconds
    Press key    GUIDE
    I wait for 6 seconds
    Conditional Channel Content Check

Stability Channel Zapping with Numeric Keys every
    [Arguments]    ${interval}    ${channel_list}=@{ZAP_CHANNEL_LIST}
    [Documentation]    This keyword does channel zapping with numeric keys every ${interval} ms between
    ...    channels from ${channel_list}.
    : FOR    ${channel_number}    IN    @{channel_list}
    \    I tune to stability test channel    ${channel_number}\
    \    I wait for ${interval} ms
    Conditional Channel Content Check

Stability Realistic Zapping with Numeric Keys
    [Arguments]    ${interval}    ${iteration_gap}    ${zap_list}=@{ZAP_CHANNEL_LIST}
    [Documentation]    Realistic Zapping with numeric keys every ${interval} interval in ms, after every ${iteration_gap} repeat gap in seconds.
    Stability Channel Zapping with Numeric Keys every    ${interval}    ${zap_list}
    I wait for ${iteration_gap} seconds

I launch menu and channel bar
    [Arguments]    ${range}    ${sleep_sec}
    [Documentation]    Launch Menu and Channel Banner for ${range} times and sleeps in between for ${sleep_sec}.
    : FOR    ${_}    IN RANGE    0    ${range}
    \    I open Main Menu
    \    I wait for ${sleep_sec} seconds
    \    I open Main Menu
    \    I wait for ${sleep_sec} seconds
    \    I press    OK
    \    I wait for ${sleep_sec} seconds
    \    I press    BACK
    Run Keyword And Continue On Failure    video output is not blackscreen

Pause Play every
    [Arguments]    ${interval}
    [Documentation]    Pause Play every ${interval} seconds.
    : FOR    ${_}    IN RANGE    30
    \    I tune to stability test channel    ${FREE_CHANNEL_2}
    \    I wait for 2 seconds
    \    I press    PLAY-PAUSE
    \    I wait for ${interval} seconds
    \    I press    PLAY-PAUSE
    \    I wait for ${interval} seconds
    \    wait until keyword succeeds    3times    20 sec    video playing
    \    I tune to stability test channel    ${FREE_CHANNEL_3}    #Tuning away and back, to come out of review buffer
    \    I wait for 2 seconds

Stability wait for specified duration after toggling twice the box standby state
    [Arguments]    ${wait_duration}=10
    [Documentation]    Change box standby state to Standby and back to Active and wait for ${wait_duration} in minutes.
    I press    POWER
    I wait for 10 seconds
    I press    POWER
    I wait for 10 seconds
    verify content is valid on the stb with all possible means
    I wait for ${wait_duration} minutes
    content available

I perform a standby cycle of
    [Arguments]    ${standby_cycle_length}    ${standby_mode}
    [Documentation]    I perform a standby cycle for ${standby_cycle_length} duration in minutes.
    ${INITIAL_CHECK_FOR_REMOTE_PAIRING_TIPS_SCREEN}    Set Variable    ${CHECK_FOR_REMOTE_PAIRING_TIPS_SCREEN}
    ${INITIAL_CHECK_FOR_REMOTE_PAIRING_REQ_POPUP}    Set Variable    ${CHECK_FOR_REMOTE_PAIRING_REQ_POPUP}
    Set Suite Variable    ${CHECK_FOR_REMOTE_PAIRING_TIPS_SCREEN}    ${True}
    Set Suite Variable    ${CHECK_FOR_REMOTE_PAIRING_REQ_POPUP}    ${True}
    Run Keyword If    '${standby_mode}' == 'ColdStandby' or '${standby_mode}' == 'LukewarmStandby'    wait until keyword succeeds    3times    10s    I send IR key    POWER
    ...    ELSE IF    '${standby_mode}' == 'ActiveStandby'    wait until keyword succeeds    3times    10s    I Press
    ...    POWER
    ...    ELSE    fail test    ${standby_mode} - Unknown standby mode
    I wait for ${standby_cycle_length} minutes
    wait until keyword succeeds    3times    5 sec    video not playing
    audio not playing
    Run Keyword If    '${standby_mode}' == 'ColdStandby' or '${standby_mode}' == 'LukewarmStandby'    wait until keyword succeeds    3times    10s    I send IR key    POWER
    ...    ELSE IF    '${standby_mode}' == 'ActiveStandby'    wait until keyword succeeds    3times    10s    I Press
    ...    POWER
    ${wait_duration}    Get From Dictionary    ${STANDBY_CONTENT_RESPONSE_WINDOW}    ${standby_mode}
    I wait for ${wait_duration} seconds
    verify content is valid on the stb without tuning away
    Set Suite Variable    ${CHECK_FOR_REMOTE_PAIRING_TIPS_SCREEN}    ${INITIAL_CHECK_FOR_REMOTE_PAIRING_TIPS_SCREEN}
    Set Suite Variable    ${CHECK_FOR_REMOTE_PAIRING_REQ_POPUP}    ${INITIAL_CHECK_FOR_REMOTE_PAIRING_REQ_POPUP}

I set standby mode to
    [Arguments]    ${standby_mode}
    [Documentation]    Set the standby mode via Application Services call. Possible values: ["ActiveStandby","LukewarmStandby","ColdStandby"]
    set application services setting    cpe.standByMode    ${standby_mode}
    ${ret}    get application service setting    cpe.standByMode
    Should Be Equal    ${ret}    ${standby_mode}    StandbyMode not set properly

Browse between VOD and TVGuide every
    [Arguments]    ${interval}
    [Documentation]    Browse between TVGuide and VOD and every ${interval} seconds.
    Press key    GUIDE
    I wait for ${interval} seconds
    Press key    VOD
    I wait for ${interval} seconds

I watch the channel
    [Arguments]    ${channel_number}
    [Documentation]    Watch a ${channel_number} for 30 mins
    I tune to stability test channel    ${channel_number}
    wait until keyword succeeds    3times    20 sec    video playing
    I wait for 30 minutes

I press a particular key every
    [Arguments]    ${interval}    ${key_name}
    [Documentation]    I press a ${key_name} and wait for ${interval} duration in ms.
    I press    ${key_name}
    I wait for ${interval} ms

I open and close the details page
    [Arguments]    ${interval_1}    ${interval_2}
    [Documentation]    I open the details page for a program after every '${interval_2}' in seconds and close the page after '${interval_1}' in seconds.
    ...    Pre-reqs: VOD or TVGuide is displayed
    I press    OK
    I wait for ${interval_1} seconds
    I press    BACK
    I wait for ${interval_2} seconds

Repeat switching playback speeds for '${repeat_num}' times on '${recording_id}'
    [Documentation]    Repeat switching playback speeds for ${repeat_num} times on saved asset ${recording_id}.
    @{trickplay_speeds}    Create List    ${2}    ${6}    ${30}    ${64}
    : FOR    ${index}    IN RANGE    ${repeat_num}
    \    @{round_details}    Evaluate    list(divmod(${index}, 4))
    \    ${trickplay_key}    Evaluate    "FFWD" if (@{round_details}[0] % 2) == 0 else "FRWD"
    \    ${playback_speed}    Get From List    ${trickplay_speeds}    @{round_details}[1]
    \    Switch play back speed and verify it    ${trickplay_key}    ${playback_speed}    ${recording_id}
    \    wait until keyword succeeds    3x    250ms    video output is not blackscreen
    \    wait until keyword succeeds    3x    250ms    video playing
    \    Run Keyword If    @{round_details}[1] == ${3} and '${trickplay_key}' == 'FRWD'    wait until keyword succeeds    6x    2s    Stability player is in play mode
    \    ...    ${recording_id}
    \    I wait for 250 ms

Play stability recordings and repeat switching playback speeds '${repeat_num}' times on each
    [Documentation]    Play saved stability recordings and do ${repeat_num} repeated trickplay action on each
    ...    Pre-reqs: @{STABILITY_TRICKPLAY_RECORDING_IDS} variable should exist.
    variable should exist    @{STABILITY_TRICKPLAY_RECORDING_IDS}    STABILITY_TRICKPLAY_RECORDING_IDS variable was not saved.
    ${index}    set variable    ${0}
    : FOR    ${recording_id}    IN    @{STABILITY_TRICKPLAY_RECORDING_IDS}
    \    Play the recording in the trickplay recording list    ${index}
    \    Repeat switching playback speeds for '${repeat_num}' times on '${recording_id}'
    \    ${index}    Evaluate    ${index} + ${1}
    \    # Work around for the ARRISEOS-16369, tuning to live channel before playing next recording
    \    I tune to stability test channel    ${FREE_CHANNEL_1}
    \    I wait for 5 seconds

Play stability recordings and repeat switching from slow motion to pause mode for '${repeat_num}' times
    [Documentation]    Play saved stability recordings and do switching from slow motion to pause mode
    ...    for ${repeat_num} times on each
    ${index}    set variable    ${0}
    : FOR    ${recording_id}    IN    @{stability_trickplay_recording_ids}
    \    Play the recording in the trickplay recording list    ${index}
    \    Repeat switching from slow motion to pause mode for '${repeat_num}' times on '${recording_id}'
    \    ${index}    Evaluate    ${index} + ${1}
    \    # Work around for the ARRISEOS-16369, tuning to live channel before playing next recording
    \    I tune to stability test channel    ${FREE_CHANNEL_1}
    \    I wait for 5 seconds

Play stability recordings '${iteration_count}' times
    [Documentation]    Play saved stability recordings ${iteration_count} times by playing, then stopping playback, and tuning
    ...    to a standard channel
    Initialize stability iteration test variables    ${iteration_count}
    repeat keyword    ${iteration_count} times    Play stability recording from UI while noting any failure encountered    ${0}

Play stability live pause then return to live '${iteration_count}' times
    [Documentation]    Play saved stability recordings ${iteration_count} times by playing, then stopping playback, and tuning
    ...    to a standard channel
    Initialize stability iteration test variables    ${iteration_count}
    Repeat stability keyword until failure threshold is reached    Play stability tune from UI to verify pause while noting any failure encountered

Check there are no core crash dumps on the STB
    [Documentation]    This keyword checks there are no core crash dumps on the STB.
    @{core_files}    Get list of core files from the STB
    should be empty    ${core_files}    STB has core crash dumps ${core_files}.

I set STB in continuous time-shift mode
    [Arguments]    ${interval}    ${iteration_gap}
    [Documentation]    Sets different time shift modes every ${interval} in seconds, interval after every ${iteration_gap} repeat gap in minutes.
    video playing
    I press    PAUSE
    I wait for ${interval} seconds
    wait until keyword succeeds    5x    200ms    verify Player 'PAUSE' mode
    I press    PLAY-PAUSE
    I wait for ${interval} seconds
    wait until keyword succeeds    5x    200ms    verify Player 'PLAY' mode
    I Press    FFWD
    I wait for ${interval} seconds
    wait until keyword succeeds    5x    200ms    verify Player 'FFWD' mode
    I Press    FRWD
    I wait for ${interval} seconds
    wait until keyword succeeds    5x    200ms    verify Player 'FRWD' mode
    I press    PLAY-PAUSE
    I wait for ${interval} seconds
    wait until keyword succeeds    5x    200ms    verify Player 'PLAY' mode
    I wait for ${iteration_gap} minutes

Collect coredumps from STB
    [Documentation]    Collect and copy coredumps from the STB and copy it to Rack PC
    @{core_files_copied_to_rack_pc}    create list
    ${timestr}    robot.libraries.DateTime.get current date    result_format=%d-%m-%Y-%H%M
    ${corefiles_root_dir}    create dir if not exists in rl    corefiles
    ${ssh_handle}    Remote.open connection    ${STB_IP}
    Remote.login    ${STB_IP}    ${ssh_handle}
    ${cpe_id}    Remote.execute_command    ${STB_IP}    ${ssh_handle}    hostname
    ${build_in_stb}    Remote.execute_command    ${STB_IP}    ${ssh_handle}    cat /etc/version
    ${core_files}    Remote.execute_command    ${STB_IP}    ${ssh_handle}    find /var/core-dumps/ -name '*.gz'
    ${output_length}    get length    ${core_files}
    run keyword if    ${output_length} == ${0}    run keywords    Remote.close connection    ${STB_IP}    ${ssh_handle}
    ...    AND    return from keyword    ${cpe_id}    ${build_in_stb}    ${core_files_copied_to_rack_pc}
    ${core_files}    split string    ${core_files}    \n
    @{core_files_list}    create list
    : FOR    ${core_file_path}    IN    @{core_files}
    \    ${valid_core_path}    replace string using regexp    ${core_file_path}    [:<>"\\|?*]    _
    \    run keyword if    '${core_file_path}' != '${valid_core_path}'    Remote.execute_command    ${STB_IP}    ${ssh_handle}    mv '${core_file_path}' '${valid_core_path}'
    \    ${core_dir}    ${app}    ${core_file}    split string from right    ${valid_core_path}    /
    \    ...    2
    \    append to list    ${core_files_list}    ${valid_core_path}
    wait until remote files remain unchanged    ${ssh_handle}    @{core_files_list}
    : FOR    ${core_file_path}    IN    @{core_files_list}
    \    ${_}    ${file_name}    split path    ${core_file_path}
    \    ${local_file}    set variable    ${corefiles_root_dir}/${VALUESETNAME}_${timestr}_${file_name}
    \    Remote.get    ${STB_IP}    ${ssh_handle}    ${core_file_path}    ${local_file}
    \    Remote.execute_command    ${STB_IP}    ${ssh_handle}    rm -f ${core_file_path}
    \    &{core_file_details}    create dictionary    corefile=${local_file}    app=${app}
    \    append to list    ${core_files_copied_to_rack_pc}    ${core_file_details}
    Remote.close connection    ${STB_IP}    ${ssh_handle}
    [Return]    ${cpe_id}    ${build_in_stb}    ${core_files_copied_to_rack_pc}

Perform selene zapping test to find crashes
    [Documentation]    Perform selene specific zapping test to find crashes
    ${status}    ${error}    run keyword and ignore error    loop over the lineup and check every    3    CHANNELUP
    run keyword if    '${status}' == 'FAIL'    I wait for 4 minutes
    Collect and upload coredumps to S3
    Check for kernel crash and upload to S3
    run keyword if    '${status}' == 'FAIL'    fail test    Test is failed due to ${error}

Play stability review buffer functions for '${iteration_count}' times
    [Documentation]    Plays stability review buffer functions for ${iteration_count} times. Initial steps include pausing in live for 5 mins and then
    ...    playing in review buffer mode. This gives enough review buffer to perform trick mode validations.
    Initialize stability iteration test variables    ${iteration_count}
    I tune to stability test channel    ${FREE_CHANNEL_1}
    I wait for 5 seconds
    wait until keyword succeeds    3s    250ms    video playing
    ${_}    ${new_speed}    wait until some change is detected after sending the specific key    PLAY-PAUSE    1s    get current player session speed
    verify player speed '${new_speed}' matches 'PAUSE'
    wait until keyword succeeds    3x    200ms    video not playing
    I wait for 5 minute
    ${_}    ${new_speed}    wait until some change is detected after sending the specific key    PLAY-PAUSE    1s    get current player session speed
    verify player speed '${new_speed}' matches 'PLAY'
    wait until keyword succeeds    3x    200ms    video playing
    Repeat stability keyword until failure threshold is reached    Play review buffer functions while noting any failure encountered

Record play delete stability local recordings for SD channels '${iteration_count}' times
    [Documentation]    Record, Play and Delete local SD recordings ${iteration_count} times
    Initialize stability iteration test variables    ${iteration_count}
    Repeat stability keyword until failure threshold is reached    Stability record play delete current event of channels    ${STABILITY_SD_CHANNELS}

Record play delete stability local recordings for HD channels '${iteration_count}' times
    [Documentation]    Record, Play and Delete local HD recordings ${iteration_count} times
    Initialize stability iteration test variables    ${iteration_count}
    Repeat stability keyword until failure threshold is reached    Stability record play delete current event of channels    ${STABILITY_HD_CHANNELS}

I launch the app '${app_name}' via '${launch}' option '${iteration_count}' times
    [Documentation]    Iterate this test '${iteration_count}' times by launching ${app_name} app via specified option(${launch}).
    ...    Currently only launch via the screens in the ${SUPPORTED_LAUNCH_METHOD} list is supported.
    ...    Currently only apps in the ${SUPPORTED_APPS} list are supported.
    ${is_app_supported}    Evaluate    '${app_name}' in ${SUPPORTED_APPS}
    ${is_launch_supported}    Evaluate    '${launch}' in ${SUPPORTED_LAUNCH_METHOD}
    should be true    ${is_app_supported} and ${is_launch_supported}    Keyword "I launch the app '${app_name}' via '${launch}' option '${iteration_count}' times" is not supported
    Initialize stability iteration test variables    ${iteration_count}
    repeat keyword    ${iteration_count} times    Launch stability '${app_name}' app via '${launch}' while noting any failure encountered

I launch the app '${app_name}' via '${launch}' option '${iteration_count}' times to play a sample video
    [Documentation]    Iterate this test '${iteration_count}' times by launching '${app_name}' app via specified option(${launch}), play a sample video, and then exit via LIVETV key.
    ...    Currently only launch via the screens in the ${SUPPORTED_LAUNCH_METHOD} list is supported.
    ...    Currently only apps in the ${SUPPORTED_APPS} list are supported.
    ${is_app_supported}    Evaluate    '${app_name}' in ${SUPPORTED_APPS}
    ${is_launch_supported}    Evaluate    '${launch}' in ${SUPPORTED_LAUNCH_METHOD}
    should be true    ${is_app_supported} and ${is_launch_supported}    Keyword "I launch the app '${app_name}' via '${launch}' option '${iteration_count}' times to play a sample video" is not supported
    Initialize stability iteration test variables    ${iteration_count}
    ${content_check_pass_count}    set variable    ${0}
    ${iteration_count}    convert to integer    ${iteration_count}
    : FOR    ${_}    IN RANGE    ${iteration_count}
    \    ${launch_status}    run keyword and return status    Stability open '${app_name}' via '${launch}'
    \    ${playback_status}    run keyword and return status    Stability attempt to playback a '${app_name}' asset
    \    ${exit_status}    run keyword if    ${launch_status}    run keyword and return status    Stability exit '${app_name}' with 'LIVETV' key
    \    Stability update current iteration report    ${launch_status} and ${playback_status} and ${exit_status}
    \    Press 'BACK' for '6' times then tune to '${FREE_CHANNEL_1}'

I exit the app '${app_name}' via '${exit_option}' option '${iteration_count}' times
    [Documentation]    Iterate this test '${iteration_count}' times by launching ${app_name} app via specified option(AppStore), then exit app via ${exit_option} option
    ...    Currently only 'Youtube' app is supported.
    run keyword if    '${exit_option}'!='BACK'    fail test    keyword "I exit the app '${app_name}' via '${exit_option}' option '${iteration_count}' times" is not supported
    Initialize stability iteration test variables    ${iteration_count}
    ${content_check_pass_count}    set variable    ${0}
    ${iteration_count}    convert to integer    ${iteration_count}
    : FOR    ${_}    IN RANGE    ${iteration_count}
    \    ${launch_status}    run keyword and return status    Stability open '${app_name}' via 'AppStore'
    \    ${exit_status}    run keyword if    ${launch_status}    run keyword and return status    Stability exit '${app_name}' with '${exit_option}' key
    \    Stability update current iteration report    ${launch_status} and ${exit_status}
    \    Press 'BACK' for '6' times then tune to '${FREE_CHANNEL_1}'

Stability schedule recordings on stability channels
    [Arguments]    ${recording_count}    ${channel_list}
    [Documentation]    This keyword iterates scheduling of '${recording_count}' recordings from the provided list of channels '${channel_list}'. It also
    ...    maintains data structures to track last booked or last failed event id. Successful recordingIDs, failed eventIDs, and complete channel event list
    ...    is stored in ${event_list} list, indexed by pool_id. The elements added to this dictionary via a sub dictionary with the below
    ...    dictionary keys : 'id', 'events', 'recordings', 'last_position', 'failed_events'
    ...    pool_id values range from 0 to ${channel_count}-1
    ...    Then sets ${EVENTS_COLLECTION} suite variable.
    ${channel_count}    get length    ${channel_list}
    ${event_list}    Create List
    set suite variable    ${EVENTS_COLLECTION}    ${event_list}
    Initialize stability iteration test variables    ${recording_count}
    ${total_event_count}    Stability populate channel list for recording test    ${channel_list}    ${recording_count}
    should be true    ${total_event_count} > ${recording_count}    Minimum available events to record ${total_event_count} less than required ${recording_count}
    Stability iterate on channel list to perform scheduling test    ${recording_count}    ${channel_list}

Complete then delete a recording on '${channel_list}' for '${recording_count}' iterations with pass rate counter
    [Documentation]    This keyword starts recording on all channels from ${channel_list},
    ...    then verifies that number of started recordings is equal to all channels from the channel list.
    ...    Then retrieves recordings remaining duration ${wait_time}, then waits for ${wait_time} duration, verifies that number of completed recordings is equal to all the channels from channel list,
    ...    updates iteration report with PASS/FAIL status, then verifies there is no recording ongoing in the background. Repeats this for ${recording_count} iterations.
    ...    Pre-reqs: ${RECORD_FAIL_WAIT_DURATION} and ${TEST_ITERATOR} variables should exist.
    Variable should exist    ${RECORD_FAIL_WAIT_DURATION}    Variable RECORD_FAIL_WAIT_DURATION does not exist.
    Variable should exist    ${TEST_ITERATOR}    Variable TEST_ITERATOR does not exist.
    ${events_per_iteration}    Get length    ${channel_list}
    Initialize stability iteration test variables    ${recording_count}
    : FOR    ${_}    IN RANGE    ${recording_count}
    \    ${create_rec_status}    Run Keyword And Return Status    Start recording the current entire event From Given Channel List    ${channel_list}
    \    ${started_rec_status}    Run Keyword And Return Status    Wait until keyword succeeds    2times    2s    The number of recordings with status filter 'STARTED' is '${events_per_iteration}'
    \    ${wait_time}    Run Keyword If    '${create_rec_status}' == '${True}' and '${started_rec_status}' == '${True}'    Get remaining duration of an ongoing event recording
    \    ...    ELSE    Set variable    ${RECORD_FAIL_WAIT_DURATION}
    \    I wait for ${wait_time} seconds
    \    ${complete_rec_status}    Run Keyword And Return Status    The number of recordings with status filter 'COMPLETE' is '${events_per_iteration}'
    \    ${status}    Run keyword and return status    Should Be True    ${create_rec_status} and ${complete_rec_status} and ${started_rec_status}    Failed. Recording created (${create_rec_status}), started (${started_rec_status}) and completed (${complete_rec_status}) statuses should be equal to TRUE.
    \    Stability update current iteration report    ${status}
    \    Run Keyword And Continue On Failure    Should be true    ${status}    Iteration ${TEST_ITERATOR} failed. Continuing test execution.
    \    Wait until keyword succeeds    2times    2s    There is no recording ongoing in the background
