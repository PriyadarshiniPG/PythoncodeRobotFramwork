*** Settings ***
Documentation     Personalization keywords
Resource          ../PA-23_Personalization/Personalization_Implementation.robot

*** Keywords ***
Watchlist Specific Teardown
    [Documentation]    Contains teardown steps in order to reset the Watchlist contents for Watchlist related tests
    Reset Watchlist
    Default Suite Teardown

Watchlist Specific Setup
    [Documentation]    Contains setup steps in order to reset the Watchlist contents for Watchlist related tests
    Default Suite Setup
    Reset Watchlist

Watchlist-UI Specific Teardown
    [Documentation]    Contains teardown steps in order to reset the Watchlist contents and restart the UI
    ...    (by rebooting the STB) for tests related to Watchlist that involve the UI
    Reset Watchlist
    Power cycle and make sure that STB is active
    Default Suite Teardown

Added VOD movie is shown in the Watchlist
    [Documentation]    Verifies if added video is in the watchlist
    ...    This keyword asserts the VOD title in the ${TILE_TITLE} variable with the title in watchlist.
    Variable should exist    ${TILE_TITLE}    The title of a VOD asset tile has not been saved. TILE_TITLE does not exist.
    Watchlist is not empty
    ${watchlist_movie_title}    I get recently added VOD title from the watchlist
    Should Be Equal    ${watchlist_movie_title}    ${TILE_TITLE}    Added VOD title from On demand is not equal to the one in watchlist

Get watchlist content via watchlist service
    [Documentation]    This keyword gets watchlist content via application service
    ${profile}    Get Current Profile Id Via As    ${STB_IP}    ${CPE_ID}    xap=${XAP}
    ${watchlist_content}    Get Watchlist Content    ${profile}    ${CUSTOMER_ID}    ${OSD_LANGUAGE}
    [Return]    ${watchlist_content}

Added VOD movie is shown in response from BO
    [Documentation]    This keyword is assert added VOD ${TILE_TITLE} variable with the response from BO
    ...    Precondition: ${TILE_TITLE} variable must exist in this scope.
    Variable should exist    ${TILE_TITLE}    The title of a VOD asset tile has not been saved. TILE_TITLE does not exist.
    ${watchlist_content}    Get watchlist content via watchlist service
    ${result}    Extract Value For Key    ${watchlist_content}    entries:    title
    Should Be Equal    ${result}    ${TILE_TITLE}    Added VOD title from On demand is not equal to the one in watchlist

Removed replay asset is not shown in response from BO
    [Documentation]    This keyword is assert removed replay asset ${REPLAY_TILE_TITLE} variable is not with the response from BO
    ...    Precondition: ${REPLAY_TILE_TITLE} variable should exist.
    Variable should exist    ${REPLAY_TILE_TITLE}    The title of a replay asset tile has not been saved. REPLAY_TILE_TITLE does not exist.
    ${watchlist_content}    Get watchlist content via watchlist service
    ${result}    Extract Value For Key    ${watchlist_content}    entries:    title
    should not contain    ${result}    ${REPLAY_TILE_TITLE}    Removed replay asset title from Watchlist is still available in BO response.

I open Linear Detail Page of the replay asset in watchlist
    [Documentation]    This keyword will open the Linear Detail Page of the replay asset in watchlist.
    ...    Precondition: Watchlist screen should be open.
    Variable should exist    ${REPLAY_TILE_TITLE}    Title of replay asset added to watchlist was not saved.
    wait until keyword succeeds    ${JSON_MAX_RETRIES}    ${JSON_RETRY_INTERVAL}    I expect page contains 'textValue:.*${REPLAY_TILE_TITLE}.*' using regular expressions
    I focus '${REPLAY_TILE_TITLE}' tile
    I Press    OK
    Linear details page is shown

There are no items added to Watchlist
    [Documentation]    Verifies if there are no items added to Watchlist and that the
    ...    'Your Watchlist is empty' screen is shown
    I open Watchlist through Saved
    Watchlist is empty
    I do not expect page contains 'id:NavigableGrid'

I focus the first asset in the Watchlist
    [Documentation]    This keyword selects the first asset tile in the Watchlist by pressing down once and
    ...    checking a tile is in focus, failing otherwise
    Watchlist is not empty
    ${json_object}    Get UI Json
    I press    DOWN
    wait until keyword succeeds    2s    100ms    Assert json changed    ${json_object}
    Move Focus to Tile Position in Grid Page    ${0}

I focus Replay tile in Watchlist
    [Documentation]    This keyword focuses the first asset in the Watchlist and checks that the asset
    ...    in focus is a Replay asset, failing if the asset is not a Replay
    I focus the first asset in the Watchlist
    Focused asset is replay

I focus 'New' profile icon    #USED
    [Documentation]    This keyword focuses the 'New' profile icon in the profile menu.
    ...    Precondition: Profile menu is open.
    'New' profile icon is shown
    Move to element and assert    textValue:Đ    color    ${HIGHLIGHTED_OPTION_COLOUR}    7    LEFT

'Create a profile' popup is shown    #USED
    [Documentation]    This keyword verifies the 'Create a profile' popup is shown.
    wait until keyword succeeds    ${JSON_MAX_RETRIES}    ${JSON_RETRY_INTERVAL}    I expect page element 'id:title-ProfileWizard' contains 'textKey:DIC_CREATE_PROFILE_TITLE'

I focus any profile color    #USED
    [Documentation]    This keyword focuses any of the profile colors available in the profile creation menu.
    ...    Precondition: Profile creation menu is open.
    Move to element and assert    textValue:ǥ    iconKeys    PROFILE    5    RIGHT
    Any profile color is focused

I type a profile name    #USED
    [Documentation]    This keyword types the word Test as a profile name using
    ...    the Virtual Keyboard and presses the GO button.
    I choose 'Test' as a profile name

I select the 'Skip' option in the 'Create a personal channel list' modal menu    #USED
    [Documentation]    This keyword verifies the correct modal is being shown, focuses the 'Skip' option and selects it.
    ${status}    Run Keyword And Return Status   I expect page element 'id:title-ProfileWizard' contains 'textKey:DIC_GENRE_SELECT_TITLE'
    Run Keyword If   '${status}'=='True'    I Press   BACK
    Interactive modal with options 'Set up my channels' and 'Skip' is shown
    I focus the 'Skip' option
    I press    OK

I select the 'Skip' option in the 'Choose your preferred genres' modal menu    #USED
    [Documentation]    This keyword verifies the correct modal is being shown, focuses the 'Skip' option and selects it.
    ...    Profile creation usually takes a while, so we wait until the modal menu is dismissed afterwards.
    'Choose your preferred genres' interactive modal is shown
    I focus the 'Skip' option
    I press    OK
    'Choose your preferred genres' interactive modal is not shown

