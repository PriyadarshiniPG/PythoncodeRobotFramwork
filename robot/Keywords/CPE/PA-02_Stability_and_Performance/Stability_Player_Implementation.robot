*** Settings ***
Documentation     Stability Player keyword definitions

*** Keywords ***
Play the recording in the trickplay recording list
    [Arguments]    ${recording_number}
    [Documentation]    Play the recording saved as part of trickplay test suite
    ...    Pre-reqs: ${STABILITY_TRICKPLAY_RECORDING_IDS} variable should exist.
    Variable should exist    ${STABILITY_TRICKPLAY_RECORDING_IDS}    Variable STABILITY_TRICKPLAY_RECORDING_IDS does not exist.
    ${recording_id}    Get From List    ${STABILITY_TRICKPLAY_RECORDING_IDS}    ${recording_number}
    I press    DVR
    I wait for 3 seconds
    I press DOWN ${recording_number} times
    I press    OK
    I wait for 2 seconds
    ${shown}    is recording play from start button    ${STB_SLOT}
    I press    OK
    I wait for 2 seconds
    Run Keyword Unless    ${shown} == ${True}    Play Recording from the start by selecting play from start
    Stability player is in play mode    ${recording_id}
    I wait for 10 seconds

Play Recording from the start by selecting play from start
    [Documentation]    Play the recording from the start by selecting the play from start option from the popup window
    ${shown}    is recording play from start popup    ${STB_SLOT}
    Run Keyword If    ${shown} == ${True}    I press    OK
    ...    ELSE    wait until keyword succeeds    3x    200ms    Go down and select play from start from popup

Go down and select play from start from popup
    [Documentation]    Navigate down and play the next recording
    I press    DOWN
    I wait for 250 ms
    ${shown}    is recording play from start popup    ${STB_SLOT}
    Should Be True    ${shown}    Play from start popup is not shown
    I press    OK

Get player speed via vldms
    [Arguments]    ${session_ref_id}
    [Documentation]    Get player session speed via vldms
    ${player_speed}    get player session speed via vldms    ${STB_IP}    ${CPE_ID}    ${session_ref_id}
    [Return]    ${player_speed}

Stability player is in play mode
    [Arguments]    ${session_ref_id}
    [Documentation]    Verify player is in play mode for stability
    ${speed}    wait until keyword succeeds    2x    500ms    Get player speed via vldms    ${session_ref_id}
    should be equal    ${speed}    ${1}    Player is not in player mode

Stability player is in slow motion mode
    [Arguments]    ${session_ref_id}
    [Documentation]    Verify player is in slow motion mode for stability
    ${speed}    wait until keyword succeeds    2x    200ms    Get player speed via vldms    ${session_ref_id}
    should be equal    ${speed}    ${0.5}    Player is not in slow motion mode

Stability player is in pause mode
    [Arguments]    ${session_ref_id}
    [Documentation]    Verify player is in play mode for stability
    ${speed}    wait until keyword succeeds    2x    200ms    Get player speed via vldms    ${session_ref_id}
    should be equal    ${speed}    ${0}    Player is not in pause mode

Switch play back speed and verify it
    [Arguments]    ${trickplay_key}    ${trickplay_speed}    ${session_ref_id}
    [Documentation]    Switch play back speed
    ${_}    ${speed}    wait until some change is detected after sending the specific key    ${trickplay_key}    1s    Get player speed via vldms    ${session_ref_id}
    ${playback_speed}    Evaluate    ${trickplay_speed} if "${trickplay_key}" == "FFWD" else ${trickplay_speed} * ${-1}
    should be equal    ${speed}    ${playback_speed}    Playback speed:${speed} not matching expected speed:${trickplay_speed}

Repeat switching from slow motion to pause mode for '${repeat_num}' times on '${recording_id}'
    [Documentation]    Repeat switching from slow motion to pause mode for ${repeat_num} times on saved asset ${recording_id}.
    : FOR    ${_}    IN RANGE    ${repeat_num}
    \    I press    PLAY-PAUSE
    \    Stability player is in pause mode    ${recording_id}
    \    wait until keyword succeeds    3x    200ms    video not playing
    \    I press    FFWD
    \    Stability player is in slow motion mode    ${recording_id}
    \    wait until keyword succeeds    3x    200ms    video playing

