*** Settings ***
Documentation     Linear Details Page keywords
Resource          ../PA-05_Linear_TV/LinearDetailsPage_Implementation.robot

*** Keywords ***
Linear Detail Page Action Menu is shown
    [Documentation]    This keyword asserts linear detail page is shown
    Linear Details Page is shown
    Log    This keyword calls another keyword -> Linear Details Page is shown. Hence, Duplicate.    WARN

Linear Details Page is shown    #USED
    [Documentation]    This keyword asserts linear detail page is shown
    Common Details Page elements are shown

Live stream is playing    #USED
    [Documentation]    This keyword closes the Channel Bar if displayed and asserts live stream is playing.
    ${status}    Run Keyword And Return Status    Channel Bar is shown
    Run Keyword If    ${status} == ${True}    I Press    BACK
    Dismiss Channel Failed Error Pop Up
    Channel Bar is not shown
    Wait until keyword succeeds    ${JSON_MAX_RETRIES}    ${JSON_RETRY_INTERVAL}    I expect page contains 'id:FullScreen.View'

Live TV is shown
    [Documentation]    This keyword checks that the watching now element contains Now on tv
    Wait until keyword succeeds    ${JSON_MAX_RETRIES}    ${JSON_RETRY_INTERVAL}    I expect page element 'id:watchingNow' contains 'textValue:.*Now on tv.*' using regular expressions

Toast Message is shown containing '${text}'
    [Documentation]    This keyword asserts toast message is shown with given text
    wait until keyword succeeds    20 times    50 ms    I expect page element 'id:toast.message' contains 'textValue:${text}'

Continue Watching is shown
    [Documentation]    This keyword asserts that Continue Watching is shown
    wait until keyword succeeds    ${JSON_MAX_RETRIES}    ${JSON_RETRY_INTERVAL}    I expect page contains 'textKey:DIC_ACTIONS_CONTINUE_WATCHING'

'CONTINUE WATCHING' action is focused
    [Documentation]    This keyword verifies if the 'CONTINUE WATCHING' action is focused
    Section is focused    DIC_ACTIONS_CONTINUE_WATCHING    textKey

'RECORD' action is shown
    [Documentation]    This keyword checks if the 'RECORD' action is shown
    Wait Until Keyword Succeeds    10 times    200 ms    I expect page contains 'textKey:DIC_ACTIONS_RECORD'

'RECORD' action is focused
    [Documentation]    This keyword verifies if the 'RECORD' action is focused
    Section is focused    DIC_ACTIONS_RECORD    textKey

'WATCH LIVE' action is focused
    [Documentation]    This keyword asserts that 'WATCH LIVE' is shown
    Section is focused    DIC_ACTIONS_BACK_TO_LIVE_CHANNEL    textKey

Delete Reminder is shown
    [Documentation]    This keyword asserts delete reminder option is shown
    wait until keyword succeeds    10 times    300 ms    I expect page contains 'textKey:DIC_ACTIONS_DELETE_REMINDER'

'SET REMINDER' action is shown  #USED
    [Documentation]    This keyword asserts 'SET REMINDER' action is shown on the details page of a future event
    wait until keyword succeeds    10 times    300 ms    I expect page contains 'textKey:DIC_ACTIONS_SET_REMINDER'

'SET REMINDER' action is not shown  #USED
    [Documentation]    This keyword asserts "SET REMINDER' option is not shown in current LTV event
    wait until keyword succeeds    10 times    300 ms    I do not expect page contains 'textKey:DIC_ACTIONS_SET_REMINDER'

I open Linear Detail Page    #USED
    [Documentation]    This keyword opens the Linear details page by pressing the INFO button on channel bar
    I open Channel Bar
    I Press    INFO
    Wait Until Keyword Succeeds    ${JSON_MAX_RETRIES}    ${JSON_RETRY_INTERVAL}    Linear Details Page is shown

I open Linear Detail Page in offline mode
    [Documentation]    This keyword opens the Linear details page by pressing the INFO button on channel bar in offline mode
    I open Channel Bar
    I Press    INFO
    Wait Until Keyword Succeeds    ${JSON_MAX_RETRIES}    ${JSON_RETRY_INTERVAL}    I expect page element 'id:DetailPage.View' contains 'viewStateKey:Error'

channel logo is shown in detail page for
    [Arguments]    ${channel_number}
    [Documentation]    This keyword verifies if channel logo metadata matches the channel name in linear detail page
    ${logo_basename}    Get Logo File Name For Channel Number From Linear Service    ${channel_number}
    wait until keyword succeeds    ${JSON_MAX_RETRIES}    ${JSON_RETRY_INTERVAL}    I expect page element 'id:channelIconprimaryMetadata' contains 'url:.+${logo_basename}\.png.*' using regular expressions

get channel logo element ancestor from channel bar
    [Documentation]    This keyword retrieves the channel logo element ancestor from Channel Bar
    ${x}    set variable if    '${GFX_RESOLUTION}'=='1080'    x:362    x:241
    ${y}    set variable if    '${GFX_RESOLUTION}'=='1080'    y:823    y:560
    @{list_parameter}    Create List    ${y}
    ${json_object}    Get Ui Json
    ${ancestor}    Get Enclosing Json    ${json_object}    id:nnVlistInner.    ${x}    ${2}    ${list_parameter}
    ...    ${True}
    [Return]    ${ancestor}

get channel logo path from channel bar
    [Documentation]    This keyword retrieves the channel logo path matching the channel name in Channel Bar
    ${ancestor}    get channel logo element ancestor from channel bar
    [Return]    ${ancestor['background']['url']}