Created profile icon is shown    #USED
    [Documentation]    This keyword verifies the profile list is being show, waits for the animation to be finished
    ...    and verifies the profile with name ${PROFILE_NAME} and color ${PROFILE_COLOR} is shown
    ...    in the profile selection menu.
    Variable should exist    ${PROFILE_COLOR}    Color of the created profile was not saved.
    Variable should exist    ${PROFILE_NAME}    Name of the created profile was not saved.
    wait until keyword succeeds    ${JSON_MAX_RETRIES}    ${JSON_RETRY_INTERVAL}    I expect focused elements contains 'id:profileItem-\\\\d+' using regular expressions
    ${created_profile_id}    Extract Value For Key    ${LAST_FETCHED_FOCUSED_ELEMENTS}    id:profileItem-\\d+    id    ${True}
    ${json_object}    Get Ui Json
    ${equals_created_profile_color}    Is In Json    ${json_object}    id:${created_profile_id}    color:${PROFILE_COLOR}
    ${equals_created_profile_name}    Is In Json    ${json_object}    id:${created_profile_id}    textValue:${PROFILE_NAME}
    should be true    ${equals_created_profile_color}    Created profile colour:${PROFILE_COLOR} was not found
    should be true    ${equals_created_profile_name}    Created profile name:${PROFILE_NAME} was not found

Created profile icon is focused    #USED
    [Documentation]    This keyword verifies the profile with name ${PROFILE_NAME} and color ${PROFILE_COLOR} is focused
    ...    in the profile selection menu.
    Variable should exist    ${PROFILE_COLOR}    Color of the created profile was not saved.
    Variable should exist    ${PROFILE_NAME}    Name of the created profile was not saved.
    ${json_object}    Get Ui Focused Elements
    ${focused_profile_id}    Extract Value For Key    ${json_object}    id:profileItem-\\d+    id    ${True}
    ${focused_profile_children}    I retrieve value for key 'children' in element 'id:${focused_profile_id}'
    ${equals_created_profile_color}    Is In Json    ${focused_profile_children}    textStyle:    color:${PROFILE_COLOR}
    ${equals_created_profile_name}    Is In Json    ${focused_profile_children}    ${EMPTY}    textValue:${PROFILE_NAME}
    should be true    ${equals_created_profile_color}    Focused profile has different color from the created profile
    should be true    ${equals_created_profile_name}    Focused profile has different name from the created profile

Created profile is set as active    #USED
    [Documentation]    This keyword verifies the profile with name ${PROFILE_NAME} and color ${PROFILE_COLOR} is set as
    ...    active, appearing in the upper right zone of the screen.
    Variable should exist    ${PROFILE_COLOR}    Color of the created profile was not saved.
    Variable should exist    ${PROFILE_NAME}    Name of the created profile was not saved.
    ${profile_indicator_children}    I retrieve value for key 'children' in element 'id:profileIndicator'
    ${equals_created_profile_color}    Is In Json    ${profile_indicator_children}    textStyle:    color:${PROFILE_COLOR}
    ${equals_created_profile_name}    Is In Json    ${profile_indicator_children}    ${EMPTY}    textValue:${PROFILE_NAME}
    should be true    ${equals_created_profile_color}    Active profile has different color from the created profile
    should be true    ${equals_created_profile_name}    Active profile has different name from the created profile

Profile Specific Teardown
    [Documentation]    Contains teardown steps for Profile related tests. Deletes all custom profiles created.
    Run Keyword And Assert Failed Reason    Dismiss Any Value Picker On Screen    Unable to Dismiss Value picker On screen
    Run Keyword And Assert Failed Reason    Reset profiles    Unable to reset profiles
    Run Keyword And Assert Failed Reason    Default Suite Teardown    Default Suite Teardown failure

Profile Creation Setup
    [Arguments]    ${name}=TEST    ${color_name}=GREEN    @{channel_lineup}
    [Documentation]    This setup creates a profile via application Services with the given ${name} (max 10 chars.),
    ...    choosing the given profile color name or the first available profile color if no color name is provided,
    ...    adding any channelIds defined in the @{channel_lineup} argument to the profile personal lineup.
    ...    Usage:
    ...    Profile Creation Setup
    ...    Profile Creation Setup NAME COLOR
    ...    Profile Creation Setup NAME COLOR 0064 0162 0163 0095
    ...    Precondition: The color name provided must be defined in the PROFILE_COLORS_DICTIONARY dictionary.
    Default Suite Setup
    Create a profile via AS    ${name}    ${color_name}    @{channel_lineup}

I Open The Profile Menu    #USED
    [Documentation]    This keyword opens the profile menu by pressing up from Settings
    ...    screen. It then verifies the profile selection menu is shown.
    I Open Settings Through Main Menu
    I Press    PROFILE
    Wait Until Keyword Succeeds And Verify Status    ${JSON_MAX_RETRIES}    ${JSON_RETRY_INTERVAL}    Profile Menu is not shown    I expect page element 'CURRENT_POPUP_LAYER:' contains 'id:profileList'

I create a profile
    [Arguments]    ${name}=TEST    ${color_name}=${None}    @{personalization_options}
    [Documentation]    This keyword creates a profile with the given ${name} (max 10 chars.), choosing the given profile
    ...    color name or the first available profile color if no color name is provided, adding any channels and
    ...    genres defined in the @{personalization_options} argument to the profile or skipping all the profile
    ...    customization options if none are provided. The @{personalization_options} argument can contain channel
    ...    numbers and genre names in any order, for example:
    ...    I create a profile
    ...    I create a profile NAME COLOR Sports Reality
    ...    I create a profile NAME COLOR 20 25 124
    ...    I create a profile NAME COLOR 2 Action 123 10 Drama 8
    ...    The name and the color of the created profile are saved in the ${PROFILE_NAME}
    ...    and ${PROFILE_COLOR} variables, respectively.
    ...    Precondition: The genre names provided must be defined in the GENRES_POSITION_DICTIONARY
    ...    and GENRES_ICON_DICTIONARY dictionaries.
    ...    Precondition: The color name provided must be defined in the PROFILE_COLORS_DICTIONARY dictionary.
    ${name_length}    get length    ${name}
    run keyword if    ${name_length} > 10    Fail    Profile name is longer than 10 characters
    @{favorite_channels}    Get numeric values from list    @{personalization_options}
    ${channels_length}    get length    ${favorite_channels}
    run keyword if    ${channels_length} != ${0} and ${channels_length} < ${MIN_CHANNELS_ALLOWED}    Fail    Personal channel lineup needs to be ${MIN_CHANNELS_ALLOWED} or more channels
    @{preferred_genres}    Get string values from list    @{personalization_options}
    ${genres_length}    get length    ${preferred_genres}
    I Open The Profile Menu
    I focus 'New' profile icon
    Wait Until Keyword Succeeds    5 times    1 s    Run Keywords     I Press    OK    AND    'Create a profile' popup is shown
    run keyword if    '${color_name}' != '${None}'    I focus the '${color_name}' profile color
    ...    ELSE    I focus any profile color
    I choose '${name}' as a profile name
    wait until keyword succeeds    ${JSON_MAX_RETRIES}    ${JSON_RETRY_INTERVAL}    I expect focused elements contains 'id:profileNextButton'
    I press    OK
    Interactive modal with options 'Set up my channels' and 'Skip' is shown
    run keyword if    ${channels_length} >= ${MIN_CHANNELS_ALLOWED}    I select my personal channel lineup in the 'Create a personal channel list' modal menu    @{favorite_channels}
    ...    ELSE    I select the 'Skip' option in the 'Create a personal channel list' modal menu
    run keyword if    ${genres_length} != ${0}    I select my preferred genre tiles in the 'Choose your preferred genres' modal menu    @{preferred_genres}
    ...    ELSE    I select the 'Skip' option in the 'Choose your preferred genres' modal menu
    Created profile icon is shown
    Created profile icon is focused
    Created profile is set as active

