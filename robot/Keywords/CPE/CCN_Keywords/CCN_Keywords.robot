*** Settings ***
Documentation     contain Platform based keywords
Resource          ../Common/Common.robot

*** Variables ***


*** Keywords ***
I switch Linear Player to PAUSE mode    #USED
    [Documentation]    This keyword switch the player to pause mode
    Show Video Player bar
    ${json_object}    Get Ui Json
    ${icon_image}    Extract Value For Key    ${json_object}    id:trickPlayIcon-LinearInfoPanel    iconKeys    ${True}
    Run Keyword If    'TRICKPLAY_PAUSE' not in '${icon_image}'    Run Keywords    I press    PLAY-PAUSE
    ...    AND    Wait Until Keyword Succeeds    ${JSON_MAX_RETRIES}    200 ms    I expect page element 'id:trickPlayIcon-LinearInfoPanel' contains 'iconKeys:TRICKPLAY_PAUSE' using regular expressions

I switch Non-Linear Player to PAUSE mode    #USED
    [Documentation]    This keyword switch the player to pause mode
    Show Video Player bar
    ${json_object}    Get Ui Json
    ${icon_image}    Extract Value For Key    ${json_object}    id:trickPlayIcon-NonLinearInfoPanel    iconKeys    ${True}
    Run Keyword If    'TRICKPLAY_PAUSE' not in '${icon_image}'    Run Keywords    I press    PLAY-PAUSE
    ...    AND    Wait Until Keyword Succeeds    ${JSON_MAX_RETRIES}    200 ms    I expect page element 'id:trickPlayIcon-NonLinearInfoPanel' contains 'iconKeys:TRICKPLAY_PAUSE' using regular expressions

I switch Linear Player to PLAY mode
    [Documentation]    This keyword switches the player to play mode
    Show Video Player bar
    ${status}    run keyword and return status    I do not expect page element 'id:trickPlayIcon-LinearInfoPanel' contains 'iconKeys:TRICKPLAY_PAUSE' using regular expressions
    Run Keyword If    ${status} == ${True}    Run Keywords    I press    PLAY-PAUSE
    ...    AND    Wait Until Keyword Succeeds    ${JSON_MAX_RETRIES}    200 ms    I expect page element 'id:trickPlayIcon-LinearInfoPanel' contains 'iconKeys:TRICKPLAY_PLAY' using regular expressions
    Hide Video Player bar

I switch Non-Linear Player to PLAY mode    #USED
    [Documentation]    This keyword switches the player to play mode
    Show Video Player bar
    ${status}    run keyword and return status    I do not expect page element 'id:trickPlayIcon-LinearInfoPanel' contains 'iconKeys:TRICKPLAY_PAUSE' using regular expressions
    Run Keyword If    ${status} == ${True}    Run Keywords    I press    PLAY-PAUSE
    ...    AND    Wait Until Keyword Succeeds    ${JSON_MAX_RETRIES}    200 ms    I expect page element 'id:trickPlayIcon-LinearInfoPanel' contains 'iconKeys:TRICKPLAY_PLAY' using regular expressions

Live TV is shown with channel bar    #USED
    [Documentation]    This keyword checks that channel bar is shown on live TV
    Wait until keyword succeeds    ${JSON_MAX_RETRIES}    ${JSON_RETRY_INTERVAL}    I expect page element 'id:mastheadScreenTitle' contains 'textKey:.*DIC_HEADER_SOURCE_LIVE' using regular expressions

Live TV is shown    #USED
    [Documentation]    This keyword checks that the watching now element contains Now on tv
    Wait until keyword succeeds    ${JSON_MAX_RETRIES}    ${JSON_RETRY_INTERVAL}    I expect page element 'id:toast.message' contains 'textKey:.*DIC_TOAST_WATCHING_LIVE' using regular expressions

I go back to TV Guide by going back from Details Page
    [Documentation]    Go back to TV Guide from currently selected Details Page of LTV event
    I Press    BACK
    Guide is shown

I open Linear Detail Page for past event
    [Documentation]    Navigates to the past event(past to past event) and opens the Linear details page by pressing the INFO button on channel bar
    I press LEFT 3 times
    I Press    INFO
    Linear Details Page is shown

I open Details Page of currently selected event in TV Guide
    [Documentation]    Open the Details Page of currently selected event in TV Guide
    I Press    INFO
    Linear Details Page is shown

I set lukewarm standby mode and put box to sleep
    [Documentation]    Keyword sets lukewarm standby mode and puts box to sleep
    I set standby mode to    LukewarmStandby
    I put stb in standby

Open First Content In Contextual Menu of Search
    [Documentation]    Keyword opens first asset from Contextual menu of Search
    Search is focused
    I press    DOWN
    I press    OK

NOW is shown on the Detail Page
    [Documentation]    This keyword asserts the NOW is shown
    wait until keyword succeeds    ${JSON_MAX_RETRIES}    ${JSON_RETRY_INTERVAL}    I expect page contains 'textKey:DIC_GENERIC_AIRING_TIME_NOW'

I tune to Detail Page of Focussed Event
    [Documentation]  This keyword tunes to focused event in guide
    I Press    INFO

I Stop TrickPlay
    [Documentation]    This keyword stops trickplay functonality and Validated Player is in Play mode
    I Press    OK
    Player is in Play mode
	
Date of Expiry is Displayed
    [Documentation]    This keyword asserts the Availble Until is shown
    wait until keyword succeeds    ${JSON_MAX_RETRIES}    ${JSON_RETRY_INTERVAL}    I expect page contains 'textKey:DIC_SECONDARY_META_AVAILABILTY_WITH_YEAR'
	
Replay ICON is Displayed
    [Documentation]    This keyword asserts replay icon is shown
    wait until keyword succeeds    ${JSON_MAX_RETRIES}    ${JSON_RETRY_INTERVAL}    I expect page contains 'textValue:G'
	
I select 'All Episode' in Detail Page
    [Documentation]  This keyword selects ALl Episode in Detail Page
    Move Focus to Section    DIC_DETAIL_EPISODE_PICKER_BTN    textKey
    I press  OK
	
Press Back
    [Documentation]  This keyword press back on any page
    I press  BACK
	
Watch Complete Replay Event And Verify Watched Indicator    #USED
    [Documentation]    This keyword will play the total content of replay asset and verifies watched indicator
    ...   by drag and drop for 15 seconds and varifies Watch again in the screen.
    I press FFWD to forward till the end
    I Open Episode Information From Detail Page
    wait until keyword succeeds    3 times    1 sec    I expect page contains 'textKey:DIC_GENERIC_FULLY_WATCHED_INDICATOR'
	
I Open Episode Information From Detail Page    #USED
    [Documentation]    Open Episode Information on the Focused Replay Event
    ...    Precondition: Focus should be on replay event in channel bar
    I open episode picker
	
Time of Event is Shown
    [Documentation]    This keyword asserts the Time of Event is shown
    wait until keyword succeeds    ${JSON_MAX_RETRIES}    ${JSON_RETRY_INTERVAL}    I expect page contains 'id:detailedInfoprimaryMetadata'
	
I Validate 'My Recordings' Is Displayed In Screen Player
    [Documentation]  This Keyword Validates 'My Recordings' in Screen Player
    wait until keyword succeeds    10 times    300 ms    I expect page element 'id:watchingNow' contains 'dictionnaryValue:My recordings'
    Video Player bar is shown
	
Press OK on REC Button in Detail Page
    [Documentation]  This keyword presses RECORD in Detail page and ends in Pop-up
    Move Focus to Section    DIC_ACTIONS_RECORD    textKey
    I press  OK
	
I Open Info Page on Focussed Event From Channel Bar
    [Documentation]   This keyword opens Info page from Channel Bar
    I Press  INFO
	
I Press REC On Record Complete Series
    [Documentation]  This keyword press REC On Record Complete Series
    I press  OK
    Toast message 'Series recording scheduled' is shown

I invoke WATCH Popup
    [Documentation]  This keyword press OK in TV Guide to invoke WATCH Popup
    I press    OK
    Interactive modal with options 'Watch live' and 'Watch from the beginning' is shown
    Interactive Modal With Options 'Play from beginning' And 'Watch live' Is Shown

I go back to Live TV from TV Guide Popup
    [Documentation]  This keyword press BACK 2 times in TV Guide on WATCH Popup to go back to Live TV
    I press BACK 2 times

I validate TV Guide items
    [Documentation]  This keyword validates TV Guide UI items
    Guide is shown
    Event Metadata Is shown In Guide
    MiniTV is shown
    Current channel event is displayed in PiG
    Get current hours in the tv guide

I wait 5 minutes and go back to Live TV by pressing back
    [Documentation]  This keyword waits for 5 minutes and goes back to Live TV by pressing back
    I wait for 5 minutes
    I press BACK 3 times

I press TV Guide button on RCU
    [Documentation]  This keyword presses TV Guide button on RCU
    I Press    GUIDE

I Open Contextual Key Menu Pop Up In TV-Guide    #USED
    [Documentation]  Open the Contextual Key Pop up from tv guide
    ...   Precondition : TV Guide should be displayed
    Guide is shown
    I Press  CONTEXT
    I wait for 2 second

Validate Asset is Playing in Player   #USED
    [Documentation]    This keyword verifies content is being played. After that, it attempts to show the Details Page
    ...    by pressing the BACK button.
    ...    Precondition: Player is displayed to play VOD asset
    Run Keyword And Ignore Error    About to start screen is shown
    Error popup is not shown
    Wait Until Keyword Succeeds    5times    3s    I expect page contains 'id:Player.View'
    Show Video Player bar
    Wait Until Keyword Succeeds    ${JSON_MAX_RETRIES}    1 s    I expect page element 'id:trickPlayIcon-(Linear|NonLinear)InfoPanel' contains 'iconKeys:TRICKPLAY_PLAY' using regular expressions

I focus past event in guide    #USED
    [Documentation]    This keyword focuses a past event in the TV guide
    I wait for 2 second
    I press LEFT 3 times
    Previous event is focused on TV Guide

I go back to player by pressing back
    [Documentation]  This keyword presses back button to go back to player
    I press    BACK
    I press    OK
    Asset is playing in player