Play stability recording from UI while noting any failure encountered
    [Arguments]    ${recording_id}
    [Documentation]    Play the specified saved stability recording index from UI, then stop playback, and tune
    ...    to a standard channel
    ...    Pre-reqs: ${TEST_ITERATOR} variable should exist.
    Variable should exist    ${TEST_ITERATOR}    Variable TEST_ITERATOR does not exist.
    ${status}    run keyword and return status    Play the recording in the trickplay recording list    ${recording_id}
    Stability update current iteration report    ${status}
    Run Keyword And Continue On Failure    should be true    ${status}    Iteration ${TEST_ITERATOR} failed and continuing the test
    # Work around for the ARRISEOS-16369, tuning to live channel before playing next recording
    I tune to stability test channel    ${FREE_CHANNEL_1}
    I wait for 5 seconds
    wait until keyword succeeds    3s    250ms    video output is not blackscreen
    wait until keyword succeeds    3s    250ms    video playing

Play stability tune from UI to verify pause while noting any failure encountered
    [Documentation]    Tunes to a stability test channel and performs PLAY-PAUSE function in review buffer, then stop playback, and tune
    ...    to a standard channel
    ...    Pre-reqs: ${TEST_ITERATOR} variable should exist.
    Variable should exist    ${TEST_ITERATOR}    Variable TEST_ITERATOR does not exist.
    I tune to stability test channel    ${FREE_CHANNEL_1}
    I wait for 5 seconds
    wait until keyword succeeds    3s    250ms    video output is not blackscreen
    wait until keyword succeeds    3s    250ms    video playing
    ${status}    run keyword and return status    Play stability tune from UI to verify pause inner loop
    Stability update current iteration report    ${status}
    Run Keyword And Continue On Failure    should be true    ${status}    Iteration ${TEST_ITERATOR} failed and continuing the test

Play stability tune from UI to verify pause inner loop
    [Documentation]    This keyword executes trick mode tests on a tuned channel and validates whether the player speed matches expected values
    ${_}    ${new_speed}    wait until some change is detected after sending the specific key    PLAY-PAUSE    1s    get current player session speed
    verify player speed '${new_speed}' matches 'PAUSE'
    wait until keyword succeeds    3x    200ms    video not playing
    I wait for 30 second
    ${_}    ${new_speed}    wait until some change is detected after sending the specific key    PLAY-PAUSE    1s    get current player session speed
    verify player speed '${new_speed}' matches 'PLAY'
    wait until keyword succeeds    3x    200ms    video playing
    I wait for 10 second
    ${_}    ${new_speed}    wait until some change is detected after sending the specific key    PLAY-PAUSE    1s    get current player session speed
    verify player speed '${new_speed}' matches 'PAUSE'
    wait until keyword succeeds    3x    200ms    video not playing
    I wait for 30 second
    wait until keyword succeeds    5x    200ms    I press    LIVETV
    wait until keyword succeeds    3x    200ms    video playing

Play saved recording using media streamer
    [Arguments]    ${recording_id}
    [Documentation]    Play saved recording using media streamer for stability
    ${storage_type}    Get device storage type
    ${record_type}    set variable if    '${storage_type}'=='HDD'    ${REC_TYPE_LDVR}    ${REC_TYPE_NDVR}
    ${recording_url}    run keyword if    '${record_type}' == '${REC_TYPE_NDVR}'    Get recording session from session service    ${CUSTOMER_ID}    ${recording_id}
    ...    ELSE IF    '${record_type}' == '${REC_TYPE_LDVR}'    Get lDVR recording playback locator    ${CUSTOMER_ID}    ${recording_id}
    ${session_id}    Request to play recording in media streamer    ${recording_id}    ${recording_url}
    wait until keyword succeeds    3x    2s    Stability player is in play mode    ${recording_id}
    wait until keyword succeeds    3x    250ms    video playing
    [Return]    ${session_id}

get player speed dictionary value
    [Arguments]    ${action}
    [Documentation]    Get the dictionary value mapping to ${action} from ${SPEED_DICTIONARY}
    ${speed_dict}    get from dictionary    ${SPEED_DICTIONARY}    ${action}
    ${speed_dict}    convert to number    ${speed_dict}
    [Return]    ${speed_dict}