I create a profile with 3 channels
    [Documentation]    This keyword creates a profile with 3 channels. It uses the default value for the icon colour
    ...    and skips the preferred genre titles.
    ...    Variables DEFAULT_PROFILE_NAME and PROFILE_3_CHANNEL_LIST are used during profile creation
    I create a profile    ${DEFAULT_PROFILE_NAME}    GREEN    @{PROFILE_3_CHANNEL_LIST}

Profile '${profile_name}' has the same channels stored in the personalization service
    [Documentation]    This keyword verifies that a previously created profile that has 3 or more favourite channels
    ...    has been created, by fetching the list of favourite channel ids, converting them to LCNs and comparing
    ...    the LCNs to the saved LCNs in variable @{FAVOURITE_CHANNEL_LIST}
    Variable should exist    ${FAVOURITE_CHANNEL_LIST}    A favourite channel list has not been created and stored in test variable FAVOURITE_CHANNEL_LIST
    ${fetched_fav_list}    get favourite channels Via Personalization Service    ${LAB_CONF}    ${CUSTOMER_ID}    ${profile_name}
    ${max_channel_number}    get length    ${fetched_fav_list}
    : FOR    ${index}    IN RANGE    ${max_channel_number}
    \    ${channel_number}    get channel lcn for channel id    ${fetched_fav_list[${index}]}
    \    should be equal as strings    ${channel_number}    ${FAVOURITE_CHANNEL_LIST[${index}]}    Favourite channel LCN from preferences service: ${channel_number} was not equal to the stored favourite channel when the profile was created: ${FAVOURITE_CHANNEL_LIST[${index}]}

'Shared' profile is focused
    [Documentation]    This keyword verifies that the Shared profile is focused in the profile selection menu.
    wait until keyword succeeds    ${JSON_MAX_RETRIES}    ${JSON_RETRY_INTERVAL}    I expect focused elements contains 'id:profileItem-0'

'Shared' profile is active
    [Documentation]    This keyword verifies that the Shared profile is the active profile.
    wait until keyword succeeds    ${JSON_MAX_RETRIES}    ${JSON_RETRY_INTERVAL}    I expect page element 'id:profileIndicator' contains 'textKey:DIC_PROFILES_SHARED_PROFILE'

I tune to the first channel of personal line-up
    [Documentation]    Tune to channel - LCN defined in variable ${FIRST_CHANNEL_OF_PERSONAL_LINEUP}
    I tune to personal channel ${FIRST_CHANNEL_OF_PERSONAL_LINEUP}

I open Manage channels through Settings
    [Documentation]    This keyword opens SETTINGS through Main Menu and navigates to Manage channels
    I open Profiles through Settings
    I open Manage channels

I set current profile to    #USED
    [Arguments]    ${profile_name}
    [Documentation]    This keyword set current profile to ${profile_name}
    I Open The Profile Menu
    ${ancestor}    I retrieve json ancestor of level '2' for element 'textValue:${profile_name}'
    ${id}    Extract value for key    ${ancestor}    id:profileItem-\\d+    id    ${True}
    Move to element assert focused elements    id:${id}    8    RIGHT
    I Press    OK
    I Open The Profile Menu
    wait until keyword succeeds    10s    1s    i expect page element 'id:profileIndicator' contains 'textValue:${profile_name}'

Channels for current profile are shown on channels list    #USED
    [Documentation]    This keyword gets channel list in personal line up then retrieves the channel names. At the end matches with UI elements
    ${personal_line_up}    Get Favourite Channels Id Available For Current Profile
    ${current_profile_channel_name_list}    Get Channel Name List From Linear Service    ${personal_line_up}
    ${channel_list_from_UI}    I Get Channel Names From Manage Channels
    Lists Should Be Equal   ${current_profile_channel_name_list}    ${channel_list_from_UI}
    I open Channel Bar

I tune to first Channel of personal line-up after profile creation
    [Documentation]    This keyword will create a profile and add 5 channels to it.Also it will tune to the first channel.
    I create a profile
    I add '5' channels to personal line-up
    I tune to the first channel of personal line-up

I Tune To Channel Outside Personal Line-up With Number Key    #USED
    [Documentation]    This keyword trying to tune to channel outside personal line-up, then validating the status
    ${personal_line_up}    Get Favourite Channels Id Available For Current Profile
    ${current_profile_channel_number_list}    Get Channel Numbers List From Linear Service    ${personal_line_up}
    I Fetch Linear Channel Number List Filtered For Zapping
    ${channel_outside_lineup}    Set Variable   ${EMPTY}
    :FOR   ${channel}   IN  @{FILTERED_CHANNEL_LIST}
    \     ${channel_outside_lineup}    Set Variable   ${channel}
    \     ${status}    Run Keyword And Return Status  List Should Not Contain Value   ${current_profile_channel_number_list}    ${channel}
    \     Exit For Loop If   '${status}'=='True'
    I tune to ${channel_outside_lineup} in the tv guide
    I Focus Current Event In The TV Guide
    I Tune The Focused ${channel_outside_lineup} In The Tv Guide

I verify currently tuned channel is the last channel in a 5 channel personal line-up
    [Documentation]    This keyword will verify that currently tuned channel is the last one in ${PROFILE_5_CHANNEL_LIST}
    variable should exist    ${PROFILE_5_CHANNEL_LIST}    Mentioned channel list doesn't exist
    I verify currently tuned channel is the last channel in the personal line-up    ${PROFILE_5_CHANNEL_LIST}

Custom Profile Activate Setup
    [Documentation]    This setup will create a custom profile with name TEST and colour Green and activate that profile
    ${profile_id}    Create a profile via AS
    set current profile via as    ${STB_IP}    ${CPE_ID}    ${profile_id['profileId']}    xap=${XAP}

I select 'Edit or Delete profile' option    #USED
    [Documentation]    This Keyword is used to select the Edit or Delete profile option in the Setting page of Active profile
    Move Focus to Setting    textKey:DIC_SETTINGS_EDIT_PROFILE_LABEL    DOWN
    I Press    OK
    Wait Until Keyword Succeeds    ${JSON_MAX_RETRIES}    ${JSON_RETRY_INTERVAL}    I expect page contains 'textKey:DIC_EDIT_PROFILE_TITLE'

Profile '${profile_name}' is deleted from BO    #USED
    [Documentation]    This keyword verifies that a previously created profile is deleted from BO
    ...    this keyword fetches the available profile names from STB and compares them with the given profile name
    @{customer_profile}    get available profiles name Via Personalization Service    ${LAB_CONF}    ${CUSTOMER_ID}
    List Should Not Contain Value       ${customer_profile}     ${profile_name}    Profile ${profile_name} was not deleted from the customer

Created profile is present on BO    #USED
    [Documentation]    This keyword verifies that the profile ${PROFILE_NAME} is created on BO.
    ...    precondition: A profile called ${PROFILE_NAME} should be created
    variable should exist    ${PROFILE_NAME}    Profile name variable ${PROFILE_NAME} has not been set
    Check that '${PROFILE_NAME}' profile is created on BO

'${custom_profile}' profile is active
    [Documentation]    This keyword verifies that a custom profile is the active profile.
    wait until keyword succeeds    ${JSON_MAX_RETRIES}    ${JSON_RETRY_INTERVAL}    I expect page element 'id:profileIndicator' contains 'textValue:${custom_profile}'

