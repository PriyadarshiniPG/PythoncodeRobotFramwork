*** Settings ***
Documentation     Keywords covering functions and aesthetic of the channel bar
Resource          ../Json/Json_handler.robot
Resource          ../Common/Stbinterface.robot
Resource          ../Common/Common.robot
Resource          ../PA-10_Player/Player_Keywords.robot
Resource          ../PA-04_User_Interface/ChannelBar_Implementation.robot
Resource          ../PA-18_Replay_TV/ReplayTV_Implementation.robot

*** Variables ***
${CHANNEL_QUERY_TIMEOUT}    5 sec
${past_event_length}    50

*** Keywords ***
LIVE TV is shown in header
    [Documentation]    Checks if LIVE TV is shown in header
    wait until keyword succeeds    ${JSON_MAX_RETRIES}    ${JSON_RETRY_INTERVAL}    I expect page contains 'textKey:DIC_HEADER_SOURCE_LIVE'

the title of the current programme is shown in the Header
    [Documentation]    Checks if the title of the current programme is shown in the Header
    wait until keyword succeeds    ${JSON_MAX_RETRIES}    ${JSON_RETRY_INTERVAL}    I expect page element 'id:watchingNow' contains 'textValue:^.+$' using regular expressions
    Prevent Channel Bar from disappearing
    &{highlighted_event}    I retrieve details for event with highlight color in Channel Bar
    ${json_object}    Get Ui Json
    ${header}    Extract Value For Key    ${json_object}    id:watchingNow    textValue
    ${item_title}    Extract Value For Key    ${json_object}    id:&{highlighted_event}[event_id]    textValue
    ${header}    convert to lowercase    ${header}
    @{header}    split string    ${header}    :    1
    ${header}    strip string    @{header}[1]
    ${item_title}    convert to lowercase    ${item_title}
    Should Contain    ${item_title}    ${header}

I open Channel Bar    #USED
    [Documentation]    This keyword will try to exit to channelbar from any screen in the UI
    ...    the for loop will execute maximum 15 times
    ...    if the FullScreen.View or NowAndNext.View screen won't be reached until then the test will fail
    Exit player if turned on
    Run Keyword if    ${OBELIX}=='True'    Make sure that either of Pairing request tips screens exited
    Dismiss Channel Failed Error Pop Up
    : FOR    ${i}    IN RANGE    ${15}
    \    ${json_object}    Get Ui Json
    \    ${is_full_screen_present}    Is In Json    ${json_object}    ${EMPTY}    id:FullScreen.View
    \    ${is_now_and_next_present}    Is In Json    ${json_object}    ${EMPTY}    id:NowAndNext.View
    \    ${is_modal_present}    Is In Json    ${json_object}    ${EMPTY}    id:Widget.ModalPopup
    \    ${is_netflix_present}    Is In Json    ${json_object}    ${EMPTY}    id:Netflix.View
    \    ${is_channel_failed}    Is In Json    ${json_object}    ${EMPTY}    id:infoScreenErrorTitle
    \    Exit For Loop If    (${is_full_screen_present} or ${is_now_and_next_present} or ${is_netflix_present} or ${is_channel_failed}) and ${is_modal_present} == ${False}
    \    Wait Until Keyword Succeeds    15 times    1 sec    Press BACK and assert json changed    ${json_object}
    Run Keyword If    ${i} == ${14}    Fail    Failed to open channelbar
    Run Keyword If    ${is_full_screen_present}    Show Channel Bar and wait until present
    ...    ELSE IF    ${is_channel_failed}    Open channel bar from channel failed view
    ...    ELSE IF    ${is_now_and_next_present}    Prevent Channel Bar from disappearing
    ...    ELSE IF    ${is_netflix_present}    Perform channel UP and tune to free channel
    Set current lineup variables

Open channel bar from channel failed view    #USED
    [Documentation]    This keyword opens Now and next view by pressing back from channel failed popup
    ${json_object}    Get Ui Json
    Press BACK and assert json changed    ${json_object}
    I expect page contains 'id:NowAndNext.View'

check if tuned channel matches with channel bar
    [Documentation]    Checks if the channel bar and the actual tuned channel matches
    ${channel_in_channelbar}    Read channel number from channel bar data
    ${tuned_channel_id}    Get current channel
    ${actual_channel_tuned}    get channel lcn for channel id    ${tuned_channel_id}
    should be equal as strings    ${channel_in_channelbar}    ${actual_channel_tuned}

Perform channel UP and tune to free channel    #USED
    [Documentation]    This keyword performs CHANNELUP operation for few times and then tunes to a random channel
    ...    from the lineup
    repeat keyword    4 times    I Press    CHANNELUP
    Tune To A Random Channel From Channel Lineup

Dismiss All Error Popups While Displaying Channel Bar    #USED
    [Documentation]    This keyword dismiss all the error popups before and after displaying the channel bar
    : FOR    ${_}    IN RANGE    ${5}
    \    ${pop_up_found}  Run Keyword And Return Status    Wait Until Keyword Succeeds    3 times    300 ms    I expect page contains 'id:Widget.ModalPopup'
    \    Run Keyword If    ${pop_up_found}    Run Keywords    I Press    BACK    AND    I wait for 1 second
    \    Exit For Loop If   not ${pop_up_found}
    Should Not Be True    ${pop_up_found}    Unable to dismiss error popup

Show Channel Bar and wait until present    #USED
    [Documentation]    Helper keyword for opening Channel Bar and waiting until its visible
    Dismiss All Error Popups While Displaying Channel Bar
    ${status}    Run Keyword And Ignore Error    I expect page contains 'id:NowAndNext.View'
    Return From Keyword If    "${status[0]}"=="PASS"    Channelbar visible
    I Press    OK
    Dismiss All Error Popups While Displaying Channel Bar
    Wait Until Keyword Succeeds    10 times   300 ms    I expect page contains 'id:NowAndNext.View'

Prevent Channel Bar from disappearing    #USED
    [Documentation]    Helper keyword to make sure Channel Bar doesn't disappear
#    ${is_correct_channel_tuned}    run keyword and return status    check if tuned channel matches with channel bar
#    run keyword unless    ${is_correct_channel_tuned}    I Press    BACK
    ${json_object}    Get Ui Json
    ${lock_text}    Is In Json    ${json_object}    id:RcuCue    textKey:^DIC_RC_CUE_UNLOCK_(PROGRAM|CHANNEL)$    ${EMPTY}    ${True}
    ${channel_bar_shown}  Run Keyword And Return Status    I expect page contains 'id:NowAndNext.View'
    Run Keyword If    not ${channel_bar_shown}    I PRESS    DOWN

Prevent Channel Bar from disappearing from an unlocked channel
    [Documentation]    Helper keyword for opening Channel Bar and waiting until its visible
    ${status}    run keyword and return status    Wait Until Keyword Succeeds    10 times    500 ms    Press BACK and assert FullScreen.View is present
    run keyword if    ${status}    I Press    OK
    Wait Until Keyword Succeeds    10 times    300 ms    I expect page contains 'id:NowAndNext.View'

Prevent Channel Bar from disappearing from a locked channel
    [Documentation]    Helper keyword for opening Channel Bar and waiting until its visible on locked channels
    Wait Until Keyword Succeeds    10 times    300 ms    I expect page contains 'id:splashContainer'
    Wait Until Keyword Succeeds    10 times    300 ms    I expect page contains 'id:NowAndNext.View'

