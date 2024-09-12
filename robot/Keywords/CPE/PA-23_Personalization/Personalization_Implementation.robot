*** Settings ***
Documentation     Personalization keywords
Resource          ../Common/Common.robot
Resource          ../CommonPages/ValuePicker_Implementation.robot
Resource          ../CommonPages/Modal_Implementation.robot
Resource          ../PA-15_VOD/Saved_Keywords.robot
Library           String
Library           Libraries.MicroServices.PersonalizationService
Library           Libraries.MicroServices.WatchlistService

*** Variables ***
&{PROFILE_COLORS_DICTIONARY}    GREEN=4dd840ff    RED=ff001fff    BLUE=3223ffff    ORANGE=ff6d00ff    PURPLE=a527ffff    BABY_BLUE=4bc0ffff
&{GENRES_POSITION_DICTIONARY}    Action=(0,0)    Comedy=(0,1)    Drama=(0,2)    Romance=(0,3)    Thrillers=(1,0)    Sports=(1,1)    News=(1,2)
...               Kids=(1,3)    GameShows=(2,0)    Music=(2,1)    Reality=(2,2)    Travel=(2,3)
&{GENRES_ICON_DICTIONARY}    ɏ=Action    ɍ=Comedy    Ɋ=Drama    ɂ=Romance    Ⱦ=Thrillers    ɀ=Sports    Ʉ=News
...               Ʌ=Kids    ɇ=GameShows    Ɍ=Music    Ƀ=Reality    Ƚ=Travel

*** Keywords ***
Watchlist is not empty
    [Documentation]    This keyword verifies the Watchlist is not empty
    wait until keyword succeeds    ${JSON_MAX_RETRIES}    ${JSON_RETRY_INTERVAL}    I expect page contains 'id:.*CollectionsBrowser' using regular expressions

Focused asset is replay
    [Documentation]    This keyword verifies if the focused asset is a Replay asset
    I expect page element 'id:shared-CollectionsBrowser_collection_\\d+_focusRectangle_\\d+_secondaryTitle' contains 'iconKeys:REPLAY' using regular expressions

I focus VOD tile
    [Documentation]    This keyword focuses the first asset tile in the Watchlist
    I focus the first asset in the Watchlist

'New' profile icon is shown
    [Documentation]    This keyword verifies the 'New' profile icon is shown
    wait until keyword succeeds    ${JSON_MAX_RETRIES}    ${JSON_RETRY_INTERVAL}    I expect page element 'id:profileList' contains 'textKey:DIC_PROFILES_NEW'
    ${new_profile_icon_is_present}    Is In Json    ${LAST_FETCHED_JSON_OBJECT}    textValue:V    textValue:Đ    ${EMPTY}
    should be true    ${new_profile_icon_is_present}    New profile icon is not shown

Any profile color is focused
    [Documentation]    This keyword verifies that any one of the available profile colors in
    ...    the profile creation menu is focused, and saves the hex color code in the ${SELECTED_COLOR} variable.
    ${children}    I retrieve value for key 'children' in element 'id:profileColorContainer'
    ${result}    Is In Json    ${children}    textValue:ǥ    iconKeys:PROFILE
    should be true    ${result}    No profile color available
    ${selected_profile}    Get Enclosing Json    ${children}    textValue:ǥ    iconKeys:PROFILE    ${1}
    ${PROFILE_COLOR}    Extract Value For Key    ${selected_profile}    textStyle:    color
    set suite variable    ${PROFILE_COLOR}

I choose '${name}' as a profile name    #USED
    [Documentation]    This keyword focuses the name input box in the profile creation menu and types the given ${name},
    ...    saving it in the ${PROFILE_NAME} variable.
    Move to element assert focused elements    id:ProfileNameInputField    5    DOWN
    set suite variable    ${PROFILE_NAME}    ${name}
    I type "${PROFILE_NAME}" on the Virtual Keyboard
    I press 'Go' on the Virtual Keyboard

Interactive modal with options 'Set up my channels' and 'Skip' is shown    #USED
    [Documentation]    This keyword verifies the modal menu with options 'Set up my channels' and 'Skip' is shown.
    wait until keyword succeeds    ${JSON_MAX_RETRIES}    ${JSON_RETRY_INTERVAL}    I expect page element 'id:title-ProfileWizard' contains 'textKey:DIC_CREATE_CHANNEL_LIST_TITLE'
    ${setup_channels_is_present}    Is In Json    ${LAST_FETCHED_JSON_OBJECT}    id:CHANNEL_LIST@ProfilesWizardSteps    textKey:DIC_CREATE_CHANNEL_LIST_BUTTON    ${EMPTY}
    ${skip_button_is_present}    Is In Json    ${LAST_FETCHED_JSON_OBJECT}    id:CHANNEL_LIST@ProfilesWizardSteps    textKey:DIC_GENERIC_BTN_SKIP    ${EMPTY}
    should be true    ${setup_channels_is_present}    'Set up my channels' options not shown
    should be true    ${skip_button_is_present}    'Skip' option not shown

'Skip' option is shown
    [Documentation]    This keyword verifies the 'Skip' option is shown.
    wait until keyword succeeds    ${JSON_MAX_RETRIES}    ${JSON_RETRY_INTERVAL}    I expect page contains 'textKey:DIC_GENERIC_BTN_SKIP'

I focus the 'Skip' option
    [Documentation]    This keyword focuses the 'Skip' option in a modal menu.
    'Skip' option is shown
    Move Focus to Button in Modal    textKey:DIC_GENERIC_BTN_SKIP    DOWN    5

'Skip' option is focused
    [Documentation]    This keyword verifies the 'Skip' option is focused in a modal menu.
    Button is Focused in Modal    textKey:DIC_GENERIC_BTN_SKIP