Partially watched entitled single VOD is available
    [Documentation]    This Keyword starts playing a VOD asset to save it as a partially watched VOD in Continue Watching of Saved item.
    ...    As part of the steps this keyword starts playing a VOD asset for 9 sec and then fast forward it for next 5 sec so that 50% of VOD asset can be covered
    ...    and can be saved as Continue Watching in saved item.
    I play a VOD asset    9    600
    I Long Press FFWD for 5 seconds
    I press    OK
    Player is in PLAY mode
    I press    STOP
    Linear Details Page is shown

I Verify the 'Continue Watching' page has a partially watched event
    [Documentation]    This keyword verifies that a partially watched event is available in 'continue watching' section at 'saved items'
    ...    Pre-reqs: 'Continue Watching' section from 'Saved' should be opened
    wait until keyword succeeds    ${JSON_MAX_RETRIES}    ${JSON_RETRY_INTERVAL}    I expect page contains 'id:shared-CollectionsBrowser_collection_\\\\d+_tile_\\\\d+' using regular expressions
    ${event_tile_id}    Extract Value For Key    ${LAST_FETCHED_JSON_OBJECT}    id:shared-CollectionsBrowser_collection_\\d+_tile_\\d+    id    ${True}
    ${ancestor}    Get Enclosing Json    ${LAST_FETCHED_JSON_OBJECT}    ${EMPTY}    id:${event_tile_id}    ${1}    ${EMPTY}
    ${is_partially_watched}    Is In Json    ${ancestor}    ${EMPTY}    id:progressBar
    should be true    ${is_partially_watched}    No partially watched event available in continue watching section from saved item

I press CONTEXTUAL KEY on partially watched event
    [Documentation]    This keyword focuses on a partially watched event and presses the contextual key, checking that action 'Play from start' is displayed.
    ...    Pre-reqs: Page is on continue watching section of saved item
    Move to element assert focused elements using regular expression    id:^.*CollectionsBrowser_collection_\\\\d_tile_0    8    DOWN
    I Press    CONTEXT
    'Play from start' action is shown

I start playback of a replay added to Watchlist
    [Documentation]    This keyword starts playback of a replay tile added to Watchlist with name ${REPLAY_TILE_TITLE}
    ...    precondition: Watchlist screen in MY TV should be open
    ...    ${REPLAY_TILE_TITLE} variable must exist in this scope.
    Replay tile is shown
    I focus '${REPLAY_TILE_TITLE}' tile
    I press    OK
    Details Page Header is shown
    'watch' action is focused
    I press    OK
    I select the 'PLAY FROM START' action
    'About to start' screen is shown

I change the profile name
    [Arguments]    ${profile_name}=${PROFILE_NAME_UPDATE}
    [Documentation]    This keyword will update the profile name to ${profile_name}
    ...    Precondition: An edit or delete profile option should be selected
    ${profile_name_length}    get length    ${profile_name}
    run keyword if    ${profile_name_length} > ${PROFILE_MAX_NAME_LENGTH}    fail test    Profile name ${profile_name} is longer than ${PROFILE_MAX_NAME_LENGTH} characters
    Move to element assert focused elements    id:ProfileNameInputField    5    UP
    I Press    OK
    wait until keyword succeeds    10s    1s    I expect page contains 'id:ProfileNameInputField'
    Clear the profile name input field content
    I type "${profile_name}" on the Virtual Keyboard
    I press 'Go' on the Virtual Keyboard
    wait until keyword succeeds    ${JSON_MAX_RETRIES}    ${JSON_RETRY_INTERVAL}    I expect focused elements contains 'textKey:DIC_GENERIC_BTN_SAVE'
    I Press    OK
    wait until keyword succeeds    10s    1s    i expect page element 'id:mastheadProfileName' contains 'textValue:${profile_name}'

Renamed profile is focused
    [Arguments]    ${renamed_profile}=${PROFILE_NAME_UPDATE}
    [Documentation]    This keyword will verify that the profile name is renamed and ${renamed_profile} is focused.
    check that '${renamed_profile}' profile is created on BO
    wait until keyword succeeds    ${JSON_MAX_RETRIES}    ${JSON_RETRY_INTERVAL}    i expect page element 'id:mastheadProfileName' contains 'textValue:${renamed_profile}'

I Expect There Are No Custom Profiles Created    #USED
    [Documentation]    This keyword verifies that there are no custom profile available only shared profile is present
    @{customer_profile}    get available profiles name Via Personalization Service    ${LAB_CONF}    ${CUSTOMER_ID}
    ${number_of_profiles}    Get length    ${customer_profile}
    should be equal as integers    ${number_of_profiles}    1    I expect there are no custom profiles but got ${customer_profile}
    should be equal as strings    @{customer_profile}    Shared Profile    I expect only the shared profile but got @{customer_profile}

Full channel line-up is shown for created profile
    [Documentation]    This keyword verifies that full channel line-up is shown for current profile
    ${current_profile_name}    get current profile name via as    ${STB_IP}    ${CPE_ID}    xap=${XAP}
    ${personal_line_up}    get favourite channels Via Personalization Service    ${LAB_CONF}    ${CUSTOMER_ID}    ${current_profile_name}    xap=${XAP}
    should be empty    ${personal_line_up}    Favorite channel list is not empty. It contains ${personal_line_up}

I delete a channel from personal line-up
    [Documentation]    This keyword deletes the first channel from the favourite channel list of personal line-up
    ...    It fetches the name of the channel to be deleted and store it in a test variable ${CHANNEL_NAME_TO_BE_DELETED}
    I open Manage channels through Settings
    ${json_object}    Get Ui Focused Elements
    ${channel_name_to_be_deleted}    Extract Value For Key    ${json_object}    id:DynamicList    title    ${True}
    Set Test Variable    ${CHANNEL_NAME_TO_BE_DELETED}    ${channel_name_to_be_deleted}
    I press    RIGHT
    Wait until keyword succeeds    ${JSON_MAX_RETRIES}    ${JSON_RETRY_INTERVAL}    I expect page contains 'textKey:DIC_PROFILES_HINT_DELETE'
    I press    OK
    Wait Until Keyword Succeeds    ${JSON_MAX_RETRIES}    ${JSON_RETRY_INTERVAL}    I do not expect page contains 'textValue:${channel_name_to_be_deleted}'
    I press    UP
    Move Focus to Section    DIC_GENERIC_BTN_CONFIRM    textKey
    'Confirm' option is shown
    I press    OK
    Profiles section is open

Channel is removed from personal line-up
    [Documentation]    This keyword verifies that the deleted channel is not present in the current favourite list.
    ...    ${NUMBER_OF_CHANNELS_ADDED_TO_FAVLIST} and ${CHANNEL_NAME_TO_BE_DELETED} variables should exist
    ...    Precondition: Any of the keywords that set the ${NUMBER_OF_CHANNELS_ADDED_TO_FAVLIST} and ${CHANNEL_NAME_TO_BE_DELETED} variable needs to be called before calling this.
    variable should exist    ${NUMBER_OF_CHANNELS_ADDED_TO_FAVLIST}    NUMBER_OF_CHANNELS_ADDED_TO_FAVLIST variable has not been set
    variable should exist    ${CHANNEL_NAME_TO_BE_DELETED}    CHANNEL_NAME_TO_BE_DELETED variable has not been set
    ${expected_number_of_channels_in_favlist}    evaluate    ${NUMBER_OF_CHANNELS_ADDED_TO_FAVLIST} - 1
    I open Manage channels through Settings
    ${fetched_fav_list}    Get Favourite Channels Id Available For Current Profile
    ${current_profile_channel_number_list}    Get Channel Numbers List From Linear Service    ${fetched_fav_list}
    @{current_profile_channel_name_list}    Get channel names list from    ${current_profile_channel_number_list}
    List Should Not Contain Value    ${current_profile_channel_name_list}    ${CHANNEL_NAME_TO_BE_DELETED}    channel name ${CHANNEL_NAME_TO_BE_DELETED} is not deleted from favourite list
    ${number_of_channels}    Get length    ${current_profile_channel_name_list}
    should be equal as integers    ${number_of_channels}    ${expected_number_of_channels_in_favlist}    I expect there are ${NUMBER_OF_CHANNELS_ADDED_TO_FAVLIST} favourite channels available after deletion of a channel