Prevent Channel Bar from disappearing from potentially locked channel
    [Documentation]    Helper keyword for opening Channel Bar and waiting until its visible on potentially locked channels
    ${json_object}    Get Ui Json
    ${lock_text}    Is In Json    ${json_object}    id:RcuCue    textKey:^DIC_RC_CUE_UNLOCK_(PROGRAM|CHANNEL)$    ${EMPTY}    ${True}
    ${lock_icon}    Is In Json    ${json_object}    id:titleText\\d+    iconKeys:LOCK    ${EMPTY}    ${True}
    Run Keyword If    ${lock_text} or ${lock_icon}    Prevent Channel Bar from disappearing from a locked channel
    ...    ELSE    Prevent Channel Bar from disappearing from an unlocked channel

Exit player if turned on    #USED
    [Documentation]    This keyword exits player if it's present
    ${json_object}    Get Ui Json
    ${is_player_turned_on}    Is In Json    ${json_object}    ${EMPTY}    id:Player.View
    Run Keyword If    '${is_player_turned_on}' == '${True}'    Run Keywords    I Press    BACK
    ...    AND    I Press    STOP
    ...    AND    Wait Until Keyword Succeeds    10 times    1 s
    ...    Run Keyword And Expect Error    *    Player is in PLAY mode

Press BACK and assert json changed    #USED
    [Arguments]    ${old_json}
    [Documentation]    This keyword presses BACK and asserts json changed after the key press
    I Press    BACK
    Assert json changed    ${old_json}

Press BACK and assert FullScreen.View is present
    [Documentation]    This keyword presses BACK and asserts FullScreen.View is present
    I Press    BACK
    Fullscreen is shown

Fullscreen is shown    #USED
    [Documentation]    This keyword asserts fullscreen or now and next view is shown
    ${json_object}    Get Ui Json
    ${is_fullscreen_visible}    Is In Json    ${json_object}    ${EMPTY}    id:FullScreen.View
    Should Be True    ${is_fullscreen_visible}    Fullscreen is not shown

Fullscreen or NowAndNext or detailpage is shown
    [Documentation]    This keyword asserts fullscreen or now and next view or details page is shown
    ${json_object}    Get Ui Json
    ${is_full_screen_visible}    Is In Json    ${json_object}    ${EMPTY}    id:FullScreen.View
    ${is_now_and_next_visible}    Is In Json    ${json_object}    ${EMPTY}    id:NowAndNext.View
    ${is_detail_page_visible}    Is In Json    ${json_object}    ${EMPTY}    id:DetailPage.View
    ${result}    Evaluate    True if ${is_full_screen_visible} or ${is_now_and_next_visible} or ${is_detail_page_visible} else False
    Should Be True    ${result}    Is not FullScreen or NowAndNext or Details page view

Assert json changed    #USED
    [Arguments]    ${old_json}
    [Documentation]    This keyword asserts json content changed
    ${new_json}    Get Ui Json
    ${are_different}    check if jsons are different    ${old_json}    ${new_json}
    Should Be True    ${are_different}    JSON has not changed

Channel Bar is shown    #USED
    [Documentation]    This keyword asserts that channel bar is shown
    wait until keyword succeeds    10 times    300 ms    I expect page contains 'id:NowAndNext.View'

Channel Bar is present
    [Documentation]    This keyword checks the presence of channel bar
    wait until keyword succeeds    5s    ${JSON_RETRY_INTERVAL}    I expect page contains 'id:NowAndNext.View'

Channel Bar is not shown    #USED
    [Documentation]    This keyword asserts channel bar is not shown
    Wait Until Keyword Succeeds    10 times    300 ms    I do not expect page contains 'id:NowAndNext.View'

Now programme is focused    #USED
    [Documentation]    Checks if Now programme is focused
    ${id}    I retrieve value for key 'id' in element 'textKey:DIC_GENERIC_AIRING_TIME_NOW'
    wait until keyword succeeds    ${JSON_MAX_RETRIES}    ${JSON_RETRY_INTERVAL}    I expect page contains 'id:${id}'
    wait until keyword succeeds    ${JSON_MAX_RETRIES}    ${JSON_RETRY_INTERVAL}    I expect page element 'id:${id}' contains 'color:${HIGHLIGHTED_NAVIGATION_COLOUR}'

Now programme is not shown
    [Documentation]    Checks if Now programme is not shown
    Log to Console    "Checking Now is not shown in current tile"
    ${id_now}    I retrieve value for key 'id' in element 'textKey:DIC_GENERIC_AIRING_TIME_NOW'
    wait until keyword succeeds    ${JSON_MAX_RETRIES}    ${JSON_RETRY_INTERVAL}    I do not expect page contains 'id:${id_now}'
    wait until keyword succeeds    ${JSON_MAX_RETRIES}    ${JSON_RETRY_INTERVAL}    I do not expect page element 'id:${id_now}' contains 'color:${HIGHLIGHTED_NAVIGATION_COLOUR}'

Next programme is focused
    [Documentation]    This keyword asserts next programme is focused
    wait until keyword succeeds    10 times    0 s    Next programme is focused implementation

Previous Programme Is Focused    #USED
    [Documentation]    This keyword asserts previous programme is focused
    wait until keyword succeeds    10 times    0 s    Previous Programme Is Focused Implementation

I tune to an Adult Locked channel
    [Documentation]    This keyword tunes to an adult locked channel.
    ...    The number of the channel is stored in ${ADULT_LOCKED_CHANNEL}
    ...    variable.
    I open Channel Bar
    I tune to channel    ${ADULT_LOCKED_CHANNEL}
    Adult Locked Channel is shown

Adult Locked Channel is shown
    [Documentation]    This keyword asserts adult locked channel is shown
    wait until keyword succeeds    ${JSON_MAX_RETRIES}    ${JSON_RETRY_INTERVAL}    I expect page element 'id:splashContainer' contains 'iconKeys:TRIPLE_X'

Channel Is Locked    #USED
    [Documentation]    Checks if Channel is locked
    wait until keyword succeeds    4 times    300 ms    I expect page element 'id:RcuCue' contains 'textKey:DIC_RC_CUE_UNLOCK_CHANNEL|DIC_RC_CUE_UNLOCK_PROGRAM' using regular expressions

Channel Is Off Air    #USED
    [Documentation]  This keyword checks whether the channel is Off Air channel.
    wait until keyword succeeds    4 times    300 ms    I expect page contains 'textKey:DIC_OFF_AIR'

Event Is Locked    #USED
    [Documentation]    Checks if Event is locked
    wait until keyword succeeds    4 times    300 ms    I expect page element 'id:RcuCue' contains 'textKey:DIC_RC_CUE_UNLOCK_PROGRAM'

Check if the expected channel is tuned
    [Documentation]    This keyword will check that the current channel number is ${TUNED_CHANNEL_NUMBER}.
    variable should exist    ${TUNED_CHANNEL_NUMBER}    Suite var TUNED_CHANNEL_NUMBER has not previously been set
    ${current_channel_number}    get current channel number
    should be equal    ${current_channel_number}    ${TUNED_CHANNEL_NUMBER}    not tuned to the expected channel

I tune to an unlocked channel
    [Documentation]    This keyword tunes to an unlocked channel
    I tune to channel    ${UNLOCKED_CHANNEL}
    Wait Until Keyword Succeeds    10 times    1 sec    I expect page element 'id:progressBar' contains 'color:${INTERACTION_COLOUR}'

I tune to an unlocked channel in offline mode
    [Documentation]    This keyword tunes to an unlocked channel in offline mode
    I tune to channel    ${UNLOCKED_CHANNEL}
    Wait Until Keyword Succeeds    10 times    1 sec    I expect page contains 'textKey:DIC_DETAIL_EVENT_NO_INFO'

I tune to channel with short duration events
    [Documentation]    This keyword tunes to a channel with short duration events
    I open Channel Bar
    I tune to channel    ${SHORT_DURATION_EVENTS_CHANNEL}