channel logo is shown in the channel bar for
    [Arguments]    ${channel_number}
    [Documentation]    This keyword verifies if channel logo metadata matches the channel name in Channel Bar
    ${image_path}    get channel logo path from channel bar
    ${logo_basename}    Get Logo File Name For Channel Number From Linear Service    ${channel_number}
    Should Match Regexp    ${image_path}    ^.+${logo_basename}.*$    logo path doesnt contain the basename of the logo file from traxis

channel logo is not shown in channel bar
    [Documentation]    This keyword verifies if channel logo metadata matches the channel name in Channel Bar
    ${image_path}    get channel logo path from channel bar
    Should Match Regexp    ${image_path}    /usr/share/.*/emptypixel.png    logo file doesnt match emptypixel.png

channel logo is shown in info panel for
    [Arguments]    ${channel_number}
    [Documentation]    This keyword asserts channel logo is shown in info panel or Guide
    ${channel_number}    Get Focused Guide Programme Cell Channel Number
    ${json_object}    Get Ui Json
    ${channel_cell}    Get Enclosing Json    ${json_object}    id:block_\\d_channel_\\d+_text    textValue:${channel_number}    ${2}    ${EMPTY}
    ...    ${True}
    ${image_path}    Extract Value For Key    ${channel_cell}    id:block_\\d_channel_\\d+_logo    url    ${True}
    ${logo_basename}    Get Logo File Name For Channel Number From Linear Service    ${channel_number}
    Should Match Regexp    ${image_path}    ^.+${logo_basename}.*$    logo path doesnt contain the basename of the logo file from traxis

I focus WATCH
    [Documentation]    This keyword focuses watch option in details page
    wait until keyword succeeds    ${JSON_MAX_RETRIES}    ${JSON_RETRY_INTERVAL}    I expect page contains 'textKey:DIC_ACTIONS_WATCH'
    Move Focus to Section    DIC_ACTIONS_WATCH    textKey

Set Reminder Specific Teardown
    [Documentation]    Contains teardown steps for set reminder related tests
    Delete All Reminders    ${CPE_ID}
    Restart UI via command over SSH by invoking /sbin/reboot
    Default Suite Teardown

I focus continue watching on detail page
    [Documentation]    Navigates to the continue watching option from watch list on Linear Detail Page
    Move Focus to Section    DIC_ACTIONS_CONTINUE_WATCHING    textKey

Focus is on the operator locked event
    [Documentation]    This keyword confirms that the focus is on the operator locked event
    wait until keyword succeeds    ${JSON_MAX_RETRIES}    ${JSON_RETRY_INTERVAL}    I expect page element 'textValue:${OPERATOR_LOCKED_EVENT}' contains 'color:${INTERACTION_COLOUR}'

Metadata is not shown in Info panel
    [Documentation]    This keyword asserts that the primary metadata is not shown in info panel
    wait until keyword succeeds    ${JSON_MAX_RETRIES}    ${JSON_RETRY_INTERVAL}    I do not expect page contains 'id:primaryMetadata'

Fast zapping is initiated immediately
    [Documentation]    This keyword confirms that when user is holding the ChannelUP key, fast zapping will initiate immediately
    Ongoing event is focused
    New channel is tuned

I tune to a channel with season event
    [Documentation]    This keyword tunes to channel with season events
    I tune to channel    ${SEASON_EVENT}

Event Genre/SubGenre is shown in Info Panel
    [Documentation]    This keyword checks that the Genre/SubGenre is shown in the info panel
    ${genre_info}    Read current Genre/SubGenre from Info Panel
    should not be empty    ${genre_info}
    Displayed Genre/SubGenre on info panel matches metadata

Focus is on the operator locked channel through guide
    [Documentation]    This keyword opens guide and confirms that the focus is on the operated locked channel
    I open Guide through the remote button
    wait until keyword succeeds    ${JSON_MAX_RETRIES}    ${JSON_RETRY_INTERVAL}    I expect page element 'textValue:${operator_locked_channel}' contains 'color:${HIGHLIGHTED_NAVIGATION_COLOUR}'

Channel unlocked by entering valid pin
    [Documentation]    This keyword confirms that the channel is unlocked and available by entering a valid pin
    I enter a valid PIN on Operator Pin Entry popup
    Operator locked channel is unlocked
    content available

Channel unlocked by entering valid pin in time frame pin entry popup
    [Documentation]    This keyword confirms that the channel is unlocked and available by entering a valid pin
    I enter a valid PIN on Operator time-frame Pin Entry popup
    Operator locked channel is unlocked
    content available

I tune to a channel with no channel logo available
    [Documentation]    This keyword tunes to a channel with no channel logo
    I tune to channel    ${NO_LOGO_CHANNEL}
    wait until keyword succeeds    ${JSON_MAX_RETRIES}    ${JSON_RETRY_INTERVAL}    I expect page element 'textValue:${NO_LOGO_CHANNEL}' contains 'color:${INTERACTION_COLOUR}'

Channel logo is shown
    [Documentation]    This keyword confirms that the channel logo is shown in details page
    ${channel_number}    Get current channel number
    channel logo is shown in detail page for    ${channel_number}

Programme Metadata Is Shown    #USED
    [Documentation]    This keyword confirms that the Programme Metadata Is Shown
    Check ongoing event is focused
    Event Duration Is Shown In Channel Bar