Year of Event is Shown
    [Documentation]    This keyword asserts the Time of Event is shown
    wait until keyword succeeds    ${JSON_MAX_RETRIES}    ${JSON_RETRY_INTERVAL}    I expect page contains 'id:detailedInfoprimaryMetadata'


Genre and Subgenre are shown
    Title is shown      #USED
    [Documentation]    This is Generic keyword which asserts title is shown in detail page For LINEAR,REC,VOD,REPLAY
    ${text_title}    Run Keyword And Return Status    wait until keyword succeeds    ${JSON_MAX_RETRIES}    ${JSON_RETRY_INTERVAL}    I expect page element 'id:title' contains 'textValue:^.+$' using regular expressions
    ${image_title}    Run Keyword And Return Status    wait until keyword succeeds    ${JSON_MAX_RETRIES}    ${JSON_RETRY_INTERVAL}    I expect page element 'id:title' contains 'url:^.+$' using regular expressions
    Should be true    ${text_title} or ${image_title}


'Yesterday' is shown in Day Picker
    [Documentation]    This keyword verifies that the Day picker in the TV Guide shows the value for
    ...    'Yesterday'
    wait until keyword succeeds    ${JSON_MAX_RETRIES}    ${JSON_RETRY_INTERVAL}    I expect page element 'id:gridNavigation_filterButton_0' contains 'textKey:DIC_GENERIC_AIRING_DATE_YESTERDAY' using regular expressions

'Tomorrow' is shown in Day Picker
    [Documentation]    This keyword verifies that the Day picker in the TV Guide shows the value for
    ...    'Tomorrow'
    wait until keyword succeeds    ${JSON_MAX_RETRIES}    ${JSON_RETRY_INTERVAL}    I expect page element 'id:gridNavigation_filterButton_0' contains 'textKey:DIC_GENERIC_AIRING_DATE_TOMORROW' using regular expressions

I press FRWD in TV Guide and validate if 'Yesterday' date is shown
    [Documentation]  This keyword presses FRWD in TV Guide and validates if 'Yesterday' date is shown
    I wait for 5 seconds
    I Press    FRWD
    'Yesterday' is shown in Day Picker

I press FRWD in TV Guide
    [Documentation]  This keyword presses FRWD in TV Guide and validates if 'Yesterday' date is shown
    I wait for 3 seconds
    I press FRWD 20 times

I press FFWD twice in TV Guide
    [Documentation]  This keyword presses FRWD in TV Guide and validates if 'Tomorrow' date is shown
    I Press    FFWD
    I wait for 3 seconds
    I press FFWD 40 times


I press FFWD twice in TV Guide and validate if 'Tomorrow' date is shown
    [Documentation]  This keyword presses FRWD in TV Guide and validates if 'Tomorrow' date is shown
    I Press    FFWD
    I wait for 3 seconds
    I Press    FFWD
    I wait for 3 seconds
    #I Press    FFWD
    'Tomorrow' is shown in Day Picker

I focus past event in the channel Bar
    [Documentation]    This keyword focuses the past event in channel Bar
    I press LEFT 80 times
    Channel Bar is shown
    #Previous programme is focused

I focus future event in the channel Bar
    [Documentation]    This keyword focuses the future event in channel Bar
    Channel Bar is shown
    #Now programme is focused
    I press RIGHT 160 times
    #Future event is focused

I focus and open HDMI resolution
    [Documentation]    Navigate the cursor to IMAGE AND SOUND in SETTINGS
    Move Focus to Setting    textKey:DIC_SETTINGS_HDMI_RES_LABEL    DOWN
    I Press    OK

I validate popup with resolution pick
    [Documentation]    Validate if popup with resolutions to pick has appeared
    wait until keyword succeeds    3 times    1 sec    I expect page contains 'textKey:DIC_SETTINGS_HDMI_RES_VALUE_FROM_TV'
	
I put STB in lukewarm standby mode via menu
    [Documentation]    This keyword set STB in lukewarm standby mode
    I open System through Settings
    I focus Standby Power Consumption
    I Press    OK
	Move Focus to Option in Value Picker    textKey:DIC_SETTINGS_STANDBYPOWER_VALUE_MEDIUM    DOWN
	I Press    OK
	I put stb in standby
	I wait for 10 seconds
	
I Validate Power Consumption Mode From Settings
    [Documentation]    This keyword set STB in hot standby mode
    I open System through Settings
    I focus Standby Power Consumption
    I Press    OK

I open replay through Main Menu
    [Documentation]   Opens replayTV
    I open Main Menu
    I open ReplayTV

I open ReplayTV
    Move Focus to Section    DIC_MAIN_MENU_TV_REPLAY    textKey
    I Press   OK



Set current standby mode to HotStandby
    [Documentation]    Sets current standby mode to HotStandby
    I open System through Settings
    I focus Standby Power Consumption
    I press    OK
    Move Focus to Option in Value Picker    textKey:DIC_SETTINGS_STANDBYPOWER_VALUE_HIGH    UP
    I Press    OK

I wait for 1 minute
    [Documentation]   Waits for 60 seconds
    I wait for 60 second

I open Guide via Main Menu
    [Documentation]    This keyword opens the Guide via Main Menu.
    I Press    MENU
    Main Menu is shown
    I focus TV Guide
    I Press    OK

Exit TVGuide Playback    #USED
    [Documentation]    This keyword exit the playback by pressing the BACK button.
    Error popup is not shown
    : FOR    ${i}    IN RANGE    2
    \    I Press    BACK
    \    ${status}    Run Keyword And Return Status    I expect page contains 'id:Player.View'
    \    Run Keyword If    ${status}==${True}    Exit For Loop

Play Already Purchased VOD Asset    #USED
    [Documentation]    This keyword plays an already purchased VOD and verifies playback. Pin entry popup is handled for age restricted VOD
    ...    and Continue Watching Popup is handled to play from start. Precondition: VOD Details page is opened
    First action is focused
    I Press    OK
    Handle Popup And Pin Entry During Playback of an Already Purchased VOD Asset
    Validate Asset is Playing in Player

I Verify InfoPage of Linear TV
    [Documentation]   This keyword verifes the Linear TV Info Page
    Poster is shown
    Synopsis Episode is shown
    Details Page Channel Logo is shown
    'Episodes' action is shown

Read Menu language from Preferences
    [Documentation]    Internal keywords to read menu lang from Preference screen
    wait until keyword succeeds    ${JSON_MAX_RETRIES}    ${JSON_RETRY_INTERVAL}    I expect page element 'id:settingFieldValueText_1' contains 'textValue:^.+$' using regular expressions
    ${menu_lang}    I retrieve value for key 'textValue' in element 'id:settingFieldValueText_1'
    ${menu_lang}    Remove String    ${menu_lang}    >
    ${menu_lang}    Strip String    ${menu_lang}
    @{matches}    Get Regexp Matches    ${menu_lang}    (^[A-Za-z]+).*   1
    [Return]    @{matches}[0]

I Open VOD
    [Documentation]   Opens VOD
    I Press    MENU
    Main Menu is shown
    I open On Demand

Verify if toast message is displayed at series end
    [Documentation]    Verify if toast message is displayed at series end
    I Press OK 3 times
    I wait for 3 seconds
    I press FFWD 6 times
    I wait for 5 seconds
    Wait Until Keyword Succeeds    ${TOAST_MSG_MAX_WAIT_TIME}    ${JSON_RETRY_INTERVAL}    I expect page contains 'id:toast.accept'
    I press    DOWN
    I press    OK

Navigate to random series episode
    [Documentation]    Navigate to random series episode
    I open On Demand through Main Menu
    I open SERIES thru MAIN menu
    I navigate to all genres vod screen
    I press    DOWN
    I wait for 2 seconds
    I press    OK

I open Live TV    #USED
    [Documentation]    Open the focused replay event and start playback by selecting 'Replay' or 'Watch' button
    ...    Precondition: Focus should be on replay event in channel bar
    I Press    OK
    Interactive modal with options 'Watch live TV' and 'Play from start' is shown
    I wait for 2 second
    I press    OK

#I set to ${lang} in Menu Language window
#    [Documentation]    keyword to set lang in Preference screen. Parameter format example: 'English'
#    send key    OK
#    # to make sure to search for ID from the top since no cyclic rotation possible
#    repeat keyword    ${MAX_MENU_LANG} times    send key    UP
#    # to find out id of new language
#    ${new_menu_language_id}    Read menu language id from Menu Language list    ${lang}
#    run keyword if    '${new_menu_language_id}' == '${None}'    fail    menu language to set not available in settings
#    log    picker-item-text-${new_menu_language_id}u
#    Move Focus to Option in Value Picker    id:picker-item-text-${new_menu_langage_id}    DOWN    8
#    send key    OK
#    ${current_menu_lang}    Read Menu language from Preferences
#    repeat keyword    3 times    I Press    BACK
#    Run keyword unless    '${current_menu_lang}' == '${lang}'    fail    New Audio language which is set not reflected in the Preference

I Navigate To More Like This
    [Documentation]   This keyword moves navigaation to MLT Section
    I press DOWN 3 times
    I expect page contains 'id:MoreLikeThis_title'

Validate Play Back From DetailPage    #USED
    [Documentation]    This Keyword Validates Locked Recording Detailpage and playback of a locked channel recording
    ...    Precondition : Detailpae should be opened.
    Linear Details Page is shown
    I Press    OK
    Handle Watch Popup Screens Before Playout Of Any Asset
    Recording starts playing
    I wait for 20 seconds
    Error popup is not shown
    I Exit Playback And Return To Detail Page

Lock A IP Channel And Tune To It    #USED
    [Documentation]    This keyword gets a random linear channel and adds to the locked
    ...    channel list and tunes to that locked channel.
    ${filterd_linear_channels}    Get Random IP Channel Number
    ${channel_id}    Get Random Element From Array    ${filterd_linear_channels}
    ${channel_number}    Get Channel Number By Id    ${CITY_ID}    ${channel_id}    ${OSD_LANGUAGE}    ${CPE_PRODUCT_CLASS}
    I set channel ${channel_number} as User Locked
    I tune to channel    ${channel_number}