I Tune To An Unsubscribed Channel      #USED
    [Documentation]    This keyword tunes to an unsubscribed channel
    ${filtered_channel_list}    I Fetch All Unsubscribed Channels
    Should Not Be Empty    ${filtered_channel_list}    unable to get unsubcribed channels
    ${unsubscribed_channel_to_tune}    Get Random Element From Array    ${filtered_channel_list}
    I Tune To Channel    ${unsubscribed_channel_to_tune}
    Set Suite Variable    ${UNSUBSCRIBED_CHANNEL}    ${unsubscribed_channel_to_tune}

I tune to Adult programme
    [Arguments]    ${locked_event_channel}=${LOCKED_18PLUS_CHANNEL}
    [Documentation]    By default, all the events on ${LOCKED_18PLUS_CHANNEL} are adult events
    I tune to channel    ${locked_event_channel}

I tune to unlocked channel with replay events
    [Documentation]    This keyword tunes to an unlocked channel with replay events
    I tune to channel    ${UNLOCKED_CHANNEL_WITH_REPLAY_EVENTS}

I tune to a channel with replay events    #USED
    [Documentation]    This Keyword Will tune to the channel with replay events and return channel number and events list.
    [Arguments]    ${replay_source}=cloud
    :FOR    ${next_channel}    IN RANGE    10
    \    ${replay_event}    ${replay_channel}    Get Replay Event Metadata And Channel Number    False     600    ${replay_source}
    \    Exit For Loop If    ${replay_event}
    I tune to channel    ${replay_channel}
    [Return]    ${replay_event}    ${replay_channel}

I Tune To Netflix Channel    #USED
    [Documentation]    Tune to Neflix channel
    ${channel_number}    Retrieve Netflix Channel Number
    Should Not Be Empty  ${channel_number}
    I Press  ${channel_number}
    I wait for 10 seconds

I tune to a channel with replay series
    [Documentation]    Tune to channel with replay series
    I tune to channel    ${REPLAY_SERIES_CHANNEL}

Channel Bar shows channel ${channelnumber}
    [Documentation]    Open channel bar and check the channel number
    I open Channel Bar
    ${actual_channel}    Read channel number from channel bar data
    Should Be Equal    ${channelnumber}    ${actual_channel}

Read current event time from Channel Bar    #USED
    [Documentation]    returns the time information of current event
    ...    Precondition: channel bar is open
    wait until keyword succeeds    ${JSON_MAX_RETRIES}    ${JSON_RETRY_INTERVAL}    I expect page element 'id:titleText\\\\d' contains 'color:${HIGHLIGHTED_NAVIGATION_COLOUR}' using regular expressions
    ${ancestor}    Get Enclosing Json    ${LAST_FETCHED_JSON_OBJECT}    id:titleText\\d    color:${HIGHLIGHTED_NAVIGATION_COLOUR}    ${3}    ${EMPTY}    ${True}
    ${event_time}    Extract Value For Key    ${ancestor}    id:extendedInfoText\\d    textValue    ${True}
    ${event_time}    strip string    ${event_time}
    [Return]    ${event_time}

Event Duration Is Shown In Channel Bar    #USED
    [Documentation]    Check event duration in present in channel bar
    ...    Precondition: channel bar is open
    ${event_time}    Read current event time from Channel Bar
    should not be empty    ${event_time}

I tune to a subscribed channel
    [Documentation]    keyword to tune to a subscribed channel
    I tune to an unlocked channel

I focus a non-series event in Channel bar
    [Documentation]    The keyword tunes to given single event channel, default is 405
    I tune to channel    ${SINGLE_EVENT_CHANNEL}

I focus a series event in Channel bar
    [Arguments]    ${series_channel}=${SERIES_EVENT_CHANNEL}
    [Documentation]    Focus a series event from ${SERIES_EVENT_CHANNEL} channel
    I tune to channel    ${series_channel}

Replay Icon Is Displayed At Right Hand Side Of The Title In Channel Bar    #USED
    [Documentation]    This keyword checks if Replay Icon Is Displayed At Right Hand Side Of The Title In Channel Bar
    ${ancestor}    I retrieve json ancestor of level '2' in element 'id:topLine\\d' for element 'color:${INTERACTION_COLOUR}' using regular expressions
    @{regexp_match}    Get Regexp Matches    ${ancestor['id']}    ^.*(\\d+)$    1
    ${id}    Set Variable    ${regexp_match[0]}
    wait until keyword succeeds    ${JSON_MAX_RETRIES}    ${JSON_RETRY_INTERVAL}    I expect page element 'id:titleText${id}' contains 'iconKeys:.*REPLAY.*' using regular expressions

I retrieve details for event with highlight color in Channel Bar
    [Documentation]    Retrieves details (event_color, event_id, event_text, id) from highlighted event in Channel Bar
    &{highlighted_event}    Create Dictionary    event_color=${None}    event_text=${None}    event_id=${None}
    ${json_object}    Get Ui Json
    ${ancestor}    Get Enclosing Json    ${json_object}    id:titleText\\d    color:${HIGHLIGHTED_NAVIGATION_COLOUR}    ${2}    ${EMPTY}
    ...    ${True}
    ${json_length}    Get Length    ${ancestor}
    return from keyword if    ${json_length}==0    ${highlighted_event}
    Set To Dictionary    ${highlighted_event}    event_text    ${ancestor['textValue']}
    Set To Dictionary    ${highlighted_event}    event_color    ${ancestor['textStyle']['color']}
    Set To Dictionary    ${highlighted_event}    event_id    ${ancestor['id']}
    ${id}    Replace String    ${ancestor['id']}    titleText    ${EMPTY}
    Set To Dictionary    ${highlighted_event}    id    ${id}
    [Return]    ${highlighted_event}

Ongoing event is focused    #USED
    [Documentation]    Verifies if ongoing event is focused
    wait until keyword succeeds    ${CHANNEL_QUERY_TIMEOUT}    0s    Check ongoing event is focused

Check ongoing event is focused    #USED
    [Documentation]    Checks if the ongoing event is focused. If we have no highlighted text, we might be on a UHD event
    ...    that we can't watch for some reason, on a locked channel, or a channel that we're not subscribed to.
    ...    In these cases, the line above the event text will be highlighted, so we can check this as a backup.
    wait until keyword succeeds    ${JSON_MAX_RETRIES}    ${JSON_RETRY_INTERVAL}    I expect page element 'id:watchingNow' contains 'textValue:^.+$' using regular expressions
    &{highlighted_event}    I retrieve details for event with highlight color in Channel Bar
    ${event_text}    Set Variable    &{highlighted_event}[event_text]
    Run Keyword If    """${event_text}""" == "${None}" or """${event_text}""" == "${EMPTY}"    Check top line for ongoing event is highlighted
    ${CB_event_name}    Read current event name from Channel Bar
    Set Suite Variable    ${CB_FOCUSED_EVENT_NAME}    ${CB_event_name}

Check top line for ongoing event is highlighted    #USED
    [Documentation]    Check that the top line above the event title is highlighted. We cannot rely on fixed id names
    ...    for each of the 5 topLine ids.
    ${json_object}    Get Ui Json
    ${json_string}    Read Json As String    ${json_object}
    @{collection}    get regexp matches    ${json_string}    topLine(\\d+)
    ${count}    Get Length    ${collection}
    Should be true    ${count}==5    We do not have 5 topLine ids
    ${middle_topLine}    Set Variable    @{collection}[2]
    wait until keyword succeeds    ${JSON_MAX_RETRIES}    ${JSON_RETRY_INTERVAL}    I expect page element 'id:${middle_topLine}' contains 'color:${INTERACTION_COLOUR}'