Channel name is shown in channel bar
    [Documentation]    This keyword confirms that the channel name is shown
    ${channel_number}    Read channel number from channel bar data
    ${ch_name}    lookup channelname for    ${channel_number}
    ${ui_ch_name}    get channel name from logo element in channel bar
    Should Match    ${ch_name}    ${ui_ch_name}    channel name from channelbar doesnt match with Traxis metadata

Actor Surname shown in Linear Detail page matches metadata
    [Documentation]    This keyword verifies that the actor surname shown in linear detail page matches with the metadata
    ${actor_surname_detail_page}    Read Actor Surname from Linear Detail Page
    ${actor_surname_metadata}    Read Actor Surname from traxis metadata
    ${actor_surname_metadata}    strip string    ${actor_surname_metadata}
    should be equal as strings    ${actor_surname_detail_page}    ${actor_surname_metadata}

Event Broadcast Start Time shown in detail page matches metadata
    [Documentation]    This keyword verifies that the start time from detail page matches with the metadata
    ${start_time_detail_page}    Read event start time from Linear Details Page
    ${start_time_metadata}    Read event start time from traxis metadata
    ${start_time_metadata}    strip string    ${start_time_metadata}
    should be equal as strings    ${start_time_detail_page}    ${start_time_metadata}

Country of origin shown in the linear detail page matches metadata
    [Documentation]    This keyword checks that the coutry of origin value in linear detail page matches with metadata
    ${country_of_origin_detail_page}    Read country of origin from linear detail page
    ${country_of_origin_traxis}    Read country of origin from traxis metadata
    ${country_of_origin_traxis}    strip string    ${country_of_origin_traxis}
    should be equal as strings    ${country_of_origin_detail_page}    ${country_of_origin_traxis}

Channel Bar metadata matches with the channel logo
    [Documentation]    This keyword checks that the channel logo shown in channel bar matches with metadata
    I open Channel Bar
    ${channel_number}    Run Keyword If    '${key_pressed}' == 'CHANNELDOWN' or '${key_pressed}' == 'CHANNELUP'    get current channel number
    ...    ELSE IF    '${key_pressed}'=='DOWN' or '${key_pressed}' == 'UP'    Read channel number from channel bar data
    ...    ELSE    ${EMPTY}
    channel logo is shown in the channel bar for    ${channel_number}

Event Broadcast Start Time shown in channel bar matches metadata
    [Documentation]    This keyword verifies that the start time from channel bar matches with the metadata
    ${start_time_channel_bar}    Read event start time from Channel Bar
    ${start_time_metadata}    Read event start time from traxis metadata
    ${start_time_metadata}    strip string    ${start_time_metadata}
    should be equal as strings    ${start_time_channel_bar}    ${start_time_metadata}    Start time from channel bar and traxis is not mached

Event Genre/SubGenre shown in Detail Page matches metadata
    [Documentation]    This keyword checks Genre/SubGenre shown in linear detail page matches with metadata
    ${genre_linear_detail_page}    Read current Genre/SubGenre from Linear Detail Page
    ${genre_metadata_traxis}    Read current Genre/SubGenre from traxis metadata
    ${genre_metadata_traxis}    strip string    ${genre_metadata_traxis}
    ${genre_metadata_from_dict}    get from dictionary    ${GENRE_SUBGENRE_DICTIONARY}    ${genre_metadata_traxis}
    should be equal as strings    ${genre_linear_detail_page}    ${genre_metadata_from_dict}    Genre/SubGenre from linear detail page and traxis is not mached

I focus programme tile
    [Documentation]    This keyword focuses the current programme tile
    now programme is focused

I open details page of the completed recording through Saved
    [Documentation]    This keyword opens Recordings detail page through Saved MENU
    I open Recordings through Saved
    I press    DOWN
    Focus partially or fully recorded tile
    I press    OK
    Recordings Details page is shown

Director First Name shown in Recording Detail Page matches metadata
    [Documentation]    This keyword verifies that the director first name shown in recording detail page matches with the metadata
    ${director_firstname_detail_page}    Read Director FirstName from Linear Detail Page
    ${director_firstname_metadata}    Read Director FirstName from traxis metadata
    should be equal as strings    ${director_firstname_detail_page}    ${director_firstname_metadata}

Actor FirstName shown in Linear Detail Page matches metadata
    [Documentation]    This keyword verifies that the actor first name shown in linear detail page matches with the metadata
    ${actors_name_detail_page}    Read Actors Name from Linear Detail Page
    ${actor_firstname_metadata}    Read Actor FirstName from traxis metadata
    should contain    ${actors_name_detail_page}    ${actor_firstname_metadata}    Actors Name shown in Linear Detail Page is not maching with Traxis metadata

Director FirstName shown in Linear Detail page matches metadata
    [Documentation]    This keyword verifies that the director first name shown in linear detail page matches with the metadata
    ${director_firstname_detail_page}    Read Director FirstName from Linear Detail Page
    ${director_firstname_metadata}    Read Director FirstName from traxis metadata
    should be equal as strings    ${director_firstname_detail_page}    ${director_firstname_metadata}

I tune to series event channel with Contributor Name
    [Documentation]    This keyword tunes to a series event channel with actor/director name
    I tune to channel    ${SERIES_EVENT_CHANNEL_WITH_CONTRIBUTOR_NAME}

I tune to single event channel with Contributor Name
    [Documentation]    This keyword tunes to a single event channel with actor/director name
    I tune to channel    ${SINGLE_EVENT_CHANNEL_WITH_CONTRIBUTOR_NAME}