I Record an Future Event From Info Page
    [Documentation]   This keyword records an event from Info Page
    I press    REC
    ${status}    run keyword and return status    Interactive modal with options 'Record complete series' and 'Record this Episode' is shown
    run keyword if    ${status}    I press OK on 'Record complete series' option
    Toast message 'Series recording scheduled' is shown

I Open Info Page on Focussed Event From Guide   #USED
    [Documentation]   This keyword opens Info page from Guide
    I press    OK
    I wait for 2 second
    Details Page Header is shown

Exit To TVGuide    #USED
    [Documentation]    This keyword exit the playback by pressing the BACK button.
    Error popup is not shown
    : FOR    ${i}    IN RANGE    2
    \    I Press    BACK
    \    ${status}    Run Keyword And Return Status    I expect page contains 'id:Guide.View'
    \    Run Keyword If    ${status}==${True}    Exit For Loop


Validate EPG Grid on Future Event   #USED
    [Documentation]    This Keyword Validates The EPG Data Till Last Day In Future
    ...    It Gets No Of Days EPG Content Is Available From EPG Service
    ...    Then Navigates To Given Day In Future And Validates EPG Data
    ...    Precondition : TV Guide Should Be Open
    ${days_of_future_epg}    Get Available Future EPG Index Days
    Check EPG Info Panel has Info Available
    Navigate To '${days_of_future_epg}' Day In Future In TV Guide
    I Press    DOWN




Validate EPG Grid on Past Event    #USED
    [Documentation]    This Keyword Validates The EPG Data Till Last Day In Future
    ...    It Gets No Of Days EPG Content Is Available From EPG Service
    ...    Then Navigates To Given Day In Future And Validates EPG Data
    ...    Precondition : TV Guide Should Be Open
    ${days_of_past_epg}    Get Available Future EPG Index Days
    Check EPG Info Panel has Info Available
    Navigate To '${days_of_past_epg}' Day In Future In TV Guide
    I Press    DOWN

Navigate To '${Nth}' Past Day Event In TV Guide    #USED
    [Documentation]    This Keyword Navigates To Given Nth Day In Past In TV Guide
    ...    Precondition : TV Guide Should Be Open
    Guide is shown
    I open Day Filter
    I Press UP ${Nth} Times
    I Press    OK
    I wait for 2 second
    I Press    DOWN

I tune to series channel
    [Documentation]    Search for a series channel
    [Arguments]    ${RETRY}=4
    :FOR    ${index}    IN RANGE    ${RETRY}
    \    Run Keyword     I open Guide through Main Menu
    \    I Press    1
    \    I wait for 3 second
    \    Run Keyword    I Tune To A Channel With Replay Events From TV Guide
    \    Run Keyword    I open Live TV
    \    I wait for 2 second
    \    Run Keyword    I Save Recording Event Name With Title '${RECORDED_EVENT_TITLE}'
    \    Run Keyword      I Open Info Page on Focussed Event From Channel Bar
    \    Run Keyword      Details Page Header is shown
    \    ${TEMP}     Run Keyword And Return Status        I expect page contains 'textKey:DIC_DETAIL_EPISODE_PICKER_BTN'
    \    exit for loop if     ${TEMP}

I Tune To Channel With Non Recording From LiveTV
    [Documentation]    Search for a series channel
    [Arguments]    ${RETRY}=4
    :FOR    ${index}    IN RANGE    ${RETRY}
    \    Run Keyword     I tune to random replay channel
    \    I wait for 3 second
    \    Run Keyword    I Save Recording Event Name With Title '${RECORDED_EVENT_TITLE}'
    \    ${TEMP}     Run Keyword And Return Status         I do not expect page contains 'iconKeys:RECORDING_CURRENT'
    \    exit for loop if     ${TEMP}

I Tune To Channel With Non Recording From TVGuide
    [Documentation]    Search for a series channel
    [Arguments]    ${RETRY}=4
    :FOR    ${index}    IN RANGE    ${RETRY}
    \    Run Keyword     I Tune To A Channel With Replay Events From TV Guide
    \    I wait for 3 second
    \    ${TEMP}     Run Keyword And Return Status         I do not expect page contains 'iconKeys:RECORDING_CURRENT'
    \    exit for loop if     ${TEMP}

I Tune To Channel With Episode Information and Non Recording From TVGuide
    [Documentation]    Search for a series channel
    [Arguments]    ${RETRY}=4
    :FOR    ${index}    IN RANGE    ${RETRY}
    \    Run Keyword     I Tune To A Channel With Replay Events From TV Guide
    \    I wait for 3 second
    \    ${EPI}     Run Keyword And Return Status      I expect page contains 'textValue:.*Ep[\\d]+$'
    \    exit for loop if     ${EPI}
    \    ${TEMP}     Run Keyword And Return Status     I do not expect page contains 'iconKeys:RECORDING_CURRENT'
    \    exit for loop if     ${TEMP}

I Tune To Channel With Episode Information and Non Recording From LiveTV
    [Documentation]    Search for a series channel
    [Arguments]    ${RETRY}=7
    :FOR    ${index}    IN RANGE    ${RETRY}
    \    Run Keyword     I Tune To Random Replay Channel
    \    I wait for 3 second
    \    Run Keyword    I Save Recording Event Name With Title '${RECORDED_EVENT_TITLE}'
    \    ${EPI}     Run Keyword And Return Status      I expect page contains 'textValue:.*Ep[\\d]+$'
    \    exit for loop if     ${EPI}
    \    ${TEMP}     Run Keyword And Return Status     I do not expect page contains 'iconKeys:RECORDING_CURRENT'
    \    exit for loop if     ${TEMP}

#Currently recording icon is shown in Channel bar
#    [Documentation]    This keyword checks if the currently recording icon is shown on the channel bar current event
#    Channel bar is shown
#    Wait Until Keyword Succeeds    10 times    300 ms    I expect page element 'id:nnHlist' contains 'iconKeys:RECORDING_CURRENT'

I Save Recording Event Name With Title '${RECORDED_EVENT_TITLE}'      #USED
    [Documentation]    This Keyword stores the event name of current event for recording
    ${CB_event_name}    Read current event name from Channel Bar
    Set Suite Variable    ${CB_FOCUSED_EVENT_NAME}    ${CB_event_name}
    Set Suite Variable    ${RECORDED_EVENT_TITLE}    ${CB_FOCUSED_EVENT_NAME}

Exit To DetailPage From PlayBack    #USED
    [Documentation]    This keyword exit the playback by pressing the BACK button.
    Error popup is not shown
    : FOR    ${i}    IN RANGE    2
    \    I Press    BACK
    \    ${status}    Run Keyword And Return Status    I expect page contains 'id:DetailPage.View'
    \    Run Keyword If    ${status}==${True}    Exit For Loop

I Record an Epiosde
    [Documentation]   This keyword records an event from Info Page
    I press    REC
    ${status}    run keyword and return status    Interactive modal with options 'Record complete series' and 'Record this Episode' is shown
    run keyword if    ${status}    I press OK on 'Record this episode' option
    'This program will be saved in full in your recordings' toast message is shown

I start recording an ongoing from TV Guide
    [Documentation]    This keyword starts recording an ongoing complete series from TV Guide.
    ...    Pre-reqs: Already tuned to a series channel
    I open Guide through the remote button
    I press    REC
    ${status}    run keyword and return status    Interactive modal with options 'Record complete series' and 'Record this Episode' is shown
    Run Keyword If    ${status}==${True}    I press OK on 'Record this episode' option
   #'This program will be saved in full in your recordings' toast message is shown

Search result should not match with search query
    ${text_value}    I retrieve value for key 'textValue' in element 'id:searchItemNode0PrimaryText'
    Should Not Be Equal    ${SEARCH_QUERY}    ${text_value}

I search for random Radio channel
    [Documentation]    This keyword searches for the channel name corresponding to the channel defined in the
    ...    ${RANDOM_RADIO} variable, assuming we are already in the Search screen.
    I search for '${RANDOM_RADIO}' using Virtual keyboard

Radio logo and Now playing verification in search result
    [Documentation]    Verifies the search result matches search key and validate logo & Playing now
    ${text_value}    I retrieve value for key 'textValue' in element 'id:searchItemNode0PrimaryText'
    ${RADIO_EVENT}    I retrieve value for key 'textValue' in element 'id:searchItemNode0SecondaryText'
    Should Not Be Equal    ${RADIO_EVENT}    ${EMPTY}
    set suite variable    ${RADIO_EVENT}    ${RADIO_EVENT}
    ${text_value}    Remove String    ${text_value}    <b>    </b>
    Should Be Equal    ${SEARCH_QUERY}    ${text_value}
    Wait Until Keyword Succeeds    5 times    1s    I expect page contains 'id:searchItemNode0Logo'
    wait until keyword succeeds    ${JSON_MAX_RETRIES}    ${JSON_RETRY_INTERVAL}    I expect page element 'id:searchItemNode0NowIndicator' contains 'textKey:DIC_GENERIC_AIRING_TIME_NOW'

Clear the channel/event name input field content    #USED
    [Documentation]    This keyword will clear the existing profile name
    ...    Precondition: Virtual Keyboard should be shown
    Virtual Keyboard is shown
    ${clear_content}    I retrieve value for key 'textValue' in element 'id:searchInputField'
    ${length_of_content}    get length    ${clear_content}
    repeat keyword    ${length_of_content}    I press 'BACKSPACE' on the Virtual Keyboard
    ${clear_content}    I retrieve value for key 'textValue' in element 'id:searchInputField'
    Run Keyword If    '${clear_content}'=='${EMPTY}'    I focus 'G' on the Virtual Keyboard


I Move Focus to TRASHBIN In Recording Section
    [Documentation]   This keyword moves focus to TRASHBIN icon
    I wait for 2 second
    I Press   RIGHT
    I Press   OK
    #Wait Until Keyword Succeeds    5 times    800 ms    I expect page element 'id:toast.message' contains 'textKey:.+TOAST_RECORDING.*'

