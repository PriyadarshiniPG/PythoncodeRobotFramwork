*** Settings ***
Documentation     Keywords regarding player aesthetic and functionality
Resource          ../Common/Stbinterface.robot
Resource          ../Json/Json_handler.robot
Resource          ../CommonPages/ValuePicker_Implementation.robot
Resource          ../PA-04_User_Interface/ChannelBar_Keywords.robot
Resource          ../PA-10_Player/Player_Implementation.robot
Library           robot.libraries.DateTime

*** Keywords ***
I open Review Buffer Player    #USED
    [Documentation]    This keyword opens the review buffer player
    I Press    PLAY-PAUSE
    Error popup is not shown
    Wait Until Keyword Succeeds And Verify Status    ${JSON_MAX_RETRIES}    ${JSON_RETRY_INTERVAL}    Unable to open Review Buffer Player    I expect page contains 'id:Player.View'
    Wait Until Keyword Succeeds    10 times    1 sec    Player is hidden

I switch Player to PAUSE mode    #USED
    [Documentation]    This keyword switch the player to pause mode
    Show Video Player bar
    ${json_object}    Get Ui Json
    ${icon_image}    Extract Value For Key    ${json_object}    id:trickPlayIcon-(Linear|NonLinear)InfoPanel    iconKeys    ${True}
    Run Keyword If    'TRICKPLAY_PAUSE' not in '${icon_image}'    Run Keywords    I press    PLAY-PAUSE
    ...    AND    Wait Until Keyword Succeeds    ${JSON_MAX_RETRIES}    200 ms    I expect page element 'id:trickPlayIcon-(Linear|NonLinear)InfoPanel' contains 'iconKeys:TRICKPLAY_PAUSE' using regular expressions

Player is in SLOW MOTION mode
    [Documentation]    This keyword asserts player is in slow motion mode
    Wait Until Keyword Succeeds    ${JSON_MAX_RETRIES}    200 ms    I expect page element 'id:trickPlayIcon-(Linear|NonLinear)InfoPanel' contains 'iconKeys:TRICKPLAY_SLOW_MOTION' using regular expressions

Player is in PAUSE mode
    [Documentation]    This keyword shows the player bar if it's not visible, and asserts that the player is in pause mode
    Show Video Player bar
    ${player_paused}    Is In Json    ${LAST_FETCHED_JSON_OBJECT}    id:trickPlayIcon-(Linear|NonLinear)InfoPanel    iconKeys:TRICKPLAY_PAUSE    ${EMPTY}    ${True}
    Should Be True    ${player_paused}    Player is not in PAUSE mode

I switch Player to PLAY mode    #USED
    [Documentation]    This keyword switches the player to play mode
    Show Video Player bar
    ${is_play_icon_not_shown}    Run Keyword And Return Status    I do not expect page element 'id:trickPlayIcon-(Linear|NonLinear)InfoPanel' contains 'iconKeys:TRICKPLAY_PLAY' using regular expressions
    Run Keyword If    ${is_play_icon_not_shown}    Run Keywords    I press    PLAY-PAUSE
    ...    AND    Wait Until Keyword Succeeds    15    200 ms    I expect page element 'id:trickPlayIcon-(Linear|NonLinear)InfoPanel' contains 'iconKeys:TRICKPLAY_PLAY' using regular expressions
    Hide Video Player bar

I switch Player to SLOW MOTION mode    #USED
    [Documentation]    This keyword switches the player to slow motion mode
    ${player_is_paused}    run keyword and return status    Player is in PAUSE mode
    Run Keyword If    '${player_is_paused}' == '${False}'    I switch Player to PAUSE mode
    I Press    FFWD
    Wait Until Keyword Succeeds    10    200 ms    I expect page element 'id:trickPlayIcon-(Linear|NonLinear)InfoPanel' contains 'iconKeys:TRICKPLAY_SLOW_MOTION' using regular expressions

Show Video Player bar    #USED
    [Documentation]    This keyword activate the Video Player bar and verifies whether it is shown
    ${player_visible}    Run Keyword And Return Status    Wait Until Keyword Succeeds    10x    100 ms    Player bar is not showing
    Run Keyword If    '${player_visible}' == '${True}'    I press    DOWN
    ${is_player_open}    Run Keyword And Return Status    Wait Until Keyword Succeeds    15 times    500 ms    I expect page contains 'id:playerUIContainer-Player'
    Return From Keyword If    ${is_player_open}    Video player bar is visible
    ${is_player_open}    Run Keyword And Return Status    Wait Until Keyword Succeeds    15 times    200 ms    Run Keywords    I Press    DOWN    AND
    ...    Wait Until Keyword Succeeds    15 times    500 ms    I expect page contains 'id:playerUIContainer-Player'
    Should Be True    ${is_player_open}    Video Player Bar is not visible


Video Player bar is shown   #USED
    [Documentation]    Verifies if Video Player bar is shown
    Show Video Player bar

Video Player bar is not shown    #USED
    [Documentation]    This keyword asserts that the Video Player bar is not shown
    Wait until keyword succeeds    ${JSON_MAX_RETRIES}    ${JSON_RETRY_INTERVAL}    I do not expect page contains 'id:playerUIContainer-Player'

Player is in PLAY mode    #USED
    [Documentation]    This keyword asserts the player is in play mode, gets the title from the Player info panel
    ...    and sets it in a test variable ${LAST_PLAYER_ASSET_TITLE}, as it might be useful later in playback
    Show Video Player bar
    ${is_player_open}    Run Keyword And Return Status   Wait Until Keyword Succeeds    ${JSON_MAX_RETRIES}    1 s    I expect page element 'id:trickPlayIcon-(Linear|NonLinear)InfoPanel' contains 'iconKeys:TRICKPLAY_PLAY' using regular expressions
    Should Be True    ${is_player_open}    Player is not in play mode
    ${last_player_asset_title}    Get asset title from Player info panel
    Set Suite Variable    ${LAST_PLAYER_ASSET_TITLE}   ${last_player_asset_title}

I switch Player to FRWD mode    #USED
    [Documentation]    This keyword switches the player to frwd mode
    ${player_is_playing}    run keyword and return status    Player is in PLAY mode
    Run Keyword If    '${player_is_playing}' == '${False}'    I switch Player to PLAY mode
    I Press    FRWD
    Error popup is not shown
    Wait Until Keyword Succeeds And Verify Status    ${JSON_MAX_RETRIES}    500 ms    Unable to switch Player to x2 FRWD mode    I expect page element 'id:trickPlayIcon-(Linear|NonLinear)InfoPanel' contains 'iconKeys:TRICKPLAY_REWIND' using regular expressions