Future event is focused    #USED
    [Documentation]    Verifies if future event is focused
    wait until keyword succeeds    ${JSON_MAX_RETRIES}    ${JSON_RETRY_INTERVAL}    I expect page element 'id:NowAndNext.View' contains 'viewState:^.+$' using regular expressions
    ${all_programmes_list}    I retrieve value for key 'viewState' in element 'id:NowAndNext.View'
    ${selected_programme}    Set Variable    ${all_programmes_list[1]['viewStateValue']}
    &{highlighted_event}    I retrieve details for event with highlight color in Channel Bar
    ${event_text}    Set Variable    &{highlighted_event}[event_text]
    Set Suite Variable    ${event_name}    ${event_text}
    Should Contain    ${event_text}    ${selected_programme}

I focus Ongoing event in Channel Bar    #USED
    [Documentation]    keyword to focus current ongoing event
    Ongoing event is focused

I focus Next event in Channel Bar    #USED
    [Documentation]    This keyword focuses next event in the channel bar by pressing right
    Skip Error popup
    ${old_json}    Get Ui Json
    I open Channel Bar
    I press    RIGHT
    wait until keyword succeeds    3s    200ms    Assert json changed    ${old_json}
    ${CB_event_name}    Read current event name from Channel Bar
    Set Suite Variable    ${CB_FOCUSED_EVENT_NAME}    ${CB_event_name}

I focus Future single event    #USED
    [Documentation]    keyword to focus future single event from channel bar
    I focus Next event in Channel Bar
    wait until keyword succeeds    5 times    1 sec    Future event is focused

I focus Ongoing single episode event
    [Documentation]    keyword to focus ongoing episode event
    I wait for 10 seconds
    ${channel_bar_is_present}    Run Keyword And Return Status    Channel Bar is shown
    Run Keyword If    ${channel_bar_is_present} == ${False}    I press    OK
    Ongoing event is focused

I focus Future Event on Channel Bar Skipping First    #USED
    [Arguments]    ${skip_count}=2
    [Documentation]    This keyword focuses future event, skipping the first few
    : FOR    ${_}    IN RANGE    ${skip_count}
    \    I focus Future single event

Set current lineup variables    #USED
    [Documentation]    keyword to save current lineup variables
    ${viewstate}    I retrieve value for key 'viewState' in element 'id:NowAndNext.View'
    ${length}    Get Length    ${viewstate}
#    should be equal    ${viewstate_length}    ${3}    viewstate length is not 3 as we expected
	: FOR    ${index}    IN RANGE    0    ${length}
#	\    should be true    '''viewStateValue''' in '''${viewstate[${index}]}'''    viewStateValue is not in viewstate[${index}] as we expected
	\    ${viewstate_data}    Set Variable If    '''viewStateValue''' in '''${viewstate[${index}]}'''    ${viewstate[${index}]['viewStateValue']}    ${EMPTY}
#    \    log to console    \n viewstate[${index}]: ${viewstate_data}
    \    ${is_valid}    Run Keyword And Return Status    Should Not Be Empty    ${viewstate_data}
	\    Run Keyword If     ${is_valid} and '${index}'=='0'    Set Suite Variable    ${previous_event_title}    ${viewstate_data}
	\    Run Keyword If     ${is_valid} and '${index}'=='1'    Set Suite Variable    ${current_event_title}    ${viewstate_data}
    \    Run Keyword If     ${is_valid} and '${index}'=='2'    Set Suite Variable    ${next_event_title}    ${viewstate_data}

I focus past replay event
    [Documentation]    This keyword focuses past replay event in the channel bar
    I Press    LEFT
    I wait for 3 seconds
    Previous programme is focused

I focus Current event
    [Documentation]    This keyword focuses current event
    I open Channel Bar

I focus Current single event
    [Documentation]    This keyword focuses current single event
    I focus Current event

I focus current replay event
    [Documentation]    This keyword focuses current replay event
    I open Channel Bar

I Focus NOW Event In Channel Bar    #USED
    [Documentation]    This keyword focuses the current event in channel Bar
    I open Channel Bar
    Now programme is focused

I Focus Past Event In Channel Bar    #USED
    [Documentation]    This keyword focuses the past event in channel Bar
    I Press    LEFT
    Channel Bar is shown
    Previous Programme Is Focused

I Focus Future Event In Channel Bar    #USED
    [Documentation]    This keyword focuses the future event in channel Bar
    Channel Bar is shown
    Now programme is focused
    I press RIGHT 2 times
    Future event is focused

Channel Bar Zapping Channel Up   #USED
    [Documentation]    This keyword Performs Channel Zapping Channel Up on the Channel Bar.
    ...    Prerequisites - Channel Bar Should Be Opened [I open Channel Bar + Channel Bar is shown]
    I Tune To Next Channel

Channel Bar Zapping Channel Down   #USED
    [Documentation]    This keyword Performs Channel Zapping Channel Down on the Channel Bar.
    ...    Prerequisites - Channel Bar Should Be Opened [I open Channel Bar + Channel Bar is shown]
    I Tune To Previous Channel

Soft Zapping Without Tuning      #USED
     [Documentation]    This keyword Performs Channel Zapping ChannelDown/Channelup for few times on the Channel Bar.
     Repeat Keyword    10 times  I Press  CHANNELUP
     Repeat Keyword    4 times  I Press  CHANNELDOWN

Channel Zapping Using Channel Number  #USED
    [Documentation]    This keyword Performs Hard zapping to a channel using the channel number.
    I Fetch Linear Channel Number List Filtered For Zapping
    ${ip_channel_id}    I Fetch All IP Channels
    @{ip_channel_numbers}   Get Channel Numbers List From Linear Service   ${ip_channel_id}
    Remove List Elements From Other List   ${FILTERED_CHANNEL_LIST}    ${ip_channel_numbers}
    ${channel_number}     Get Random Element From Array    ${FILTERED_CHANNEL_LIST}
    I Press   ${channel_number}

New channel is not tuned
    [Documentation]    This keyword will check if the current tuned channel is not same as to which the test has tuned to using a test variable
    ${channel_number}    Get current channel number
    should not be empty    ${channel_number}    Error in getting tuned channel
    should be equal as strings    ${TUNED_CHANNEL_NUMBER}    ${channel_number}    Channel should not be tuned to another channel

New channel is tuned
    [Documentation]    This keyword will retry multiple times and check if channel is tuned to another channel
    wait until keyword succeeds    ${CHANNEL_QUERY_TIMEOUT}    0s    Check if new channel is tuned

Next Channel Is Tuned    #USED
    [Documentation]    This keyword verifies if the STB is tuned to the next channel in channel lineup based on test variable
    wait until keyword succeeds    ${CHANNEL_QUERY_TIMEOUT}    0s    Check If Next Channel Is Tuned

