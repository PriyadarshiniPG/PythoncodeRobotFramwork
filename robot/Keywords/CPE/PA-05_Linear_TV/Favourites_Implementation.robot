*** Settings ***
Documentation     Favourities implementation
Resource          ../Common/Common.robot
Resource          ../CommonPages/Modal_Implementation.robot
Resource          ../PA-08_Settings/Settings_Implementation.robot
Resource          ../PA-08_Settings/Preferences_Keywords.robot
Resource          ../PA-09_Parental_Control/Locked_Keywords.robot
Resource          ../PA-09_Parental_Control/ParentalControl_Keywords.robot
Resource          ../PA-05_Linear_TV/ChannelInfo_Keywords.robot

*** Keywords ***
I focus Favourite Channels
    [Documentation]    This keyword focuses favourite channels in preferences in settings
    Move Focus to Setting    textKey:DIC_SETTINGS_FAVOURITE_CHANNELS_LABEL    DOWN    8

Manage Favourite channels is shown
    [Documentation]    This keyword asserts manage favourite channels window is shown
    wait until keyword succeeds    ${JSON_MAX_RETRIES}    ${JSON_RETRY_INTERVAL}    I expect page contains 'textKey:DIC_FAVOURITES_HEADER'

Manage Personal Line Up Channel Pop Up Is Shown  #USED
    [Documentation]    This keyword validates the Manage Personal Line up Pop Up after clearng the selected list is displayed
    wait until keyword succeeds    ${JSON_MAX_RETRIES}    ${JSON_RETRY_INTERVAL}    I expect page contains 'textKey:DIC_PROFILES_LIST_EMPTY'

I Focus 'Clear List' In Manage Profile Channel List    #USED
    [Documentation]    This keyword focuses 'Clear List' button in the Manage Profile Channel List modal window
    Move Focus to Button in Interactive Modal    textKey:DIC_MODEL_BUTTON_CLEAR_PROFILES_LIST    DOWN    3

Clear Profile Channels List Confirmation Pop Up Is Shown   #USED
    [Documentation]    This keyword checks Clear Profile Channel list confirmation pop up
    wait until keyword succeeds    ${JSON_MAX_RETRIES}    ${JSON_RETRY_INTERVAL}    I expect page contains 'textKey:DIC_MODEL_HEADER_CLEAR_PROFILES_LIST'

I Choose 'Clear List' On Manage Personal Channels    #USED
    [Documentation]    This keyword removes all the channels from personal line up list and verifies empty personal line up channels list is shown
    I Focus The 'Clear List' Option In Manage Profile Channel List
    I press    OK
    Clear Profile Channels List Confirmation Pop Up Is Shown
    I Focus 'Clear List' In Manage Profile Channel List
    I press    OK
    wait until keyword succeeds    3times    2 sec    Manage Personal Line Up Channel Pop Up Is Shown

Favourite channels list is shown
    [Documentation]    This keyword verifies that favourite channels list is empty
    wait until keyword succeeds    ${JSON_MAX_RETRIES}    ${JSON_RETRY_INTERVAL}    I expect page contains 'id:item-prefix-image-container-0'

I check if '${nth}' channel has favourite icon
    [Documentation]    This keyword returns boolean value stating if a channel has a favourite icon shown next to it on the list
    ${nth}    Evaluate    ${nth}-${1}
    ${json_object}    Get Ui Json
    ${is_marked_favourite}    Is In Json    ${json_object}    id:item-check-icon-${nth}    textValue:B
    [Return]    ${is_marked_favourite}

Make sure that '${nth}' channel is not marked as favourite
    [Documentation]    This keyword asserts that the specified channel is not marked as favourite
    ${is_marked_favourite}    I check if '${nth}' channel has favourite icon
    Run Keyword If    ${is_marked_favourite} == ${True}    I press    OK

Verify if '${nth}' channel is not marked as favourite
    [Documentation]    This keyword asserts that favourite icon is not shown in the specified channel
    ${is_marked_favourite}    I check if '${nth}' channel has favourite icon
    Should Not Be True    ${is_marked_favourite}

Verify if '${nth}' channel is marked as favourite
    [Documentation]    This keyword asserts that favourite icon is shown in the specified channel
    ${is_marked_favourite}    I check if '${nth}' channel has favourite icon
    Should Be True    ${is_marked_favourite}

I mark if channel '${channel_name}' has favourite icon
    [Documentation]    This keyword returns a boolean value that verifies the focused channel has favourite icon
    ${is_marked_favourite}    I verify if the focused channel has favourite icon
    [Return]    ${is_marked_favourite}