I switch Player to x6 FRWD mode    #USED
    [Documentation]    This keyword switches the review buffer player to 6x frwd mode
    I switch Player to FRWD mode
    I Press    FRWD
    Wait Until Keyword Succeeds And Verify Status    ${JSON_MAX_RETRIES}    200 ms    Unable to switch Player to x6 FRWD mode    I expect page element 'id:rcuKeyFeedback-Player' contains 'image:/usr/share/.+/.*rew_x6.png' using regular expressions

I switch Player to x30 FRWD mode    #USED
    [Documentation]    This keyword switches the review buffer player to 30x frwd mode
    I switch Player to x6 FRWD mode
    I Press    FRWD
    Wait Until Keyword Succeeds And Verify Status    ${JSON_MAX_RETRIES}    200 ms    Unable to switch Player to x30 FRWD mode    I expect page element 'id:rcuKeyFeedback-Player' contains 'image:/usr/share/.+/.*rew_x30.png' using regular expressions

I switch Player to x64 FRWD mode    #USED
    [Documentation]    This keyword switches the review buffer player to 64x frwd mode
    I switch Player to x30 FRWD mode
    I Press    FRWD
    Wait Until Keyword Succeeds And Verify Status    ${JSON_MAX_RETRIES}    200 ms    Unable to switch Player to x64 FRWD mode    I expect page element 'id:rcuKeyFeedback-Player' contains 'image:/usr/share/.+/.*rew_x64.png' using regular expressions

Player is in FFWD mode
    [Documentation]    This keyword asserts player is in ffwd mode
    Wait Until Keyword Succeeds    ${JSON_MAX_RETRIES}    200 ms    I expect page element 'id:trickPlayIcon-(Linear|NonLinear)InfoPanel' contains 'iconKeys:TRICKPLAY_FAST_FORWARD' using regular expressions

Player is in '${speed}' FFWD mode     #USED
    [Documentation]    This keyword asserts the player is in ${speed} FFWD mode
    ...    Valid values of ${speed} are x2, x6, x30, x64
    Error popup is not shown
    Wait Until Keyword Succeeds And Verify Status    ${JSON_MAX_RETRIES}    500 ms    Unable To find ff_${speed} icon in Player    I expect page element 'id:rcuKeyFeedback-Player' contains 'image:/usr/share/.+/.*ff_${speed}.png' using regular expressions

Player is in FRWD mode
    [Documentation]    This keyword asserts player is in frwd mode
    Wait Until Keyword Succeeds    ${JSON_MAX_RETRIES}    200 ms    I expect page element 'id:trickPlayIcon-(Linear|NonLinear)InfoPanel' contains 'iconKeys:TRICKPLAY_REWIND' using regular expressions

Player is in '${speed}' FRWD mode    #USED
    [Documentation]    This keyword asserts the player is in ${speed} FRWD mode
    ...    Valid values of ${speed} are x2, x6, x30, x64
    Error popup is not shown
    Wait Until Keyword Succeeds And Verify Status    ${JSON_MAX_RETRIES}    500 ms    Unable To find rew_${speed} icon in Player    I expect page element 'id:rcuKeyFeedback-Player' contains 'image:/usr/share/.+/.*rew_${speed}.png' using regular expressions

Drag & Drop mode is initiated for
    [Arguments]    ${info_panel_type}
    [Documentation]    This keyword asserts the Drag & Drop mode is initiated.
    ...    Player type should be passed as argument ${info_panel_type}
    ...    Valid values for argument ${info_panel_type} are 'Non Linear Player' and 'Linear Player'
    ${info_panel_type}    run keyword if    '${info_panel_type}'=='Linear Player'    Set Variable    LinearInfoPanel
    ...    ELSE IF    '${info_panel_type}'=='Non Linear Player'    Set Variable    NonLinearInfoPanel
    ...    ELSE    fail    Incorrect Player Type value ${info_panel_type}. Valid are 'Non Linear Player' and 'Linear Player'
    Wait Until Keyword Succeeds    ${JSON_MAX_RETRIES}    ${JSON_RETRY_INTERVAL}    I expect page element 'id:dndPositionIndicator-${info_panel_type}' contains 'image:/usr/share/.+/.*drag_n_drop-marker.png' using regular expressions

I switch Player to FFWD mode    #USED
    [Documentation]    This keyword switches the player to ffwd mode
    ${player_is_playing}    run keyword and return status    Player is in PLAY mode
    Run Keyword If    '${player_is_playing}' == '${False}'    I switch Player to PLAY mode
    I Press    FFWD
    Error popup is not shown
    Wait Until Keyword Succeeds And Verify Status    ${JSON_MAX_RETRIES}    500 ms    Unable to Switch player to x2 FFWD mode    I expect page element 'id:trickPlayIcon-(Linear|NonLinear)InfoPanel' contains 'iconKeys:TRICKPLAY_FAST_FORWARD' using regular expressions

I switch Player to x6 FFWD mode     #USED
    [Documentation]    This keyword switches the review buffer player to 6x ffwd mode
    I switch Player to FFWD mode
    I press    FFWD
    Wait Until Keyword Succeeds And Verify Status    ${JSON_MAX_RETRIES}    200 ms    Unable to switch Player to x6 FFWD mode   I expect page element 'id:rcuKeyFeedback-Player' contains 'image:/usr/share/.+/.*ff_x6.png' using regular expressions

I switch Player to x30 FFWD mode    #USED
    [Documentation]    This keyword switches the review buffer player to 30x ffwd mode
    I switch Player to x6 FFWD mode
    I press    FFWD
    Wait Until Keyword Succeeds And Verify Status    ${JSON_MAX_RETRIES}    200 ms    Unable to switch Player to x30 FFWD mode    I expect page element 'id:rcuKeyFeedback-Player' contains 'image:/usr/share/.+/.*ff_x30.png' using regular expressions

I switch Player to x64 FFWD mode     #USED
    [Documentation]    This keyword switches the review buffer player to 64x ffwd mode
    I switch Player to x30 FFWD mode
    I press    FFWD
    Wait Until Keyword Succeeds And Verify Status    ${JSON_MAX_RETRIES}    200 ms    Unable to switch Player to x64 FFWD mode    I expect page element 'id:rcuKeyFeedback-Player' contains 'image:/usr/share/.+/.*ff_x64.png' using regular expressions

I press FFWD to forward till the end    #USED
    [Documentation]    This keyword plays the buffer till the end of the programme
    I switch Player to x64 FFWD mode
    Wait Until Keyword Succeeds    ${JSON_MAX_RETRIES}    200 ms    I expect page element 'id:rcuKeyFeedback-Player' contains 'image:/usr/share/.+/.*ff_x64.png' using regular expressions
    Wait Until Keyword Succeeds    50 times    5 sec    I do not expect page element 'id:rcuKeyFeedback-Player' contains 'image:/usr/share/.+/.*ff_x64.png' using regular expressions