'Choose your preferred genres' interactive modal is shown    #USED
    [Documentation]    This keyword verifies the modal menu with genre preference tiles and the 'Skip' option is shown.
    wait until keyword succeeds    ${JSON_MAX_RETRIES}    ${JSON_RETRY_INTERVAL}    I expect page element 'id:title-ProfileWizard' contains 'textKey:DIC_GENRE_SELECT_TITLE'
    ${genre_tiles_are_present}    Is In Json    ${LAST_FETCHED_JSON_OBJECT}    id:GENRE_PICKER@ProfilesWizardSteps    id:genreGridContainer    ${EMPTY}
    ${skip_button_is_present}    Is In Json    ${LAST_FETCHED_JSON_OBJECT}    id:GENRE_PICKER@ProfilesWizardSteps    textKey:DIC_GENERIC_BTN_SKIP    ${EMPTY}
    ${end_button_is_present}    Is In Json    ${LAST_FETCHED_JSON_OBJECT}    id:GENRE_PICKER@ProfilesWizardSteps    textKey:DIC_GENERIC_BTN_FINISH    ${EMPTY}
    should be true    ${genre_tiles_are_present}    Genre tiles are not shown
    should be true    ${skip_button_is_present} or ${end_button_is_present}    'Skip/End' option not shown

'Choose your preferred genres' interactive modal is not shown   #USED
    [Documentation]    This keyword verifies the modal menu with the 'Choose your preferred genres' title is not shown.
    wait until keyword succeeds    10x    1s    I do not expect page element 'id:title-ProfileWizard' contains 'textKey:DIC_GENRE_SELECT_TITLE'

Get numeric values from list
    [Arguments]    @{argument_list}
    [Documentation]    This keyword returns the numeric values contained in the given list.
    ...    The argument list is traversed separating the integer and string values. The integer values are saved in an
    ...    additional list that is returned.
    @{digit_list}    Create List
    : FOR    ${element}    IN    @{argument_list}
    \    run keyword if    '${element}'.isdigit()    Append To List    ${digit_list}    ${element}
    [Return]    @{digit_list}

Get string values from list
    [Arguments]    @{argument_list}
    [Documentation]    This keyword returns the string values contained in the given list.
    ...    The argument list is traversed separating the integer and string values. The string values are saved in an
    ...    additional list that is returned.
    @{string_list}    Create List
    : FOR    ${element}    IN    @{argument_list}
    \    run keyword if    not '${element}'.isdigit()    Append To List    ${string_list}    ${element}
    [Return]    @{string_list}

I select my personal channel lineup in the 'Create a personal channel list' modal menu
    [Arguments]    @{favorite_channels}
    [Documentation]    This keyword selects the channel LCN saved in the @{favorite_channels} argument and
    ...    continues with the profile creation.
    Interactive modal with options 'Set up my channels' and 'Skip' is shown
    I select the 'Set up my channels' option in the 'Create a personal channel list' modal menu
    Favorite channel selection modal is shown
    : FOR    ${channel}    IN    @{favorite_channels}
    \    I press    ${channel}
    \    I verify the focused '${channel}' is added to the Favourites list
    \    I press    OK
    set test variable    @{FAVOURITE_CHANNEL_LIST}    @{favorite_channels}
    I press    BACK
    'Manage profile channels list' interactive modal is shown
    wait until keyword succeeds    ${JSON_MAX_RETRIES}    ${JSON_RETRY_INTERVAL}    I expect focused elements contains 'textKey:DIC_GENERIC_BTN_CONFIRM'
    I press    OK

I select my preferred genre tiles in the 'Choose your preferred genres' modal menu
    [Arguments]    @{preferred_genres}
    [Documentation]    This keyword selects the genre tiles saved in the @{preferred_genres} argument and selects the
    ...    'End' option in the 'Choose your preferred genres' modal menu.
    ...    Profile creation usually takes a while, so we wait until the modal menu is dismissed afterwards.
    'Choose your preferred genres' interactive modal is shown
    : FOR    ${genre}    IN    @{preferred_genres}
    \    ${current_position}    Get position of the currently focused preferred genres tile
    \    ${position}    get from dictionary    ${GENRES_POSITION_DICTIONARY}    ${genre}
    \    ${row_diff}    evaluate    ${current_position}[0] - ${position}[0]
    \    ${column_diff}    evaluate    ${current_position}[1] - ${position}[1]
    \    ${horizontal_key}    set variable if    ${column_diff} < 0    RIGHT    LEFT
    \    ${vertical_key}    set variable if    ${row_diff} < 0    DOWN    UP
    \    ${row_diff}    evaluate    abs(${row_diff})
    \    ${column_diff}    evaluate    abs(${column_diff})
    \    Iterate keyboard ${row_diff} times in ${vertical_key} direction
    \    Iterate keyboard ${column_diff} times in ${horizontal_key} direction
    \    I press    OK
    I focus the 'End' option
    I press    OK
    'Choose your preferred genres' interactive modal is not shown

Get position of the currently focused preferred genres tile
    [Documentation]    This keyword returns the position of the currently focused tile in the
    ...    'Choose your preferred genres' modal menu. If the 'Skip' or 'End' options are focused instead, the focus is
    ...    moved up once first.
    ${skip_is_focused}    run keyword and return status    'Skip' option is focused
    ${end_is_focused}    run keyword and return status    'End' option is focused
    run keyword if    ${skip_is_focused} or ${end_is_focused}    I press    UP
    ${genre_grid}    I retrieve value for key 'children' in element 'id:genreGridContainer'
    ${genre_tile}    Get Enclosing Json    ${genre_grid}    image:/usr/share/lgioui/img/shared_components/roundCorners_20.png    color:${INTERACTION_COLOUR}    ${2}
    ${genre_symbol}    Extract Value For Key    ${genre_tile}    textValue:^[ɏɍɊɂȾɀɄɅɇɌɃȽ]$    textValue    ${True}
    ${genre_name}    get from dictionary    ${GENRES_ICON_DICTIONARY}    ${genre_symbol}
    ${current_position}    get from dictionary    ${GENRES_POSITION_DICTIONARY}    ${genre_name}
    [Return]    ${current_position}

