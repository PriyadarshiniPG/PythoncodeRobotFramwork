*** Settings ***
Documentation     Content checks related keywords
Library           Libraries.Obelix

*** Keywords ***
audio playing
    [Documentation]    This keywords succeeds if audio level in finite, if it fails warning is issued
    ${value}    is audio playing    ${STB_SLOT}
    run keyword if    ${value} == ${False}    Log    Warning: Keyword failed: Audio Should be playing.    WARN

audio not playing
    [Documentation]    This keywords succeeds if audio level is zero ie No audio output from STB, if it fails warning is issued
    ${value}    is audio playing    ${STB_SLOT}
    run keyword if    ${value}    Log    Warning: Keyword failed: Audio Should not be playing.    WARN

Check Content Is Available    #USED
    [Documentation]    Keyword to make sure that video is playing using Obelix
    Run Keyword If    '${OBELIX}' == 'True'    Video Playing
    ...    ELSE    Log    OBELIX variable set to False, skipping content check    WARN

Check Content Is Unavailable    #USED
    [Documentation]    Keyword to make sure that video is not playing using Obelix
    Run Keyword If    '${OBELIX}' == 'True'    Video Not Playing
    ...    ELSE    Log    OBELIX variable set to False, skipping content check    WARN

Content Available    #USED
    [Arguments]    ${timeout}=5s
    [Documentation]    to check Video present using Obelix
    Wait Until Keyword Succeeds    ${timeout}    0s    Check Content Is Available

Both Audio and Video are playing out
    [Documentation]    to check video / audio is playing
    content available

content unavailable
    [Arguments]    ${timeout}=5s
    [Documentation]    to check Audio / Video not present
    wait until keyword succeeds    ${timeout}    0s    Check content is unavailable

both audio and video are not available
    [Documentation]    checks that audio and video are not playing
    audio not playing
    video not playing

Channel content is locked
    [Documentation]    This keywords checks if channel is locked by validation of Audio, Video and Blackscreen and return True if it is or False if it's not.
    ${blackscreen_status}    is black screen    ${STB_SLOT}
    ${video_status}    is video playing    ${STB_SLOT}
    ${audio_status}    is audio playing    ${STB_SLOT}
    ${status}    set variable if    '${blackscreen_status}' == '${False}' and '${video_status}' == '${False}' and '${audio_status}' == '${False}'    ${True}    ${False}
    [Return]    ${status}

Channel content is available
    [Documentation]    This keywords checks if channel is available by validation of Audio and Video, and return True if it is or False if it's not.
    ${video_status}    is video playing    ${STB_SLOT}
    ${audio_status}    is audio playing    ${STB_SLOT}
    ${status}    set variable if    '${video_status}' == '${True}' and '${audio_status}' == '${True}'    ${True}    ${False}
    [Return]    ${status}

video output is blackscreen
    [Documentation]    This keywords succeeds stb output is black screen
    ${ret}    is black screen    ${STB_SLOT}
    should be true    ${ret}    video output is not blackscreen

video output is not blackscreen
    [Documentation]    This keywords succeeds if stb output is other than black screen
    ${ret}    is black screen    ${STB_SLOT}
    should not be true    ${ret}    video output is blackscreen

video playing
    [Documentation]    This keywords succeeds if stb output is a moving video
    ${ret}    is video playing    ${STB_SLOT}
    should be true    ${ret}    Video should be playing

video not playing
    [Documentation]    This keywords succeeds if stb output is a frozen image , can be black screen also
    ${ret}    is video playing    ${STB_SLOT}
    should not be true    ${ret}    Video should not be playing

I wait until content is available
    [Arguments]    ${duration}=2m
    [Documentation]    This keyword verifies that the content is available within the max specified duration
    content available    ${duration}

verify content is valid on the stb with all possible means
    [Documentation]    In case of poster images or not black screen, the stb content can be validated as below. Also, if STB is still not showing content,
    ...    attempt to tune to list of known validated scrambled channels and verify content.
    ${content_status}    run keyword and return status    verify content is valid on the stb without tuning away
    run keyword unless    ${content_status}    tune to scrambled channel and check content

verify content is valid on the stb without tuning away
    [Documentation]    In case of poster images or not black screen, the stb content can be validated as below
    ${content_status}    run keyword and return status    content available
    return from keyword if    ${content_status}
    ${status_not_black_screen}    run keyword unless    ${content_status}    run keyword and return status    video output is not blackscreen
    run keyword unless    ${status_not_black_screen}    fail    blackscreen detected
    wait until keyword succeeds    3times    1 sec    I press    BACK
    content available