I press FRWD until it reached the start of Player    #USED
    [Documentation]    This keyword rewinds Player till the start of the playback
    I switch Player to x64 FRWD mode
    Wait Until Keyword Succeeds    ${JSON_MAX_RETRIES}    200 ms    I expect page element 'id:rcuKeyFeedback-Player' contains 'image:/usr/share/.+/.*rew_x64.png' using regular expressions
    Wait Until Keyword Succeeds    50 times    5 sec    I do not expect page element 'id:rcuKeyFeedback-Player' contains 'image:/usr/share/.+/.*rew_x64.png' using regular expressions
    Video Player bar is not shown

Player Header is shown
    [Documentation]    This keyword asserts player header is shown
    Wait Until Keyword Succeeds    ${JSON_MAX_RETRIES}    200 ms    I expect page contains 'id:playerUIContainer-Player'
    Show Video Player bar
    I expect page element 'id:mastheadScreenTitle' contains 'textKey:DIC_HEADER_PLAYER'

Player Channel logo is shown
    [Documentation]    This keyword asserts channel logo is shown in the review buffer player
    Show Video Player bar
    I expect page element 'id:channelLogo.*InfoPanel' contains 'url:.+\.png.*' using regular expressions

Replay Channel logo is shown
    [Documentation]    This keyword asserts the channel logo is shown in the player
    Show Video Player bar
    I expect page element 'id:channelLogo-NonLinearInfoPanel' contains 'url:.+\.png.*' using regular expressions

Title of the replay event is shown
    [Documentation]    This keyword asserts title of the event is shown in the replay player
    Show Video Player bar
    ${json_object}    Get Ui Json
    ${is_in}    Is In Json    ${json_object}    ${EMPTY}    id:assetTitle-NonLinearInfoPanel
    Should Be True    ${is_in}    assetTitle missing or empty
    ${title}    Extract Value For Key    ${json_object}    id:assetTitle-NonLinearInfoPanel    textKey
    Should Not Be Empty    ${title}    Title of event missing

Progress bar is shown
    [Documentation]    This keyword asserts player progress bar is shown
    Wait Until Keyword Succeeds    ${JSON_MAX_RETRIES}    200 ms    I expect page contains 'id:.*PlayerProgressBar.*' using regular expressions

Trickplay icon is shown
    [Documentation]    This keyword asserts trickplay icon is shown in player
    Show Video Player bar
    I expect page contains 'id:trickPlayIcon.*InfoPanel' using regular expressions

Replay icon is shown
    [Documentation]    This keyword asserts the non linear replay icon is shown in player
    I expect page contains 'id:playerReplayIcon-NonLinearInfoPanel'

NonLinear Trickplay icon is shown
    [Documentation]    This keyword asserts the nonlinear trickplay icon is shown in player
    I expect page contains 'id:trickPlayCircle-NonLinearInfoPanel'

RCU hint is shown
    [Documentation]    This keyword asserts RCU hint is shown in player
    Show Video Player bar
    I expect page contains 'id:rcuKeyFeedback-Player'

Time indicating current position is shown
    [Documentation]    This keyword asserts current position time is shown in player
    Show Video Player bar
    I expect page contains 'id:currentPosition.*InfoPanel' using regular expressions

Time left until the end of the event is shown
    [Documentation]    This keyword asserts time until the end of the event is shown in player
    Show Video Player bar
    I expect page contains 'id:timeBeforeEnd.*InfoPanel' using regular expressions

Event title is shown    #USED
    [Documentation]    Verifies that if the Event Title is shown
    Show Video Player bar
    I expect page element 'id:watchingNow' contains 'textKey:DIC_HEADER_SOURCE_BUFFER' using regular expressions

Title is displayed in review buffer header    #USED
    [Documentation]    This keyword verifies that title is shown in review buffer header
    Event title is shown
    I expect page contains 'textKey:DIC_HEADER_SOURCE_BUFFER'

Verify current time is shown in the review buffer header
    [Documentation]    Checks the current time is shown in review buffer header and verifies whether the current STB time
    ...    and system time difference less than 3 minutes
    wait until keyword succeeds    ${JSON_MAX_RETRIES}    ${JSON_RETRY_INTERVAL}    I expect page element 'id:mastheadTime' contains 'textValue:^.+$' using regular expressions
    ${time_from_json}    I retrieve value for key 'textValue' in element 'id:mastheadTime'
    ${current_system_time}    robot.libraries.DateTime.Get Current Date    result_format=%H:%M
    ${time_difference}    robot.libraries.DateTime.Subtract Time From Time    ${current_system_time}    ${time_from_json}
    ${time_difference}    Convert to Integer    ${time_difference}
    ${time}    Evaluate    abs(${time_difference})
    Should Be True    ${time}<3    Current STB time and System time is not matching

Start and end time of the active event is shown
    [Documentation]    This keyword asserts event start and end time are shown in player
    Show Video Player bar
    I expect page element 'id:startEndTime-LinearInfoPanel' contains 'textValue:[0-9][0-9]:[0-9][0-9] \- [0-9][0-9]:[0-9][0-9]' using regular expressions

Linear Detail Page for the active event in Review Buffer Player is shown
    [Documentation]    This keyword asserts linear details page is shown
    Wait Until Keyword Succeeds    ${JSON_MAX_RETRIES}    200 ms    I expect page contains 'id:DetailPage.View'

Interactive modal with options 'Continue watching' and 'Watch live TV' is shown
    [Documentation]    This keyword asserts modal window with options 'Continue watching' and 'Watch live TV' is shown
    Interactive modal is shown
    I expect page contains 'textKey:DIC_ACTIONS_SWITCH_TO_LIVE'
    I expect page contains 'textKey:DIC_ACTIONS_WATCH'

I tune to channel with recordable single events
    [Documentation]    Tune to the test channel with recordable and playbackable single events
    I tune to channel    ${RECORDABLE_SINGLE_EVENTS_CHANNEL}

Review Buffer Player is not opened
    [Documentation]    This keyword verifies that the Review Buffer Player is not opened
    Video Player bar is not shown

Player is hidden
    [Documentation]    This keyword asserts player is hidden
    Video Player bar is not shown

About to start screen is shown
    [Documentation]    Check the about to start screen is displayed and then wait until it disappears
    Wait until keyword Succeeds    ${JSON_MAX_RETRIES}    ${JSON_RETRY_INTERVAL}    I expect page contains 'textKey:DIC_ABOUT_TO_START_HEADER'
    Wait Until Keyword Succeeds    30 times    1 sec    I do not expect page contains 'textKey:DIC_ABOUT_TO_START_HEADER'

Waiting indicator is not shown
    [Documentation]    Assert the content loading spinner is not shown
    Wait Until Keyword Succeeds    ${JSON_MAX_RETRIES}    ${JSON_RETRY_INTERVAL}    I do not expect page contains 'id:spinner-ContentLoading'

Waiting indicator is shown
    [Documentation]    Assert the content loading spinner is shown
    Wait Until Keyword Succeeds    ${JSON_MAX_RETRIES}    ${JSON_RETRY_INTERVAL}    I expect page contains 'id:spinner-ContentLoading'