'End' option is shown
    [Documentation]    This keyword verifies the 'End' option is shown.
    wait until keyword succeeds    ${JSON_MAX_RETRIES}    ${JSON_RETRY_INTERVAL}    I expect page contains 'textKey:DIC_GENERIC_BTN_FINISH'

I focus the 'End' option
    [Documentation]    This keyword focuses the 'End' option in a modal menu.
    'End' option is shown
    Move Focus to Button in Modal    textKey:DIC_GENERIC_BTN_FINISH    DOWN    5

'End' option is focused
    [Documentation]    This keyword verifies the 'End' option is focused in a modal menu.
    Button is Focused in Modal    textKey:DIC_GENERIC_BTN_FINISH

I focus the Active profile
    [Documentation]    This keyword verifies the profile selection menu is shown, verifies
    ...    the Active profile is being shown and focuses it. It also returns the json node id of the Active profile.
    ...    Precondition: Profile selection menu should be open.
    ${profile_indicator_children}    I retrieve value for key 'children' in element 'id:profileIndicator'
    ${active_profile_name}    Extract Value For Key    ${profile_indicator_children}    ${EMPTY}    textValue
    ${active_profile_color}    Extract Value For Key    ${profile_indicator_children}    textValue:ǥ    color
    ${profile_items}    Extract Value For Key    ${LAST_FETCHED_JSON_OBJECT}    id:profileList    children
    ${active_profile_node}    Get Enclosing Json    ${profile_items}    id:profileItem-\\d+    textValue:${active_profile_name}    ${2}    ${EMPTY}
    ...    ${True}
    ${equals_active_profile_color}    Is In Json    ${active_profile_node}    ${EMPTY}    color:${active_profile_color}
    should be true    ${equals_active_profile_color}    Active profile could not be found
    ${active_profile_id}    Extract Value For Key    ${active_profile_node}    ${EMPTY}    id    ${True}
    Move to element assert focused elements    id:${active_profile_id}    10    RIGHT
    [Return]    ${active_profile_id}

I select the Edit option on the Active profile
    [Documentation]    This keyword focuses the Active profile, moves down to focus the edit button below,
    ...    verifies an edit button is in focus and selects the profile edit button.
    ...    Precondition: Profile selection menu should be open.
    ${active_profile_id}    I focus the Active profile
    Move to element assert focused elements    id:profileEditBtn-${active_profile_id}    3    DOWN
    I press    OK

'Delete' option is shown
    [Documentation]    This keyword verifies the 'Delete' option is shown.
    wait until keyword succeeds    ${JSON_MAX_RETRIES}    ${JSON_RETRY_INTERVAL}    I expect page contains 'textKey:DIC_BUTTON_DELETE'

I focus the 'Delete' option
    [Documentation]    This keyword focuses the 'Delete' option in a modal menu.
    ...    Precondition: Profile deletion modal should be open.
    'Delete' option is shown
    Move Focus to Button in Modal    textKey:DIC_BUTTON_DELETE    DOWN    5

I select the 'Delete' option    #USED
    [Documentation]    This keyword focuses the 'Delete' option and selects it.
    ...    Precondition: Profile deletion modal should be open.
    I focus the 'Delete' option
    I press    OK

'Delete profile' interactive modal is shown    #USED
    [Documentation]    This keyword verifies the 'Delete profile' interactive modal menu
    ...    with 'Confirm' and 'Cancel' options is shown.
    wait until keyword succeeds    10s    1s    I expect page element 'id:interactiveModalPopup' contains 'textKey:DIC_DELETE_PROFILE_TITLE'
    ${confirm_button_is_present}    Is In Json    ${LAST_FETCHED_JSON_OBJECT}    id:interactiveModalPopup    textKey:DIC_GENERIC_BTN_CONFIRM    ${EMPTY}
    ${cancel_button_is_present}    Is In Json    ${LAST_FETCHED_JSON_OBJECT}    id:interactiveModalPopup    textKey:DIC_GENERIC_BTN_CANCEL    ${EMPTY}
    should be true    ${confirm_button_is_present}    'Confirm' option is not shown
    should be true    ${cancel_button_is_present}    'Cancel' option is not shown

'Delete profile' interactive modal is not shown     #USED
    [Documentation]    This keyword verifies the 'Delete profile' interactive modal menu is not shown.
    wait until keyword succeeds    10x    1s    I do not expect page element 'id:interactiveModalPopup' contains 'textKey:DIC_DELETE_PROFILE_TITLE'

'Confirm' option is shown
    [Documentation]    This keyword verifies the 'Confirm' option is shown.
    wait until keyword succeeds    ${JSON_MAX_RETRIES}    ${JSON_RETRY_INTERVAL}    I expect page contains 'textKey:DIC_GENERIC_BTN_CONFIRM'

I focus the 'Confirm' option
    [Documentation]    This keyword verifies the 'Confirm' option is present, then focuses it.
    'Confirm' option is shown
    Move Focus to Button in Modal    textKey:DIC_GENERIC_BTN_CONFIRM    UP    5

I select the 'Confirm' option in the 'Delete profile' modal menu    #USED
    [Documentation]    This keyword verifies the correct modal is being shown, focuses the 'Confirm' option
    ...    and selects it. Profile deletion sometimes takes a while, so we wait until the
    ...    modal menu is dismissed afterwards.
    ...    Precondition: 'Delete profile' modal should be open.
    'Delete profile' interactive modal is shown
    I focus the 'Confirm' option
    I press    OK
    'Delete profile' interactive modal is not shown
    I wait for 3 second

Created profile is not shown in the profile selection menu
    [Documentation]    This keyword verifies that the last created profile (the one with name ${PROFILE_NAME}
    ...    and color ${PROFILE_COLOR}) is not shown in the profile selection menu.
    ${status}    run keyword and return status    Created profile icon is shown
    should not be true    ${status}    Last created profile is shown

'Deleted profile' toast message is shown
    [Documentation]    This keyword verifies the 'Deleted profile' toast message is shown.
    Wait Until Keyword Succeeds    ${TOAST_MSG_MAX_WAIT_TIME}    0.1s    I expect page element 'id:toast.message' contains 'textKey:DIC_PROFILE_DELETE_TOAST_MESSAGE'