STB is able to show content
    [Documentation]    Keyword to verify that STB is able to tune and present content
    tune to free channel and check content

linear tv is shown
    [Documentation]    check if linear channel is viewable on the box
    wait until keyword succeeds    3times    10 sec    tune to free channel and check content

Conditional Channel Content Check
    [Documentation]    This keyword will get the channelId, current channelList entry for this channelId and check if it's marked as 'EnvIssue', 'AlternatingLockedVideo', channel id is '0065' or it's 'NOTFOUND' in the list.
    ...    If yes, then it will return from keyword with warning message. If no, it will check if current channel has 'VideoAudio', "Video", "Audio" or it's 'Locked' according to channelList.csv. On fail, report will be generated.
    ...    if CONTENT_CHECK_FAILURE_COUNTER is equal to CONTENT_CHECK_FAILURE_THRESHOLD test will fail.
    ${channelId}    Get current channel
    ${screenProp}    define current tuned screen    ${channelId}
    run keyword if    '${screenProp[0]}' == 'NOTFOUND'    run keywords    log    Check the channel id: ${channelId} and add it to the channelList.csv file    WARN
    ...    AND    return from keyword
    ...    ELSE IF    '${screenProp[2]}' == 'EnvIssue'    run keywords    log    This channel won't be checked as it's currently flagged as an environment issue    WARN
    ...    AND    return from keyword
    ...    ELSE IF    '${screenProp[2]}' == 'AlternatingLockedVideo'    run keywords    log    This channel is alternating between locked and video and won't be checked    WARN
    ...    AND    return from keyword
    ...    ELSE IF    '${screenProp[1]}' == '0065'    run keywords    log    This channel contain off air time and won't be checked    WARN
    ...    AND    return from keyword
    ${test_result}    run keyword if    '${screenProp[2]}' == 'VideoAudio'    Channel content is available
    ...    ELSE IF    '${screenProp[2]}' == 'Locked'    Channel content is locked
    ...    ELSE IF    '${screenProp[2]}' == 'Video'    is video playing    ${STB_SLOT}
    ...    ELSE IF    '${screenProp[2]}' == 'Audio'    is audio playing    ${STB_SLOT}
    run keyword if    '${test_result}' == '${False}'    Conditional Channel Content Check Report Generator    ${screenProp}    ${channelId}
    run keyword if    '${CONTENT_CHECK_FAILURE_COUNTER}' == '${CONTENT_CHECK_FAILURE_THRESHOLD}'    fail    CONTENT_CHECK_FAILURE_COUNTER has reached the CONTENT_CHECK_FAILURE_THRESHOLD, failing this test case.

Conditional Channel Content Check Report Generator
    [Arguments]    ${screenProp}    ${channelId}
    [Documentation]    This keyword will take a screenshot, get current channel number, generate warning report using screenshot, channel number, ${screenProp} and ${channelId} variables
    ...    and set new suite variable for ${CONTENT_CHECK_FAILURE_COUNTER}, incrementing its value by 1
    ${path}    get screenshot    ${STB_SLOT}
    ${channel_num}    Get current channel number
    ${fail_report}    set variable    "TestStatus:FAIL|ChannelId:${channelId}|ChannelNumber:${channel_num}"${\n}"ExpectedChannelStatus:${screenProp[2]}"${\n}"ScreenShot:${path}"
    set suite variable    ${CONTENT_CHECK_FAILURE_COUNTER}    ${CONTENT_CHECK_FAILURE_COUNTER+1}
    Log    ${fail_report}    WARN

Channel Data Verification
    [Arguments]    @{channel_list}
    [Documentation]    Checks if Traxis data is present for all passed channels
    : FOR    ${channel_number}    IN    @{channel_list}
    \    ${status}    Run Keyword and Return Status    Check if data is present for channel    ${channel_number}
    \    Run Keyword If    ${status} == ${False}    Fail    Data not present for the channel. Traxis does not respond properly. Test is skipped

Check if data is present for channel
    [Arguments]    ${channel_number}
    [Documentation]    Checks if Traxis data is present a channel
    ${channel_id}    Get channel ID using channel number    ${channel_number}
    @{event_info}    get current event    ${channel_id}    ${CPE_ID}
    [Return]    @{event_info}