I open Replay player    #USED
    [Documentation]    Open the focused replay event and start playback by selecting 'Replay' or 'Watch' button
    ...    Precondition: Focus should be on replay event in channel bar
    I Press    INFO
    Wait Until Keyword Succeeds    ${JSON_MAX_RETRIES}    ${JSON_RETRY_INTERVAL}    Replay Details Page is shown
    Play Any Asset From Detail Page
    Error popup is not shown

I Open Replay Player Of Added Replay Event In Watchlist    #USED
    [Documentation]    Open the focused replay event and start playback by selecting 'Replay' or 'Watch' button
    ...    Precondition: Focus should be on  Detail page of added replay event
    Play Any Asset From Detail Page
    Error popup is not shown

Replay header is shown    #USED
    [Documentation]    Check for the replay header
    wait until keyword succeeds    ${JSON_MAX_RETRIES}    ${JSON_RETRY_INTERVAL}    I expect page contains 'textKey:DIC_HEADER_SOURCE_REPLAY'

Interactive modal with options 'Watch live' and 'Watch from the beginning' is shown
    [Documentation]    This keyword asserts modal window with options 'Watch live' and 'Watch from the beginning' is shown
    Interactive modal is shown
    I expect page contains 'textKey:DIC_ACTIONS_SWITCH_TO_LIVE'
    I expect page contains 'textKey:DIC_ACTIONS_PLAY_FROM_START'

I invoke Video Player Bar pressing UP
    [Documentation]    Invoke Video Player Bar by pressing UP
    ${player_visible}    Get player visibility
    Run Keyword If    '${player_visible}' == '${False}'    I press    UP
    ${player_visible}    Get player visibility
    Should Be Equal    ${player_visible}    ${True}    Video Player Bar is not shown

Player Specific Teardown
    [Documentation]    Restart UI to get out of playback
    Reset All Continue Watching Events
    Restart UI via command over SSH
    Reset All Recordings
    Default Suite Teardown

I switch Player to x2 FFWD mode    #USED
    [Documentation]    Alternative keyword for I switch Player to FFWD mode
    I switch Player to FFWD mode
    LOG    This keyword calls for I switch Player to FFWD mode

I switch Player to x2 FRWD mode    #USED
    [Documentation]    Alternative keyword for I switch Player to FRWD mode
    I switch Player to FRWD mode
    LOG    This keyword calls for I switch Player to FRWD mode

I start playback of a past replay event from the replay events channel
    [Documentation]    Tune to replay events channel and start playback of a past replay event
    I tune to a channel with replay events
    I focus past replay event
    I open replay player
    About to start screen is shown

I start playback of a past replay event from the unlocked replay events channel
    [Documentation]    Tune to unlocked replay event channel and initate playback of a past replay event
    I tune to unlocked channel with replay events
    I focus past replay event
    I open replay player
    About to start screen is shown

I initate playback of a replay event from the replay series channel
    [Documentation]    Tune to replay series channel and initate playback of a past replay event without waiting for the playback to start
    I tune to a channel with replay series
    I focus past replay event
    I open replay player

I dismiss Video Player Bar pressing DOWN
    [Documentation]    Press down to dismiss player bar
    I Press    DOWN
    Wait Until Keyword Succeeds    ${JSON_MAX_RETRIES}    ${JSON_RETRY_INTERVAL}    Video Player bar is not shown

I have recorded a full single event
    [Documentation]    Record a full single event from the recordable single event channel
    I tune to channel with recordable single events
    I recorded an event

I start playback of the recording through Saved
    [Documentation]    Start and play the recording through saved, leave to play for a bit of time to make it usable for following FRWD actions
    I open Recordings through Saved
    I PLAY recording
    About to start screen is shown
    I wait for 30 seconds
    Player is in PLAY mode
    Hide Video Player bar

I initiate a playback of the recording through Saved
    [Documentation]    Select and initiate a playback of the recording through saved without verifiyng it actually starts
    I open Recordings through Saved
    I PLAY recording

I open the contextual menu to select 'Watch live TV'
    [Documentation]    Open the contextual menu from within RB playback, focus the 'Watch live TV' item and press ok
    I Press    CONTEXT
    Wait Until Keyword Succeeds    ${JSON_MAX_RETRIES}    ${JSON_RETRY_INTERVAL}    I expect page contains 'textKey:DIC_ACTIONS_BACK_TO_LIVE'
    Move Focus to Option in Value Picker    textKey:DIC_ACTIONS_BACK_TO_LIVE    DOWN    4
    I Press    OK

video is playing from start    #USED
    [Documentation]    Verify video is playing from start
    Run Keyword And Ignore Error    'About to start' screen is shown
    I wait for 2 seconds
    Error popup is not shown
    Player is in PLAY mode

I open Watch from the linear details page
    [Documentation]    Open LDP from whithin playback of RB and then open watch
    Show Video Player bar
    I press    OK
    Linear Detail Page for the active event in Review Buffer Player is shown
    I focus WATCH
    I press    OK

Player UI Elements are shown
    [Documentation]    Check for the presence of certain elements in Player UI
    video player bar is shown
    player header is shown
    Title of the replay event is shown
    trickplay icon is shown
    progress bar is shown
    time indicating current position is shown
    time left until the end of the event is shown
    player channel logo is shown

The viewing progress indicator is updated dynamically
    [Documentation]    Verifies that the progress bar is present and that it updates dynamically by checking for a change
    ...    in the current position time value and a change in the current position x value of the progress indicator
    progress bar is shown
    ${position_data0}    Get viewing progress indicator data
    ${position_time0}    set variable    ${position_data0[0]}
    ${position_value0}    set variable    ${position_data0[1]}
    ${position_time0_as_int}    Get time as integer    ${position_time0}
    ${x0}    Get progress indicator x position as int from position    ${position_value0}
    I wait for 10 seconds
    ${position_data1}    Get viewing progress indicator data
    ${position_time1}    set variable    ${position_data1[0]}
    ${position_value1}    set variable    ${position_data1[1]}
    ${position_time1_as_int}    Get time as integer    ${position_time1}
    ${x1}    Get progress indicator x position as int from position    ${position_value1}
    Should Be True    ${position_time1_as_int} > ${position_time0_as_int}    current progress indicator time is not greater than the previous value
    Should Be True    ${x1} > ${x0}    current progress indicator position is not greater than the previous value

Player Specific Teardown with Favourites list clearance
    [Documentation]    Some tests setup favourite lists. Clear this list before performing the player specific teardown
    ${status}    run keyword and return status    I Clear Favourites channel list
    run keyword unless    ${status}    Reset Channels    FAVORITE
    Player Specific Teardown

I start playback of a past replay event from current channel
    [Documentation]    Start playback of a past replay event from the current channel. Sometimes we don't want to tune.
    ...    Pre-req: User is on full-screen, live TV.
    I focus current replay event
    I focus past replay event
    I open replay player
    About to start screen is shown
    Player is in PLAY mode