There is no tile on the right side
    [Documentation]    This keyword asserts that no tile is shown on the right side
    ${event_name}    I retrieve value for key 'viewStateValue' in element 'viewStateKey:nextProgramme'
    Should Be Empty    ${event_name}    Program tile shown in right side of channel bar

End of the event is reached
    [Documentation]    This keyword confirms that the focused event metadata is shown
    Event Duration Is Shown In Channel Bar
    Future event is focused

I have Recorded a series event recording with contributor name
    [Documentation]    Tune to the series event channel with contributor name and record a minute of the current event
    I tune to channel    ${SERIES_EVENT_CHANNEL_WITH_CONTRIBUTOR_NAME}
    I create a partial recording of a current series event

I have Recorded a series event recording
    [Documentation]    Tune to the series event channel and record a minute of the current event
    I tune to channel    ${REPLAY_SERIES_CHANNEL}
    I create a partial recording of a current series event

Actor First Name shown in Recording Detail Page matches metadata
    [Documentation]    This keyword verifies that the actor first name shown in recording detail page matches with the metadata
    ${actors_name_detail_page}    Read Actors Name from Linear Detail Page
    ${actor_firstname_metadata}    Read Actor FirstName from traxis metadata
    should contain    ${actors_name_detail_page}    ${actor_firstname_metadata}    Actors Name shown in Recording Detail Page is not maching with Traxis metadata

I tune to an encrypted channel
    [Documentation]    This keyword tunes to an encrypted channel
    I tune to channel    ${ENCRYPTED_CHANNEL}

Season info shown in Detail Page matches metadata
    [Documentation]    This keyword checks that the season info shown in linear detail page matches with metadata
    ${season_info_detail_page}    Read season info from linear detail page
    ${season_info_traxis}    Read season info from traxis metadata
    should be equal as strings    ${season_info_detail_page}    ${season_info_traxis}

Channel Bar Is Locked    #USED
    [Documentation]    This keyword checks whether the channel bar is locked
    Lock Icon present
    "Locked Channel" Text Is Shown In Channel Bar For Locked Channels

I add operator locked channel as Favourites
    [Documentation]    Add operator locked channel as favourites by LCN
    I add channel to Favourites by LCN    ${OPERATOR_LOCKED_CHANNEL}

I tune to a channel before an IP channel
    [Documentation]    This keyword tunes to a channel before IP channel
    ${channel_number}    get from referenced channel via ls    ${CITY_ID}    ${IP_CHANNEL}    ${CPE_ID}    ${OSD_LANGUAGE}    ${CPE_PRODUCT_CLASS}
    ...    -1
    I tune to channel    ${channel_number}

IP channel is tuned
    [Documentation]    This keyword verifies that the tuned channel is IP Channel
    Make sure that channel tuned to    ${IP_CHANNEL}

I Tune To An IP Channel   #USED
    [Documentation]    This keyword tunes to an IP channel
    ${filtered_list}    I Fetch Linear Channel List Filtered
    ${length}    Get Length    ${filtered_list}
    ${ip_channel}    Set Variable    ${None}
    ${is_channel_present}    Set Variable    ${None}
    :FOR    ${index}    IN RANGE    ${length}
    \    ${ip_channel}    Get Random IP Channel Number
    \    ${channel_id}    Get channel ID using channel number    ${ip_channel}
    \    ${is_channel_present}    Run Keyword and Return status    Should Contain    ${filtered_list}    ${channel_id}
    \    Exit For Loop If    ${is_channel_present}
    Should Be True    ${is_channel_present}    IP channel is not present which is not adult, 4k.
    I tune to channel    ${ip_channel}
    Error popup is not shown

IP channel displayed in the line-up
    [Documentation]    This keyword verifies that the IP channel exist in the channel line-up
    ${channel_number}    Get current channel number
    should not be empty    ${channel_number}    IP Channel is not exist in the channel line-up

IP channel displayed in Guide
    [Documentation]    This keyword verifies that IP channel has the focus in guide
    wait until keyword succeeds    ${JSON_MAX_RETRIES}    ${JSON_RETRY_INTERVAL}    I expect page element 'textValue:${IP_CHANNEL}' contains 'color:${HIGHLIGHTED_NAVIGATION_COLOUR}'

I tune to an unlocked non-favourite IP channel
    [Documentation]    This keyword tunes to an unlocked non-favourite channel
    I tune to channel    ${IP_CHANNEL}

I open 'Add channel to Favourites' option
    [Documentation]    This keyword checks if Add channel to Favourites focused if list empty
    Move Focus to Option in Value Picker    textKey:DIC_ACTIONS_CHANNEL_OPTIONS_ADD_TO_FAVOURITES    DOWN    2
    I Press    OK

I add IP channel to favourites through channel management value picker
    [Documentation]    Add IP channel to favourites by LCN
    I add channel to Favourites by LCN    ${IP_CHANNEL}

Currently tuned channel is added to favourites
    [Documentation]    This keyword verifies that the IP channel is added to the favourites list and favourite icon is shown
    @{channel_list_from_traxis}    get_channel_lists_by_type_from_traxis    ${CPE_ID}    FAVORITE
    ${channel_id}    Get current channel
    list should contain value    ${channel_list_from_traxis}    ${channel_id}
    I open Channel Bar
    wait until keyword succeeds    5times    3s    I expect page element 'id:nnfavIcon' contains 'textValue:B'

I add the IP channel to locked channels list through locked channels value picker
    [Documentation]    Add IP channel to parental control locked channel list through channels value picker
    I add channel '${IP_CHANNEL}' to the locked channels list through parental control