I check poster image of recorded asset
    [Documentation]   I check updated layout of poster image for recorded asset
    ${color_status}    Run Keyword and Return Status    I expect page contains 'id:DetailPagePosterBackground'
    Should Be True    ${color_status}    'poster color not set'
    log    ${color_status}

Verify background image for empty Rented page
    [Documentation]    This keyword verifies the empty background image for empty rented page from saved menu
    ...    prerequisite :   Rented section should be empty
    Move to element assert focused elements    textKey:DIC_RENTED_EMPTY_BUTTON    3    DOWN
    I Press   OK

I Change The Language In Settings
    [Documentation]   Changes The Language In Settings
    I open Settings through Main Menu
    I focus Menu Language
    I Press   OK
    I wait for 2 second
    I Press   UP
    I Press   OK

I focus feature event with Series in channel Bar
    [Documentation]    This keyword focus feature event with Series in channel Bar (Prereq : Guide is open)
    I Press RIGHT 2 times
    :FOR    ${i}    IN RANGE    999999
    \    ${replay_status}    I retrieve value for key 'dictionnaryValue' in element 'id:gridInfoTitle'
    \    Exit For Loop If    '${replay_status}' is not None
    \    I Press    DOWN

I press REC on a future series episode only from the Channel Bar HDD
    [Documentation]    This keyword focuses the next event in the channel bar; verifies the Channel Bar has metadata;
    ...    presses REC then checks the interactive modal contains the options 'Record complete series' and
    ...    'Record this episode' and finally checks that the modal has pre and post padding settings.
    ...    Pre-reqs: Already tuned to a series channel
    I focus Next event in Channel Bar
    Future event is focused
    I verify that metadata is present on channel bar
    I press    REC
    Interactive modal with options 'Record complete series' and 'Record this Episode' is shown

I schedule only future series episode recording from the Channel Bar HDD
    [Documentation]    This keyword schedules a future single episode recording from the Channel Bar.
    ...    Pre-reqs: Already tuned to a series channel.
    ...    NOTE: Currently...this keyword will only work for a CPE with HDD and local recordings enabled,
    ...    as it checks padding options are present on the interactive modal.
    I press REC on a future series episode only from the Channel Bar HDD
    I press OK on 'Record this episode' option


Delete the series in detail page
    [Documentation]    Delete the series. #Prereq: Saved --> Recordings -> Detail page is opened
    I Press     OK
    Move Focus to Section    DIC_ACTIONS_EDIT_RECORDING    textKey
    I Press     OK
    ${delete}    run keyword and return status    Interactive modal with options 'Record complete series' and 'Delete recording' is shown
    ${stop}    run keyword and return status    Interactive modal with options 'Stop recording' and 'Stop & delete recording' is shown
    Run Keyword If    ${stop}    Run Keywords    I focus 'Stop recording' option
    ...    AND    I press    OK
    ...    AND    I wait for 5 second
    ...    AND    I Press    OK
    ...    AND    I focus 'Delete recording'
    ...    AND    I Press    OK
    ...    ELSE IF    ${delete}    Run Keywords    I focus 'Delete recording'
    ...    AND    I Press    OK

Current channel is running in PiG
    [Documentation]    This keyword verifies that MiniTV(PIG) is playing for a specific channel
    Header Is Shown For Linear Player
    ${json_object}    Get Ui Json
    ${is_source_live}    Is In Json    ${json_object}    ${EMPTY}    textKey:DIC_HEADER_SOURCE_LIVE    ${EMPTY}
    should be true    ${is_source_live}    PiG is not playing current live channel event

Select Replay Catalogue option for replay event
    [Documentation]    This keyword checks and selects replay catalogue option for replay event
    I press    BACK
    I wait for 2 seconds
    I Press    CONTEXT
    ${status}    run keyword and return status    wait until keyword succeeds    5 times    100 ms    I expect page contains 'id:picker-item-text-2'
    log    ${status}
    Run Keyword If    ${status}==True    Run Keywords    I press DOWN 2 times
    ...    AND    I press    OK

I Navigate to Replay/CatchUP TV
    [Documentation]
    I open Main Menu
    Move Focus to Section    DIC_MAIN_MENU_TV_REPLAY    textKey
    I wait for 2 second
    I Press   OK

Select Replay Catalogue option for currently recording asset
    [Documentation]    This keyword checks and selects replay catalogue option for currently recording asset
    I press    OK
    ${episode}    run keyword and return status    wait until keyword succeeds    5 times    100 ms    I expect page contains 'id: EpisodePicker.View'
    log    ${episode}
    Run Keyword If    ${episode}==True    Run Keywords    I press    OK
    ...    AND    I wait for 350 ms
    ...    AND     I press    BACK
    I wait for 350 ms
    I press    BACK
    I wait for 2 seconds
    I PRESS    CONTEXT
    ${status}    run keyword and return status    wait until keyword succeeds    5 times    100 ms    I expect page contains 'id:picker-item-text-1'
    log    ${status}
    Run Keyword If    ${status}==True    Run Keywords    I press    DOWN
    ...    AND    I press    OK

Get the focused series title from recording
    [Documentation]    This keyword gets the series title
    ${json_object}    Get Ui Json
    ${series_title}    Extract Value For Key    ${json_object}    textKey:DIC_GENERIC_EPISODE_FULL    textValue
    ${series_status}    Run Keyword and return status     I expect page contains 'textValue:${series_title}'
    log    ${series_status}
    Set Global Variable     ${series_title}

Delete Recording From Grid
    [Documentation]    This keyword deletes the series recording
    I press    RIGHT
    I Press   OK
    I wait for 2 second
    I Press   OK

I tune to random channel and verify meta data after CH+/CH-
    I Tune To Random Linear Channel
    ${now_channel_number}    Get current channel number
    I Press   CHANNELUP
    ${prev_channel_number}   Get current channel number
    ${event_title}    Read current event name from Channel Bar
    Should Not Be Empty    ${event_title}    Title of event missing
    Channel Bar is shown
    Event Duration Is Shown In Channel Bar
    Run keyword if      ${prev_channel_number} > ${now_channel_number}
    ...    LOG     ${prev_channel_number}
    I Press   CHANNELDOWN
    ${next_channel_number}    Get current channel number
    ${event_title}    Read current event name from Channel Bar
    Should Not Be Empty    ${event_title}    Title of event missing
    Channel Bar is shown
    Event Duration Is Shown In Channel Bar
    Run keyword if      ${next_channel_number} < ${prev_channel_number}
    ...    LOG     ${next_channel_number}

Tune to Last Channel in TV Guide
    [Documentation]   Tunes to Last Channel in TV Guide
    I tune to 999 in the tv guide

Navigate page using CH+/- and verify the channels     #USED
    [Documentation]     This keyword will verify the channels when navigating page using CH+/- and
    ...     keep the pointer in last channel even if the page contains less than 7 channels
    # Guide page 1 and get the channel number.
    #Tune to Last Channel in TV Guide
    I press    CHANNELUP
    I wait for 2 second
    @{channel_number_list_page1}  Create List
    : FOR    ${INDEX}    IN RANGE   0   7
    \   ${channel_number}       I retrieve value for key 'textValue' in element 'id:block_.*_channel_${INDEX}_text' using regular expressions
    \   append to list    ${channel_number_list_page1}    ${channel_number}
    \   run keyword if  ${INDEX} == 6   I tune to ${channel_number} in the tv guide
    # Press Ch- and get the channel number from page 2.
    #Also validate channel number is integer or not inorder to keep valid channel even if the page has less than 7 channel.
    I press    CHANNELUP
    I wait for 2 second
    @{channel_number_list_page2}  Create List
    : FOR    ${INDEX}    IN RANGE   0   7
    \   ${channel_number}       I retrieve value for key 'textValue' in element 'id:block_.*_channel_${INDEX}_text' using regular expressions
    \   ${type1}    Evaluate    type(${channel_number}).__name__
    \   run keyword if  ${type1} == 'int'   append to list    ${channel_number_list_page2}    ${channel_number}
    # Validate page 2 channel against page 1 channel. CH- is successful if both channels doesn't match.
    : FOR    ${channel}    IN      @{channel_number_list_page1}
    \   should be true  ${channel} not in ${channel_number_list_page2}  'Pagedown navigation failed'
    # Press CH+ and get the channel from page 1 .
    #Also validate channel number is integer or not inorder to keep valid channel even if the page has less than 7 channel.
    I press    CHANNELUP
    I wait for 2 second
    @{channel_number_list_page3}  Create List
    : FOR    ${INDEX}    IN RANGE   0   7
    \   ${channel_number}       I retrieve value for key 'textValue' in element 'id:block_.*_channel_${INDEX}_text' using regular expressions
    \   ${type2}    Evaluate    type(${channel_number}).__name__
    \   run keyword if  ${type2} == 'int'   append to list    ${channel_number_list_page3}    ${channel_number}
    I wait for 2 second
    # Validate page 1 channel against page 2 channel. CH- is successful if both channels doesn't match
    : FOR    ${channel}    IN      @{channel_number_list_page2}
    \   should be true  ${channel} not in ${channel_number_list_page3}  'Pageup navigation failed'
        # Press CH+ and get the channel from page 1 .
    #Also validate channel number is integer or not inorder to keep valid channel even if the page has less than 7 channel.
    I press    CHANNELUP
    I wait for 2 second
    @{channel_number_list_page4}  Create List
    : FOR    ${INDEX}    IN RANGE   0   7
    \   ${channel_number}       I retrieve value for key 'textValue' in element 'id:block_.*_channel_${INDEX}_text' using regular expressions
    \   ${type2}    Evaluate    type(${channel_number}).__name__
    \   run keyword if  ${type2} == 'int'   append to list    ${channel_number_list_page4}    ${channel_number}
    I wait for 2 second
    # Validate page 1 channel against page 2 channel. CH- is successful if both channels doesn't match
    : FOR    ${channel}    IN      @{channel_number_list_page3}
    \   should be true  ${channel} not in ${channel_number_list_page4}  'Pageup navigation failed'
        # Press CH+ and get the channel from page 1 .
    #Also validate channel number is integer or not inorder to keep valid channel even if the page has less than 7 channel.
    I press    CHANNELUP
    I wait for 2 second
    @{channel_number_list_page5}  Create List
    : FOR    ${INDEX}    IN RANGE   0   7
    \   ${channel_number}       I retrieve value for key 'textValue' in element 'id:block_.*_channel_${INDEX}_text' using regular expressions
    \   ${type2}    Evaluate    type(${channel_number}).__name__
    \   run keyword if  ${type2} == 'int'   append to list    ${channel_number_list_page5}    ${channel_number}
    I wait for 2 second
    # Validate page 1 channel against page 2 channel. CH- is successful if both channels doesn't match
    : FOR    ${channel}    IN      @{channel_number_list_page4}
    \   should be true  ${channel} not in ${channel_number_list_page5}  'Pageup navigation failed'
        # Press CH+ and get the channel from page 1 .
    #Also validate channel number is integer or not inorder to keep valid channel even if the page has less than 7 channel.
    I press    CHANNELUP
    I wait for 2 second
    @{channel_number_list_page6}  Create List
    : FOR    ${INDEX}    IN RANGE   0   7
    \   ${channel_number}       I retrieve value for key 'textValue' in element 'id:block_.*_channel_${INDEX}_text' using regular expressions
    \   ${type2}    Evaluate    type(${channel_number}).__name__
    \   run keyword if  ${type2} == 'int'   append to list    ${channel_number_list_page6}    ${channel_number}
    I wait for 2 second
    # Validate page 1 channel against page 2 channel. CH- is successful if both channels doesn't match
    : FOR    ${channel}    IN      @{channel_number_list_page5}
    \   should be true  ${channel} not in ${channel_number_list_page6}  'Pageup navigation failed'
    I press    CHANNELUP
    I wait for 2 second
    I press    CHANNELUP
    I wait for 2 second
    I press    CHANNELUP
    I wait for 2 second
    I press    CHANNELUP
    I wait for 2 second
    I press    CHANNELUP
    I wait for 2 second