Make sure Playout continues for the duration    #USED
    [Arguments]    ${play_duration}
    [Documentation]    Make sure playout continue for the specified duration
    ${timedelta}    robot.libraries.DateTime.Convert Time    ${play_duration}    timedelta
    : FOR    ${count}    IN RANGE    ${timedelta.total_seconds()}/5
    \    I wait for 5 seconds
    \    Wait until keyword succeeds    5s    ${JSON_RETRY_INTERVAL}    I expect page contains 'id:Player.View'

'Fast forwarding on this channel is not allowed' toast is shown
    [Documentation]    Verifes that the FFWD prevention toast message is shown
    wait until keyword succeeds    ${JSON_MAX_RETRIES}    ${JSON_RETRY_INTERVAL}    I expect page contains 'textKey:DIC_ERROR_MESSAGE_FFWD_NOT_ALLOWED_VOD_PVR'

I play the partial recording from the start through Saved
    [Documentation]    Start and play the recording from the start through saved, leave to play for a bit of time
    ...    to make it usable for following FFWD/FRWD actions
    I open Recordings through Saved
    I PLAY recording
    I focus 'Play from start'
    I press    OK
    About to start screen is shown
    I wait for 30 seconds
    Player is in PLAY mode
    Hide Video Player bar

Player background is GREY
    [Documentation]    This keyword verifies that if subtitles test channel is having GREY background
    Screenshot has the given background color    GREY    ${SUBTITLE_RECORDED_EVENT_GREY_REGION}

I select 'Play from start' on a partially recorded ongoing event through Saved
    [Documentation]    This keyword plays the partially recorded event from start
    I open Recordings through Saved
    I PLAY recording
    I focus 'Play from start'
    I press    OK
    Recording starts playing
    Hide Video Player bar

I press PLAY-PAUSE on the Review Buffer channel
    [Documentation]    This keyword tunes to a review buffer channel and presses PLAY-PAUSE to display the Review Buffer player
    I tune to channel    ${REPLAY_EVENTS_CHANNEL}
    I open Review Buffer Player

Play-out of the event is started
    [Documentation]    This keyword will wait for player bar to hide and verifies the played content is playing
    ...    Precondition: The player should be playing an event
    About to start screen is shown
    Player is in PLAY mode

I initiate Drag & Drop functionality for
    [Arguments]    ${info_panel_type}
    [Documentation]    This keyword retrieves the current video playout position on the timeline then sets it as a test variable and
    ...    initiates the Drag & Drop functionality by pressing FRWD button for 4 seconds
    ...    and then expects the Drag & Drop mode to be initiated.
    ...    Player type should be passed as argument ${info_panel_type}
    ...    Valid values for argument ${info_panel_type} are 'Non Linear Player' and 'Linear Player'
    ...    Pre-reqs: Player has to be present.
    ${position}    Get video playout position on the timeline
    Set Test Variable    ${PLAYER_POSITION}    ${position}
    I Long Press FRWD for 4 seconds
    Drag & Drop mode is initiated for    ${info_panel_type}

Thumbnail view is shown
    [Documentation]    This keyword expects the page to contain a thumbnail view.
    ...    Pre-reqs: Drug & Drop mode should be initiated.
    Wait until keyword succeeds    ${JSON_MAX_RETRIES}    ${JSON_RETRY_INTERVAL}    I expect page contains 'id:ThumbnailScrubber'

I play a VOD asset
    [Arguments]    ${secs_to_play}=${PLAY_TIME_SECS_TO_ALLOW_TRICKPLAY}    ${min_duration}=${VOD_ASSET_MIN_DURATION}    ${max_duration}=${VOD_ASSET_MAX_DURATION}
    [Documentation]    This keyword enters the VOD Movie collection, focuses a movie tile within ${min_duration} and ${max_duration}, selects the tile then plays
    ...    the VOD asset for ${secs_to_play}, which is set to ${PLAY_TIME_SECS_TO_ALLOW_TRICKPLAY} by default,
    ...    so there's a large enough buffer to allow all trickplay speeds.
    ...    If the asset needs to be rented, rental and PIN entry takes place.
    ...    If the asset is already partially watched, the asset is played from the start.
    ...    Note that the VOD playback time will be slightly more than the argument value as there's a timing issue
    ...    related to the player bar auto-dismissing that needs to be handled.
    I focus a VOD tile in section    Movies    ${min_duration}    ${max_duration}
    I press    OK
    VOD Details page is shown
    ${is_partially_watched}    run keyword and return status    'WATCH' action is shown
    I press    OK
    run keyword if    ${is_partially_watched}    I select the 'PLAY FROM START' action
    About to start screen is shown
    # Timing issue. Wait until the player vanishes at the start of playback, then make it appear
    Wait until keyword succeeds    10 times    1 sec    I do not expect page contains 'id:playerUIContainer-Player'
    Player is in PLAY mode
    Make sure Playout continues for the duration    ${secs_to_play}

I create a Review Buffer of '${number_of_minutes}' minutes on a replay channel
    [Documentation]    This keyword creates a review buffer on a replay channel, ${number_of_minutes} in length
    ...    by tuning to the channel, pausing, then waiting for ${number_of_minutes}
    I tune to unlocked channel with replay events
    I open Review Buffer Player
    Video Player Bar is shown
    Player is in PAUSE mode
    I wait for ${number_of_minutes} minutes
    I switch Player to PLAY mode

The same VOD asset is still playing
    [Documentation]    This keyword checks that the same VOD asset is still playing by checking video is present
    ...    and that the title in the Player info panel has not changed since the start of VOD playback
    ...    Pre-reqs: test var ${LAST_PLAYER_ASSET_TITLE} has been set when playback of the VOD asset starts
    ...    The VOD asset is still playing
    video playing
    Asset title from Player info panel has not changed

I play an already rented VOD movie asset directly from the tile for '${secs_to_play}' seconds
    [Documentation]    This keyword enters the VOD Movie collection, focuses the already rented movie tile
    ...    which has been set in test variable ${RENTED_MOVIE_TITLE}, presses PLAY on that tile and
    ...    plays back the VOD asset for ${secs_to_play}
    ...    Note that the VOD playback time will be slightly more than the argument value as there's a timing issue
    ...    related to the player bar auto-dismissing that needs to be handled.
    Variable should exist    ${RENTED_MOVIE_TITLE}    A movie has not been rented. RENTED_MOVIE_TITLE does not exist.
    I open On Demand through Main Menu
    I focus rented VOD movie
    I press    PLAY-PAUSE
    About to start screen is shown
    # Timing issue. Wait until the player vanishes at the start of playback, then make it appear
    Wait until keyword succeeds    10 times    1 sec    I do not expect page contains 'id:playerUIContainer-Player'
    Player is in PLAY mode
    Make sure Playout continues for the duration    ${secs_to_play}