I focus the '${color_name}' profile color    #USED
    [Documentation]    This keyword verifies that the color ${color_name} is present in the &{PROFILE_COLORS_DICTIONARY}
    ...    dictionary, then focuses it if the color is available in the profile creation menu.
    Verify '${color_name}' is not in use
    ${color_code}    Get From Dictionary    ${PROFILE_COLORS_DICTIONARY}    ${color_name}
    : FOR    ${_}    IN RANGE    ${8}
    \    I wait for ${MOVE_ANIMATION_DELAY} ms
    \    ${ancestor}    I retrieve json ancestor of level '2' for element 'color:\#${color_code}'
    \    ${color_is_focused}    Is In Json    ${ancestor}    textValue:ǥ    opacity:255
    \    exit for loop if    ${color_is_focused}
    \    I Press    RIGHT
    '${color_name}' profile color is focused
    Set Suite Variable    ${FOCUSED_COLOR_CODE}   ${color_code}

'${color_name}' profile color is focused    #USED
    [Documentation]    This keyword verifies that the ${color_name} profile color in
    ...    the profile creation menu is focused, and saves the hex color code in the ${PROFILE_COLOR} variable.
    ${color_code}    Get From Dictionary    ${PROFILE_COLORS_DICTIONARY}    ${color_name}
    ${ancestor}    I retrieve json ancestor of level '2' for element 'color:\#${color_code}'
    ${result}    Is In Json    ${ancestor}    textValue:ǥ    opacity:255
    should be true    ${result}    Selected color '${color_name}' is not focused
    set suite variable    ${PROFILE_COLOR}    \#${color_code}

Verify '${color_name}' is not in use        #USED
    [Documentation]    This keyword verifies that the given ${color_name} color is not in use by checking
    ...    the color of the active profile and the profile selection menu.
    ...    Precondition: Profile selection menu should be open.
    ${color_code}    Get From Dictionary    ${PROFILE_COLORS_DICTIONARY}    ${color_name}
    ${json_object}    Get Ui Json
    ${is_already_created}    Is In Json    ${json_object}    id:profileItem-\\d    color:\#${color_code}    ${EMPTY}    ${True}
    ${is_active_profile}    Is In Json    ${json_object}    id:profileIndicatorIcon    color:\#${color_code}
    Should not be true    ${is_already_created} or ${is_active_profile}    Profile color '${color_name}' is already in use

Verify User Cannot Select Empty Profile Color       #USED
    [Documentation]    This keyword verifies that profile color cannot be left empty during the profile creation
    ...    Precondition: Create Profile menu should be open.
    Wait Until Keyword Succeeds    ${JSON_MAX_RETRIES}    ${JSON_RETRY_INTERVAL}    I expect page contains 'textKey:DIC_CREATE_PROFILE_TITLE'
    ${json_object}    Get Ui Json
    ${number_of_profiles}    I Get The Number Of Custom Profiles
    : FOR    ${i}    IN RANGE    1    ${number_of_profiles} + 1
    \    ${extracted_color}    Extract Value For Key    ${json_object}    id:profileItem-${i}    color
    \    Should Not Be Equal    ${extracted_color}    None   The extracted color for id:profileItem-${i} is None or id:profileItem-${i} is not present in the UI state    False

'Set up my channels' option is shown
    [Documentation]    This keyword verifies the 'Set up my channels' option is shown.
    wait until keyword succeeds    ${JSON_MAX_RETRIES}    ${JSON_RETRY_INTERVAL}    I expect page contains 'textKey:DIC_CREATE_CHANNEL_LIST_BUTTON'

I focus the 'Set up my channels' option
    [Documentation]    This keyword focuses the 'Set up my channels' option in a modal menu.
    'Set up my channels' option is shown
    Move to element assert focused elements    textKey:DIC_CREATE_CHANNEL_LIST_BUTTON    4    UP

I select the 'Set up my channels' option in the 'Create a personal channel list' modal menu    #USED
    [Documentation]    This keyword verifies the correct modal is being shown, focuses the 'Set up my channels' option and selects it.
    Interactive modal with options 'Set up my channels' and 'Skip' is shown
    I focus the 'Set up my channels' option
    I press    OK

Favorite channel selection modal is shown   #USED
    [Documentation]    This keyword verifies the favorite channel selection modal is shown
    wait until keyword succeeds    ${JSON_MAX_RETRIES}    ${JSON_RETRY_INTERVAL}    I expect page contains 'id:Default.ValuePicker'
    ${select_channels_present}    Is In Json    ${LAST_FETCHED_JSON_OBJECT}    id:Default.ValuePicker    textKey:DIC_CHANNEL_PICKER_DESELECT_ALL
    should be true    ${select_channels_present}    Favorite channel selection modal is not visible

'Manage profile channels list' interactive modal is shown
    [Documentation]    This keyword verifies the personal channel line up management list is shown
    wait until keyword succeeds    ${JSON_MAX_RETRIES}    ${JSON_RETRY_INTERVAL}    I expect page contains 'id:DynamicList.View'
    ${manage_channels_present}    Is In Json    ${LAST_FETCHED_JSON_OBJECT}    id:dynamicListTitle    textKey:DIC_PROFILES_HEADER
    should be true    ${manage_channels_present}    Profile channel management list is not visible

Reset profiles
    [Documentation]    This keyword deletes all custom profiles via application services
    reset profiles via as    ${STB_IP}    ${CPE_ID}    xap=${XAP}

Create a profile via AS
    [Arguments]    ${name}=TEST    ${color_name}=GREEN    @{channel_lineup}
    [Documentation]    This keyword creates a profile via application services with the provided arguments.
    ...    Precondition: The color name provided must be defined in the PROFILE_COLORS_DICTIONARY dictionary.
    ...    and returns the created profile id
    dictionary should contain key    ${PROFILE_COLORS_DICTIONARY}    ${color_name}    Provided color '${color_name}' is not a possible profile color
    ${profile_id}    add profile via as    ${STB_IP}    ${CPE_ID}    ${name}    ${color_name}    ${channel_lineup}
    ...    xap=${XAP}
    [Return]    ${profile_id}