Profile Specific Setup
    [Documentation]    Contains setup steps for Profile related tests. Deletes all custom profiles created
    Default Suite Setup
    Run Keyword And Assert Failed Reason    Reset profiles    Unable to reset profiles
    Run Keyword And Assert Failed Reason    Clear Locked Channel List In Teardown   Unable to clear the locked channel list

Added Replay Asset To Watchlist Is Shown In Response From BO    #USED
    [Documentation]    This keyword asserts that added replay asset ${FILTERED_REPLAY_EVENT} is present in watchlist service response
    ...    Precondition: ${FILTERED_REPLAY_EVENT} variable should exist.
    Variable should exist    ${FILTERED_REPLAY_EVENT}    The title of a replay asset tile has not been saved. FILTERED_REPLAY_EVENT does not exist.
    ${profile}    Get Current Profile Id Via As    ${STB_IP}    ${CPE_ID}    xap=${XAP}
    ${watchlist_content}    Get Watchlist Content    ${profile}    ${CUSTOMER_ID}    ${OSD_LANGUAGE}    ${CPE_ID}
    @{entries}    Set Variable    ${watchlist_content['entries']}
    :FOR    ${event}    IN    @{entries}
    \    ${watchlist_asset}    Set Variable    ${event['title']}
    \    Continue For Loop If    '''${watchlist_asset}''' != '''${FILTERED_REPLAY_EVENT['title']}'''
    \    Exit For Loop If    '''${event['title']}'''=='''${FILTERED_REPLAY_EVENT['title']}'''
    Should Be Equal    ${watchlist_asset}    ${FILTERED_REPLAY_EVENT['title']}    Added replay asset title from On demand is not equal to the one in watchlist

I start playback of the VOD series added to Watchlist
    [Documentation]    This keyword starts the playback of the tile with name ${VOD_TILE_TITLE},
    ...    first opening its Detail Page, and then initiating the Rent flow if needed or
    ...    selecting the 'WATCH' action, verifying the playback starts.
    ...    Precondition: ${VOD_TILE_TITLE} variable must exist in this scope and watchlist screen in Saved should be open.
    Added VOD series is shown in Watchlist
    I press    OK
    VOD Details Page is shown
    ${is_entitled}    run keyword and return status    'PLAY FROM START' action is shown
    run keyword if    ${is_entitled}    I press    PLAY-PAUSE
    ...    ELSE    I rent the focused asset

Added VOD series is shown in Watchlist
    [Documentation]    This keyword verifies if the VOD series asset title ${VOD_TILE_TITLE} is available in watchlist.
    ...    Precondition: ${VOD_TILE_TITLE} variable should exist and watchlist page should be open.
    Variable should exist    ${VOD_TILE_TITLE}    The title of a VOD series asset tile has not been saved. VOD_TILE_TITLE does not exist.
    I focus the first asset in the Watchlist
    ${watchlist_vod_title}    Get Focused Tile    title
    Should Be Equal    ${watchlist_vod_title}    ${VOD_TILE_TITLE}    Added vod series asset title is not equal to the one in watchlist

Added VOD series is shown in response from BO
    [Documentation]    This keyword verifies that the watchlist title fetched from BO matches the title saved in variable VOD_TILE_TITLE
    ...    Precondition: ${VOD_TILE_TITLE} variable should exist.
    Variable should exist    ${VOD_TILE_TITLE}    The title of a replay asset tile has not been saved. VOD_TILE_TITLE does not exist.
    ${profile}    Get Current Profile Id Via As    ${STB_IP}    ${CPE_ID}    xap=${XAP}
    ${watchlist_content}    Get Watchlist Content    ${profile}    ${CUSTOMER_ID}    ${OSD_LANGUAGE}
    ${bo_watchlist_title}    Extract Value For Key    ${watchlist_content}    entries:    title
    Should Be Equal    ${bo_watchlist_title}    ${VOD_TILE_TITLE}    Added VOD series asset title from On demand is not equal to the one in watchlist

I added one VOD series asset to Watchlist
    [Documentation]    This keyword adds one VOD series asset to the watch list
    I Open On Demand through Main Menu
    I open details page for series asset
    I add the asset to watchlist

I continue to watch a partially watched Replay asset from the last bookmark
    [Documentation]    This keyword will continue to watch a partially watched
    ...    replay asset from the last bookmark.
    ...    Precondition: continue watching should be open,
    ...    The ${REPLAY_TILE_TITLE} variable must have been set before.
    variable should exist    ${REPLAY_TILE_TITLE}    Suite variable REPLAY_TILE_TITLE has not been set.
    I focus '${REPLAY_TILE_TITLE}' tile
    I press    OK
    continue watching is shown
    I select the 'continue watching' action
    Asset starts playing from where it stopped

Bookmark state of the replay asset is displayed correctly
    [Documentation]    This keyword verifies that the asset with title ${REPLAY_TILE_TITLE} is present in the current screen.
    ...    and the tile contains a progress indicator below showing where the asset was stopped last time it was played.
    ...    Precondition: A screen with replay tiles must be opened,
    ...    The ${REPLAY_TILE_TITLE} variable must have been set before.
    Variable should exist    ${REPLAY_TILE_TITLE}    Suite variable REPLAY_TILE_TITLE has not been set.
    Bookmark state of the asset is displayed correctly    ${REPLAY_TILE_TITLE}

Bookmark Reset Suite Teardown
    [Documentation]    This teardown reset all Bookmarks. After that, it restarts the UI to be sure no cached data remains.
    ...    Then, it calls the Default Suite Teardown.
    Reset All Continue Watching Events
    Restart UI via command over SSH
    Default Suite Teardown

I Create '${number_of_profiles}' Of Custom Profiles With '${number_of_char}' In Name    #USED
    [Documentation]    This keyword creates Custom profils based on the number provided and the number of characters allowed in Profile name
    I Create N Custom Profiles    ${number_of_profiles}    ${number_of_char}
    @{custom_profile}    get available profiles name Via Personalization Service    ${LAB_CONF}    ${CUSTOMER_ID}
    Set Suite Variable    ${CUSTOM_PROFILE}    ${custom_profile}

I Switch Between All Profiles    #USED
    [Documentation]    This Keyword switch between all the profil;es and validates
    Switch Between Profiles

Profile '${profille_name}' Is Active Via As    #USED
    [Documentation]
    ${current_profile_name}    get current profile name via as    ${STB_IP}    ${CPE_ID}    xap=${XAP}
    Should Be True    '${current_profile_name}' == '${profille_name}'