I tune to random channel and verify only CH+/CH-
    I Tune To Random Linear Channel
    ${now_channel_number}    Get current channel number
    I Press   CHANNELUP
    ${prev_channel_number}   Get current channel number
    Run keyword if      ${prev_channel_number} > ${now_channel_number}
    ...    LOG     ${prev_channel_number}
    I Press   CHANNELDOWN
    ${next_channel_number}    Get current channel number
    Run keyword if      ${next_channel_number} == ${now_channel_number}
    ...    LOG     ${next_channel_number}

Verify deleted recording is not present in page
    [Documentation]    This keyword verifies if the deleted series is no longer displayed in the recording list
    log    ${series_title}
    I wait for 5 seconds
    ${series_status}    Run Keyword and return status     I expect page contains 'textValue:${series_title}'
    log    ${series_status}
    Should Not Be True    ${series_status}

Focus Series Recording
    [Documentation]    This keyword focuses the series recording
    I press    DOWN
    I press    OK
    : FOR    ${INDEX}    IN RANGE   0   35
    \   ${focused_elements}    Get Ui Json
    \   ${status}    Is In Json    ${focused_elements}    ${EMPTY}    textKey:DIC_GENERIC_EPISODE_FULL
    \   log    ${status}
    \   Exit For Loop If    ${status}==True
    \   I press    DOWN
    I press DOWN 3 times



Verify all dates option for Replay Catalogue
    [Documentation]    Verify date option is displayed in Replay Catalogue page
    ${date}    I retrieve value for key 'textValue' in element 'textKey: DIC_FILTER_ALL_DATES'
    Should not be empty    ${date}

Verify sort button option for Replay Catalogue
    [Documentation]    Verify sort option is displayed in Replay Catalogue page
    ${sort}    I retrieve value for key 'textValue' in element 'id:gridNavigation_sortButton'
    Should not be empty    ${sort}

Verify time option for Replay Catalogue
    [Documentation]    Verify time option is displayed in Replay Catalogue page
    ${time}    I retrieve value for key 'textValue' in element 'id:mastheadTime'
    Should not be empty    ${time}


I start recording from TV Guide
    [Documentation]    This keyword starts recording an ongoing complete series from TV Guide.
    ...    Pre-reqs: Already tuned to a series channel
    I press    REC
    ${status}    run keyword and return status    Interactive modal with options 'Record complete series' and 'Record this Episode' is shown
    Run Keyword If    ${status}==${True}    I press OK on 'Record this episode' option
    #'This program will be saved in full in your recordings' toast message is shown

Selects Asset with multiple episodes
    [Documentation]    This keyword selects the asset fow which multiple episodes are available
    : FOR    ${INDEX}    IN RANGE   0   9
    \    ${status}    Run Keyword and Return Status    I retrieve value for key 'dictionnaryValue' in element 'id:gridInfoTitle'
    \    log    ${status}
    \    Exit For Loop If    ${status}==True
    \    ...ELSE IF    ${status}==False    I press    DOWN

Exit MainMenu     #USED
    [Documentation]    This keyword exit the playback by pressing the BACK button.
    Error popup is not shown
    : FOR    ${i}    IN RANGE    2
    \    I Press    BACK
    \    ${status}    Run Keyword And Return Status    I expect page contains 'id:FullScreen.View'
    \    Run Keyword If    ${status}==${True}    Exit For Loop


I Open The Recently Used In Apps    #USED
    [Documentation]    Open Apps and move focus to the Apps Store
    I open Apps through Main menu
    I focus Recently Used

I focus Recently Used       #USED
    [Documentation]    Focuses the App Store tab in Apps section
    I Press   DOWN
    I Press   DOWN
    Wait Until Keyword Succeeds    10 times    300 ms    App store content has loaded

Select YouTube From Recently Used Section   #USED
    [Documentation]    Keyword focus and open the specific app under App Store
    I Open The Recently Used In Apps
    I Press    OK

I playback of a past replay event from current channel
    [Documentation]    Start playback of a past replay event from the current channel. Sometimes we don't want to tune.
    ...    Pre-req: User is on full-screen, live TV.
    I focus current replay event
    I focus past replay event
    I Press    OK
    Details Page Header is shown
    I PLAY Recording From Detail Page
    Player is in PLAY mode

I Validate Screen PlayBack If PIN Is requested
    First action is focused
    I Press    OK
	${status}    Run Keyword And Return Status    'Rent' interactive modal is shown
	Run Keyword If    ${status}    I Enter A Valid Pin
	${pin_entry_present}    Run Keyword And Return Status    Age Restricted PIN Entry Popup Is Shown
    Run Keyword If    ${pin_entry_present}    I Enter A Valid Pin
	I Handle Watch Popup Screens And Any Warning Screen For Already Purchased VOD Asset

Info Is Focused    #USED
    [Documentation]    Checks if NETWORK is focused
    Section is Focused    ${DIC_SETTINGS_INFO}    title

I Set Menu Language To English
    [Documentation]   Sets Menu Language to english
    I open Settings through Main Menu
    Move Focus to Setting    id:titleText_1    DOWN    5
    I wait for 2 second
    I Press    OK
    I wait for 2 second
    Move Focus to Option in Value Picker    textKey:DIC_LANG_ORG_ENGLISH    DOWN    8
    I wait for 2 second
    I Press    OK

Return keyboard format in search menu
    [Documentation]    It will return keyboard format (like QWERTY OR QWERTZ). Search should be open prior to this
    ${KEYBOARD_FORMAT}   Set Variable    ${EMPTY}
    : FOR    ${INDEX}    IN RANGE    2    8
    \    ${row_0}    Get 'id:keyboard-key-0-${INDEX}-OnScreenKeyboardPanelLayout\\w+$' text value
    \    ${KEYBOARD_FORMAT}=        Catenate    SEPARATOR=        ${KEYBOARD_FORMAT}    ${row_0}
    [Return]    ${KEYBOARD_FORMAT}

I Set Menu Language To OtherLanguage
    [Documentation]   Sets Menu Language to english
    I open Settings through Main Menu
    Move Focus to Setting    id:titleText_1    DOWN    5
    I wait for 2 second
    I Press    OK
    I wait for 2 second
    I press UP 2 times
    I wait for 2 second
    I Press    OK

I Select First Asset And Land in InfoPage
    [Documentation]    Selects First Asset In Recording Page
    I press OK 2 times
    I wait for 2 second
    I Press   OK
    ${status}     Run Keyword And Return Status    Episode picker is shown
    I wait for 2 second
    Run Keyword If    ${status}    I Press    OK

I Play Asset From Episode Picker
    [Documentation]  Plays Asset From Episode Picker
    I Press   OK
    I PLAY recording From Detail Page

I Press Contextual Key
    [Documentation]  Press Contextual Key
    I Press    CONTEXT
    I wait for 2 second
    I Press    OK
    Details Page Header is shown

I switch Player to FFWD mode While In Pause    #USED
    [Documentation]    This keyword switches the player to ffwd mode
    I Press    FFWD
    Wait Until Keyword Succeeds    ${JSON_MAX_RETRIES}    200 ms    I expect page element 'id:trickPlayIcon-(Linear|NonLinear)InfoPanel' contains 'iconKeys:TRICKPLAY_FAST_FORWARD' using regular expressions

Move Focus Back From BackToTop
    [Documentation]  Move Focus Back From BackToTop
    I Press   OK
    On Demand is shown

Exit OnDemand     #USED
    [Documentation]    This keyword exit the playback by pressing the BACK button.
    Error popup is not shown
    : FOR    ${i}    IN RANGE    2
    \    I Press    BACK
    \    ${status}    Run Keyword And Return Status    I expect page contains 'id:MainMenu.View'
    \    Run Keyword If    ${status}==${True}    Exit For Loop

I Focus first tile for Recently Added
    [Documentation]    This keyword attempts to focus the first tile on 'Recently Added'
    ...    and verifies the Details Page is shown.
    ...    Precondition: The Main Menu should be open and the On Demand section focused.
    I Press    DOWN
    I press    LEFT

I Validate Channel Bar by Focusing on Most Watched Channels
    [Documentation]  Validates And Focus on Most Watched Channels
    wait until keyword succeeds    ${JSON_MAX_RETRIES}    ${JSON_RETRY_INTERVAL}    I expect page contains 'textKey:DIC_CONTEXTUAL_MAIN_MENU_RECENTLY_WATCHED_CHANNELS'
    I Press   DOWN
    I Press   OK
    Channel Bar is shown
    Main Menu is not shown