I get recently added VOD title from the watchlist
    [Documentation]    This keyword focuses the tile with name ${TITLE_TITLE} and extracts the title name
    ...    Precondition: ${TILE_TITLE} variable must exist in this scope.
    Variable should exist    ${TILE_TITLE}    The title of a VOD asset tile has not been saved. TILE_TITLE does not exist.
    I focus '${TILE_TITLE}' tile
    ${watchlist_movie_title}    Get Focused Tile    title
    [Return]    ${watchlist_movie_title}

Clear the profile name input field content    #USED
    [Documentation]    This keyword will clear the existing profile name
    ...    Precondition: Virtual Keyboard should be shown
    Virtual Keyboard is shown
    ${clear_content}    I retrieve value for key 'textValue' in element 'id:ProfileNameInputField'
    ${length_of_content}    get length    ${clear_content}
    repeat keyword    ${length_of_content}    I press 'BACKSPACE' on the Virtual Keyboard
    ${clear_content}    I retrieve value for key 'textValue' in element 'id:ProfileNameInputField'
    Run Keyword If    '${clear_content}'=='${EMPTY}'    I focus 'G' on the Virtual Keyboard

Add channels to the personal line-up    #USED
    [Arguments]    ${channel_list}
    [Documentation]    This keyword adds the given channels to the active personal profile
    ...    Precondition: The active profile must be a personal profile not the shared profile
    I open Profiles through Settings
    I open Manage channels
    wait until keyword succeeds    5 times    300 ms    I expect focused elements contains 'textKey:DIC_PROFILE_LINEUP_ADD_CHANNELS'
    I press    OK
    wait until keyword succeeds    3 times    300 ms    I expect page contains 'textKey:DIC_CHANNEL_PICKER_DESELECT_ALL'
    : FOR    ${channel}    IN    @{channel_list}
    \    I press    ${channel}
    \    I wait for 2 seconds
    \    I verify the focused '${channel}' is added to the Favourites list
    \    I wait for 2 seconds
    \    I press    OK
    \    I wait for 5 seconds
    \    ${status}    Run Keyword And Return Status    Wait Until Keyword Succeeds    10 times    500 ms    Make sure that personal line-up icon is shown for the channel    ${channel}
    \    Run Keyword Unless    ${status}    Run Keywords     I Press    OK    AND    I wait for 5 seconds
    \    ...    AND    Wait Until Keyword Succeeds    5 times    500 ms    Make sure that personal line-up icon is shown for the channel    ${channel}
    I press    BACK
    wait until keyword succeeds    5 times    200 ms    I expect focused elements contains 'textKey:DIC_GENERIC_BTN_CONFIRM'
    I press    OK

I verify currently tuned channel is the last channel in the personal line-up    #USED
    [Arguments]    ${personal_channel_list}
    [Documentation]    This keyword confirms that the last channel from personal channel list, ${personal_channel_list} is tuned.
    ${last_channel_number}    get from list    ${personal_channel_list}    -1
    ${channel_id}    get main session ref id via vldms    ${STB_IP}    ${CPE_ID}
    Log   VLDMS - Current channel_id: ${channel_id}
    Should Not Be Empty    ${channel_id}    Not able to retrieve channel id of the focused channel from channel bar
    ${current_channel}    get channel lcn for channel id    ${channel_id}
    should be equal    ${last_channel_number}    ${current_channel}    Not tuned to last channel in the personal line-up

Check that '${profile_name}' profile is created on BO    #USED
    [Documentation]    This keyword checks that ${profile_name} profile is created on BO.
    @{customer_profile}    get available profiles name Via Personalization Service    ${LAB_CONF}    ${CUSTOMER_ID}
    List Should contain Value    ${customer_profile}    ${profile_name}    Profile '${profile_name}' was not created.

Make sure that personal line-up icon is shown for the channel
    [Arguments]    ${channel}
    [Documentation]    This keyword verifies if the personal line-up icon is shown for the given channel
    ...    Precondition: 'Add channels' selection pop-up must be present
    ${ancestor}    I retrieve json ancestor of level '2' in element 'id:item-prefix-text-\\\d+' for element 'textValue:${channel}$' using regular expressions
    ${result}    Is In Json    ${ancestor}    id:item-check-icon-\\d+    iconKeys:MANAGE_FAVOURITE    ${EMPTY}    ${True}
    should be true    ${result}    The personal line-up icon is not shown for the channel ${channel}

Get Channel Name List From Linear Service    #USED
    [Arguments]    ${channel_id_list}
    [Documentation]    This keyword retrieves the channel names from ${channel_id_list}
    ...    returns ${channel_name_list}
    @{channel_name_list}    Create List
    : FOR    ${channel_id}    IN    @{channel_id_list}
    \    ${channel_name}    Get Channel Name For Channel Id    ${channel_id}
    \    Append To List    ${channel_name_list}    ${channel_name}
    [Return]    ${channel_name_list}

Get Channel Numbers List From Linear Service    #USED
    [Arguments]    ${channel_id_list}
    [Documentation]    This keyword retrieves the channel numbers from ${channel_id_list}
    ...    returns ${channel_number_list}
    @{channel_number_list}    Create List
    : FOR    ${channel_id}    IN    @{channel_id_list}
    \    ${channel_number}    get channel lcn for channel id    ${channel_id}
    \    append to list    ${channel_number_list}    ${channel_number}
    [Return]    ${channel_number_list}

Get channel names list from
    [Arguments]    ${channel_number_list}
    [Documentation]    This keyword retrieves the channel names from ${channel_number_list}
    ...    returns ${channel_name_list}
    @{channel_name_list}    Create List
    : FOR    ${channel_number}    IN    @{channel_number_list}
    \    ${channel_names}    lookup channelname for    ${channel_number}
    \    append to list    ${channel_name_list}    ${channel_names}
    [Return]    ${channel_name_list}