I Expect There Are '${expected_number_of_profiles}' Custom Profiles Created    #USED
    [Documentation]    This keyword verifies that there are specified number of custom profile available. Expected Number of custom profiles should be one more than the actual expectation, there is a default shared profile.
    @{customer_profile}    get available profiles name Via Personalization Service    ${LAB_CONF}    ${CUSTOMER_ID}
    ${number_of_profiles}    Get length    ${customer_profile}
    ${expected_number_of_profiles}    Evaluate    (${expected_number_of_profiles} + ${1})
    should be equal as integers    ${number_of_profiles}    ${expected_number_of_profiles}    I expect there are ${expected_number_of_profiles} custom profiles but got ${number_of_profiles}

Switch To '${profile}' Profile    #USED
    [Documentation]    This keyword switches to a specific profile.
    I set current profile to  ${profile}

Get The Focused Color From Profile Settings Menu        #USED
    [Documentation]   Returns the color of the profile from Profile Settings page
    ...         Precondition : Profile Settings page should be opened.
    Wait Until Keyword Succeeds    ${JSON_MAX_RETRIES}    ${JSON_RETRY_INTERVAL}    I expect page contains 'textKey:DIC_SETTINGS'
    ${json_object}    Get Ui Json
    ${textStyle}    Extract Value For Key    ${json_object}    id:mastheadProfileIcon   textStyle
    ${profile_color}    Extract value for key    ${textStyle}    ${EMPTY}    color
    [Return]   ${profile_color}

I Edit Profile Color   #USED
    [Documentation]  The keyword verifies the current profile edit page and chanhes the color to a random available color.
    ...          Precondition : The Profile Edit Page is opened and focus is on Save button.
    Wait Until Keyword Succeeds    ${JSON_MAX_RETRIES}    ${JSON_RETRY_INTERVAL}    I expect focused elements contains 'textKey:DIC_GENERIC_BTN_SAVE'
    :FOR  ${_}  IN RANGE   5
    \    I wait for 2 ms
    \    ${elem_profile_icon}    Run Keyword And Return Status    I expect focused elements contains 'id:profileColortItem-\\\\d+' using regular expressions
    \    ${elem_save_button}     Run Keyword And Return Status    I do not expect focused elements contain 'textKey:DIC_GENERIC_BTN_SAVE' using regular expressions
    \    ${elem_input_field}     Run Keyword And Return Status    I do not expect focused elements contain 'id:ProfileNameInputField' using regular expressions
    \    Exit For Loop If    ${elem_profile_icon} and ${elem_save_button} and ${elem_input_field}
    \    I Press    UP
    I Focus Any Color From Edit Profile
    Move to element assert focused elements  textKey:DIC_GENERIC_BTN_SAVE   5    DOWN
    I Press   OK
    Wait Until Keyword Succeeds    ${JSON_MAX_RETRIES}    ${JSON_RETRY_INTERVAL}    I expect page contains 'textKey:DIC_SETTINGS_EDIT_PROFILE_LABEL'

I Change The Color Of ${profile} profile    #USED
    [Documentation]     The keyword changes the color of specified profile
    I Open The Profile Menu
    I Select The Edit Option Of The ${profile} Profile
    ${profile_color_before}     Get The Focused Color From Profile Settings Menu
    I select 'Edit or Delete profile' option
    I Edit Profile Color
    Wait Until Keyword Succeeds    ${JSON_MAX_RETRIES}    ${JSON_RETRY_INTERVAL}    I expect page element 'id:mastheadProfileIcon' has text color '\#${FOCUSED_COLOR_CODE}'
    ${profile_color_after}     Get The Focused Color From Profile Settings Menu
    Should Be True      '${profile_color_before}'!='${profile_color_after}'      'Color change is not reflected'

I Check Edit Option Not Available For Shared Profile       #USED
    [Documentation]     Verifies whether Edit icon is present on Profile Wizard of Shared Profile
    I Open The Profile Menu
    I focus the 'Shared Profile' profile
    I do not expect page contains 'id:profileEditBtn-profileItem-\\d$' using regular expressions

I Edit Profile Name With A Random String   #USED
    [Documentation]  The keyword renames the profile with a random string.
    ...  Precondition : The Profile Edit page is displayed
    Wait Until Keyword Succeeds    ${JSON_MAX_RETRIES}    ${JSON_RETRY_INTERVAL}    I expect focused elements contains 'textKey:DIC_GENERIC_BTN_SAVE'
    Move to element assert focused elements    id:ProfileNameInputField    3    UP
    I Press  OK
    Clear the profile name input field content
    ${name}    Generate Random String	4	[LETTERS]
    I choose '${name}' as a profile name
    Wait Until Keyword Succeeds    ${JSON_MAX_RETRIES}    ${JSON_RETRY_INTERVAL}    I expect focused elements contains 'textKey:DIC_GENERIC_BTN_SAVE'
    I Press  OK
    I wait for 4 seconds
    Check that '${PROFILE_NAME}' profile is created on BO

Rename ${profile} Profile And Validate   #USED
    [Documentation]    This keyword renames the specified profile through UI and validates
    I Open The Profile Menu
    I Select The Edit Option Of The ${profile} Profile
    I select 'Edit or Delete profile' option
    I Edit Profile Name With A Random String
    I wait for 5 seconds
    Check that '${PROFILE_NAME}' profile is created on BO

Set ${profile} As The Start Up Profile From Any Custom Profile   #USED
    [Documentation]    This keyword set the given profile as the start up profile
    I Open The Profile Menu
    I Select The Edit Option Of The ${profile} Profile
    I focus 'Default profile on start-up'
    I Press   OK
    ${picker_displayed}    Run Keyword And Return Status    Wait Until Keyword Succeeds    ${JSON_MAX_RETRIES}    ${JSON_RETRY_INTERVAL}    I expect page contains 'id:value-picker'
    Run Keyword If    not ${picker_displayed}    Wait Until Keyword Succeeds    ${JSON_MAX_RETRIES}    ${JSON_RETRY_INTERVAL}    I expect page contains 'id:ValuePicker'
    I Focus ${profile} Of Value Picker On Profile List
    I Press   OK
    I wait for 5 seconds
    I Check '${profile}' Is The Start-UP Profile

I Delete ${profile} And Validate   #USED
    [Documentation]  The keyword deletes specified profile and validate it through backend
    I Open The Profile Menu
    I Select The Edit Option Of The ${profile} Profile
    I select 'Edit or Delete profile' option
    Move to element assert focused elements     textKey:DIC_BUTTON_DELETE    3    DOWN
    I Press   OK
    I Select The 'Confirm' Option In The 'Delete Profile' Modal Menu
    Profile '${profile}' is deleted from BO

I Check '${profile}' Is The Active Profile   #USED
    [Documentation]   Checks the active profile with the specified profile
    ${active_profile}   I Get The Active Profile Name
    Should Be True   '${profile}'=='${active_profile}'      '${profile} Is Not The Active Profile'

I Check '${profile}' Is The Start-UP Profile   #USED
    [Documentation]   Checks the start up profile with the specified profile
    ${start_up_profile}   I Get The Start Up Profile
    Should Be True   '${profile}'=='${start_up_profile}'      '${profile} Is Not The Start Up Profile'