The VOD playout has finished
    [Documentation]    This keyword checks that VOD playout has finished by checking that the Player.View is
    ...    no longer present.
    ...    Note: There's an assumption that a VOD asset was playing out and now it isn't. Don't confuse the
    ...    playerUIContainer-Player with the Player.View.
    Wait until keyword succeeds    20times    5s    I do not expect page contains 'id:Player.View'

I have recorded a full single event with subtitles
    [Documentation]    Record a full single event from the recordable single event channel with subtitles.
    I tune to a replay channel with subtitles
    I recorded an event

I create a Review Buffer of '${number_of_minutes}' minutes on a replay channel with subtitles
    [Documentation]    This keyword creates a review buffer on a replay channel with subtitles, ${number_of_minutes} in length
    ...    by tuning to the channel, pausing, then waiting for ${number_of_minutes}
    I tune to a replay channel with subtitles
    I open Review Buffer Player
    Video Player Bar is shown
    Player is in PAUSE mode
    I wait for ${number_of_minutes} minutes
    I switch Player to PLAY mode

I start playback of a current replay event from channel
    [Documentation]    Start playback of a replay event from the current channel.
    ...    Pre-reqs: Replay event channel should already be tuned.
    I focus current replay event
    I open replay player
    About to start screen is shown
    Player is in PLAY mode

The playout jumps forward '${number:\d+}' seconds
    [Documentation]    This keyword verifies that the player progress has jumped forward for ${number} seconds
    Variable should exist    ${PLAYER_PROGRESS_TIME}    No progress time saved for the asset playing
    ${progress_time}    Get linear player viewing progress indicator time
    ${PLAYER_PROGRESS_TIME}    robot.libraries.DateTime.Convert Time    ${PLAYER_PROGRESS_TIME}
    ${progress_time}    robot.libraries.DateTime.Convert Time    ${progress_time}
    ${time_difference}    Evaluate    abs(${PLAYER_PROGRESS_TIME} - ${progress_time} + ${number})
    Should Be True    ${time_difference} < ${CONTINUE_WATCHING_TOLERANCE_VALUE_SECONDS}    Playout didn't skip the correct number of seconds

The playout jumps back '${number:\d+}' seconds
    [Documentation]    This keyword verifies that the player progress has jumped backwards for ${number} seconds
    Variable should exist    ${PLAYER_PROGRESS_TIME}    No progress time saved for the asset playing
    ${progress_time}    Get linear player viewing progress indicator time
    ${PLAYER_PROGRESS_TIME}    robot.libraries.DateTime.Convert Time    ${PLAYER_PROGRESS_TIME}
    ${progress_time}    robot.libraries.DateTime.Convert Time    ${progress_time}
    ${time_difference}    Evaluate    abs(${PLAYER_PROGRESS_TIME} - ${progress_time} - ${number})
    Should Be True    ${time_difference} < ${CONTINUE_WATCHING_TOLERANCE_VALUE_SECONDS}    Playout didn't skip the correct number of seconds

The playout jumps back to the start
    [Documentation]    This keyword verifies that the player progress has jumped back to the start of the video
    Show Video Player bar
    ${progress_time}    ${_}    Get viewing progress indicator data
    ${progress_time}    robot.libraries.DateTime.Convert Time    ${progress_time}
    Should Be True    ${progress_time} < ${CONTINUE_WATCHING_TOLERANCE_VALUE_SECONDS}    Playout didn't jump back to the start

I verify that current video playout position on the timeline is less than the previous position
    [Documentation]    This keyword retrieves the video playout new position value and compares it with the previous playout position.
    ...    Previous playout position should be available as a test variable ${PLAYER_POSITION}.
    ...    Pre-reqs: Player has to be present.
    Variable should exist    ${PLAYER_POSITION}    Test variable PLAYER_POSITION has not been set.
    ${position}    Get video playout position on the timeline
    Should be true    ${position} < ${PLAYER_POSITION}    Current video playout position ${position} on the timeline is not less than previous position ${PLAYER_POSITION}.

I am able to navigate through review buffer
    [Documentation]    This keyword verifies that FFWD and FRWD is possible in the review buffer
    I press FRWD until it reached the start of Player
    I press FFWD to forward till the end

Content playback has started from the local RAM
    [Documentation]    This keyword will verify if the content playback has started from the local RAM buffer.
    ${ssh_handle}    Remote.open connection    ${STB_IP}
    Remote.login    ${STB_IP}    ${ssh_handle}
    ${query_result}    Remote.execute_command    ${STB_IP}    ${ssh_handle}    journalctl -n '${JOURNAL_LINE_COUNT_TO_MATCH_RB_SOLUTION}' | grep -i "playbacksource"
    should not be empty    ${query_result}    No "playbacksource" specific entries are found in journalctl log
    Remote.close connection    ${STB_IP}    ${ssh_handle}
    should contain    ${query_result}    ${BUFFER_TYPE_RAM}    The content playback not started from RAM

I Exit Playback    #USED
    [Documentation]    This keyword ensure that the playback has been exited
    : FOR    ${i}    IN RANGE    5
    \    I Press    STOP
    \    ${status}    Run Keyword And Return Status    I do not expect page contains 'id:Player.View'
    \    Exit For Loop If    ${status}
    Should Be True    ${status}    Unable to exit the player

I Exit Playback And Return To Detail Page    #USED
    [Documentation]    This keyword exit the playback and ensures the detail page is shown properly
    I Exit Playback
    Common Details Page elements are shown

Header Is Shown For Linear Player     #USED
    [Documentation]    This keyword verifies that on the TV Guide EPG page, the Programme Header text is Shown
    wait until keyword succeeds    ${JSON_MAX_RETRIES}    ${JSON_RETRY_INTERVAL}    I expect page element 'id:watchingNow' contains 'textKey:(DIC_HEADER_SOURCE_LIVE|DIC_HEADER_SOURCE_RADIO)' using regular expressions

I Skip Forward In Review Buffer After Waiting '${time}' Seconds    #USED
    [Documentation]    This keyword verifies the skip forward actions in review Buffer
    ...    Pre-requisites : Video plackback should be in PAUSE mode
    ...    Skip FORWARD will skip the video by 30 seconds and we are also considering a buffer of 4 seconds.
    I wait for ${time} seconds
    I Press    PLAY-PAUSE
    Show Video Player bar
    ${position_1}    Get linear player viewing progress indicator time
    I press    RIGHT
    Show Video Player bar
    ${position_2}    Get linear player viewing progress indicator time
    ${time_difference}    Subtract Time From Time    ${position_2}    ${position_1}
    ${time_difference}    Convert To Integer    ${time_difference}
    Should Be True    26<=${time_difference}<=34    Unable to skip Forward in review Buffer