IP channel is added to locked channels list
    [Documentation]    This keyword verifies that IP channel is shown in the locked channel list window
    Manage locked channels is shown
    I expect page element 'id:prefixText' contains 'textValue:${IP_CHANNEL}'

I select Set Reminder
    [Documentation]    This keyword sets an event reminder
    I focus Set Reminder
    I Press    OK

Reminder is set for a future event from Guide
    [Documentation]    Set a reminder for the immediate next event in ${SHORT_DURATION_EVENTS_CHANNEL} channel via Guide
    I open Guide through the remote button
    I press    ${SHORT_DURATION_EVENTS_CHANNEL}
    wait until keyword succeeds    ${JSON_MAX_RETRIES}    ${JSON_RETRY_INTERVAL}    I expect page element 'textValue:${SHORT_DURATION_EVENTS_CHANNEL}' contains 'color:${HIGHLIGHTED_NAVIGATION_COLOUR}'
    : FOR    ${i}    IN RANGE    ${30}
    \    I press    RIGHT
    \    I wait for 3 seconds
    \    I press    INFO
    \    Linear Details Page is shown
    \    ${has_reminder_option}    run keyword and return status    'SET REMINDER' action is shown
    \    run keyword if    ${has_reminder_option}==${False}    run keywords    I press    INFO
    \    ...    AND    Linear Detail Page is not shown
    \    ...    AND    continue for loop
    \    I select Set Reminder
    \    Verify Reminder is set
    \    ${title}    I retrieve value for key 'textValue' in element 'id:gridInfoTitle'
    \    ${REMINDER_TITLE}    set test variable    ${title}
    \    I press    INFO
    \    Linear Detail Page is not shown
    \    Exit For Loop

I open Linear Detail Page for future reminder event
    [Documentation]    Navigates to the future reminder event via Guide and opens the Linear details page
    I open Guide through the remote button
    I press    ${SHORT_DURATION_EVENTS_CHANNEL}
    wait until keyword succeeds    ${JSON_MAX_RETRIES}    ${JSON_RETRY_INTERVAL}    I expect page element 'textValue:${SHORT_DURATION_EVENTS_CHANNEL}' contains 'color:${HIGHLIGHTED_NAVIGATION_COLOUR}'
    : FOR    ${i}    IN RANGE    ${30}
    \    I press    RIGHT
    \    I press    INFO
    \    Linear Details Page is shown
    \    ${has_reminder_set}    run keyword and return status    Delete Reminder is shown
    \    return from keyword if    ${has_reminder_set}
    \    I press    INFO
    \    Linear Detail Page is not shown

The reminder is deleted via details page
    [Documentation]    Delete the reminder via the Details page
    I select Delete Reminder
    Verify Reminder is deleted

I open Linear Detail Page for future event    #USED
    [Documentation]    Navigates to the future event( next to next event) and opens the Linear details page by pressing the INFO button on channel bar
    I press RIGHT 2 times
    I Press    INFO
    Linear Details Page is shown

I set reminder on this event
    [Documentation]    This keyword sets an event reminder
    I select Set Reminder
    Verify Reminder is set

Verify Reminder is set
    [Documentation]    This keyword verifies that reminder is set in the details view
    Toast message is shown containing 'Reminder is set'
    Delete Reminder is shown
    Reminder icon is set in details view

Verify Reminder is deleted
    [Documentation]    This keyword verifies that reminder is not set following an action in the details view
    Toast message is shown containing 'Reminder deleted'
    'SET REMINDER' action is shown

I wait until start of future reminder event
    [Documentation]    Waits till the future reminder event starts
    ${json_object}    Get Ui Json
    ${header_1}    Extract Value For Key    ${json_object}    id:detailedInfoprimaryMetadata    textValue
    ${header_2}    Extract Value For Key    ${json_object}    id:mastheadTime    textValue
    @{regexp_match_1}    Get Regexp Matches    ${header_1}    (\\d{2}):(\\d{2}) ?- ?(\\d{2}):(\\d{2})    1    2    3
    ...    4
    ${current_event_time_end_hours}    ${current_event_time_end_minutes}    Set Variable    @{regexp_match_1[0]}[2]    @{regexp_match_1[0]}[3]
    ${current_event_time_end_hours}    Convert To Integer    ${current_event_time_end_hours}
    ${current_event_time_end_minutes}    Convert To Integer    ${current_event_time_end_minutes}
    @{regexp_match_2}    Get Regexp Matches    ${header_2}    (\\d{2}):(\\d{2})    1    2
    ${current_time_hours}    ${current_time_minutes}    Set Variable    @{regexp_match_1[0]}[0]    @{regexp_match_1[0]}[1]
    ${current_time_hours}    Convert To Integer    ${current_time_hours}
    ${current_time_minutes}    Convert To Integer    ${current_time_minutes}
    ${same_hour}    Evaluate    ${current_time_hours} == ${current_event_time_end_hours}
    ${current_event_duration_left}    Set Variable If    '${same_hour}' == 'False'    ${current_event_time_end_minutes + (60 - ${current_time_minutes})}    ${current_event_time_end_minutes - ${current_time_minutes}}
    I wait for ${current_event_duration_left} minutes

The reminder toast message is not presented
    [Documentation]    This keyword verifies that the reminder toast message is not shown
    wait until keyword succeeds    ${JSON_MAX_RETRIES}    ${JSON_RETRY_INTERVAL}    I do not expect page contains 'textKey:DIC_INFORMATIVE_NOTIFICATION_REMINDER_START'