User Cannot Create A Custom Profiles With Already Used Color    #USED
    [Documentation]     The keyword checks that user cannot create new custom profile with color that was already used earlier. Negative scenario validation.
    ...      PRE-CONDITION: A Custom Profile is just created.
    I Open The Profile Menu
    ${profile_indicator_children}    I retrieve value for key 'children' in element 'id:profileIndicator'
    ${active_profile_color}    Extract Value For Key    ${profile_indicator_children}    textValue:ǥ    color
    I focus 'New' profile icon
    Wait Until Keyword Succeeds    5 times    1 s    Run Keywords     I Press    OK    AND    'Create a profile' popup is shown
    I Verify '${active_profile_color}' Not Available For Create Profile

User Cannot Create A Custom Profiles With No Color  #USED
    [Documentation]     The keyword checks that user cannot create new custom profile without selecting any color. Negative scenario validation.
    I Open The Profile Menu
    I focus 'New' profile icon
    Wait Until Keyword Succeeds    5 times    1 s    Run Keywords     I Press    OK    AND    'Create a profile' popup is shown
    Verify User Cannot Select Empty Profile Color

I Check Channel Zap Outside Personal Line Up Channels   #USED
    [Documentation]   Tune to a channel outside personal line up and verify whether tuned to the last personal line up channel
    ${personal_line_up}  Get Favourite Channels Id Available For Current Profile
    ${channel_numbers}  Get Channel Numbers List From Linear Service   ${personal_line_up}
    ${number_of_channels}  Get Length  ${personal_line_up}
    I Open Channel Bar
    ${number_of_channels}   Evaluate  ${number_of_channels} + 1
    ${channel_number}   Convert To String   ${number_of_channels}
    I Press   ${channel_number}
    I Wait For 5 Second
    I verify currently tuned channel is the last channel in the personal line-up     ${channel_numbers}

I Add '${number_of_channels}' Random Channels To Personal Line-up  #USED
    [Documentation]  The keyword picks specified number of random channels and add them to personal line-up
    @{channel_numbers}   Create List
    :FOR  ${item}  IN RANGE  99
    \     ${length}   Get Length  ${channel_numbers}
    \     Exit For Loop If   ${length}==${number_of_channels}
    \     ${channel}  Get Random Replay Channel Number
    \     Run Keyword If   '''${channel}''' not in '''${channel_numbers}'''  Append To List  ${channel_numbers}  ${channel}
    Add channels to the personal line-up   ${channel_numbers}

I Check Channel Bar Contains Channels From Personal Line Up  #USED
    [Documentation]  The keyword zap to each channel in personal channel list and verify in channel bar
    ${channel_ids}  Get Favourite Channels Id Available For Current Profile
    I press   1
    :FOR   ${channel}  IN   @{channel_ids}
    \   ${channel_id}    Get current channel
    \   Should Contain  ${channel_ids}   ${channel_id}   'Channels are not as per personal Line up'
    \   I Press    CHANNELUP

I Create '${number_of_profiles}' Of Custom Profiles With '${number_of_char}' In Name From BO      #USED
    [Documentation]  The keyword creates n number of custom profiles through backend with given number of characters in profile name.
    I open Guide through Main Menu
    wait until keyword succeeds    50 s    0 s    Validate TVGuide Is loaded
    ${current_channel_number}    Get Focused Guide Programme Cell Channel Number
    Set Suite Variable    ${current_channel_number}
    : FOR    ${INDEX}    IN RANGE    ${number_of_profiles}
    \  ${name}  Generate Random String	 ${number_of_char}	[LETTERS]
    \  ${color_name}  I Choose A Random Color Not In Use
    \  ${profile_id}    Create A Profile Via Personalization Service    ${name}   ${color_name}
    \  I Wait For 2 seconds
    \  Check that '${name}' profile is created on BO
    @{custom_profile}    I Get The Profile Names From BO
    Set Suite Variable    ${CUSTOM_PROFILE}    ${custom_profile}

I Add The Tuned Channel To Personal Line-Up Via Pop-up    #USED
    [Documentation]  The keyword zap to next channel and verify the 'Add The Channel to Personal Line-up popup'
    ...       Add to Personal Line up pop is displayed on channel zap.
    #Live stream is playing
    I Press   CHANNELUP
    ${channel_id}   Get Current Channel
    ${status}   Run Keyword If    not ${RF_FEED_PRESENT}    Run Keyword And Return Status   Wait Until Keyword Succeeds    3 times    10 ms    Error screen 'CS2004' is shown
    Run Keyword If   not ${RF_FEED_PRESENT} and ${status}   I Press  BACK
    Interactive modal is shown
    ${status}   Run Keyword And Return Status   Wait Until Keyword Succeeds    ${JSON_MAX_RETRIES}    ${JSON_RETRY_INTERVAL}      I expect focused elements contains 'textKey:DIC_OUT_OF_LINE_UP_CHANNEL_KEEP'
    Should Be True    ${status}   "Keep this channel?" Interactive Model Popup is not displayed
    Dismiss Channel Failed Error Pop Up
    I Press   OK
    Wait Until Keyword Succeeds    ${JSON_MAX_RETRIES}    ${JSON_RETRY_INTERVAL}      Interactive modal is not shown
    ${personal_line_up}   Get Favourite Channels Id Available For Current Profile
    List Should Contain Value    ${personal_line_up}     ${channel_id}

Create A Custom Profile With '${name}' Profile Name    #USED
    [Documentation]  The keyword will create a new custom profile using the provided name as the profile name.
    ...     Also checks for the name length once the profile is successfully created
    Common Steps To Start Creating A Profile With Any Color
    I choose '${name}' as a profile name
    I press    OK
    I select the 'Skip' option in the 'Create a personal channel list' modal menu
    I select the 'Skip' option in the 'Choose your preferred genres' modal menu
    ${accepted_profile_name}    I retrieve value for key 'textValue' in element 'id:mastheadProfileName'
    ${name_length}    Get Length    ${accepted_profile_name}
    Should Be True    ${name_length} <= 10    ${accepted_profile_name} is longer than 10 characters and accepted by system.

Create A Custom Profile With No Profile Name    #USED
    [Documentation]  The keyword will try to create a new custom profile using with blank profile name and capture the error.
    ...     Negative scenario validation.
    Common Steps To Start Creating A Profile With Any Color
    I Press    DOWN
    virtual keyboard is shown
    I Press    BACK
    virtual keyboard is not shown
    Move to element assert focused elements    textKey:DIC_GENERIC_BTN_NEXT    4    DOWN
    I Press    OK
    ${is_enter_a_value}   Run Keyword And Return Status    Wait Until Keyword Succeeds    ${JSON_MAX_RETRIES}    ${JSON_RETRY_INTERVAL}    I expect page element 'id:InputErrorTextProfileNameInputField' contains 'textValue:Please enter a name'
    ${is_choose_a_value}   Run Keyword And Return Status    Wait Until Keyword Succeeds    ${JSON_MAX_RETRIES}    ${JSON_RETRY_INTERVAL}    I expect page element 'id:InputErrorTextProfileNameInputField' contains 'textValue:Choose a name'
    Should Be True    ${is_enter_a_value} or ${is_choose_a_value}

Common Steps To Start Creating A Profile With Any Color    #USED
    [Documentation]  This keyword handles all common steps needed to create a new custom profile with any color selection.
    ...     Does not create the actual profile but executes steps until profile color selection.
    I Open The Profile Menu
    I focus 'New' profile icon
    Wait Until Keyword Succeeds    5 times    1 s    Run Keywords     I Press    OK    AND    'Create a profile' popup is shown
    I focus any profile color