I Skip Backward In Review Buffer    #USED
    [Documentation]    This keyword verifies the skip Backward actions in review Buffer
    ...    Pre-requisites : Video plackback should be in PLAY mode. Skip forward should be performed
    ...    before skip backward. Skip BACKWARD will skip the video by 30 seconds and we are also 
    ...    considering a buffer of 4 seconds.
    Show Video Player bar
    ${position_2}    Get linear player viewing progress indicator time
    I press    LEFT
    Show Video Player bar
    ${position_3}    Get linear player viewing progress indicator time
    ${time_difference}    Subtract Time From Time    ${position_2}    ${position_3}
    ${time_difference}    Convert To Integer    ${time_difference}
    Should Be True    26<=${time_difference}<=34    Unable to skip Backward in review Buffer

Delayed Stream Toast Message Is Present    #USED
    [Documentation]    Keyword to verify the toast message for delayed stream is present
    Wait Until Keyword Succeeds    10times    1s    I expect page contains 'textKey:DIC_TOAST_DELAYED_STREAM'

'Switch to live TV' Action Is Shown In Delayed Stream Toast Message    #USED
    [Documentation]    This keyword verifies the 'Switch to live TV' action is shown in delayed stream toast message.
    Wait Until Keyword Succeeds    ${JSON_MAX_RETRIES}    ${JSON_RETRY_INTERVAL}    I expect page contains 'textKey:DIC_ACTIONS_BACK_TO_LIVE'

'Switch to live TV' Action Is Focused In Delayed Stream Toast Message    #USED
    [Documentation]    This keyword verifies that the 'Switch to live TV' action is focused in delayed stream toast message.
    Move Focus to Option in Value Picker    textKey:DIC_ACTIONS_BACK_TO_LIVE    DOWN    2
    Option is Focused in Value Picker    textKey:DIC_ACTIONS_BACK_TO_LIVE

'Dismiss' Action Is Shown In Delayed Stream Toast Message    #USED
    [Documentation]    This keyword verifies the 'Dismiss' action is shown in delayed stream toast message.
    Wait Until Keyword Succeeds    ${JSON_MAX_RETRIES}    ${JSON_RETRY_INTERVAL}    I expect page contains 'textKey:DIC_GENERIC_BTN_DISMISS'

'Dismiss' Action Is Focused In Delayed Stream Toast Message    #USED
    [Documentation]    This keyword verifies that the 'Dismiss' action is focused in delayed stream toast message.
    Move Focus to Option in Value Picker    textKey:DIC_GENERIC_BTN_DISMISS    DOWN    2
    Option is Focused in Value Picker    textKey:DIC_GENERIC_BTN_DISMISS

I Verify Playback In Review Buffer Mode    #USED
    [Documentation]    This keyword verifies that the Time Shifted TV is playing without any errors
    Title is displayed in review buffer header
    Player is in PLAY mode
    Error popup is not shown

I Verify Playback In Live Mode    #USED
    [Documentation]    This keyword verifies that the Live TV is playing without any errors
    I open Channel Bar
    LIVE TV is shown in header
    Error popup is not shown

Continue Watching Replay Asset For '${time}' And Get Time From Progress Indicator   #USED
    [Documentation]    Open the focused replay event and start playback by selecting 'Replay' or 'Watch' button.
    ...    It will continues to watch the replay asset for ${time} seconds.
    ...    It sets the continue watching progress time as Suite variable
    ...    i.e., 'CONTINUE_WATCHING_PROGRESS_TIME' and the stops the playback.
    ...    Precondition: Focus should be on replay event in channel bar
    I Press    INFO
    Replay Details Page is shown
    Continue Watching Asset From Detail Page
    Player is in PLAY mode
    Make sure Playout continues for the duration    ${time}s
    I switch Player to PAUSE mode
    Show Video Player bar
    ${continue_watching_progress_time}    ${continue_watching_progress_value}    Get viewing progress indicator data
    Set Suite Variable    ${CONTINUE_WATCHING_PROGRESS_TIME}    ${continue_watching_progress_time}

Continue Watching Selected Recording Asset For '${time}' and Get Time From Progress Indicator       #USED
    [Documentation]    This Keyword starts continue watching the selected Recording Asset
    ...     and sets the current progress time from progress indicator to suite variable 'CONTINUE_WATCHING_PROGRESS_TIME'
    Continue Watching Asset From Detail Page
    Player is in PLAY mode
    Make sure Playout continues for the duration    ${time}s
    I Press    PAUSE
    ${continue_watching_progress_time}    ${continue_watching_progress_value}    Get viewing progress indicator data
    I Press    STOP
    Set Suite Variable    ${CONTINUE_WATCHING_PROGRESS_TIME}    ${continue_watching_progress_time}

Catch Back To Live TV From Review Buffer   #USED
    [Documentation]   Checks whether LIVE TV is playing after review buffer playback
    I switch Player to x64 FFWD mode
    wait until keyword succeeds    ${JSON_MAX_RETRIES}    ${JSON_RETRY_INTERVAL}    I expect page contains 'textKey:DIC_TOAST_WATCHING_LIVE'

I Open IP Channel    #USED
    [Documentation]    This opens IP Channel
    I Open Detail Page
    ${replay_enabled}    Run Keyword And Return Status    wait until keyword succeeds    ${JSON_MAX_RETRIES}    ${JSON_RETRY_INTERVAL}    I expect page contains 'id:replayIconprimaryMetadata'
    ${watch_is_present}    Run Keyword And Return Status    Wait Until Keyword Succeeds    2s    100 ms    I expect page contains 'textKey:DIC_ACTIONS_WATCH'
    Run Keyword If    ${watch_is_present}==True    Run Keywords
    ...    I focus WATCH    AND    I press    OK    AND    Handle Pin Popup
    ...    AND    Interactive modal with options 'Watch live' and 'Watch from the beginning' is shown
    ...    AND    Move Focus to Section    DIC_ACTIONS_SWITCH_TO_LIVE    textKey
    ...    AND    I Press    OK
    ...    ELSE    Run Keywords
    ...    Wait Until Keyword Succeeds    ${JSON_MAX_RETRIES}    ${JSON_RETRY_INTERVAL}    I expect page contains 'textKey:DIC_ACTIONS_BACK_TO_LIVE'
    ...    AND    I Press    OK

Interactive Modal With Options 'Play from beginning' And 'Watch live' Is Shown    #USED
    [Documentation]    This keyword asserts modal window with options 'Play from beginning' and 'Watch live' is shown
    I expect page contains 'textKey:DIC_ACTIONS_SWITCH_TO_LIVE'
    I expect page contains 'textKey:DIC_ACTIONS_PLAY_FROM_START'