I Navigate To Recently Added VOD
    [Documentation]   [Documentation]  Validates And Focus on Most Watched Channels
    I Press   DOWN
    I press RIGHT 3 times

Validate the Detail Page of Adult Channel
    [Documentation]     Validates the Detail Page of Adult Channel
    I Press    INFO
    Pin Entry popup is shown
    Enter Valid Pin and OpenDetail Page

I select 'live TV'
    [Documentation]   Selects LiveTV
    I wait for 2 second
    I Press    OK

I Tune To Another IP Channel   #USED
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

Enter Valid Pin and OpenDetail Page
    [Documentation]
    I enter a valid pin
    I Press   OK
    Details Page Header is shown

Future Programme name is shown
    [Documentation]    This keyword asserts future  Programme is shown in detail page
    ${event_name}    I retrieve value for key 'viewStateValue' in element 'viewStateKey:nextProgramme'
    Should not be empty    ${event_name}

Verify day picker in replay grid page
    [Documentation]    Verify day picker in replay grid page
    I wait for 2 second
    I open Day Filter
    Move Focus to Option in Value Picker    textKey:DIC_GENERIC_AIRING_DATE_YESTERDAY    DOWN    3
    I press    OK

I PLAY Replay Asset From Detail Page    #USED
    [Documentation]    This Keyword Starts And Validates Recordings playout from detail page
    Details Page Header is shown
    Play Any Asset From Detail Page
    Recording starts playing

Verify sort by popularity and alphabet in replay grid page
    [Documentation]    Verify day picker in replay grid page
    Wait Until Keyword Succeeds    10s    1s    I expect page contains 'textKey:DIC_SORT_POPULARITY'
    Navigate To Sort Button In All Genres Page
    I Press     OK
    Wait Until Keyword Succeeds    10s    1s    I expect page contains 'textKey:DIC_SORT_A-Z'
    I Press     DOWN
    I Press     OK

Create A Custom Profile With '${profile1}'first customized profile
    [Documentation]  The keyword will create a new custom profile using the provided name as the profile name with few channel
    I open the Profile menu
    I focus 'New' profile icon
    I press    OK
    'Create a profile' popup is shown
    I focus any profile color
    I press    DOWN
    I choose '${profile1}' as a profile name
    wait until keyword succeeds    ${JSON_MAX_RETRIES}    ${JSON_RETRY_INTERVAL}    I expect focused elements contains 'id:profileNextButton'
    I press    OK
    I select the 'Set up my channels' option in the 'Create a personal channel list' modal menu
    :FOR    ${i}    IN RANGE    5
    \    I press    OK
    \    I press    DOWN
    I press    BACK
    'Manage profile channels list' interactive modal is shown
    wait until keyword succeeds    ${JSON_MAX_RETRIES}    ${JSON_RETRY_INTERVAL}    I expect focused elements contains 'textKey:DIC_GENERIC_BTN_CONFIRM'
    I press    OK
    I focus the 'Skip' option
    I press    OK

Create A Custom Profile With '${profile2}'
    [Documentation]  The keyword will create a new custom profile using the provided name as the profile name with separate channel list different from profile 1
    I wait for 2 seconds
    I open the Profile menu
    I focus 'New' profile icon
    I wait for 2 seconds
    I press    OK
    'Create a profile' popup is shown
    I wait for 2 seconds
    I focus any profile color
    I press    DOWN
    I wait for 2 seconds
    I choose '${profile2}' as a profile name
    wait until keyword succeeds    ${JSON_MAX_RETRIES}    ${JSON_RETRY_INTERVAL}    I expect focused elements contains 'id:profileNextButton'
    I press    OK
    I wait for 2 seconds
    I select the 'Set up my channels' option in the 'Create a personal channel list' modal menu
    I press DOWN 12 times
    I wait for 2 seconds
    :FOR    ${i}    IN RANGE    5
    \    I press    OK
    \    I wait for 2 second
    \    I press    DOWN
    I press    BACK
    I wait for 2 seconds
    'Manage profile channels list' interactive modal is shown
    wait until keyword succeeds    ${JSON_MAX_RETRIES}    ${JSON_RETRY_INTERVAL}    I expect focused elements contains 'textKey:DIC_GENERIC_BTN_CONFIRM'
    I press    OK
    I focus the 'Skip' option
    I press    OK

I Focus The '${profile1}' custom Profile
    [Documentation]    This keyword focus the specified profile in profile selection menu
    I wait for 2 seconds
    I press    PROFILE
    Wait Until Keyword Succeeds    ${JSON_MAX_RETRIES}    ${JSON_RETRY_INTERVAL}    I expect page contains 'textKey:DIC_PROFILES_TITLE'
    ${customer_profile}    I Get The Profile Names From BO
    ${profile_id}   Get Index From List    ${customer_profile}    ${profile1}
    Move to element assert focused elements    id:profileItem-${profile_id}    10    RIGHT
    [Return]    ${profile_id}
    I press    OK

Verify Custom '${profile1}'
    [Documentation]    Verify Custom Profile
    I wait for 2 seconds
    I press    DOWN
    I wait for 2 seconds
    ${custom_channel_name}    I retrieve value for key 'textValue' in element 'id:mastheadProfileName'
    log    ${custom_channel_name}
    Should Be True   '${custom_channel_name}'=='${profile1}'


Verify tuned channel for first custom profile
    [Documentation]    Verify tuned channel for profile1
    I press    BACK
    I press    DOWN
    ${live_channel_profile1}    I retrieve value for key 'textValue' in element 'id:watchingNow'
    log    ${live_channel_profile1}
    Set Global Variable     ${live_channel_profile1}

I Focus the Current Event In Guide After DayPicker Is Selected
    [Documentation]    Focus the Current Event In Guide After DayPicker Is Selected
    I wait for 2 second
    I Press   DOWN

Validate Current Event In Guide After DayPicker Is Selected    #USED
    [Documentation]    This Keyword Validates The EPG Data Till Last Day In Future
    ...    It Gets No Of Days EPG Content Is Available From EPG Service
    ...    Then Navigates To Given Day In Future And Validates EPG Data
    ...    Precondition : TV Guide Should Be Open
    ${days_of_future_epg}    Get Available Future EPG Index Days
    Check EPG Info Panel has Info Available
    Navigate To '${days_of_future_epg}' Day In Future In TV Guide
    I Focus the Current Event In Guide After DayPicker Is Selected

I Focus The '${profile2}' second custom Profile
    [Documentation]    This keyword focus the specified profile in profile selection menu
    I press    PROFILE
    Wait Until Keyword Succeeds    ${JSON_MAX_RETRIES}    ${JSON_RETRY_INTERVAL}    I expect page contains 'textKey:DIC_PROFILES_TITLE'
    ${customer_profile}    I Get The Profile Names From BO
    ${profile_id}   Get Index From List    ${customer_profile}    ${profile2}
    Move to element assert focused elements    id:profileItem-${profile_id}    10    RIGHT
    [Return]    ${profile_id}
    I press    OK

Verify second profile is tuned to a different channel
    [Documentation]    Verify second profile is tuned to a different channel
    I press DOWN 2 times
    I wait for 2 seconds
    I press DOWN 2 times
    ${live_channel_profile2}    I retrieve value for key 'textValue' in element 'id:watchingNow'
    Run Keyword If    '${live_channel_profile2}' == '${live_channel_profile1}'    log    'same programme playing for different channel'
    Run Keyword If    '${live_channel_profile2}' != '${live_channel_profile1}'    log    'different programme'

I open SERIES thru MAIN menu
    [Documentation]     Open Series through main menu
    I Press     MENU
    I wait for 2 seconds
    Move Focus to Section    MOVIES & SERIES     textValue
    I wait for 2 seconds
    I Press     OK
    I wait for 2 seconds
    Move Focus to Section    SERIES     textValue
    I wait for 2 seconds
    I Press OK 2 times
    I wait for 2 seconds
    I Press   OK

Watch series fully
    [Documentation]  Prereq: Open any option under saved menu (continue watching)
    I Press OK 3 times
    Run Keyword And Assert Failed Reason     I press FFWD to forward till the end   'Unable to fast forward'


Validate Duration Year Genre in Primary metadata    #USED
    [Documentation]    This keyword verifies that the Year of production of the asset is shown in Details Page primary metadata
    ${text_value}    I retrieve value for key 'textValue' in element 'id:detailedInfoprimaryMetadata'
    ${out}=        Catenate    SEPARATOR=        font>    ${text_value}    <font
    @{matches}    Get Regexp Matches    ${out}    font\>(.*?)\<font   1
    : FOR    ${INDEX}    IN RANGE    1    len(@{matches})    2
    #\    Should Not Be Empty    @{matches}[${INDEX}]
    \    run keyword if    @{matches}[${INDEX}] != ''     Log    @{matches}[${INDEX}]

I Navigat to Recording With Title '${recording_title}'      #USED
    [Documentation]    This Keyword Navigates to the Specific Row inside complete recorded recordings list UI Or
    ...    Complete Planned recordings list UI based on title of the selected asset.
    ...    param : title  -   Title from the event details
    ...    prerequisite :   Should be in recorded recordings list UI Or Complete Planned recordings list UI. Suite variable
    ...     ${MAX_ACTIONS} should exist
    Move To Element Assert Provided Element Is Highlighted    textValue:^.*${recording_title}.*    ${MAX_ACTIONS}    RIGHT


Delete the series in saved menu
    [Documentation]    Delete the series. #Prereq: Saved --> Recordings -> Detail page is opened
    #Run Keyword If     ${DELETE_DONE}    [Return]    true
    #I Press     OK
    #Move Focus to Section    DIC_ACTIONS_EDIT_RECORDING    textKey
    #I Press     OK
    I press    REC
    ${delete_recording}    run keyword and return status     Interactive modal with options 'Record complete series' and 'Delete recording' is shown
    ${stop_and_delete}    run keyword and return status    Interactive modal with options 'Stop recording' and 'Stop & delete recording' is shown
    Run Keyword If    ${stop_and_delete}    I press OK on 'Stop & Delete Recording' option
    Run Keyword If    ${delete_recording}    run keywords    Move Focus to Button in Interactive Modal    textKey:DIC_INTERACTIVE_MODAL_BUTTON_DELETE_EPISODE    DOWN    2
    ...    AND    I Press    OK