Add channel '${channelnumber}' to Favourites list
    [Documentation]    This keyword add channel to favourites list
    wait until keyword succeeds    ${JSON_MAX_RETRIES}    ${JSON_RETRY_INTERVAL}    I expect page element 'id:value-picker' contains 'children:^.+$' using regular expressions
    ${is_locked}    I mark if channel '${channel_number}' has favourite icon
    Run Keyword If    ${is_locked} == ${False}    I press    OK

I add channel to Favourites by number
    [Arguments]    ${channel_number}
    [Documentation]    Precondition : Preference is highlighted
    ...    add channel to favourite list by channel number and it also navigates to the preferences page
    ${channel_name}    lookup channelname for    ${channel_number}
    I focus Favourite Channels
    I Press    OK
    I open 'Add channels' through Favourite channels
    Favourite channels list is shown
    I press    ${channel_number}
    I verify the focused '${channel_number}' is added to the Favourites list
    add channel '${channel_name}' to Favourites list
    I navigate from favourites list to preferences page

I verify the focused '${channel}' is added to the Favourites list      #USED
    [Documentation]    This keyword verifies the focused channel and selected channel is same
    Wait Until Keyword Succeeds    9 times    ${JSON_RETRY_INTERVAL}    I expect page element 'textValue:${channel}' contains 'color:${HIGHLIGHTED_OPTION_COLOUR}'

I navigate from favourites list to preferences page
    [Documentation]    Navigate to preferences page
    : FOR    ${index}    IN RANGE    ${0}    ${3}
    \    I press    BACK
    \    ${status}    run keyword and return status    I expect page contains 'textKey:DIC_MODEL_HEADER_SURF_FAV'
    \    run keyword if    ${status}==${true}    I disable Surf Favourites
    \    ${json_object}    Get Ui Json
    \    ${dynamic_list}    Is In Json    ${json_object}    ${EMPTY}    id:DynamicList.View
    \    Exit For Loop If    "${dynamic_list}" == "False"

I disable Surf Favourites
    [Documentation]    Disables the surfing to favourite channels
    ...    Precondition -> Manage favourite channels screen should be open
    ${status}    run keyword and return status    I expect page contains 'textKey:DIC_MODEL_HEADER_SURF_FAV'
    run keyword if    ${status} == ${false}    I Press    BACK
    wait until keyword succeeds    ${JSON_MAX_RETRIES}    ${JSON_RETRY_INTERVAL}    I expect page contains 'textKey:DIC_MODEL_HEADER_SURF_FAV'
    Move Focus to Button in Modal    textKey:DIC_MODEL_BUTTON2_SURF_ALL    DOWN    3
    I press    OK

I check if Clear list is present
    [Documentation]    This keyword returns boolean value stating if clear list button is shown in manage favourite channels window
    ${json_object}    Get Ui Json
    ${clear_list_present}    Is In Json    ${json_object}    ${EMPTY}    textKey:DIC_FAVOURITES_MENU_CLEAR
    [Return]    ${clear_list_present}

I mark '${channel_with_index}' as favourite
    [Documentation]    This keyword marks the channel as favourite by index
    I focus '${channel_with_index}' channel
    Make sure that '${channel_with_index}' channel is not marked as favourite
    Verify if '${channel_with_index}' channel is not marked as favourite
    I press    OK
    Verify if '${channel_with_index}' channel is marked as favourite
    I press    BACK

I verify if the focused channel has favourite icon
    [Documentation]    This keyword returns a boolean value stating if the focused channel has favourite icon shown in the list
    ${focused_channel_id_digit}    get focused channel id digit from favorites value picker
    ${json_object}    Get Ui Json
    ${is_marked_favourite}    Is In Json    ${json_object}    id:item-check-icon-${focused_channel_id_digit}    textValue:B
    [Return]    ${is_marked_favourite}

get focused channel id digit from favorites value picker
    [Documentation]    This keyword returns an ID digit from the focused channel
    wait until keyword succeeds    ${JSON_MAX_RETRIES}    ${JSON_RETRY_INTERVAL}    I expect page element 'id:value-picker' contains 'children:^.+$' using regular expressions
    &{ancestor}    I retrieve json ancestor of level '2' in element 'id:item-check-icon-\\d+' for element 'color:${HIGHLIGHTED_OPTION_COLOUR}' using regular expressions
    ${id}    Set Variable    ${ancestor['id']}
    @{regexp_match}    Get Regexp Matches    ${id}    item-check-icon-(\\d+)    1
    ${digit}    Set Variable    @{regexp_match}[0]
    [Return]    ${digit}

Clear favourites list via AS and restart UI
    [Documentation]    This keyword clears the favourites list and restarts UI in order to reflect the changes
    Reset Channels    FAVORITE
    Restart UI via command over SSH

I focus Surf Favorite Channels Only
    [Documentation]    This keyword focuses surf favourite channels in preferences in settings
    Move Focus to Setting    textKey:DIC_SETTINGS_FAVOURITE_MODE_LABEL    DOWN    8