Verify Player '${action}' mode
    [Documentation]    Verifies that the player is in ${action} mode.
    ${speed_dict}    get player speed dictionary value    ${action}
    ${channel_id}    Get current channel
    ${speed}    wait until keyword succeeds    10x    200ms    Get player speed via vldms    ${channel_id}
    should be equal    ${speed}    ${speed_dict}    Player Not in expected mode

verify player speed '${speed}' matches '${action}'
    [Documentation]    Verifies the mode in which the player is, matches the expected
    ${speed_dict}    get player speed dictionary value    ${action}
    should be equal    ${speed}    ${speed_dict}    Player speed '${speed}' is not '${speed_dict}'

get current player session speed
    [Documentation]    Get the current player session speed
    ${channel_id}    Get current channel
    ${speed}    Get player speed via vldms    ${channel_id}
    [Return]    ${speed}

Play review buffer functions while noting any failure encountered
    [Documentation]    Plays stability review buffer functions, notify failures and set player state to play mode.
    ...    Initially we need at least 5mins review buffer.
    ...    Pre-reqs: ${TEST_ITERATOR} variable should exist.
    Variable should exist    ${TEST_ITERATOR}    Variable TEST_ITERATOR does not exist.
    ${buffer_status}    run keyword and return status    ensure review buffer position is in mid range
    Run Keyword And Continue On Failure    should be true    ${buffer_status}    Review buffer not in mid range in ${TEST_ITERATOR} iteration
    ${status}    run keyword and return status    Perform stability review buffer test on the tuned channel
    Stability update current iteration report    ${status}
    ${player_status}    run keyword and return status    verify Player 'PLAY' mode
    run keyword unless    ${player_status}    wait until keyword succeeds    5x    200ms    I press    PLAY-PAUSE
    Run Keyword And Continue On Failure    should be true    ${status}    Iteration ${TEST_ITERATOR} failed and continuing the test

Get review buffer positions
    [Documentation]    This keyword retrieves the RMF Session Manager properties duration, position, speed
    ${channel_id}    Get current channel
    ${review_buffer_duration}    ${position}    ${speed}    get player session properties with ref id via vldms    ${STB_IP}    ${CPE_ID}    ${channel_id}
    [Return]    ${review_buffer_duration}    ${position}    ${speed}

Initiate 30x trickmode action on player session via '${key_press}'
    [Documentation]    This keyword sets the player speed to the intended 30x speed via ${key_press} key. Assumption is player is in PLAY mode currently.
    ${current_speed}    ${new_speed}    wait until some change is detected after sending the specific key    ${key_press}    1s    get current player session speed
    should be true    '${current_speed}'!='${new_speed}'    Unable to change to newer speed
    ${new_speed}    ${mid_speed}    wait until some change is detected after sending the specific key    ${key_press}    1s    get current player session speed
    should be true    '${new_speed}'!='${mid_speed}'    Unable to change to newer speed
    ${mid_speed}    ${final_speed}    wait until some change is detected after sending the specific key    ${key_press}    1s    get current player session speed
    should be true    '${mid_speed}'!='${final_speed}'    Unable to change to newer speed

Is review buffer current position in mid range
    [Documentation]    This keyword checks if the position of the player session in review buffer is within mid 80%
    ${review_buffer_duration}    ${position}    ${speed}    ${is_in_mid_range}    ${suggested_key_press}    get review buffer positions relative to mid range
    should be true    ${is_in_mid_range}    Review buffer position not in mid 80% range

Ensure review buffer position is in mid range
    [Arguments]    ${wait_duration}=20s
    [Documentation]    This keyword checks the time in secs, left for trick modes towards either end of the review buffer(left and right), and ensures the current
    ...    position is within the mid 80% of the review buffer range within ${wait_duration} duration of starting the correction. If not, this keyword will
    ...    perform trickmode to move the position within that range.
    ${review_buffer_duration}    ${position}    ${speed}    ${is_in_mid_range}    ${suggested_key_press}    get review buffer positions relative to mid range
    return from keyword if    ${is_in_mid_range}
    initiate 30x trickmode action on player session via '${suggested_key_press}'
    wait until keyword succeeds    ${wait_duration}    200ms    is review buffer current position in mid range
    ${_}    ${new_speed}    wait until some change is detected after sending the specific key    PLAY-PAUSE    1s    get current player session speed
    ensure review buffer bounds are sufficient
    verify player speed '${new_speed}' matches 'PLAY'