Verfiy Watch Popup For Locked Channels And Select 'WATCH LIVE'   #USED
    [Documentation]    This Keyword verifies if watch popup is dispayed for the locked channel and selects watch live
    ${valid}    Run Keyword And Return Status    Interactive Modal With Options 'Play from beginning' And 'Watch live' Is Shown
    Run Keyword If    ${valid}    Run Keywords    Move Focus to Section    DIC_ACTIONS_SWITCH_TO_LIVE    textKey
    ...    AND    I Press    OK
#**********************************CPE PERFORMANCE***************************************************
Get Current Session RefID via VLDMS
    [Documentation]    This keyword return thes RefId of the current Session from VLDMS
    #${start}  robot.libraries.DateTime.Get Current Date
    ${sessions_info_json}    get tuner details via vldms    ${STB_IP}    ${CPE_ID}
    #${stop}   robot.libraries.DateTime.Get Current Date
    #${diff}   robot.libraries.DateTime.Subtract Date From Date     ${stop}     ${start}
    #Set Suite Variable    ${LAST_HTTP_TIME}    ${diff}
    ${ref_id}    Extract Value For Key    ${sessions_info_json}    type:main    refId
    [Return]    ${ref_id}

Verify Linear TV is Tuned via VLDMS
    [Documentation]    This keyword checks that the linear channel is tuned using VLDMS
    [Arguments]    ${channel_ids}
    #${start}  robot.libraries.DateTime.Get Current Date
    ${sessions_info_json}    get tuner details via vldms    ${STB_IP}    ${CPE_ID}
    #${stop}   robot.libraries.DateTime.Get Current Date
    #${diff}   robot.libraries.DateTime.Subtract Date From Date     ${stop}     ${start}
    #Set Suite Variable    ${LAST_HTTP_TIME}    ${diff}
    ${tunerStatus}    Extract Value For Key    ${sessions_info_json}    type:main    tunerStatus
    ${lock_status}    Is In Json    ${sessions_info_json}     type:main    tunerStatus:locked
    :FOR    ${channel_id}    IN    @{channel_ids}
    \    ${channel_status}    run keyword and return status    Is In Json    ${sessions_info_json}     type:main    refId:${channel_id}
    \    exit for loop if      ${channel_status}
    ${lock_status}    set variable if    '${COUNTRY}' == 'pl' or 'preprod_ch' or 'preprod_nl' in '${LAB_NAME}'   'true'    ${lock_status}
    Should be True      ${lock_status} and ${channel_status}

Verify IP is Played via VLDMS
    [Documentation]     Verifies if the IP content is currenlty played from VLDMS Session Manager
    #${start}  robot.libraries.DateTime.Get Current Date
    ${sessions_info_json}    get tuner details via vldms    ${STB_IP}    ${CPE_ID}
#    ${stop}   robot.libraries.DateTime.Get Current Date
#    ${diff}   robot.libraries.DateTime.Subtract Date From Date     ${stop}     ${start}
#    Set Suite Variable    ${LAST_HTTP_TIME}    ${diff}
    ${ref_id}    Extract Value For Key    ${sessions_info_json}    type:main    refId
    ${active_status}    Is In Json    ${sessions_info_json}     type:main    active:true
    Should Match Regexp    ${ref_id}    (^crid:.*|.*)    'Reference ID is not for IP content'
    Should be True      ${active_status}     'Session is not active'

I Play from Start from Guide
    [Documentation]    Open the focused replay event and start playback by selecting 'Replay' or 'Watch' button
    ...    Precondition: Focus should be on replay event in guide
    I wait for 2 second
    I Press    OK
    I wait for 2 second
    I focus 'Play from start'
    I press    OK
    I wait for 4 second
    ${age_lock_status}    run keyword and return status    I expect page element 'id:pinEntryModalPopupBody' contains 'textKey:DIC_PIN_BODY_AGE_LOCK'
    run keyword if    ${age_lock_status}     I enter a valid pin


Swith Player to '${speed}' FF Mode
    [Documentation]    Switches the current video play back in given FF speed
    ${ref_id}    get main session ref id via vldms    ${STB_IP}    ${CPE_ID}
    : FOR    ${index}    IN RANGE    4
        \    send key    FFWD
        \    I wait for 2 seconds
        \    ${current_speed}    Get player speed via vldms    ${ref_id}
        \    Exit For Loop IF    ${speed} == ${current_speed}
    Should Be True      ${speed} == ${current_speed}

Swith Player to '${speed}' FR Mode
    [Documentation]    Switches the current video play back in given FR speed
    ${ref_id}    get main session ref id via vldms    ${STB_IP}    ${CPE_ID}
    : FOR    ${index}    IN RANGE    4
        \    send key    FRWD
        \    I wait for 2 seconds
        \    ${current_speed}    Get player speed via vldms    ${ref_id}
        \    Exit For Loop IF    ${speed} == ${current_speed}
    Should Be True      ${speed} == ${current_speed}

I open Live TV    #USED
    [Documentation]    Open the focused replay event and start playback by selecting 'Replay' or 'Watch' button
    ...    Precondition: Focus should be on replay event in channel bar
    I Press    OK
    ${channel_locked}    Run Keyword And Return Status    locked icon is shown for events ar 0 and above in guide
    wait until keyword succeeds    20 times   100 ms    Interactive modal with options 'Watch live TV' and 'Play from start' is shown
    I press    OK
#    ${pin_entry_present}    Run Keyword And Return Status    Pin Entry popup is shown
    Run Keyword If    ${channel_locked}    I Enter A Valid Pin

I Select Play From Start
    [Documentation]   This keyword records an event from Info Page
    I press    OK
    ${status}    run keyword and return status    Interactive modal with options 'Continue Watching' and 'Play From Start' is shown
    run keyword if    ${status}    I press   DOWN
    I wait for 2 second
    I press    OK

#############################CPE PERFORMANCE###################

I dismiss Video Player Bar
    [Documentation]    Press down to dismiss player bar
    Wait Until Keyword Succeeds    50s    ${DEFAULT_RETRY_INTERVAL}    Video Player bar is not shown after down key press

Video Player bar is not shown after down key press
    [Documentation]    This keyword asserts that the Video Player bar is not shown
    ${status}  run keyword and return status  I do not expect page contains 'id:playerUIContainer-Player'
    run keyword if  ${status}   return from keyword
    I press   DOWN
    run keyword and return    I do not expect page contains 'id:playerUIContainer-Player'

Video playout is started
    [Documentation]  To verify if video playout is started
    ${json_object}    Get Ui Json
    ${is_player_view_shown}    Is In Json    ${json_object}    ${EMPTY}    id:Player.View
    Should be true    ${is_player_view_shown}    video player view not shown
    ${is_player_open}    Is In Json    ${json_object}    ${EMPTY}    id:playerUIContainer-Player
    Should be true    ${is_player_open}    video player bar not shown
    ${is_progress_bar_shown}    Is In Json    ${json_object}    ${EMPTY}    id:.*PlayerProgressBar.*    ${EMPTY}    ${True}
    Should be true    ${is_progress_bar_shown}   video player progress bar not started