I Get Channel Names From Manage Channels    #USED
    [Documentation]    This keyword retrieves the channel names of the channels listed in Manage Channels page and returns the list of names in UI
    @{channel_name_list_from_ui}    Create List
    ${tiles_container_data}    I retrieve value for key 'data' in focused element 'id:DynamicList'
    Log   ${tiles_container_data}
    : FOR    ${ui_channel_names}    IN    @{tiles_container_data}
    \    append to list    ${channel_name_list_from_ui}    ${ui_channel_names['title']}
    [Return]   ${channel_name_list_from_ui}

Lookup channel list for
    [Arguments]    ${number_of_channels}
    [Documentation]    Returns ${channel_number_list} for ${number_of_channels}.
    ${channel_number_list}    set variable if    ${number_of_channels} == 3    ${PROFILE_3_CHANNEL_LIST}    ${number_of_channels} == 5    ${PROFILE_5_CHANNEL_LIST}
    [Return]    ${channel_number_list}

I get recently added replay title from the watchlist
    [Documentation]    This keyword focuses the tile with name ${REPLAY_TILE_TITLE} and extracts the title name
    ...    Precondition: ${REPLAY_TILE_TITLE} variable should exist. Watchlist screen should be opened.
    Variable should exist    ${REPLAY_TILE_TITLE}    The title of a replay asset tile has not been saved. REPLAY_TILE_TITLE does not exist.
    I focus '${REPLAY_TILE_TITLE}' tile
    ${watchlist_replay_title}    Get Focused Tile    title
    should not be empty    ${watchlist_replay_title}    A replay asset with the title ${REPLAY_TILE_TITLE} not available in watchlist.
    [Return]    ${watchlist_replay_title}

I Create N Custom Profiles    #USED
    [Arguments]    ${number_of_profiles}    ${number_of_char}
    [Documentation]    This keyword creates Custom profils based on the number provided and the number characters allowed in Profile name
    I Open The Profile Menu
    : FOR    ${INDEX}    IN RANGE    ${number_of_profiles}
    \    I focus 'New' profile icon
    \    Wait Until Keyword Succeeds    5 times    1 s    Run Keywords     I Press    OK    AND    'Create a profile' popup is shown
    \    I focus any profile color
    \    ${name}    Generate Random String	${number_of_char}	[LETTERS]
    \    I choose '${name}' as a profile name
    \    I press    OK
    \    I select the 'Skip' option in the 'Create a personal channel list' modal menu
    \    When I select the 'Skip' option in the 'Choose your preferred genres' modal menu
    \    Created profile icon is shown
    \    Created profile icon is focused

Switch Between Profiles    #USED
    [Documentation]    This Keyword switch between all the profiles and validates
    @{customer_profile}    I Get The Profile Names From BO
    ${number_of_profiles}    Get length    ${customer_profile}
    : FOR    ${INDEX}    IN RANGE    ${number_of_profiles}
    \    Log    ${INDEX}
    \    Log    ${customer_profile}
    \    ${profille_name}    Set Variable    ${customer_profile[${INDEX}]}
    \    ${profille_name_ui}    Set Variable if    '${profille_name}' == 'Shared Profile'    Shared    ${profille_name}
    \    I set current profile to    ${profille_name_ui}
    \    Profile '${profille_name}' Is Active Via As

I Focus The '${profile}' Profile  #USED
    [Documentation]    This keyword focus the specified profile in profile selection menu
    ...    Precondition: Profile selection menu should be open.
    Wait Until Keyword Succeeds    ${JSON_MAX_RETRIES}    ${JSON_RETRY_INTERVAL}    I expect page contains 'textKey:DIC_PROFILES_TITLE'
    ${customer_profile}    I Get The Profile Names From BO
    ${profile_id}   Get Index From List    ${customer_profile}    ${profile}
    Move to element assert focused elements    id:profileItem-${profile_id}    10    RIGHT
    [Return]    ${profile_id}

I Select The Edit Option Of The ${profile_name} Profile   #USED
    [Documentation]    This keyword focuses the Active profile, moves down to focus the edit button below,
    ...    verifies an edit button is in focus and selects the profile edit button.
    ...    Precondition: Profile selection menu should be open.
    Wait Until Keyword Succeeds    ${JSON_MAX_RETRIES}    1s    I expect page contains 'textKey:DIC_PROFILES_TITLE'
    I Focus The '${profile_name}' Profile
    ${customer_profile}    I Get The Profile Names From BO
    ${profile_id}   Get Index From List    ${customer_profile}    ${profile_name}
    Move to element assert focused elements    id:profileEditBtn-profileItem-${profile_id}    3    DOWN
    I press    OK
    Wait Until Keyword Succeeds    ${JSON_MAX_RETRIES}    ${JSON_RETRY_INTERVAL}    I expect page contains 'textKey:DIC_SETTINGS_EDIT_PROFILE_LABEL'
    Wait Until Keyword Succeeds    ${JSON_MAX_RETRIES}    ${JSON_RETRY_INTERVAL}    I expect page element 'id:mastheadProfileName' contains 'textValue:${profile_name}'

I Focus Any Color From Edit Profile    #USED
    [Documentation]   This keyword selects a random available color and moves the focus to it.
    ...        Precondition : The Edit Profile Page should be open. Focus should be on the Profile Color Selection area.
    Wait Until Keyword Succeeds    ${JSON_MAX_RETRIES}    ${JSON_RETRY_INTERVAL}    I expect focused elements contains 'id:profileColortItem-\\\\d+' using regular expressions
    ${customer_cpe_profile_json}   I Get The Profile Details From BO
    @{used_profile_colors}     Create List
    :FOR   ${profile}  IN   @{customer_cpe_profile_json['profiles']}
    \       ${colour}   Get From Dictionary  ${profile}   colour
    \       Append To List    ${used_profile_colors}   ${colour}
    :FOR    ${color}    IN   @{PROFILE_COLORS_DICTIONARY.keys()}
    \   Exit For Loop If   '''${color}''' not in '''${used_profile_colors}'''
    I focus the '${color}' profile color