Trigger Profile Creation For A Custom Profile With '${number_of_char}' Chars In Name    #USED
    [Documentation]  User can go step back or cancel at any point.
    ...    In this step we will validate if profile creation can be dismissed after entering profile name.
    Common Steps To Start Creating A Profile With Any Color
    ${name}    Generate Random String	${number_of_char}	[LETTERS]
    I choose '${name}' as a profile name

Trigger Profile Creation For '${number_of_char}' Char Custom Profile On Selecting '${number_of_channels}' Channels    #USED
    [Documentation]  User can go step back or cancel at any point.
    ...    In this step we will validate if profile creation can be dismissed after all channels are selected on profile creation wizard.
    Trigger Profile Creation For A Custom Profile With '${number_of_char}' Chars In Name
    I Press    OK
    Choose To Add '${number_of_channels}' Channels During Profile Creation

Trigger Profile Creation For '${number_of_char}' Char Custom Profile On Selecting '${number_of_genres}' Genres    #USED
    [Documentation]  User can go step back or cancel at any point.
    ...    In this step we will validate if profile creation can be dismissed after ${number_of_genres} are selected on profile creation wizard.
    Trigger Profile Creation For A Custom Profile With '${number_of_char}' Chars In Name
    I Press    OK
    I select the 'Skip' option in the 'Create a personal channel list' modal menu
    Choose To Add ${number_of_genres} Genre During Profile Creation

Dismiss Profile Creation    #USED
    [Documentation]  During profile creation user can go step back or cancel at any point.
    Repeat Keyword    3 times     I Press    MENU
    I Expect There Are No Custom Profiles Created

I Validate Profile Name And Profile Color In Live TV    #USED
    [Documentation]   The keyword checks the Profile Color and Name From Live TV is same as the one from backend
    I open Channel Bar
    ${profile_name_from_ui}   Get The Profile Name From Live TV
    ${profile_name_from_bo}   I Get The Active Profile Name
    Should Be Equal   ${profile_name_from_ui}     ${profile_name_from_bo}
    ${profile_color_from_ui}  Get The Profile Color From Live TV
    ${profile_color_from_bo}   I Get The Active Profile Color
    Should Be Equal     ${profile_color_from_ui}    ${profile_color_from_bo}

Validate Personal Line up Is Empty If All Channels Are Added To The Line-Up   #USED
    [Documentation]  The keyword checks whether the personal line is empty if it conatins the entire list of channels.
    ${personal_line_up}  Get Favourite Channels Id Available For Current Profile
    Should Be Empty    ${personal_line_up}

I Check '3+ Channels' Interactive Modal Is Shown    #USED
    [Documentation]  The keyword verifies the '3+ channels' interactive modal is displayed on screen
    wait until keyword succeeds    ${JSON_MAX_RETRIES}    ${JSON_RETRY_INTERVAL}    I expect page element 'id:interactiveModalPopup' contains 'textKey:DIC_PROFILE_LINEUP_EXIT_HEADER'

I Clear The Personal Line Up Channel List From Manage Profile Channel List    #USED
    [Documentation]  The keyword clears the personal line up channel list.
    ...    Precondition :   The Manage Profile Channel List Interactive modal pop up is shown.
    ...    Once the keyword is executed, Interactive modal with options 'Set up my channels' and 'Skip' is shown
    ${status}    Run Keyword And Return Status   I expect page element 'id:interactiveModalPopup' contains 'textKey:DIC_PROFILE_LINEUP_EXIT_HEADER'
    Run Keyword If   '${status}'=='True'    I Press   BACK
    I Focus The 'Clear List' Option In Manage Profile Channel List
    I Press   OK
    Wait Until Keyword Succeeds     ${JSON_MAX_RETRIES}    ${JSON_RETRY_INTERVAL}    I expect page contains 'textKey:DIC_MODEL_HEADER_CLEAR_PROFILES_LIST'
    Move to element assert focused elements    textKey:DIC_MODEL_BUTTON_CLEAR_PROFILES_LIST    2    DOWN
    I Press  OK
    Interactive modal with options 'Set up my channels' and 'Skip' is shown

I 'Confirm' To Add The Channels To Personal Line Up    #USED
    [Documentation]  The keyword adds the selected channel to personal line-up
    wait until keyword succeeds    ${JSON_MAX_RETRIES}    ${JSON_RETRY_INTERVAL}    I expect page contains 'id:Default.ValuePicker'
    I press    BACK
    'Manage profile channels list' interactive modal is shown
    Move to element assert focused elements     textKey:DIC_GENERIC_BTN_CONFIRM    3    RIGHT
    I press    OK
    I do not expect page contains 'id:Default.ValuePicker'

I Check 'Default profile on start-up' Is 'Not' Available   #USED
    [Documentation]  The keyword validates if the Default profile on start-up is not available on the Settings page
    ${status}    Run Keyword And Return Status    I focus 'Default profile on start-up'
    Should Not Be True   ${status}

Validate Manage Channels For Shared Profile   #USED
    [Documentation]   The keyword validates OK press on Manage Channels of a Shared Profile
    ...     If there are no custom profiles, Profile Creation page should be displayed
    ...     If there are any custom profiles, Profile Selection page should be displayed
    ...     Precondition :  Profile Settings page is displayed
    Wait Until Keyword Succeeds    ${JSON_MAX_RETRIES}    ${JSON_RETRY_INTERVAL}    I expect page contains 'textKey:DIC_SETTINGS'
    I focus 'Manage channels'
    I Press   OK
    ${profile_create_page}    Run Keyword And Return Status    'Create a profile' popup is shown
    ${profile_selection_list}   Run Keyword And Return Status     wait until keyword succeeds    ${JSON_MAX_RETRIES}    ${JSON_RETRY_INTERVAL}    I expect page element 'CURRENT_POPUP_LAYER:' contains 'id:profileList'
    Should Be True   ${profile_create_page} or ${profile_selection_list}

I Create A Profile With ${number_of_genres} Genres     #USED
    [Documentation]    The keyword creates a profile with n number of custom profiles
    Trigger Profile Creation For '${number_of_char}' Char Custom Profile On Selecting '${number_of_genres}' Genres
    I focus the 'End' option
    I press    OK
    'Choose your preferred genres' interactive modal is not shown

Dismiss Any Value Picker On Screen    #USED
    [Documentation]    The keyword dismiss any value picker displayed on screen
    ...   If the Manage Profile Channel List is displyed, it clear the selected channel list
    ...   Finally tunes to line TV
    ${is_on_personal_channel_list}    Run Keyword And Return Status   I expect page contains 'id:Default.ValuePicker'
    Run Keyword If  ${is_on_personal_channel_list}    I Press    BACK
    ${is_on_manage_channels_modal}    Run Keyword And Return Status    'Manage profile channels list' interactive modal is shown
    ${clear_list_button}    Run Keyword And Return Status   I expect page contains 'textKey:DIC_FAVOURITES_MENU_CLEAR'
    ${is_value_picker_handled}  Run Keyword And Return Status   Run Keyword If   ${is_on_manage_channels_modal} and ${clear_list_button}   I Choose 'Clear List' On Manage Personal Channels
    ${status}   Run Keyword And Return Status    I play LIVE TV
    ${is_menu_pressed}  Run Keyword And Return Status    Run Keyword If  not ${status}   I Press MENU 3 times
    Should Be True  ${is_value_picker_handled} or ${status} or ${is_menu_pressed}    Unable to handle the screen