Next channel is tuned in personal line-up
    [Documentation]    This keyword verifies if the next channel in personal line up is tuned
    ...    Precondition: Suite variable TUNED_CHANNEL_NUMBER must be set
    Variable should exist    ${TUNED_CHANNEL_NUMBER}    Suite var TUNED_CHANNEL_NUMBER has not previously been set
    ${current_profile_name}    get current profile name via as    ${STB_IP}    ${CPE_ID}    xap=${XAP}
    ${personal_line_up}    get favourite channels Via Personalization Service    ${LAB_CONF}    ${CUSTOMER_ID}    ${current_profile_name}    xap=${XAP}
    ${previous_channel_index}    set variable    ${EMPTY}
    ${personal_line_up_length}    get length    ${personal_line_up}
    : FOR    ${index}    IN RANGE    ${personal_line_up_length}
    \    ${channel_number}    get channel lcn for channel id    ${personal_line_up[${index}]}
    \    ${status}    Evaluate    ${TUNED_CHANNEL_NUMBER} == ${channel_number}
    \    ${previous_channel_index}    set variable if    ${status}    ${index}
    \    exit for loop if    ${status}
    ${previous_channel_index}    set variable if    ${${personal_line_up_length} - ${1}} == ${previous_channel_index}    ${-1}    ${previous_channel_index}
    ${next_channel_id}    set variable    ${personal_line_up[${previous_channel_index}+1]}
    ${current_channel_id}    get main session ref id via vldms    ${STB_IP}    ${CPE_ID}
    should be equal as strings    ${current_channel_id}    ${next_channel_id}    Next channel in the lineup is not tuned

Previous Channel Is Tuned    #USED
    [Documentation]    This keyword verifies if the STB is tuned to the previous channel in channel lineup based on test variable
    wait until keyword succeeds    ${CHANNEL_QUERY_TIMEOUT}    0s    Check If Previous Channel Is Tuned

Check if new channel is tuned
    [Documentation]    This keyword will check if the current tuned channel is same as to which the test has tuned to using a test variable
    ${channel_number}    Get current channel number
    should not be empty    ${channel_number}    Error in getting tuned channel
    should not be equal as strings    ${TUNED_CHANNEL_NUMBER}    ${channel_number}    Channel is not tuned to another channel

Unlocked channel is tuned
    [Documentation]    This keyword verify that we are tuned to the unlocked channel
    ${actual_channel}    Get current channel number
    Should Be Equal    ${UNLOCKED_CHANNEL}    ${actual_channel}    Not tuned to unlocked channel
    content available

Previous channel is not tuned
    [Documentation]    This keyword will check if the previous channel is not same as to which the test has tuned to using a test variable
    variable should exist    ${TUNED_CHANNEL_NUMBER}    Suite var TUNED_CHANNEL_NUMBER has not previously been set
    ${previous_channel_number}    get from referenced channel via ls    ${CITY_ID}    ${TUNED_CHANNEL_NUMBER}    ${CPE_ID}    ${OSD_LANGUAGE}    ${CPE_PRODUCT_CLASS}
    ...    -1
    ${channel_number}    Get current channel number
    should not be equal as strings    ${channel_number}    ${previous_channel_number}    Previous Channel Is Tuned

Next channel is not tuned
    [Documentation]    This keyword will check if the next channel is not same as to which the test has tuned to using a test variable
    variable should exist    ${TUNED_CHANNEL_NUMBER}    Suite var TUNED_CHANNEL_NUMBER has not previously been set
    ${next_channel_number}    get from referenced channel via ls    ${CITY_ID}    ${TUNED_CHANNEL_NUMBER}    ${CPE_ID}    ${OSD_LANGUAGE}    ${CPE_PRODUCT_CLASS}
    ...    1
    ${channel_number}    Get current channel number
    should not be equal as strings    ${channel_number}    ${next_channel_number}    Next Channel Is Tuned

Check If Previous Channel Is Tuned    #USED
    [Documentation]    This keyword verifies that we are tuned to the previous channel
    ...    Prerequisites TUNED_CHANNEL_NUMBER should exist
    variable should exist    ${TUNED_CHANNEL_NUMBER}    Suite var TUNED_CHANNEL_NUMBER has not previously been set
    ${actual_channel}    Wait Until Keyword Succeeds    10 times    150 ms    Read channel number from channel bar data
    ${previous_channel_number}    get from referenced channel via ls    ${CITY_ID}    ${TUNED_CHANNEL_NUMBER}    ${CPE_ID}    ${OSD_LANGUAGE}    ${CPE_PRODUCT_CLASS}
    ...    -1
    ${channel_number}    Get current channel number
    should be equal as strings    ${channel_number}    ${previous_channel_number}    Previous channel in the lineup is not tuned
    Should Be Equal    ${channel_number}    ${actual_channel}    Channel number incorrect in channel bar

Check If Next Channel Is Tuned    #USED
    [Documentation]    This keyword verifies that we are tuned to the next channel
    ...    Prerequisites TUNED_CHANNEL_NUMBER should exist
    variable should exist    ${TUNED_CHANNEL_NUMBER}    Suite var TUNED_CHANNEL_NUMBER has not previously been set
    ${actual_channel}    Wait Until Keyword Succeeds    10 times    150 ms    Read channel number from channel bar data
    ${next_channel_number}    get from referenced channel via ls    ${CITY_ID}    ${TUNED_CHANNEL_NUMBER}    ${CPE_ID}    ${OSD_LANGUAGE}    ${CPE_PRODUCT_CLASS}
    ...    1
    ${next_channel_number_fix_duplicate}    Run Keyword If    '${next_channel_number}'=='${TUNED_CHANNEL_NUMBER}'    get from referenced channel via ls    ${CITY_ID}    ${TUNED_CHANNEL_NUMBER}    ${CPE_ID}    ${OSD_LANGUAGE}    ${CPE_PRODUCT_CLASS}
    ...    2
    ${next_channel_number}    set variable if    ${next_channel_number_fix_duplicate} != ${None}    ${next_channel_number_fix_duplicate}    ${next_channel_number}
    ${channel_number}    Get current channel number
    should be equal as strings    ${channel_number}    ${next_channel_number}    Next channel in the lineup is not tuned
    Should Be Equal    ${channel_number}    ${actual_channel}    Channel number incorrect in channel bar

Previous channel info is shown in the channel bar
    [Documentation]    This keyword will check that the previous channel number is shown in the channel bar.
    variable should exist    ${TUNED_CHANNEL_NUMBER}    Suite var TUNED_CHANNEL_NUMBER has not previously been set
    ${previous_channel_number}    get from referenced channel via ls    ${CITY_ID}    ${TUNED_CHANNEL_NUMBER}    ${CPE_ID}    ${OSD_LANGUAGE}    ${CPE_PRODUCT_CLASS}
    ...    -1
    ${channel_number_from_channel_bar}    Read channel number from channel bar data
    Should Be Equal    ${previous_channel_number}    ${channel_number_from_channel_bar}    previous channel info is not shown in the channel bar

I tune to channel '${channel_number}' using numeric keys
    [Documentation]    Presses the channel number. (Does not verify whether the channel is tuned)
    ...    This keyword cannot be used in Setups and Teardowns as it uses a test variable
    I open Channel Bar
    I press    ${channel_number}
    set test variable    ${PRESSED_CHANNEL}    ${channel_number}

Next channel info is shown in the channel bar
    [Documentation]    This keyword will check that the next channel number is shown in the channel bar.
    variable should exist    ${TUNED_CHANNEL_NUMBER}    Suite var TUNED_CHANNEL_NUMBER has not previously been set
    ${next_channel_number}    get from referenced channel via ls    ${CITY_ID}    ${TUNED_CHANNEL_NUMBER}    ${CPE_ID}    ${OSD_LANGUAGE}    ${CPE_PRODUCT_CLASS}
    ...    1
    ${channel_number_from_channel_bar}    Read channel number from channel bar data
    Should Be Equal    ${next_channel_number}    ${channel_number_from_channel_bar}    next channel info is not shown in the channel bar

Unsubscribed RC CUE is shown    #USED
    [Documentation]    keyword verifies unsubscrided channel displays RCU CUE
    Wait until keyword succeeds    ${JSON_MAX_RETRIES}    ${JSON_RETRY_INTERVAL}    I expect page element 'id:RcuCue' contains 'textKey:DIC_RC_CUE_SUBSCRIBE_CHANNEL'
    I do not expect page contains 'textKey: DIC_RC_CUE_SUBSCRIBE_CHANNEL'