I Verify '${profile_color_before}' Not Available For Create Profile    #USED
    [Documentation]   This keyword check if already used color is available color for selction.
    ...        Precondition : The Create Profile Page should be open. Focus should be on the Profile Color Selection area.
    Wait Until Keyword Succeeds    ${JSON_MAX_RETRIES}    ${JSON_RETRY_INTERVAL}    I expect page contains 'textKey:DIC_CREATE_PROFILE_TITLE'
    ${customer_cpe_profile_json}   get profile details via personalization service    ${LAB_CONF}    ${CUSTOMER_ID}
    Log    ${customer_cpe_profile_json}
    @{used_profile_colors}     Create List
    :FOR   ${profile}  IN   @{customer_cpe_profile_json['profiles']}
    \       ${colour}   Get From Dictionary  ${profile}   colour
    \       Append To List    ${used_profile_colors}   ${colour}
    :FOR    ${color}    IN   @{PROFILE_COLORS_DICTIONARY.keys()}
    \   Exit For Loop If   '''${color}''' in '''${used_profile_colors}'''
    Run Keyword And Expect Error    Profile color '${color}' is already in use    I focus the '${color}' profile color

I focus 'Default profile on start-up'   #USED
    [Documentation]    Keyword focuses 'Default profile on start-up' in 'PROFILES'
    ...    Precondition: Should be on 'PROFILES' view
    Wait Until Keyword Succeeds    ${JSON_MAX_RETRIES}    ${JSON_RETRY_INTERVAL}    I expect page contains 'textKey:DIC_SETTINGS_EDIT_PROFILE_LABEL'
    Move to element and assert    textKey:DIC_SETTINGS_DEFAULT_PROFILE_LABEL    color    ${HIGHLIGHTED_NAVIGATION_COLOUR}    10    DOWN

I Focus ${profile} Of Value Picker On Profile List   #USED
    [Documentation]   Specified Profile is focused from the Submenu of the Default Profile On Start-Up option
    ...         Initially focus is shifted to Shared Profile and then navigated to the required profile
    ...          Precondition : Default profile on start-up Page is dispalyed
    ${picker_displayed}    Run Keyword And Return Status    Wait Until Keyword Succeeds    ${JSON_MAX_RETRIES}    ${JSON_RETRY_INTERVAL}    I expect page contains 'id:value-picker'
    Run Keyword If    not ${picker_displayed}    Wait Until Keyword Succeeds    ${JSON_MAX_RETRIES}    ${JSON_RETRY_INTERVAL}    I expect page contains 'id:ValuePicker'
    Move to element and assert    textKey:DIC_PROFILES_SHARED_PROFILE    color    ${HIGHLIGHTED_OPTION_COLOUR}    8    UP
    Move Focus to Option in Value Picker  textValue:${profile}    DOWN   7
    Option is Focused in Value Picker   textValue:${profile}

I Get Random ${number_of_channels} Channels From BO    #USED
    [Documentation]  The keyword gets specified number of random channels from BO
    @{total_channel_list}    I Fetch All Replay Channels From Linear Service
    ${list_length}    Get Length    ${total_channel_list}
    @{random_list}    Create List
    : FOR    ${INDEX}    IN RANGE    ${list_length}
    \    ${single_channel}    Evaluate    random.choice($total_channel_list)  random
    \    ${single_channel}    Convert To String    ${single_channel}
    \    Run Keyword If    @{random_list} != @{EMPTY}    Continue For Loop If    '${single_channel}' in ${random_list}
    \    Append To List    ${random_list}   ${single_channel}
    \    ${list_len}    Get Length    ${random_list}
    \    ${number_of_channels}    Convert To Integer    ${number_of_channels}
    \    Log    ${number_of_channels}
    \    Log    ${list_len}
    \    Exit For Loop If    ${list_len} == ${number_of_channels}
    ${channel_number_list}    Get channel numbers list from Linear Service    ${random_list}
    [Return]  ${channel_number_list}

I Choose A Random Color Not In Use     #USED
    [Documentation]  The keyword chooses a random coor which is not in use and is available in PROFILE_COLORS_DICTIONARY
    ${customer_cpe_profile_json}   I Get The Profile Details From BO
    @{used_profile_colors}     Create List
    :FOR   ${profile}  IN   @{customer_cpe_profile_json['profiles']}
    \       ${colour}   Get From Dictionary  ${profile}   colour
    \       Append To List    ${used_profile_colors}   ${colour}
    :FOR    ${color}    IN   @{PROFILE_COLORS_DICTIONARY.keys()}
    \   Exit For Loop If   '''${color}''' not in '''${used_profile_colors}'''
    [Return]  ${color}

Choose To Add '${number_of_channels}' Channels During Profile Creation    #USED
    [Documentation]  This keyword handles common steps needed post entering profile name on profile creation wizard to added # channels for personal line-up.
    ...     Does not create the actual profile but executes steps needed to select the channels from the favourite channel selection modal.
    Interactive modal with options 'Set up my channels' and 'Skip' is shown
    I wait for 2 seconds
    I select the 'Set up my channels' option in the 'Create a personal channel list' modal menu
    Favorite channel selection modal is shown
    @{channel_list}   Create List
    :FOR  ${item}  IN RANGE  99
    \     ${channel_list}    Remove Duplicates    ${channel_list}
    \     ${length}   Get Length  ${channel_list}
    \     Exit For Loop If   ${length}==${number_of_channels}
    \     ${channel}  Get Random Replay Channel Number
    \     Run Keyword If   '''${channel}''' not in '''${channel_list}'''  Append To List  ${channel_list}  ${channel}
    : FOR    ${channel}    IN    @{channel_list}
    \    I Press    ${channel}
    \    I wait for 2 seconds
    \    I verify the focused '${channel}' is added to the Favourites list
    \    I wait for 2 seconds
    \    I Press    OK
    \    I wait for 5 seconds
    \    ${status}    Run Keyword And Return Status    Wait Until Keyword Succeeds    10 times    500 ms    Make sure that personal line-up icon is shown for the channel    ${channel}
    \    Run Keyword Unless    ${status}    Run Keywords     I Press    OK    AND    I wait for 5 seconds
    \    ...    AND    Wait Until Keyword Succeeds    5 times    500 ms    Make sure that personal line-up icon is shown for the channel    ${channel}