Ensure review buffer bounds are sufficient
    [Arguments]    ${which_end}=FORWARD    ${left_limit}=${REVIEW_BUFFER_REWIND_BUFFER_WINDOW_IN_SECS}    ${right_limit}=${REVIEW_BUFFER_FAST_FORWARD_BUFFER_WINDOW_IN_SECS}
    [Documentation]    This keyword checks the time in secs, left for trick modes towards either end of the review buffer(left and right). If user is viewing in forward
    ...    mode(${which_end} == FORWARD), the right most available review buffer is validated. If user is viewing in rewind mode(${which_end} == 'REWIND'), the
    ...    left most available review buffer is validated.
    ${review_buffer_duration}    ${position}    ${speed}    ${is_in_mid_range}    ${new_direction_forward}    get review buffer positions relative to mid range
    ${left_remaining}    evaluate    ${position}/1000
    ${left_remaining}    convert to number    ${left_remaining}
    ${right_remaining}    evaluate    (${review_buffer_duration} - ${position})/1000
    ${right_remaining}    convert to number    ${right_remaining}
    ${is_left_buffer_enough}    evaluate    ${left_remaining} >= ${left_limit}
    ${is_right_buffer_enough}    evaluate    ${right_remaining} >= ${right_limit}
    ${error_condition}    set variable if    '${which_end}'=='REWIND'    ${is_left_buffer_enough}    '${which_end}'=='FORWARD'    ${is_right_buffer_enough}
    ${error_msg}    set variable if    '${which_end}'=='FORWARD'    Forward review buffer ${right_remaining}s is not enough    Rewind review buffer ${left_remaining}s is not enough
    should be true    ${error_condition}    ${error_msg}

Get review buffer positions relative to mid range
    [Documentation]    This keyword checks the time in secs, left for trick modes towards either end of the review buffer(left and right). And
    ...    depending on the current speed of the trick mode, it would suggest whether the current position is within 80% of the current review buffer.
    ...    Also, it suggests which key press should the user invoke in order to correct the position to within 80% review buffer window.
    ...    And it returns the 5 parameters, current review buffer duration, current position, current playing speed, whether the position is within 80% window,
    ...    and what key press the user should send to adjust the review buffer position.
    ${review_buffer_duration}    ${position}    ${speed}    get review buffer positions
    ${position}    convert to number    ${position}
    ${review_buffer_duration}    convert to number    ${review_buffer_duration}
    ${mid_point}    evaluate    ${review_buffer_duration}/2
    ${mid_range_left}    evaluate    ${mid_point} - ${mid_point}*2/5
    ${mid_range_right}    evaluate    ${mid_point} + ${mid_point}*2/5
    ${is_in_mid_range}    evaluate    ${position} >= ${mid_range_left} and ${position} <= ${mid_range_right}
    ${suggested_key_press}    set variable if    ${position}<${mid_range_left}    FFWD    ${position}>${mid_range_right}    FRWD    ${EMPTY}
    [Return]    ${review_buffer_duration}    ${position}    ${speed}    ${is_in_mid_range}    ${suggested_key_press}

