*** Settings ***
Documentation     Favourities keywords
Resource          ../PA-05_Linear_TV/Favourites_Implementation.robot

*** Keywords ***
I open Favourite Channels through Preferences
    [Documentation]    This keyword opens favourite channels through preferences in settings
    I open Profiles through Settings
    I open Favourite Channels list

I open Favourite Channels list
    [Documentation]    This keyword opens favourite channels list
    I focus Favourite Channels
    I Press    OK
    Manage Favourite channels is shown

Favourites channels list is empty
    [Documentation]    This keyword clears the list using the 'Clear list' button then checks if it was successful
    Manage Favourite channels is shown
    ${clear_list_button_present}    I check if Clear list is present
    Run Keyword If    ${clear_list_button_present} == ${True}    I Choose 'Clear List' On Manage Personal Channels
    wait until keyword succeeds    3times    2 sec    Manage Personal Line Up Channel Pop Up Is Shown
    I press    BACK
    'PROFILES' is shown in Section Navigation

I focus '${nth}' channel
    [Documentation]    This keyword focuses nth channel on the list of channels in favourites modal window
    ${nth}    Evaluate    ${nth}-${1}
    Move Focus to Option in Value Picker    id:picker-item-text-${nth}    DOWN    30

I add '${number_of}' channels as Favourites
    [Documentation]    Add channel to favourites list and asserts manage favourite channels window is shown and it also
    ...    navigates to the preferences page
    I open Favourite Channels list
    : FOR    ${channel_with_index}    IN RANGE    ${1}    ${number_of}+${1}
    \    I open 'Add channels' through Favourite channels
    \    Favourite channels list is shown
    \    I mark '${channel_with_index}' as favourite
    \    Manage Favourite channels is shown
    I navigate from favourites list to preferences page

I Clear Favourites channel list
    [Documentation]    This keyword clears Favourites channel list and returns to Preference page
    I open Favourite Channels through Preferences
    ${clear_list_button_present}    I check if Clear list is present
    Run Keyword If    ${clear_list_button_present} == ${True}    I Choose 'Clear List' On Manage Personal Channels
    I press    BACK

Clear Favourites channel list in teardown
    [Documentation]    This keyword clears Favourites channel list first through UI and then through AppService if fails
    [Timeout]    10 minutes
    run keyword if test failed    Capture screenshot and json
    ${status}    run keyword and return status    I Clear Favourites channel list
    run keyword unless    ${status}    Clear favourites list via AS and restart UI

I add channel to Favourites by LCN
    [Arguments]    ${lcn}
    [Documentation]    This keyword adds a channel to favourites list by number
    ...    Precondition : Preference is highlighted
    I add channel to Favourites by number    ${lcn}

I choose unfavourite channel
    [Documentation]    This keyword tunes to unfavourite channel
    I tune to channel    ${SD2_CHANNEL}

Favourite indicator shown in guide for the highlighted event
    [Documentation]    This keyword verifies if the favourite icon/indicator is shown for the current highlighted event in guide
    &{event}    Get Focused Guide Programme Cell Details
    @{match}    Get Regexp Matches    &{event}[event_id]    (block_\\d+_event_\\d+_)(\\d+)    1
    ${replaced}    Replace String Using Regexp    @{match}[0]    block_\\d    block_1
    ${replaced}    Replace String Using Regexp    ${replaced}    event    channel
    @{event_id}    split string from right    ${replaced}    _    1
    ${event_id}    catenate    SEPARATOR=    @{event_id}[0]    _    favIcon
    I expect page element 'id:${event_id}' contains 'iconKeys:FAVOURITE'

Favorite indicator not shown in guide for the highlighted event
    [Documentation]    This keyword verifies if the favourite icon/indicator is not shown for the current highlighted event in guide
    ${status}    run keyword and return status    Favourite indicator shown in guide for the highlighted event
    should not be true    ${status}    Favourite indicator not shown in guide for the highlighted event

I add 3 channels to Favourites
    [Documentation]    This keyword adds 3 channels to favourites
    I Clear Favourites channel list
    I add channel to Favourites by LCN    5
    I add channel to Favourites by LCN    7
    I add channel to Favourites by LCN    6

I turn favourite channel mode
    [Documentation]    This keyword verifies to Enable Surf favourite channels only and verify the ON/OFF for favourite channel
    I open Profiles through Settings
    I focus Surf Favorite Channels Only
    ${id}    I retrieve value for key 'id' in element 'textKey:DIC_SETTINGS_FAVOURITE_MODE_LABEL'
    @{key}    Split String From Right    ${id}    _    1
    ${new_id}    set variable    settingFieldValueText_@{key}[1]
    ${status}    run keyword and return status    I expect page element 'id:${new_id}' contains 'textKey:DIC_SETTINGS_OPTION_ON'
    run keyword unless    ${status}    I Press    OK
    Wait Until Keyword Succeeds    ${JSON_MAX_RETRIES}    ${JSON_RETRY_INTERVAL}    I expect page element 'id:${new_id}' contains 'textKey:DIC_SETTINGS_OPTION_ON'
    I Press    BACK

Favourite mode is off
    [Documentation]    This keyword verifies that the favourite icon is not shown on the Channel Banner
    I open Channel Bar
    wait until keyword succeeds    5times    7s    I do not expect page element 'id:RcuCue' contains 'textKey:DIC_RC_CUE_SURFING_FAVORITES'

I see all the favorite channels in the fast channel list
    [Arguments]    ${favorite_channel_count}
    [Documentation]    This keyword verifies that all the favourite channels shown in the channel bar matches with fast channel list
    : FOR    ${index}    IN RANGE    ${favorite_channel_count}
    \    I Press    CHANNELUP
    \    I open Channel Bar
    \    wait until keyword succeeds    5times    3s    I expect page element 'id:RcuCue' contains 'textKey:DIC_RC_CUE_SURFING_FAVORITES'

Favourites Channel list numbers are sorted from 1 to 3
    [Documentation]    This keyword verifies that the favourites list is populated with channels from 1 to 3
    : FOR    ${list_id}    IN RANGE    3
    \    ${json_object}    Get Ui Json
    \    ${id_prefix_text_json}    Get Enclosing Json    ${json_object}    id:dynamicListItem-${list_id}    id:prefixText    ${1}
    \    ${channel_number_used}    Set Variable    ${id_prefix_text_json['textValue']}
    \    Should Be Equal As Integers    ${list_id+1}    ${channel_number_used}    Channel number does not match!

I add 3 replay event channels to Favourites
    [Documentation]    This keyword clears the favourites list and adds 3 replay channels to the list
    I Clear Favourites channel list
    I add channel to Favourites by LCN    ${REPLAY_SERIES_CHANNEL}
    I add channel to Favourites by LCN    ${UNLOCKED_CHANNEL_WITH_REPLAY_EVENTS}
    I add channel to Favourites by LCN    ${REPLAY_EVENTS_CHANNEL}