Metadata is not shown on operator locked channel
    [Documentation]    This keyword asserts that metadata is not shown on the operator locked channel
    wait until keyword succeeds    ${JSON_MAX_RETRIES}    ${JSON_RETRY_INTERVAL}    I expect page element 'id:rcuCueGuide' contains 'textKey:DIC_RC_CUE_UNLOCK_CHANNEL' using regular expressions

Current Program title is displayed in channel bar
    [Documentation]    This keyword gets the current event titles from the channel bar
    ${indexes_ids}    Get id for the current and next events
    Set Test Variable    ${INDEX_ID}    ${indexes_ids[0]}
    Set Test Variable    ${INDEX_ID_NEXT}    ${indexes_ids[1]}
    the title of the current programme is shown in the Header

I wait for the next event
    [Documentation]    This keyword waits for the next event either is more, equal or less than 16 minutes
    ${time_left_until_next_event}    Get time left until next event
    ${time_left_until_next_event_less_than_16_minutes}    Evaluate    (${time_left_until_next_event}<16)
    Run Keyword If    '${time_left_until_next_event_less_than_16_minutes}' == 'True'    Log    'Next event will be in less than 16 minutes time so I'm not waiting..."    WARN
    ...    ELSE IF    '${time_left_until_next_event_less_than_16_minutes}' == 'False'    Waiting time until Starts in is displayed    ${time_left_until_next_event}
    ${next_event_in}    Minutes left until the next event
    ${next_event_in}    Convert To Integer    ${next_event_in}
    ${waiting_time}    Set Variable    ${next_event_in + 0.1}
    I Wait for ${waiting_time} minutes

Program title is updated dynamically in channel bar
    [Documentation]    This keyword checks if the current event title matches the previous 'next event'
    ${next_title}    Set Variable    ${next_event_title}
    I Open Channel Bar
    Should Be Equal As Strings    ${next_title}    ${current_event_title}    Event is not the same

Verify new channel is tuned with video
    [Documentation]    This keyword verifies that the new channel is tuned, channel bar is shown and video is playing after pressing channel down 2 times
    I open Channel Bar
    variable should exist    ${TUNED_CHANNEL_NUMBER}    Suite var TUNED_CHANNEL_NUMBER has not previously been set
    ${channel_number}    get from referenced channel via ls    ${CITY_ID}    ${TUNED_CHANNEL_NUMBER}    ${CPE_ID}    ${OSD_LANGUAGE}    ${CPE_PRODUCT_CLASS}
    ...    -2
    ${current_tuned_channel_number}    Get current channel number
    should not be empty    ${current_tuned_channel_number}    Error in getting tuned channel
    Should Be Equal    ${channel_number}    ${current_tuned_channel_number}    Channel is not tuned to another channel
    video playing

I tune to a subscribed encrypted channel
    [Documentation]    This keyword tunes to an encrypted channel
    I tune to channel    ${SUBSCRIBED_ENCRYPTED_CHANNEL}

I tune to two digit LCN using numeric key
    [Documentation]    This keyword tunes to two digit LCN
    I tune to channel '${TWO_DIGIT_CHANNEL}' using numeric keys

I tune to one digit LCN using numeric key
    [Documentation]    This keyword tunes to one digit LCN
    I tune to channel '${ONE_DIGIT_CHANNEL}' using numeric keys

Channel Bar content matches with metadata
    [Documentation]    This keyword verifies that the channel bar contents matches with metadata
    Compare event duration in 'channel bar' and traxis metadata
    Compare event name in channel bar and traxis metadata

Channel logo block contains the single digit channel number
    [Documentation]    This keyword verifies that the channel logo block contains the one digit channel number
    ${channel_number}    Read channel number from channel bar data
    Should Be Equal    ${ONE_DIGIT_CHANNEL}    ${channel_number}

Channel logo block contains the two digit channel number
    [Documentation]    This keyword verifies that the channel logo block contains the two digit channel number
    ${channel_number}    Read channel number from channel bar data
    Should Be Equal    ${TWO_DIGIT_CHANNEL}    ${channel_number}

Teletext page is shown
    [Documentation]    This keyword verifies that teletext is displayed on the screen
    I verify Teletext is displayed

Correct Channel Bar Metadata Is Shown    #USED
    [Documentation]    This keyword verifies that the tuned channel metadata with informations: correct LCN , Event title , Now icon present and correct start/end time is displayed in channel bar
    Programme Metadata Is Shown
    ${actual_channel}    Read channel number from channel bar data
    Should Be Equal    ${TUNED_CHANNEL_NUMBER}    ${actual_channel}    Channel number incorrect in channel bar
    ${event_title}    Read current event name from Channel Bar
    Should Not Be Empty    ${event_title}    Title of event missing

Metadata is not shown on operator locked event
    [Documentation]    This keyword asserts that the metadata is not shown on operator locked event
    Metadata is not shown in Info panel

Content is unavailable with locked metadata
    [Documentation]    This keyword verifies that the metadata is locked and content is not available
    Verify content locked
    content unavailable

Metadata is not shown on user locked channel
    [Documentation]    This keyword asserts that metadata is not shown on the user locked channel
    Metadata is not shown on operator locked channel
    Log    This keyword calls for Metadata is not shown on operator locked channel    WARN

I add '${number_of}' channels to the Locked channel list
    [Documentation]    Add channels to the locked channel list
    I open Lock channels with valid pin
    : FOR    ${channel_with_index}    IN RANGE    ${1}    ${number_of}+${1}
    \    I open 'Add channels' for Locked
    \    I mark '${channel_with_index}' as locked
    \    Manage locked channels is shown
    I press    BACK
    Manage locked channels is not shown