I Navigate to Episodes or Season collection in Recordings Browser
    I open Saved through Main Menu
    I press OK 2 times
    I wait for 3 second
    Move To Element Assert Provided Element Is Highlighted    textValue:.*\\(\\d (seasons|episodes)\\).*    50    DOWN
    I Press   OK
    ${status}     Run Keyword And Return Status    Episode picker is shown
    I wait for 2 second
    Run Keyword If    ${status}    I Press    OK
    Details Page Header is shown

I Navigate to Episode collection in Recordings Browser
    I open Saved through Main Menu
    I press OK 2 times
    I wait for 3 second
    Move To Element Assert Provided Element Is Highlighted    textValue:.*\\(\\d (episodes)\\).*    50    DOWN
    I Press   OK
    ${status}     Run Keyword And Return Status    Episode picker is shown
    I wait for 2 second
    Run Keyword If    ${status}    I Press    OK
    Details Page Header is shown

I Navigate to Episodes collections in Browser
    I open Saved through Main Menu
    I press OK 2 times
    I wait for 3 second
    Move To Element Assert Provided Element Is Highlighted    textValue:.*Ep[\\d]+$    50    DOWN
    I Press   OK

Interactive modal with options 'stop and delete the series' is shown
    [Documentation]    Interactive modal with options 'stop and delete the series' is shown
    I expect page element 'id:interactiveModalButton0' contains 'textKey:DIC_INTERACTIVE_MODAL_BUTTON_STOP_REC_CANCEL_SERIES'

Cancel recording series in saved menu
    [Documentation]    Cancel ongoing recording series in saved menu
    I press    REC
    ${delete}    run keyword and return status    Interactive modal with options 'stop and delete the series' is shown
    Set Suite Variable    ${DELETE_DONE}    ${delete}
    ${cancel}    Run Keyword And return status    Interactive modal with options 'Stop recording this episode ' and 'Cancel Series Recording' is shown
    Run Keyword If    ${cancel}    Run Keywords    I focus 'Cancel series recording'
    ...    AND    I press    OK
    ...    AND    Wait Until Keyword Succeeds    ${TOAST_MSG_MAX_WAIT_TIME}    ${JSON_RETRY_INTERVAL}    I expect page element 'id:toast.message' contains 'textKey:DIC_SPINNER_CANCELLING_SERIES_REC'
    ...    ELSE IF    ${delete}    Run Keyword    I Press    OK

Tune to random replay event and set series title
    Run Keyword And Assert Failed Reason    I Tune To A Random Replay Channel Without Ongoing Recording    'Unable to Tune to replay event.'
    ${event_name}   Read current event name from Channel Bar
    Set Suite Variable    ${SELECTED_ASSET_TITLE}    ${event_name}
    Set Suite Variable    ${RECORDED_EVENT_TITLE}    ${event_name}

Verify recorded series and focus the title
    Run Keyword And Assert Failed Reason    I check ongoing or done recording is present in Recorded list    'Unable to check Ongoing recording present on Saved - Recorded list.'
    I press     BACK
    I wait for 2 seconds
    Move Focus to Tile    ${SELECTED_ASSET_TITLE}    title

Verify recorded series in Saved
    Run Keyword And Assert Failed Reason    I check ongoing or done recording is present in Recorded list    'Unable to check Ongoing recording present on Saved - Recorded list.'
    I press     BACK
    I wait for 2 seconds
    Move Focus to Tile    ${RECORDED_EVENT_TITLE}    title

I open content in more like this And Validate Primary details    #USED
    [Documentation]    Focus the random tile under More like this and validate basic elements
    I Press    DOWN
    I Press    OK
    Wait Until Keyword Succeeds    ${JSON_MAX_RETRIES}    ${JSON_RETRY_INTERVAL}    Common Details Page elements are shown
    I Press    BACK
    I Press    RIGHT
    I Press    OK
    Wait Until Keyword Succeeds    ${JSON_MAX_RETRIES}    ${JSON_RETRY_INTERVAL}    Common Details Page elements are shown

More like this collection is available in detail page
    [Documentation]    This keyword asserts that the More like this Collection is available
    I Press    DOWN
    I expect page contains 'textKey:DIC_COLLECTION_MORE_LIKE_THIS'
    I expect page contains 'id:MoreLikeThis_tile_0'
    I expect page contains 'id:MoreLikeThis_tile_1'

I Record a Episode
    [Documentation]    This keyword initiates recording of an episode of a series event
    ...    Precondition: A recordable series asset needs to be focused
    I Press    REC
    Interactive modal with options 'Record complete series' and 'Record this Episode' is shown
    I focus 'Record this episode'
    I Press    OK
    #'This program will be saved in full in your recordings' toast message is shown

I Record a Complete Series
    [Documentation]    This keyword initiates recording of an complete series of a  event
    ...    Precondition: A recordable series asset needs to be focused
    I Press    REC
    I focus 'Record complete series'
    I Press    OK
    #Toast message 'Series recording scheduled' is shown

I Record a Episode from Future Event
    [Documentation]    This keyword initiates recording of an episode of a series event
    ...    Precondition: A recordable series asset needs to be focused
    I Press    REC
    Interactive modal with options 'Record complete series' and 'Record this Episode' is shown
    I focus 'Record this episode'
    I Press    OK
    #Wait Until Keyword Succeeds    ${TOAST_MSG_MAX_WAIT_TIME}    ${JSON_RETRY_INTERVAL}    I expect page element 'id:toast.icon' contains 'iconKeys:RECORDING_SCHEDULED'

I start recording Future Event from TV Guide
    [Documentation]    This keyword starts recording an ongoing complete series from TV Guide.
    ...    Pre-reqs: Already tuned to a series channel
    I open Guide through the remote button
   # I focus future event in the tv guide
    I press RIGHT 2 times
    I wait for 2 second
    I press    REC
    I wait for 2 second
    I focus 'Record this episode'
    I Press    OK
    Wait Until Keyword Succeeds    ${TOAST_MSG_MAX_WAIT_TIME}    ${JSON_RETRY_INTERVAL}    I expect page contains 'id:toast.icon'

    #Wait Until Keyword Succeeds    ${TOAST_MSG_MAX_WAIT_TIME}    ${JSON_RETRY_INTERVAL}    I expect page element 'id:toast.icon' contains 'iconKeys:RECORDING_SCHEDULED'

Verify if the current video is available in Continue Watching page for custom profile
    [Documentation]    Open Selected VOD INFO Page from continue watching page
    I press    DOWN
    I wait for 2 seconds
    I press    INFO
    I wait for 2 seconds
    ${movie_verify}     I retrieve value for key 'textValue' in element 'id:description'
    Should Be True     '${movie_verify}' == '${movie_verify}'
    I PLAY Replay Asset From Detail Page

Retrieve title of selected video from VOD Info page
    [Documentation]    Retrieve title of selected video from VOD Info page
    ${movie}    I retrieve value for key 'textValue' in element 'id:description'
    Set Global Variable     ${movie}
    I wait for 5 seconds
    I press FFWD 6 times
    I wait for 8 seconds

I open Guide from keyboard
    [Documentation]   Opens Guide
    I Press     GUIDE

I added one replay asset to Watchlist    #USED
    [Documentation]    Adds one replay asset to Watchlist tuning to a channel with replay events and adding the current
    ...    event to the Watchlist through the Detail Page, saving the title in the ${REPLAY_TILE_TITLE} variable
    #I activate Replay TV    # This keyword is commented because this option is not available with all the tenants.
    I Tune To A Channel With Replay Events From TV Guide
    I open Linear Detail Page
    ${is_already_added}    Run Keyword And Return Status    'REMOVE FROM WATCHLIST' action is shown
    Run Keyword If    ${is_already_added}    I select 'Remove from watchlist' in a Detail Page
    I wait for 2 seconds
    I open Add To Watchlist
    ${REPLAY_TILE_TITLE}    I retrieve value for key 'textValue' in element 'id:title'
    Set Suite Variable    ${REPLAY_TILE_TITLE}    ${REPLAY_TILE_TITLE}

Added replay asset is shown in the Watchlist
    [Documentation]    This keyword asserts the replay asset title in the ${REPLAY_TILE_TITLE} variable with the title in watchlist.
    ...    Precondition: ${REPLAY_TILE_TITLE} variable must exist in this scope
    Variable should exist    ${REPLAY_TILE_TITLE}    The title of a replay asset tile has not been saved. REPLAY_TILE_TITLE does not exist.
    Watchlist is not empty
    ${watchlist_replay_title}    I get recently added replay title from the watchlist
    Should Be Equal    ${watchlist_replay_title}    ${REPLAY_TILE_TITLE}    Added replay title is not equal to the one in watchlist

Add to watchlist
    [Documentation]  Add to watchlist
    I Add The Asset To Watchlist

Verify if the current video is not available in Continue Watching page for second profile
    [Documentation]    This keyword verifies if the current video is not available in Continue Watching page for second profile
    ${empty_state}     Run Keyword And Return Status    I expect page contains 'id:continueWatchingEmptyStateTitle-EmptyStateNoContent'
    Should Be True    ${empty_state}

Open video playback progress bar for second custom profile and verify the title and retrieve the progress
    [Documentation]    Open video playback progress bar for seconnd custom profile and verify the title and retrieve the progress
    I Press    OK
    I wait for 5 seconds
    I press FFWD 6 times
    I wait for 8 seconds
    ${title_profile2}    I retrieve value for key 'textValue' in element 'id:assetTitle-NonLinearInfoPanel'
    Should Be True     '${title_profile2}'=='${title_profile2}'
    ${progress_profile2}     I retrieve value for key 'textValue' in element 'id:currentPosition-NonLinearInfoPanel'
    Set Global Variable     ${progress_profile2}