Event starts now
    [Arguments]    ${wait_duration}=6 min
    [Documentation]    Wait until the next event starts
    Wait until keyword succeeds    ${wait_duration}    2s    Event is started

I tune to channel with short replay events
    [Documentation]    This keyword tunes to a channel with short replay events
    I tune to channel    ${REPLAY_EPISODES_EVENTS_CHANNEL}

Channel with short replay events is shown
    [Documentation]    This keyword verifies channel with short replay events is shown
    Channel ${REPLAY_EPISODES_EVENTS_CHANNEL} is tuned

Channel Bar metadata matches with the channel logo and number
    [Documentation]    This keyword checks if the channel bar is showing the correct channel number and logo
    ${channel_number}    Read channel number from channel bar data
    ${current_channel_number}    get current channel number
    Should be equal as strings    ${channel_number}    ${current_channel_number}    Channel number doesn't match
    channel logo is shown in the channel bar for    ${channel_number}

I tune to SD HD combined channel
    [Documentation]    This Keyword is used to tune to Channel with SD/HD
    I tune to channel    ${SD_HD_SERVICE}

I tune to a linear channel
    [Documentation]    Tune to a linear channel
    I tune to channel    ${LINEAR_CHANNEL}

I tune to a linear channel with Boxset
    [Documentation]    Tune to a linear channel with Boxset
    I tune to channel    ${LINEAR_CHANNEL}

I tune to a replay channel with Boxset
    [Documentation]    Tune to a replay channel with Boxset
    I tune to channel    ${REPLAY_BOXSET_CHANNEL}

I Select The Current Programme On An Untuned Channel After Soft Zapping  #USED
    [Documentation]    If we've soft zapped to a channel we need to select it with the OK button but... it might be a
    ...    normal event, replay event or locked channel so this needs to be detected and dealt with.
    ${status}    Run Keyword And Return Status    Replay Icon Is Displayed At Right Hand Side Of The Title In Channel Bar
    Run Keyword If    ${status}    Run Keywords    I press    OK
    ...    AND    Interactive modal with options 'Watch live TV' and 'Play from start' is shown
    I Press    OK
    ${status}    Run Keyword And Return Status    Lock Icon present
    Run Keyword If    ${status}    I insert correct parental pin

I select another Season
    [Documentation]    This keyword selects another season after Focusing a season in the episode picker inside the Details Page
    I focus a season
    I focus another season

I focus the event '${number_of}' events into the future from the current event on the Channel Bar
    [Documentation]    This keyword makes sure the Channel Bar is open then focuses the event ${number_of} events
    ...    into the future
    I open Channel Bar
    : FOR    ${_}    IN RANGE    ${number_of}
    \    I focus Next event in Channel Bar

I am not subscribed to Replay Product
    [Documentation]    This Keyword is used to remove Replay Product via ITC tool
    delete products by feature    Replay    ${LAB_TYPE}    ${CPE_ID}

I Tune to a channel with series with a minimum of 3 seasons
    [Documentation]    This keyword tunes to a channel with severals seasons
    I tune to channel    ${SEVERALS_SEASONS_CHANNEL}

I focus another season
    [Documentation]    This keyword verifies that another season is focused
    ${ancestor}    I retrieve json ancestor of level '2' in element 'id:titleNodeseason_item_\\d' for element 'color:${HIGHLIGHTED_OPTION_COLOUR}' using regular expressions
    ${current_season}    Extract Value For Key    ${ancestor}    textKey:DIC_GENERIC_SEASON_NUMBER    textValue
    I press    DOWN
    ${ancestor}    I retrieve json ancestor of level '2' in element 'id:titleNodeseason_item_\\d' for element 'color:${HIGHLIGHTED_OPTION_COLOUR}' using regular expressions
    ${next_season}    Extract Value For Key    ${ancestor}    textKey:DIC_GENERIC_SEASON_NUMBER    textValue
    should not be equal    ${current_season}    ${next_season}    current season and next season are equal!
    Set Test Variable    ${LAST_FETCHED_ANOTHER_SEASON}    ${next_season}

I tune to a replay channel with subtitles
    [Documentation]    Tune to a replay channel with subtitles.
    I tune to channel    ${REPLAY_BOXSET_CHANNEL}

I Dismiss Channel Bar    #USED
    [Documentation]    This keyword dismiss the channel bar by pressing BACK
    Skip Error popup
    I Press    BACK
    Channel Bar is not shown

I tune to a channel with audio description
    [Documentation]    This keyword tunes to a channel with an Audio Description audio track available
    I tune to channel    ${AUDIO_DESCRIPTION_CHANNEL}

Replay icon is not shown in channelbar
    [Documentation]    This keyword will verify that the replay icon is not displayed in the channel bar.
    Channel bar is shown
    wait until keyword succeeds    ${JSON_MAX_RETRIES}    ${JSON_RETRY_INTERVAL}    I do not expect page element 'id:titleTextIcons\\\\d+' contains 'iconKeys:.*REPLAY.*' using regular expressions

I Tune To Replay Channel And Focus Past Replay Event With '${replay_source}' Content Source    #USED
    [Documentation]    This keyword focus a past replay event with the given replay content source
    I Tune To Replay Channel And Focus Past Replay Event     ${replay_source}

I Tune To Replay Channel And Focus Past Replay Event    #USED
    [Documentation]    This keyword focuses past replay event in the channel bar and
    ...   returns the name of focussed replay event. It sets the details of past focussed replay event
    ...   to a Suite variable ${FILTERED_REPLAY_EVENT}
    [Arguments]    ${replay_source}=Any
    ${replay_event}    ${replay_channel}    I tune to a channel with replay events    ${replay_source}
    Set Suite Variable    ${FILTERED_REPLAY_EVENT}    ${replay_event}
    Log    Details of replay event: ${FILTERED_REPLAY_EVENT}
    I Ensure Channel Is Unlocked From Channel Bar
    Dismiss Channel Failed Error Pop Up
    Error popup is not shown
    ${season_id}    Extract Value For Key    ${FILTERED_REPLAY_EVENT}    ${EMPTY}    seriesId
    ${show_id}    Extract Value For Key    ${FILTERED_REPLAY_EVENT}    ${EMPTY}    parentSeriesId
    ${seriesName}    Extract Value For Key    ${FILTERED_REPLAY_EVENT}    ${EMPTY}    seriesName
    ${title}    Extract Value For Key    ${FILTERED_REPLAY_EVENT}    ${EMPTY}    title
    ${cws_title}    Set Variable If    "${season_id}" == "${None}" and "${show_id}" == "${None}" and '''${seriesName}''' != "${None}"    ${seriesName}    ${title}
    Set Suite Variable    ${CWS_REPLAY_ASSET_TITLE}    ${cws_title}
    Should Be True    "${title}" != "${None}"   Unable to fetch the title of the replay asset from BO
    :FOR    ${next_channel}    IN RANGE    ${past_event_length}
    \    Set current lineup variables
    \    ${is_replay_event}    Run Keyword And Return status    Should Contain     ${current_event_title}    ${title}
    \    ${is_current}    Run Keyword And Return status    Now programme is focused
    \    Exit For Loop If    ${is_replay_event} and (not ${is_current})
    \    Run Keywords    I Press    LEFT    AND    I wait for 500 ms
    Should Be True    ${is_replay_event}    Unable to find the replay event (${title}) after 50 retries on channel: ${replay_channel}
    [Return]    ${title}