Choose To Add ${number_of_genres} Genre During Profile Creation    #USED
    [Documentation]  This keyword handles steps to select x no. of genres from available genres on the CPE.
    ...     PRE-CONDITION: User is on profile creation with profile name already entered and favourite channels selected
    ...     Does not create the actual profile but executes steps needed to select the genre from the Choose your preferred genres interactive modal.
    'Choose your preferred genres' interactive modal is shown
    Wait Until Keyword Succeeds    ${JSON_MAX_RETRIES}    ${JSON_RETRY_INTERVAL}    I expect page contains 'id:genreGridContainer'
    ${genres}    I Get Available Genres For Profiles From BO
    Log    ${genres}
    ${overall_genres}   Get Length  ${genres}
    @{genre_list}   Create List
    :FOR  ${INDEX}  IN    @{genres}
    \     ${genre_list}    Remove Duplicates    ${genre_list}
    \     ${length}   Get Length  ${genre_list}
    \     Exit For Loop If   ${length}==${number_of_genres}
    \     ${selected_genre}    Evaluate    random.choice($genres)  random
    \     Append To List  ${genre_list}  ${selected_genre}
    Log    ${genre_list}
    : FOR    ${genre}    IN    @{genre_list}
    \    Repeat Keyword    4 times     I Press    UP
    \    Repeat Keyword    4 times     I Press    LEFT
    \    Loop To Find A Genre From Overall Genres    ${genre}    ${genre_list}    ${overall_genres}

Loop To Find A Genre From Overall Genres    #USED
    [Arguments]    ${genre}    ${genre_list}    ${overall_genres}
    [Documentation]   PRE-CONDITION: User should be on Choose your preferred genres interactive modal popup screen.
    ...    Will loop for selected genres
    ${rows}   Evaluate    ${overall_genres}/4
    : FOR    ${item}    IN RANGE    ${rows}
    \    Run Keyword If    int(float('${item}'))%2 == 0    Loop On Rows To Find Choosen Genre    ${genre}    RIGHT
    \    Run Keyword If    int(float('${item}'))%2 != 0    Loop On Rows To Find Choosen Genre    ${genre}    LEFT

Loop On Rows To Find Choosen Genre    #USED
    [Arguments]    ${genre}    ${key}
    [Documentation]   PRE-CONDITION: User should be on Choose your preferred genres interactive modal popup screen.
    ...    Will loop for selected single genre on given rows and move focus to ${key} if genre is not highlighted
     : FOR    ${i}    IN RANGE    4
     \    ${ancestor}    I retrieve json ancestor of level '1' for element 'textValue:${genre}'
     \    ${is_it_focused}    Extract Value For Key    ${ancestor}    ${EMPTY}    color
     \    Run Keyword If    '${is_it_focused}'!='${HIGHLIGHTED_OPTION_COLOUR}'    I Press    ${key}
     \    Run Keyword If    '${is_it_focused}'=='${HIGHLIGHTED_OPTION_COLOUR}'    Run Keywords    I Press    OK    AND    Log    \nGenre : ${genre} is selected    AND    Exit For Loop
     \    I wait for 2 seconds
     I Press    DOWN
     
Get The Profile Name From Live TV    #USED
    [Documentation]  The keyword reads the profile name from the top left corner of live tv when channel bar is launched
    Wait Until Keyword Succeeds    ${JSON_MAX_RETRIES}    ${JSON_RETRY_INTERVAL}    I expect page contains 'textKey:DIC_HEADER_SOURCE_LIVE'
    ${profile_name}    I retrieve value for key 'textValue' in element 'id:mastheadProfileName'
    [Return]    ${profile_name}

Get The Profile Color From Live TV    #USED
    [Documentation]  The keyword reads the profile color from the top left corner of live tv when channel bar is launched
    ...    Returns the color code of the respective profile color
    Wait Until Keyword Succeeds    ${JSON_MAX_RETRIES}    ${JSON_RETRY_INTERVAL}    I expect page contains 'textKey:DIC_HEADER_SOURCE_LIVE'
    ${json_object}    Get Ui Json
    ${textStyle}    Extract Value For Key    ${json_object}    id:mastheadProfileIcon    textStyle
    ${color_code}    Extract value for key    ${textStyle}    ${EMPTY}    color
    ${profile_color_code}   Strip String     ${color_code}     mode=left   characters=#
    :FOR   ${key}  IN  @{PROFILE_COLORS_DICTIONARY.keys()}
    \     ${profile_color}    Set Variable    ${key}
    \     Exit For Loop If   "${PROFILE_COLORS_DICTIONARY["${key}"]}"=="${profile_color_code}"
    Log  ${profile_color}
    [Return]    ${profile_color}

I Focus The 'Clear List' Option In Manage Profile Channel List    #USED
    [Documentation]  The keyword focuses the cancel option in manage profile channel list
    ...  Precondition   Manage Profile Channel List Interactive Modal is shown
    'Manage profile channels list' interactive modal is shown
    ${is_confirm_button_focused}  Run Keyword And Return Status    I expect focused elements contains 'textKey:DIC_GENERIC_BTN_CONFIRM'
    ${is_add_channel_button_focused}  Run Keyword And Return Status    I expect focused elements contains 'textKey:DIC_PROFILE_LINEUP_ADD_CHANNELS'
    Run Keyword If   ${is_add_channel_button_focused}     Move to element assert focused elements     textKey:DIC_FAVOURITES_MENU_CLEAR    2    RIGHT
    Run Keyword If   ${is_confirm_button_focused}     Move to element assert focused elements     textKey:DIC_FAVOURITES_MENU_CLEAR    2    LEFT