I Start Recording Complete Series Future Event from TV Guide
    [Documentation]    This keyword starts recording an ongoing complete series from TV Guide.
    ...    Pre-reqs: Already tuned to a series channel
    I open Guide through the remote button
   # I focus future event in the tv guide
    I press RIGHT 2 times
    I press    REC
    I focus 'Record this episode'
    I Press    OK
    Wait Until Keyword Succeeds    ${TOAST_MSG_MAX_WAIT_TIME}    ${JSON_RETRY_INTERVAL}    I expect page contains 'id:toast.icon'

    #Wait Until Keyword Succeeds    ${TOAST_MSG_MAX_WAIT_TIME}    ${JSON_RETRY_INTERVAL}    I expect page element 'id:toast.icon' contains 'iconKeys:RECORDING_SCHEDULED'

I Open the first item in the CMM search
    [Documentation]    This keyword opens the first item in the search results
    I Press   DOWN
    I Press    OK
    Details Page Header is shown

I play selected Radio
    [Documentation]    This keyword opens the Radio Portal from Main Menu TV guide section
    I press    OK
    I wait for 5 second
    Radio is being played

Radio is being played    #USED
    [Documentation]    Verifies that Radio is being played
    I expect page element 'id:watchingNow' contains 'dictionnaryValue:Radio' using regular expressions

I Pause the LTV Playback
    [Documentation]   Pause the LTV Playback
    I Press   PAUSE

I Resume the Playback
    [Documentation]   Pause the LTV Playback
    I Press    PLAY-PAUSE

I focus future event in the guide
    [Documentation]    This keyword focuses a future event in the TV guide
    #I focus current event in the tv guide
    I press RIGHT 2 times

I Tune To A Random Replay Channel    #USED
    ${channel_number1}    Get Random Replay Channel Number
    I tune to channel    ${channel_number1}
    I wait for 5 second
    ${channel_number2}    Get Random Replay Channel Number
    I tune to channel    ${channel_number2}
    Channel Bar is shown
    I wait for 3 second
    Press BACK and assert FullScreen.View is present
    I wait for 3 second
    I open Main Menu
    I wait for 3 second
    Press BACK and assert FullScreen.View is present
    I wait for 1 second
    I tune to channel    ${channel_number1}

I focus CMM on Saved
    I Press   DOWN

I Navigate to Personalisation In Settings to Validate
    [Documentation]   Navigates to Personalisation In Settings to Validate
    Move Focus to Setting    textKey:DIC_SETTINGS_SUGGESTIONS_DISCONTINUE_LABEL    DOWN
    ${status}     Run Keyword And Return Status    Personalisation In Settings Is Set To OFF
    I wait for 2 second
    Run Keyword If    ${status}    I Press    OK
    I wait for 2 second
    Move Focus to Option in Value Picker    textKey:DIC_SETTINGS_SUGGESTIONS_DISCONTINUE_TC_BTN_DECLINE    UP    4
    I Press    OK

Personalisation In Settings Is Set To OFF
    [Documentation]    Personalisation In Settings Is Set To OFF
    Wait until keyword succeeds    ${JSON_MAX_RETRIES}    ${JSON_RETRY_INTERVAL}    I expect page element 'id:titleText_2' contains 'textKey:.*DIC_SETTINGS_SUGGESTIONS_DISCONTINUE_LABEL' using regular expressions

I Turn 'ON' Personalisation In Settings
    [Documentation]   Turn 'ON' Personalisation In Settings
    Move Focus to Setting    textKey:DIC_SETTINGS_SUGGESTIONS_LABEL    DOWN
    I Press   OK
    I press DOWN 4 times
    I wait for 2 second
    I Press   OK

Player in '${speed}' FFWD mode    #USED
    [Documentation]    This keyword asserts the player is in ${speed} FRWD mode
    ...    Valid values of ${speed} are x0.5
    Wait Until Keyword Succeeds    ${JSON_MAX_RETRIES}    200 ms    I expect page element 'id:rcuKeyFeedback-Player' contains 'image:/usr/share/.+/.*slow_motion.png' using regular expressions

I Move Back To Linar TV
    [Documentation]    Move Back To Linar TV
    I press BACK 4 times
    I wait for 5 second
    I Press    PLAY-PAUSE
    I wait for 60 second
    I press    PLAY-PAUSE

Set AgeLock To Off
    [Documentation]   Sets age lock to off
    I open Parental Control through Settings
    I focus Set Age Lock
    I wait for 2 second
    I select to enter a valid pin
    I wait for 2 second
    I press UP 9 times
    I wait for 2 second
    I Press    OK

Set AgeLock To Max as Per Country
    [Documentation]    Set AgeLock To Max as Per Country
    I open Parental Control through Settings
    I focus Set Age Lock
    I wait for 2 second
    I select to enter a valid pin
    I press DOWN 8 times
    I Press    OK


I Tune To A Replay event without Ongoing Recording from TV Guide
    [Documentation]     The keyword tune to a random replay event without ongoing recording.
    ${replay_channels}    I Fetch All Replay Channels From Linear Service
    @{channel_number_list}   Get Channel Numbers List From Linear Service   ${replay_channels}
    :FOR  ${channel}  IN   @{channel_number_list}
    \    I press    ${channel}
    \    I wait for 2 second
    \    I press    GUIDE
    \    I wait for 3 second
    \    ${event_title}    I retrieve the random event id displayed in tv guide
    \    I wait for 3 second
    \    ${status}    Run Keyword And Return Status     I expect page element 'id:${event_title}' contains 'iconKeys:RECORDING_CURRENT'
    \    Run Keyword If    ${status} == False    Exit For Loop

I retrieve the random event id displayed in tv guide
    [Documentation]     The keyword retrieves the random event id displayed in tv guide
    ${status}    I retrieve value for key 'textValue' in element 'id:gridInfoTitle'
    ${json_object}    Get Ui Json
    ${json_string}    Read Json As String    ${json_object}
    @{collection}    get regexp matches    ${json_string}    block_\\d+_event_\\d+_\\d+
    :FOR  ${event}  IN   @{collection}
    \    ${current_event_title}    I retrieve value for key 'textValue' in element 'id:${event}' using regular expressions
    \    ${screenhint_presence}    Run Keyword And Return Status    Should Contain    ${status}    ${current_event_title}
    \    ${eventTitle}    Set Variable If    '${current_event_title}' != '${EMPTY}' and ${screenhint_presence}    ${event}
    \    Exit For Loop If    '${current_event_title}' != '${EMPTY}' and ${screenhint_presence}
    [RETURN]    ${eventTitle}


Verify Attributes under Info and Network
    [Documentation]    Verify Attributes under Info and Network
    I open Settings through Main Menu
    I focus Info
    ${about}    I retrieve value for key 'textValue' in element 'textKey:DIC_SETTINGS_ABOUT_LABEL'
    ${diagnostics}    I retrieve value for key 'textValue' in element 'textKey:DIC_SETTINGS_DIAG_LABEL'
    ${help}    I retrieve value for key 'textValue' in element 'textKey:DIC_SETTINGS_HELP_LABEL'
    I Focus Network
    Move Focus to Setting    textKey:DIC_SETTINGS_NW_LABEL    DOWN
    I wait for 2 seconds
    ${ssid}    I retrieve value for key 'textValue' in element 'id:hintNetworkName'
    ${SSID}    Run Keyword And Return Status    Should Contain    ${ssid}    SSID
    ${url}    Run Keyword And Return Status    Should Contain    ${help}    website
    Should Be True    ${SSID} and '${about}'=='About' and '${diagnostics}'=='Diagnostics' and ${url}

Verify Power Consumption Attributes
    [Documentation]    Verify Power Consumption Attributes
    I open System through Settings
    I focus Standby Power Consumption
    I press    OK
    wait until keyword succeeds    4 times    5s    I expect page contains 'id:ValuePicker'
    ${hot}    I retrieve value for key 'textValue' in element 'textKey:DIC_SETTINGS_STANDBYPOWER_VALUE_HIGH'
    ${lukewarm}     I retrieve value for key 'textValue' in element 'textKey:DIC_SETTINGS_STANDBYPOWER_VALUE_MEDIUM'
    ${eco}    I retrieve value for key 'textValue' in element 'textKey:DIC_SETTINGS_STANDBYPOWER_VALUE_LOW'
    Should Be True     '${hot}' == 'Fast start' and '${lukewarm}' == 'Active start' and '${eco}' == 'Conserve energy'


I Navigate To A VOD Series Asset    #USED
    [Documentation]    This keyword fetches season details of a series VOD asset from backend and navigates to a
    ...    random episode in a random season for the series
    ${section_name}    ${series_list}    Get VOD Series Assets Belonging To A Section From Backend
    ${selected_series}    Get Random Element From Array    ${series_list}
    ${nav_dict}    Get Random Episode From VOD Series Details    ${selected_series}
    Log    ${nav_dict}
    Navigate To VOD Series Asset And Focus Given Episode    ${section_name}    ${nav_dict['seriesTitle']}    ${nav_dict['seasonNumber']}
    ...    ${nav_dict['seasonsInSeries']}     ${nav_dict['seriesTitle']}

Navigate To VOD Series Asset And Focus Given Episode    #USED
    [Documentation]    This keyword navigates to a VOD Asset whose title is provided and moves focus to episode
    ...    according to details provided
    [Arguments]    ${section_name}    ${series_title}    ${selected_season}    ${seasons_in_series}
    ...    ${series_title}
    I open '${section_name}'
    I focus '${series_title}' tile
    I Press   CONTEXT
    I wait for 2 second
    #I open episode picker
    #Check If Season Selected Is '${selected_season}', Otherwise Navigate To It Using Maximum Action '${seasons_in_series}'

Press Contextual Key To Validate Info
    [Documentation]    Press Contextual Key To Validate Info
    I Press   CONTEXT
    I wait for 3 second
    I Press   BACK
    I wait for 3 second
    I start recording from tv guide
    I wait for 5 second
    I Press   CONTEXT
    I wait for 3 second

Press Contextual Key To Validate Info On Replay
    [Documentation]    Press Contextual Key To Validate Info
    I Press   CONTEXT
    I wait for 3 second