I Ensure Channel Is Unlocked From Channel Bar    #USED
    [Documentation]    This keyword ensures that the channel is unlocked if it is locked already
    ${is_locked_channel}    Run Keyword And Return Status    Channel Is Locked
    Run Keyword If    ${is_locked_channel}    I press    OK
    ${is_resume_replay_popup}    Run Keyword And Return Status   Interactive modal with options 'Continue watching' and 'Watch live TV' is shown
    Run Keyword If    ${is_resume_replay_popup}    I select 'Watch live TV'
    ${pin_entry_present}    Run Keyword And Return Status    Pin Entry popup is shown
    Run Keyword If    ${pin_entry_present}    I Enter A Valid Pin

Progress Bar Is Shown In Channel Bar    #USED
    [Documentation]    This keyword ensures that the progress bar is visible for the currently playing event in channel bar
    Wait Until Keyword Succeeds    ${JSON_MAX_RETRIES}    ${JSON_RETRY_INTERVAL}    I expect page contains 'id:progressBar'

I Ensure Event Is Unlocked From Channel Bar
    [Documentation]    This keyword ensures that event is unlocked from channel bar if it is locked already
    ${status}    Run Keyword And Return status  Event Is Locked
    Run Keyword If    ${status}    Run Keywords    I press    OK
    ...    AND    Verfiy Watch Popup For Locked Channels And Select 'WATCH LIVE'
    ...   AND    Handle Pin Popup

"Locked Channel" Text Is Shown In Channel Bar For Locked Channels     #USED
    [Documentation]    Checks the channel bar contains "Locked Channel" instead of event duration and event title
    ...    Precondition: channel bar is open
    Wait Until Keyword Succeeds    3 times    1 sec    I expect page contains 'textKey:DIC_LOCKED_CHANNEL'

I Verify That Adult Channel Is Tuned    #USED
    [Documentation]    This keyword verifies that adult channel is tuned to.
    Verify That Adult Channel Is Tuned    ${False}

I Verify Unlocked Adult Channel With Events Unlocked    #USED
    [Documentation]    This keyword verifies that age rated channel was unlocked.
    I open Channel Bar
    Verify Unlocked Adult Channel With Events Unlocked

I Verify That Adult Channel Is Tuned After Unlock    #USED
    [Documentation]    This keyword verifies that adult channel is tuned after previously unlocking an adult channel.
    Verify That Adult Channel Is Tuned    ${True}

Dismiss '${error_code}' Pop Up    #USED
    [Documentation]  This keyword dismiss any error pop up is displayed on screen
    : FOR    ${_}    IN RANGE    ${10}
    \    ${pop_up_found}  Run Keyword And Return Status   Error screen '${error_code}' is shown
    \    Run Keyword If    ${pop_up_found}    Run Keywords    I Press    BACK    AND    I wait for 1 second
    \    Exit For Loop If   not ${pop_up_found}
    Should Not Be True    ${pop_up_found}    Unable to dismiss error popup
    
Dismiss Channel Failed Error Pop Up    #USED
    [Documentation]  This keyword dismiss Channel not available error pop up when RF feed is not connected to CPE
    Run Keyword If    not ${RF_FEED_PRESENT}    Dismiss 'CS2004' Pop Up    ELSE    No Operation

Validate Channel Bar Timeout After Tuning    #USED
    [Documentation]    This keyword validates whether the channel bar animation is completed after 150 ms after tuning to the required channel
    I Tune To Random Linear Channel
    Channel Zapping Using Channel Number
    ${status}   Run Keyword If    not ${RF_FEED_PRESENT}    Run Keyword And Return Status   Wait Until Keyword Succeeds    3 times    10 ms    Error screen 'CS2004' is shown
    Run Keyword If   not ${RF_FEED_PRESENT} and ${status}   I Press  BACK
    ${is_animated}    Run Keyword And Return Status   Wait Until Keyword Succeeds    15 times    20 ms    I expect page contains 'id:NowAndNext.View'
    Should Be True   ${is_animated}    Channel Bar animation is not completed in 150 ms
    ${is_dismissed}    Run Keyword And Return Status   Wait Until Keyword Succeeds    15 times    500 ms    I do not expect page contains 'id:NowAndNext.View'
    Should Be True   ${is_dismissed}    Channel Bar is not autodismissed after 5000 ms

Validate Channel Bar Timeout For Hard Zap After Tuning   #USED
    [Documentation]    This keyword validates whether the channel bar animation is completed after 150 ms after tuning to the required channel
    I play LIVE TV
    I open Channel Bar
    Repeat Keyword  10 times  Channel Bar Zapping Channel Up
    Repeat Keyword  4 times  Channel Bar Zapping Channel Down
    ${status}   Run Keyword If    not ${RF_FEED_PRESENT}    Run Keyword And Return Status   Wait Until Keyword Succeeds    3 times    10 ms    Error screen 'CS2004' is shown
    Run Keyword If   not ${RF_FEED_PRESENT} and ${status}   I Press  BACK
    ${is_animated}    Run Keyword And Return Status   Wait Until Keyword Succeeds    15 times    20 ms    I expect page contains 'id:NowAndNext.View'
    Should Be True   ${is_animated}    Channel Bar animation is not completed in 150 ms
    ${is_dismissed}    Run Keyword And Return Status   Wait Until Keyword Succeeds    15 times    500 ms    I do not expect page contains 'id:NowAndNext.View'
    Should Be True   ${is_dismissed}    Channel Bar is not autodismissed after 5000 ms

Validate Channel Bar Timeout Without Tuning    #USED
    [Documentation]    This keyword validates whether the channel bar animation is completed after 150 ms without tuning to the required channel
    I play LIVE TV
    I open Channel Bar
    Soft Zapping Without Tuning
    ${status}   Run Keyword If    not ${RF_FEED_PRESENT}    Run Keyword And Return Status   Wait Until Keyword Succeeds    3 times    10 ms    Error screen 'CS2004' is shown
    Run Keyword If   not ${RF_FEED_PRESENT} and ${status}   I Press  BACK
    ${is_animated}    Run Keyword And Return Status   Wait Until Keyword Succeeds    15 times    20 ms    I expect page contains 'id:NowAndNext.View'
    Should Be True   ${is_animated}    Channel Bar animation is not completed in 150 ms
    ${is_dismissed}    Run Keyword And Return Status   Wait Until Keyword Succeeds    15 times    500 ms    I do not expect page contains 'id:NowAndNext.View'
    Should Be True   ${is_dismissed}    Channel Bar is not autodismissed after 5000 ms

I Tune To A Watershed Compliant Channel    #USED
    [Documentation]    This keyword tunes to a watershed compliant channel
    ${channel}    I Fetch Random Watershed Compliant Channel With Filters
    ${channel_number}    Convert To String    ${channel}
    I tune to channel    ${channel_number}

#*************************CPE PERFORMANCE****************************
Channel Bar for live event is Shown
    [Documentation]    This keyword ensures that the channel bar for current event is shown
    [Arguments]    ${channel_number}
    ${json_object}    Get Ui Json
    ${now_next_view}    Is In Json    ${json_object}    ${EMPTY}    id:NowAndNext.View
    ${channel_bar_number}    Extract Value For Key    ${json_object}    id:nnchannelNumber    textValue
    ${ancestor}    Get Enclosing Json    ${json_object}    id:titleText\\d    color:${HIGHLIGHTED_NAVIGATION_COLOUR}    ${3}    ${EMPTY}    ${True}
    ${event_time}    Extract Value For Key    ${ancestor}    id:extendedInfoText\\d    textValue    ${True}
    ${event_time}    strip string    ${event_time}
    ${event_title}    Extract Value For Key  ${json_object}    viewStateKey:selectedProgramme    viewStateValue
    Should not be empty    ${event_title}    "Event title is not shown"
    Should Be True    ${channel_bar_number} == ${channel_number}    "Channel Number not matched"
    Should Be True    ${now_next_view}  "Channel Bar not loaded"
    Should not be empty    ${event_time}    "Event time is not shown"
    #Check event with now has highlight
    ${live_event_id}    Extract Value For Key  ${json_object}    textKey:DIC_GENERIC_AIRING_TIME_NOW    id
    log    ${HIGHLIGHTED_NAVIGATION_COLOUR}