Perform stability review buffer test on the tuned channel
    [Documentation]    Performs stability review buffer function to verify trick play speed
    ${_}    ${new_speed}    wait until some change is detected after sending the specific key    PLAY-PAUSE    1s    get current player session speed
    ensure review buffer bounds are sufficient
    embed screenshot in the robot framework report
    verify player speed '${new_speed}' matches 'PAUSE'
    wait until keyword succeeds    3x    200ms    video not playing
    ${_}    ${new_speed}    wait until some change is detected after sending the specific key    PLAY-PAUSE    1s    get current player session speed
    ensure review buffer bounds are sufficient
    verify player speed '${new_speed}' matches 'PLAY'
    wait until keyword succeeds    3x    200ms    video playing
    ${_}    ${new_speed}    wait until some change is detected after sending the specific key    PLAY-PAUSE    1s    get current player session speed
    ensure review buffer bounds are sufficient
    verify player speed '${new_speed}' matches 'PAUSE'
    wait until keyword succeeds    3x    200ms    video not playing
    ${_}    ${new_speed}    wait until some change is detected after sending the specific key    FFWD    1s    get current player session speed
    ensure review buffer bounds are sufficient
    embed screenshot in the robot framework report
    verify player speed '${new_speed}' matches 'SLOW_MOTION'
    wait until keyword succeeds    3s    250ms    video output is not blackscreen
    ${_}    ${new_speed}    wait until some change is detected after sending the specific key    FFWD    1s    get current player session speed
    ensure review buffer bounds are sufficient
    verify player speed '${new_speed}' matches 'FFWD'
    wait until keyword succeeds    3s    250ms    video output is not blackscreen
    ${_}    ${new_speed}    wait until some change is detected after sending the specific key    FFWD    1s    get current player session speed
    ensure review buffer bounds are sufficient
    verify player speed '${new_speed}' matches 'FFWDX6'
    wait until keyword succeeds    3s    250ms    video output is not blackscreen
    ${_}    ${new_speed}    wait until some change is detected after sending the specific key    FFWD    1s    get current player session speed
    ensure review buffer bounds are sufficient
    verify player speed '${new_speed}' matches 'FFWDX30'
    wait until keyword succeeds    3s    250ms    video output is not blackscreen
    ${_}    ${new_speed}    wait until some change is detected after sending the specific key    FFWD    1s    get current player session speed
    ensure review buffer bounds are sufficient
    embed screenshot in the robot framework report
    verify player speed '${new_speed}' matches 'FFWDX64'
    wait until keyword succeeds    3s    250ms    video output is not blackscreen
    ${_}    ${new_speed}    wait until some change is detected after sending the specific key    PLAY-PAUSE    1s    get current player session speed
    ensure review buffer bounds are sufficient    REWIND
    verify player speed '${new_speed}' matches 'PLAY'
    wait until keyword succeeds    3x    200ms    video playing
    ${_}    ${new_speed}    wait until some change is detected after sending the specific key    FRWD    1s    get current player session speed
    ensure review buffer bounds are sufficient    REWIND
    verify player speed '${new_speed}' matches 'FRWD'
    wait until keyword succeeds    3s    250ms    video output is not blackscreen
    ${_}    ${new_speed}    wait until some change is detected after sending the specific key    FRWD    1s    get current player session speed
    ensure review buffer bounds are sufficient    REWIND
    verify player speed '${new_speed}' matches 'FRWDX6'
    wait until keyword succeeds    3s    250ms    video output is not blackscreen
    ${_}    ${new_speed}    wait until some change is detected after sending the specific key    FRWD    1s    get current player session speed
    ensure review buffer bounds are sufficient    REWIND
    verify player speed '${new_speed}' matches 'FRWDX30'
    wait until keyword succeeds    3s    250ms    video output is not blackscreen
    ${_}    ${new_speed}    wait until some change is detected after sending the specific key    FRWD    1s    get current player session speed
    ensure review buffer bounds are sufficient    REWIND
    embed screenshot in the robot framework report
    verify player speed '${new_speed}' matches 'FRWDX64'
    wait until keyword succeeds    3s    250ms    video output is not blackscreen
    ${_}    ${new_speed}    wait until some change is detected after sending the specific key    PLAY-PAUSE    1s    get current player session speed
    ensure review buffer bounds are sufficient
    verify player speed '${new_speed}' matches 'PLAY'
    wait until keyword succeeds    3x    200ms    video playing

#***********************************CPE PERFORMANCE**********************************************
Verify Player '${action}' mode for '${session_id}'
    [Documentation]    Verifies that the player is in ${action} mode for given session
    ${speed_dict}    get player speed dictionary value    ${action}
    ${speed}    Get player speed via vldms    ${session_id}
    ${result}    Should be equal as strings    ${speed}  ${speed_dict}   Player Not in '${action}' mode
    [Return]    ${result}