User Locked Channel Unlocked By Entering Valid Pin    #USED
    [Documentation]    This keyword verifies that the channel is unlocked by entering valid pin and content is available
    I unlock the channel
    channel is unlocked

I tune to one of the User Locked channels
    [Documentation]    This keyword tunes to one of the user locked channels
    @{channel_list}    get channel list by type via as    ${STB_IP}    ${CPE_ID}    LOCKED    ${False}
    ${channel_number}    get channel number by id    ${CITY_ID}    @{channel_list}[0]    ${OSD_LANGUAGE}    ${CPE_PRODUCT_CLASS}
    I tune to channel    ${channel_number}

Record an ongoing program on a locked channel
    [Documentation]    Record an event from channel bar
    Reset All Recordings
    I try to record an event
    I press OK on 'Record complete series' option
    Toast message 'Series recording scheduled' is shown

I open episodes for the series asset
    [Documentation]    Navigate to episodes tab and attempt to open episode picker
    I focus Episodes
    I press    OK

I unlock the Adult programme
    [Documentation]    This keyword verifies that an adult program unlocked by entering valid pin
    I press    OK
    I enter a valid PIN on Adult programme Pin Entry popup
    Stream is unlocked
    Adult programme is unlocked

I tune to an Operator Locked IP channel
    [Documentation]    This keyword tunes to an Operator Locked IP channel
    I tune to channel    ${OPERATOR_LOCKED_IP_CHANNEL}

Content is available in More like this    #USED
    [Documentation]    This keyword verifies that events are available under More like this by focusing the first tile
    Move to element assert focused elements    id:MoreLikeThis    ${4}    DOWN

Channel number is shown in channel bar
    [Documentation]    This keyword confirms that the channel number is shown
    I open Channel Bar
    ${channel_number}    Read channel number from channel bar data
    should not be empty    ${channel_number}

I focus Episodes
    [Documentation]    Focus the Episodes tab in the Details Page
    Wait Until Keyword Succeeds    ${JSON_MAX_RETRIES}    ${JSON_RETRY_INTERVAL}    I expect page contains 'textKey:DIC_DETAIL_EPISODE_PICKER_BTN'
    Move Focus to Section    DIC_DETAIL_EPISODE_PICKER_BTN    textKey

I have Recorded an IP channel event
    [Documentation]    Remove any potential other recordings and then tune to
    ...    the IP channel and record a minute of the current event
    Reset All Recordings
    I tune to channel    ${IP_CHANNEL}
    I create a partial recording of a current series event

I select 'Watch live TV'        #USED
    [Documentation]    Select and click OK on the 'Watch live TV' option in the modal
    Interactive modal with options 'Continue watching' and 'Watch live TV' is shown
    Move Focus to Option in Value Picker    textKey:DIC_ACTIONS_SWITCH_TO_LIVE    DOWN    4
    I press    OK

I focus a lock replay channel in 'More like this'
    [Documentation]    Focus a locked replay event in 'More like this'
    ...    Precondition: 'More like this' section should be available with contents
    ${more_like_this_collection}    I retrieve json ancestor of level '1' for element 'id:CollectionContainer_moreLikeThisCollection'
    ${tiles_count}    Get Length    ${more_like_this_collection['children']}
    : FOR    ${i}    IN RANGE    ${tiles_count}
    \    ${search_result}    Extract Value For Key    ${more_like_this_collection}    id:moreLikeThisCollection_tile_${i}    textValue
    \    ${is_locked}    Is In Json    ${more_like_this_collection}    id:moreLikeThisCollection_tile_${i}    textValue:.*>J<font.*    ${EMPTY}
    \    ...    ${True}
    \    ${is_replay_event}    Is In Json    ${more_like_this_collection}    id:Tile_title_secondary_moreLikeThisCollection_tile_${i}    iconKeys:REPLAY    ${EMPTY}
    \    ...    ${True}
    \    ${is_found}    Evaluate    True if ${is_locked} and ${is_replay_event} else False
    \    Exit For Loop If    ${is_found}
    \    I Press    RIGHT
    should be true    ${is_found}    Locked replay event is not found in 'More like this'

I open Linear Detail Page for AR locked events
    [Documentation]    This keyword handles the PIN Entry popup and opens the Linear details page
    ...    by pressing the INFO button on channel bar
    I open Channel Bar
    I Press    INFO
    ${status}    run keyword and return status    Pin Entry popup is shown
    run keyword if    ${status}    I enter a valid pin
    Linear Details Page is shown

I open details page of a failed recording through Saved
    [Documentation]    This keyword opens the Recordings detail page of a failed recording through Saved MENU.
    ...    For HDD STBs, a partial recording will have failure text.
    ...    NOTE: This is a copy of keyword I open details page of the completed recording through My TV
    ...    which needs to be re-worked and renamed in another PR.
    I open Recordings through Saved
    I press    DOWN
    Focus partially or fully recorded tile
    I press    OK
    Recordings Details page is shown

I open Language Options from Linear Details Page
    [Documentation]    This keyword opens the 'Language settings' from Linear Details Page
    I open Linear Detail Page
    Move Focus to Section    DIC_ACTIONS_LANGUAGE_OPTIONS    textKey
    I Press    OK

I have Recorded an IP channel with subtitles event
    [Documentation]    Remove any potential other recordings and then tune to
    ...    the IP channel with subtitles and record a minute of the current event.
    ...    Value for ${IP_CHANNEL_WITH_SUBTITLES} is set in Channel_Lineup.robot
    Reset All Recordings
    I tune to channel    ${IP_CHANNEL_WITH_SUBTITLES}
    I create a partial recording of a current series event