#    ${live_event_now_status}    Is In Json    ${json_object}    id:${live_event_id}    color:${HIGHLIGHTED_NAVIGATION_COLOUR}
    ${live_event_now_status}    Is In Json    ${json_object}    id:${live_event_id}    dictionnaryValue:Now
    Should Be True    ${live_event_now_status}  "Highlighted event has no 'NOW' logo"

I tune to cartoon channel
    [Documentation]    Tune to a cartoon channel
    ${channel_number}    Convert To String    ${TV_GUIDE_CARTOON_CHANNEL}
    I tune to channel    ${channel_number}

Channel Bar for future event is Shown
    [Documentation]    This keyword ensures that the channel bar for next event is shown
    [Arguments]    ${channel_number}
    ${json_object}    Get Ui Json
    ${now_next_view}    Is In Json    ${json_object}    ${EMPTY}    id:NowAndNext.View
    ${current_highlighted_program_title}     Extract Value For Key    ${json_object}    viewStateKey:selectedProgramme    viewStateValue
    ${channel_bar_number}    Extract Value For Key    ${json_object}    id:nnchannelNumber    textValue
    ${ancestor}    Get Enclosing Json    ${json_object}    ${EMPTY}    textValue:${current_highlighted_program_title}    ${2}    ${EMPTY}    ${True}
    Log    ${ancestor}
    ${event_time}    Extract Value For Key    ${ancestor}    id:extendedInfoText\\d    textValue    ${True}
    ${event_time}    strip string    ${event_time}
    ${event_title}    Extract Value For Key  ${json_object}    viewStateKey:selectedProgramme    viewStateValue
    Should not be empty    ${event_title}    "Event title is not shown"
    Should Be True    ${channel_bar_number} == ${channel_number}    "Channel Number not matched"
    Should Be True    ${now_next_view}  "Channel Bar not loaded"
    Should not be empty    ${event_time}    "Event time is not shown"
    #Check if future event by checking if event start time is greater than current time
    ${current_time}    Extract Value For Key    ${json_object}    id:mastheadClock    textValue
    @{event_info}    split string    ${event_time}    -
    ${event_start_time}    strip string    @{event_info}[0]
    ${time_status}    compare event time    ${event_start_time}    ${current_time}
    Should Be True    ${time_status} == 1    "Event time is not in future"

Channel Bar for past event is Shown
    [Documentation]    This keyword ensures that the channel bar for previous event is shown
    [Arguments]    ${channel_number}
    ${json_object}    Get Ui Json
    ${now_next_view}    Is In Json    ${json_object}    ${EMPTY}    id:NowAndNext.View
    ${current_highlighted_program_title}     Extract Value For Key    ${json_object}    viewStateKey:selectedProgramme    viewStateValue
    ${channel_bar_number}    Extract Value For Key    ${json_object}    id:nnchannelNumber    textValue
    ${ancestor}    Get Enclosing Json    ${json_object}    ${EMPTY}    textValue:${current_highlighted_program_title}    ${2}    ${EMPTY}    ${True}
    ${event_time}    Extract Value For Key    ${ancestor}    id:extendedInfoText\\d    textValue    ${True}
    ${event_time}    strip string    ${event_time}
    ${event_title}    Extract Value For Key  ${json_object}    viewStateKey:selectedProgramme    viewStateValue
    Should not be empty    ${event_title}    "Event title is not shown"
    Should Be True    ${channel_bar_number} == ${channel_number}    "Channel Number not matched"
    Should Be True    ${now_next_view}  "Channel Bar not loaded"
    Should not be empty    ${event_time}    "Event time is not shown"
    #Check if future event by checking if event start time is greater than current time
    ${current_time}    Extract Value For Key    ${json_object}    id:mastheadClock    textValue
    @{event_info}    split string    ${event_time}    -
    ${event_start_time}    strip string    @{event_info}[0]
    ${time_status}    compare event time    ${current_time}    ${event_start_time}
    Should Be True    ${time_status} == 1    "Event time is not in past"

Get the Adjacent Channel
    [Documentation]      Get the Adjacent Channel
    ...    position=1 for next channel
    ...    position=-1 for previous channel
    [Arguments]  ${channel_number}    ${position}
    :FOR    ${index}    in    RANGE    ${0}    ${1}
    \    ${new_channel_id}    get from referenced channel via ls    ${CITY_ID}    ${channel_number}    ${CPE_ID}    ${OSD_LANGUAGE}    ${CPE_PRODUCT_CLASS}
    \    ...    ${position}
    \    exit for loop if      ${new_channel_id} != ${channel_number}
    \    ${position}    run keyword if    ${position} < 0    Evaluate    ${position} - 1
    \    ...    ELSE      Evaluate    ${position} + 1
    [Return]     ${new_channel_id}

Channel Bar for live event is Shown after standby
    [Documentation]    This keyword ensures that the channel bar for current event is shown
    ${json_object}    Get Ui Json
    ${connection_error_status}    Is In Json    ${json_object}    ${EMPTY}    textKey:DIC_ERROR_9003_MESSAGE
    run keyword if    ${connection_error_status}    I press    OK
    run keyword if    ${connection_error_status}    I enter a valid pin
    ${pin_pop_up_status}    Is In Json    ${json_object}    ${EMPTY}    id:pinEntryModalPopupTitle
    run keyword if    ${pin_pop_up_status}    I enter a valid pin
    #${setting_modal_status}    run keyword and return status     I expect page contains 'textKey:DIC_COLD_STARTUP_CONSOLIDATED_MODE'
    ${setting_modal_status}    Is In Json    ${json_object}    ${EMPTY}    textKey:DIC_COLD_STARTUP_CONSOLIDATED_MODE
    run keyword if    ${setting_modal_status}    I press    DOWN
    run keyword if    ${setting_modal_status}    I press    OK
    run keyword if    ${pin_pop_up_status} or ${connection_error_status} or ${setting_modal_status}     return from keyword
    ${now_next_view}    Is In Json    ${json_object}    ${EMPTY}    id:NowAndNext.View
    ${ancestor}    Get Enclosing Json    ${json_object}    id:titleText\\d    color:${HIGHLIGHTED_NAVIGATION_COLOUR}    ${3}    ${EMPTY}    ${True}
    ${event_time}    Extract Value For Key    ${ancestor}    id:extendedInfoText\\d    textValue    ${True}
    ${event_time}    strip string    ${event_time}
    ${event_title}    Extract Value For Key  ${json_object}    viewStateKey:selectedProgramme    viewStateValue
    Should not be empty    ${event_title}    "Event title is not shown"
    Should Be True    ${now_next_view}  "Channel Bar not loaded"
    Should not be empty    ${event_time}    "Event time is not shown"
    #Check event with now has highlight
    ${live_event_id}    Extract Value For Key  ${json_object}    textKey:DIC_GENERIC_AIRING_TIME_NOW    id
    ${live_event_now_status}    Is In Json    ${json_object}    id:${live_event_id}    color:${HIGHLIGHTED_NAVIGATION_COLOUR}
    Should Be True    ${live_event_now_status}  "Highlighted event has no 'NOW' logo"