Informative Notification is shown with the string <Program> has been started on <Channel>
    [Documentation]    This keyword verifies if informative norification with string <Program> has been started on <Channel> is shown
    wait until keyword succeeds    10s    0    I expect page element 'id:toast.message' contains 'textKey:DIC_INFORMATIVE_NOTIFICATION_REMINDER_STARTED'

Interactive notification is shown with reminder icon
    [Documentation]    This keyword verifies if informative norification with icon is shown
    wait until keyword succeeds    10s    0    I expect page element 'id:toast.icon' contains 'iconKeys:REMINDER'

'NOW' Icon Is Shown In Primary Metadata    #USED
    [Documentation]    This keyword verifies that the NOW icon is shown in primary metadata
    ${text_value}    I retrieve value for key 'textValue' in element 'id:nowIconprimaryMetadata'
    Should Be Equal      ${text_value}       NOW    NOW Icon is Not Visible On Channel Bar

Validate Event Expiry If Replay Event       #USED
    [Documentation]    This keyword checks if current Event Is Replay Enabled, If yes, Checks if expiry is Shown In Linear Details Page
    ${replay_enabled}    Run Keyword And Return Status    wait until keyword succeeds    ${JSON_MAX_RETRIES}    ${JSON_RETRY_INTERVAL}    I expect page contains 'id:replayIconprimaryMetadata'
    Run Keyword If    ${replay_enabled}==True    wait until keyword succeeds    20 times    1 sec    I expect page contains 'textKey:DIC_SECONDARY_META_AVAILABILTY_WITH_YEAR'

I Get Details Of Current Event On Tuned Channel     #USED
    [Documentation]    This keyword gets the details of the currently playing event on tuned channel
    ${channel_id}    Get channel ID using channel number    ${TUNED_CHANNEL_NUMBER}
    @{current_event}    Get current channel event via as    ${channel_id}
    ${current_event_details}    Get Details Of An Event Based On Event ID    ${current_event[0]}
    Set Suite Variable     ${LAST_FETCHED_DETAILS_PAGE_DETAILS}        ${current_event_details}

I Tune And Watch Replay Event For '${time}' Seconds    #USED
    [Documentation]    This keyword tunes to linear channel and watch replay asset for '${time}' seconds
    ...    setting the event title to a suite variable
    ...    param: '${time}' is a time for watching linear event in seconds
    I Tune To Replay Channel Based On Current Event Remaining Time
    Header Is Shown For Linear Player
    ${event_title}    I retrieve value for key 'textValue' in element 'id:watchingNow' using regular expressions
    ${isLiveTV}    Run Keyword And Return Status    Should Contain    ${event_title}    Live TV:
    @{split_string}    Run Keyword If    ${isLiveTV}    Split String    ${event_title}    Live TV:
    ...    ELSE    Split String    ${event_title}    Now on tv:
    ${title}    Set Variable    ${split_string[-1]}
    ${watched_title}    Strip String    ${title}
    ${regex_escaped_title}    Regexp Escape    ${watched_title}
    ${watched_event_title}    Regexp Escape    ${regex_escaped_title}
    Set Suite Variable    ${EVENT_TITLE}    ${watched_event_title}
    I wait for ${time} seconds

Get Next IP Channel    #USED
    [Documentation]    This keyword returns next IP channel.
    ${channel_id}    Get current channel
    ${ip_channels}   I Fetch All IP Channels
    ${length}    Get Length    ${ip_channels}
    ${current_index}    Get Index From List    ${ip_channels}    ${channel_id}
    ${next_ip_channel_id}    Run Keyword If    ${current_index} < ${length-1}    Get From List    ${ip_channels}    ${current_index+1}
    ...    ELSE    Get From List    ${ip_channels}    ${current_index-1}
    ${next_ip_channel}    get channel number by id    ${CITY_ID}    ${next_ip_channel_id}    ${OSD_LANGUAGE}    ${CPE_PRODUCT_CLASS}
    [Return]    ${next_ip_channel}

I Go To Next IP Channel Using CH+/CH-    #USED
    [Documentation]    This keyword goes to next IP channel using CH+/CH-.
    ${next_ip_channel}    Get Next IP Channel
    ${response}    Get All Channels Via LinearService
    ${length}    Get Length    ${response}
    :FOR    ${index}    IN RANGE    0    ${length}
    \    ${channel_number}    Get current channel number
    \    Run Keyword If    ${channel_number} < ${next_ip_channel}    Channel Bar Zapping Channel Up
    \    ...    ELSE IF    ${channel_number} > ${next_ip_channel}    Channel Bar Zapping Channel Down
    \    Exit For Loop If    ${channel_number} == ${next_ip_channel}
    Error popup is not shown

I Go To Next IP Channel Using UP/DOWN    #USED
    [Documentation]    This keyword goes to next IP channel using UP/DOWN.
    ${next_ip_channel}    Get Next IP Channel
    ${response}    Get All Channels Via LinearService
    ${length}    Get Length    ${response}
    :FOR    ${index}    IN RANGE    0    ${length}
    \    ${channel_number}    Get current channel number
    \    Run Keyword If    ${channel_number} < ${next_ip_channel}    I press    UP
    \    ...    ELSE IF    ${channel_number} > ${next_ip_channel}    I press    DOWN
    \    Exit For Loop If    ${channel_number} == ${next_ip_channel}
    Error popup is not shown
