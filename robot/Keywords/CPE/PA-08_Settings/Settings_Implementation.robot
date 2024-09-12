*** Settings ***
Documentation     Settings implementation keywords
Resource          ../Common/Common.robot
Resource          ../CommonPages/ValuePicker_Implementation.robot
Resource          ../CommonPages/Modal_Implementation.robot
Resource          ../PA-04_User_Interface/MainMenu_Keywords.robot
Resource          ../PA-08_Settings/System_Keywords.robot
Resource          ../PA-09_Parental_Control/Locked_Keywords.robot
Library           Libraries.MicroServices.PersonalizationService


*** Variables ***
${INCORRECT_PIN_ENTRY_LIMIT}    ${3}

*** Keywords ***
Move Focus to Setting
    [Arguments]    ${setting}    ${direction}    ${max_number_of_moves}=${DEFAULT_MAX_VALUE_PICKER_OPTIONS}
    [Documentation]    Navigate in a Settings Section to the setting identified by ${setting} through the direction specified by ${direction}
    ...    Accepts an optional ${max_number_of_moves} positional argument
    Move to element with text color    ${setting}    ${HIGHLIGHTED_NAVIGATION_COLOUR}    ${max_number_of_moves}    ${direction}

Setting is Focused      #USED
    [Arguments]    ${setting}
    [Documentation]    Validates is setting identified by ${setting} is Focused in the Settings Section
    wait until keyword succeeds    10s    1s    I expect page element '${setting}' has text color '${HIGHLIGHTED_NAVIGATION_COLOUR}'

Focus Profiles from any point in settings screen
    [Documentation]    This keyword focuses PROFILES header in Settings screen regardless of tab and item focused
    'PROFILES' is shown in Section Navigation
    Move Focus to the top level Section Navigation
    I focus Profiles

I focus Profiles
    [Documentation]    Keyword focuses Profiles in Settings
    Move Focus to Section    PROFILES    textValue

I open Profiles
    [Documentation]    Navigates to PROFILES header in SETTINGS screen
    'PROFILES' is shown in Section Navigation
    I focus Profiles
    Profiles is focused
    Profiles section is open

I open Profiles through Settings   #USED
    [Documentation]    Opens SETTINGS through Main Menu and navigates to PROFILES
    I open Settings through Main Menu
    I open Profiles

I focus 'Manage channels'
    [Documentation]    Keyword focuses 'Manage channels' in 'PROFILES'
    ...    Precondition: Should be on 'PROFILES' view
    Move to element and assert    textKey:DIC_SETTINGS_PROFILE_CHANNELS_LABEL    color    ${HIGHLIGHTED_NAVIGATION_COLOUR}    10    DOWN

I open Manage channels
    [Documentation]    Navigates to 'Manage channels' and opens it
    I focus 'Manage channels'
    I press    OK
    wait until keyword succeeds    ${JSON_MAX_RETRIES}    ${JSON_RETRY_INTERVAL}    I expect page contains 'textKey:(DIC_PROFILE_LINEUP_ADD_CHANNELS|DIC_PROFILES_HEADER)' using regular expressions

I open Sound&Image through Settings
    [Documentation]    Opens SETTINGS through Main Menu and navigates to IMAGE AND SOUND
    I open Settings through Main Menu
    I open Sound&Image

I focus System
    [Documentation]    Keyword focuses SYSTEM in Settings
    Move Focus to Section    ${DIC_SETTINGS_SYSTEM}    title

System is focused
    [Documentation]    Checks if System is focused
    Section is Focused    ${DIC_SETTINGS_SYSTEM}    title

I open System
    [Documentation]    Navigates to SYSTEM header in SETTINGS screen
    'SYSTEM' is shown in Section Navigation
    I focus System
    System is focused
    System section is open

I open System through Settings
    [Documentation]    Opens SETTINGS through Main Menu and navigates to SYSTEM
    I open Settings through Main Menu
    I open System

I focus Standby Power Consumption
    [Documentation]    Keyword focus Stand by option under SYSTEM
    Move Focus to Setting    textKey:DIC_SETTINGS_STANDBY_POWER_LABEL    DOWN

I focus 'Confirm' Factory reset
    [Documentation]    Keyword focuses 'Confirm' Factory reset option in the Factory reset popup
    Move Focus to Button in Modal    textKey:DIC_GENERIC_BTN_CONFIRM    DOWN

I focus Factory reset
    [Documentation]    Focuses Factory reset option under SYSTEM
    Move Focus to Setting    textKey:DIC_SETTINGS_FACTORY_RESET_LABEL    DOWN

I focus 'Cancel' Factory reset
    [Documentation]    Focuses cancel Factory reset option in the Factory reset popup
    Move Focus to Button in Modal    textKey:DIC_GENERIC_BTN_CANCEL    DOWN

Check if Replay TV is activated
    [Documentation]    Checks if Replay TV is activated.
    I open System through Settings
    ${replay_status}    i retrieve value for key 'dictionnaryValue' in element 'id:settingFieldValueText_3'
    [Return]    ${replay_status}

Activate Replay TV
    [Documentation]    Activates Replay TV setting
    Move Focus to Setting    textKey:DIC_SETTINGS_REPLAY_OPTIN_LABEL    DOWN
    I Press    OK
    Move Focus to Button in Modal    textKey:DIC_OPTIN_REPLAY_BTN_AGREE    DOWN    2
    I Press    OK
    wait until keyword succeeds    ${JSON_MAX_RETRIES}    ${JSON_RETRY_INTERVAL}    I expect page contains 'textKey:DIC_INFO_REPLAY_OPTIN_SUCCES_HEADER'
    I wait till the next event starts in ${REPLAY_EVENTS_CHANNEL}

I activate Replay TV
    [Documentation]    Checks if Replay TV is already activated. If not.. then activates it.
    ${replay_status}    Check if Replay TV is activated
    run keyword if    '${replay_status}' == 'Off'    Activate Replay TV

I focus Parental Control    #USED
    [Documentation]    Focuses Parental Control
    Move Focus to Section    ${DIC_SETTINGS_PARENTAL_CONTROL}    title

I open Lock Channels through Parental Control    #USED
    [Documentation]    Opens Channel Locking option under PARENTAL CONTROL
    I open Parental Control through Settings
    I open Lock Channels

I focus Lock Channels
    [Documentation]    Keyword focuse Channel locking
    Move Focus to Setting    textKey:DIC_SETTINGS_LOCK_CHANNELS_LABEL    DOWN

I focus Set Age Lock
    [Documentation]    Keyword focuses Set Age Lock
    Move Focus to Setting    textKey:DIC_SETTINGS_AGE_LOCK_LABEL    DOWN    5

Type a valid pin    #USED
    [Documentation]    Keyword enters security PIN
    ${current_pin}    get pin via personalization service    ${LAB_CONF}    ${CUSTOMER_ID}
    @{master_pin}    Split String To Characters    ${current_pin}
    : FOR    ${digit}    IN    @{master_pin}
    \    I Press    ${digit}

New Pin Updated In Backend    #USED
    [Documentation]    Keyword validate whether new PIN has been updated in personalization service
    ${current_pin}    get pin via personalization service    ${LAB_CONF}    ${CUSTOMER_ID}
    Should Be True     '${current_pin}'=='${newpin}'

Generate wrong pin
    [Arguments]    ${current_pin}
    [Documentation]    Generate a random PIN other than the current master PIN
    ${generatedpin}    Generate new pin
    run keyword if    '${generatedpin}' == '${current_pin}'    fail    Wrong pin is same to current pin
    [Return]    ${generatedpin}

Generate new pin
    [Documentation]    Generate Parental control master PIN realtime
    ${masterpin}    Generate Random String    4    [NUMBERS]
    LOG    ${masterpin}
    [Return]    ${masterpin}

Pin entry for factory reset popup is shown
    [Documentation]    This keyword asserts PIN entry popup modal window for Factory Reset
    wait until keyword succeeds    ${JSON_MAX_RETRIES}    ${JSON_RETRY_INTERVAL}    I expect page contains 'textKey:DIC_PIN_ENTRY_MESSAGE_FACTORY_RESET'

Factory reset popup is shown
    [Documentation]    This keyword asserts popup modal window for Factory Reset
    wait until keyword succeeds    ${JSON_MAX_RETRIES}    ${JSON_RETRY_INTERVAL}    I expect page element 'textKey:DIC_SETTINGS_FACTORY_RESET_LABEL' contains 'textValue:Factory reset'

I focus 'Clear list' for locked
    [Documentation]    Focuses Clear list button for locked
    Wait Until Keyword Succeeds    10 times    200 ms    I expect page contains 'textKey:DIC_LOCKED_MENU_CLEAR'
    Move Focus to Button in Modal    textKey:DIC_LOCKED_MENU_SELECT    UP    4
    Move Focus to Button in Modal    textKey:DIC_LOCKED_MENU_CLEAR    RIGHT    3

I focus 'Clear list' for favourites
    [Documentation]    Focuses Clear list button for favourites
    Wait Until Keyword Succeeds    10 times    200 ms    I expect page contains 'textKey:DIC_FAVOURITES_MENU_CLEAR'
    Move Focus to Button in Modal    textKey:DIC_FAVOURITES_MENU_SELECT    UP    4
    Move Focus to Button in Modal    textKey:DIC_FAVOURITES_MENU_CLEAR    RIGHT    3
    Should Be True    ${is_highlighted}

I focus Sound&Image
    [Documentation]    Navigate the cursor to IMAGE AND SOUND in SETTINGS
    Move Focus to Section    ${DIC_SETTINGS_SOUND_IMAGE}    title

I focus Change PIN    #USED
    [Documentation]    Focuses Change PIN
    Move Focus to Setting    textKey:DIC_SETTINGS_CHANGE_PIN_LABEL    DOWN

Info is highlighted
    [Documentation]    This keyword asserts info header is highlighted
    Section is Focused    DIC_HELP    title

Profiles section is open
    [Documentation]    This keyword asserts PREFERENCE screen is opened in settings
    wait until keyword succeeds    ${JSON_MAX_RETRIES}    ${JSON_RETRY_INTERVAL}    I expect page contains 'textKey:DIC_SETTINGS_PROFILE_CHANNELS_LABEL'

Parental Control section is open    #USED
    [Documentation]    This keyword asserts parental control screen is opened in settings
    wait until keyword succeeds    ${JSON_MAX_RETRIES}    ${JSON_RETRY_INTERVAL}    I expect page contains 'textKey:DIC_SETTINGS_CHANGE_PIN_LABEL'

System section is open
    [Documentation]    This keyword asserts system screen is opened in settings
    wait until keyword succeeds    ${JSON_MAX_RETRIES}    ${JSON_RETRY_INTERVAL}    I expect page contains 'textKey:DIC_SETTINGS_SLEEP_AFTER_LABEL'

Sound & Image section is open
    [Documentation]    This keyword asserts sound and image screen is opened in settings
    wait until keyword succeeds    ${JSON_MAX_RETRIES}    ${JSON_RETRY_INTERVAL}    I expect page contains 'textKey:DIC_SETTINGS_PRIM_VIDEO_OUTPUT_LABEL'

Info section is open
    [Documentation]    This keyword asserts info section is open
    wait until keyword succeeds    ${JSON_MAX_RETRIES}    ${JSON_RETRY_INTERVAL}    I expect page contains 'textKey:DIC_SETTINGS_HELP_LABEL'

Profiles is focused
    [Documentation]    Checks if PROFILES section is focused
    Section is Focused    ${DIC_SETTINGS_PROFILE}    title

Parental Control is focused    #USED
    [Documentation]    Checks if Parental Control is focused
    Section is Focused    ${DIC_SETTINGS_PARENTAL_CONTROL}    title

Sound & Image is focused
    [Documentation]    Checks if Sound & Image is focused
    Section is Focused    ${DIC_SETTINGS_SOUND_IMAGE}    title

I open Sound&Image
    [Documentation]    Navigates to IMAGE AND SOUND header in SETTINGS
    'IMAGE AND SOUND' is shown in Section Navigation
    I focus Sound&Image
    Sound & Image is focused
    Sound & Image section is open

I focus Subtitle options
    [Documentation]    Focuses Subtitle options
    Move Focus to Setting    textKey:DIC_SETTINGS_SUBTITLES_LABEL    DOWN    7

Secured Wi-Fi network is available
    [Documentation]    Checks if Secured Wi-Fi network is available
    Log    Secured Wi-Fi network is available
    Wait Until Keyword Succeeds    10 times    200 ms    I expect page contains 'id:value-picker'
    Wait Until Keyword Succeeds    10 times    200 ms    I expect page contains 'id:item-prefix-icon-2'
    ${index_found}    Set Variable    ${False}
    : FOR    ${index}    IN RANGE    ${2}    ${14}
    \    ${wifi_network_bgd}    I retrieve value for key 'background' in element 'id:item-prefix-icon-${index}'
    \    ${secured_wifi_found}    Evaluate    True if "wifi_lock_icon" in "${wifi_network_bgd['image']}" else False
    \    Exit For Loop If    ${secured_wifi_found} == ${True}
    \    I press    DOWN
    Should Be True    ${secured_wifi_found}
    Log    Secured Wi-Fi network is available End

Save the original CPE product list
    [Documentation]    Create and save list of all products available on this STB
    ${cpe_products}    Get CPE products    ${LAB_TYPE}    ${CPE_ID}
    set suite variable    ${CPE_PRODUCTS}

I perform factory reset through UI
    [Documentation]    Keyword to perform factory reset through UI
    Open Factory Reset From System Settings Menu
    I enter a valid pin for Factory reset
    Factory reset popup is shown
    I focus 'Confirm' Factory reset
    I Press    OK

I focus Standby timer
    [Documentation]    This keyword focuses Standby timer in System screen in Settings
    Move Focus to Setting    textKey:DIC_SETTINGS_SLEEP_AFTER_LABEL    DOWN    8

Get current standby mode
    [Documentation]    Read current standby mode set in stb
    I open System through Settings
    I focus Standby Power Consumption
    ${standbymode}    Read Standby Mode from Standby Power Consumption Menu
    [Return]    ${standbymode}

I focus Menu Language
    [Documentation]    Keyword focuses Menu Language
    Move Focus to Setting    id:titleText_1    DOWN    5

I focus Info
    [Documentation]    Focus Info tab
    Move Focus to Section    ${DIC_SETTINGS_INFO}    title

I open Info     #USED
    [Documentation]    Open Info tab
    'INFO' is shown in Section Navigation
    I focus Info
    I Press    OK
    Info section is open

I open About     #USED
    [Documentation]    Focus and open About tab
    I open Settings through Main Menu
    I focus Info
    Info is highlighted
    I focus About
    About is highlighted
    I press    OK
    About screen is opened

I focus About
    [Documentation]    Focus About tab
    Move Focus to Setting    textKey:${DIC_SETTINGS_ABOUT}    DOWN    8

About is highlighted
    [Documentation]    About screen is highlighted
    Setting is Focused    textKey:${DIC_SETTINGS_ABOUT}

About screen is opened
    [Documentation]    About screen is shown
    wait until keyword succeeds    ${JSON_MAX_RETRIES}    ${JSON_RETRY_INTERVAL}    I expect page contains 'textKey:${DIC_SETTINGS_DIAG_SW_VER}'

retrieve sw version from about screen
    [Documentation]    Get sw version from about screen
    ${json_object}    Get Ui Json
    ${node_id}    Extract Value For Key    ${json_object}    textKey:${DIC_SETTINGS_DIAG_SW_VER}    id
    @{splitted_string}    Split String    ${node_id}    separator=infoScreenListNodeLabel
    ${node_number}    set variable    @{splitted_string}[1]
    ${version}    Extract Value For Key    ${json_object}    id:infoScreenListNodeValue${node_number}    textValue
    ${version}    Convert To Lowercase    ${version}
    [Return]    ${version}

I focus Diagnostics     #USED
    [Documentation]    This keyword focuses Diagnostics in Info screen in Settings
    Move Focus to Setting    textKey:${DIC_SETTINGS_DIAG}    DOWN    8

Diagnostics is show     #USED
    [Documentation]    This keyword asserts 'Diagnostics' option is shown
    wait until keyword succeeds    ${JSON_MAX_RETRIES}    ${JSON_RETRY_INTERVAL}    I expect page contains 'textKey:${DIC_SETTINGS_DIAG}'

Adult programme PIN entry popup is shown
    [Documentation]    Checks if the Pin Entry popup has the correct title and text for Adult event
    Pin Entry popup is shown
    Default popup title is shown
    wait until keyword succeeds    ${JSON_MAX_RETRIES}    ${JSON_RETRY_INTERVAL}    I expect page element 'id:pinEntryModalPopupBody' contains 'textKey:DIC_PIN_BODY_ADULT_PROGRAMME'

Operator time-frame PIN entry popup is shown
    [Documentation]    Checks if the Pin Entry popup has the correct title and text for Operator locked time-frame
    Pin Entry popup is shown
    Default popup title is shown
    wait until keyword succeeds    ${JSON_MAX_RETRIES}    ${JSON_RETRY_INTERVAL}    I expect page element 'id:pinEntryModalPopupBody' contains 'textKey:DIC_PIN_BODY_OPERATOR_LOCK_TIMEBOX'

Default popup title is shown    #USED
    [Documentation]    Checks if the Pin Entry popup has the correct default title 'Please enter your PIN code'
    wait until keyword succeeds    ${JSON_MAX_RETRIES}    ${JSON_RETRY_INTERVAL}    I expect page element 'id:pinEntryModalPopupTitle' contains 'textKey:DIC_PLEASE_ENTER_YOUR_PIN_CODE'

I focus Cancel all scheduled recordings
    [Documentation]    Focus the Cancel all scheduled recordings item in Settings - System
    Move Focus to Setting    textKey:DIC_SETTINGS_DELETE_PLANNED_RECORDINGS_LABEL    DOWN

Interactive modal with options 'Cancel all recordings' and 'Close' is shown
    [Documentation]    This keyword asserts modal window with 'Cancel all recordings' and 'Close' options is shown
    Interactive modal is shown
    I expect page element 'id:interactiveModalButton0' contains 'textKey:DIC_MODEL_BUTTON_CANCEL_ALL_PLANNED_RECORDINGS'
    I expect page element 'id:interactiveModalButton1' contains 'textKey:DIC_GENERIC_BTN_CLOSE'

I focus 'Cancel all recordings' option
    [Documentation]    This keyword puts focus on the 'Cancel all recordings' option in the modal popup window
    Move Focus to Button in Modal    textKey:DIC_MODEL_BUTTON_CANCEL_ALL_PLANNED_RECORDINGS    UP    2

I press OK on 'Cancel all recordings' option
    [Documentation]    Focus and press OK on the Cancel all recordings button
    Wait Until Keyword Succeeds    ${JSON_MAX_RETRIES}    ${JSON_RETRY_INTERVAL}    Interactive modal with options 'Cancel all recordings' and 'Close' is shown
    I focus 'Cancel all recordings' option
    I press    OK
    Wait Until Keyword Succeeds    10 times    ${JSON_RETRY_INTERVAL}    I expect page contains 'id:pinEntryModalPopupTitle'

Ethernet Detection Suite Teardown
    [Documentation]    This keyword brings up the ethernet interface and follows the default teardown process
    I Make sure that STB detects ethernet connection
    Default Suite Teardown

Age Restricted PIN Entry Popup Is Shown    #USED
    [Documentation]    Checks if the Pin Entry popup has the correct title and text for Age Restricted asset
    Pin Entry popup is shown
    Default popup title is shown
    wait until keyword succeeds    ${JSON_MAX_RETRIES}    ${JSON_RETRY_INTERVAL}    I expect page element 'id:pinEntryModalPopupBody' contains 'textKey:DIC_PIN_BODY_AGE_LOCK'

I Focus Network    #USED
    [Documentation]    Navigate the cursor to NETWORK in SETTINGS
    Move Focus to Section    ${DIC_SETTINGS_NETWORK}    title

Network Is Focused    #USED
    [Documentation]    Checks if NETWORK is focused
    Section is Focused    ${DIC_SETTINGS_NETWORK}    title

Network Section Is Open    #USED
    [Documentation]    This keyword asserts parental control screen is opened in settings
    wait until keyword succeeds    ${JSON_MAX_RETRIES}    ${JSON_RETRY_INTERVAL}    I expect page contains 'textKey:DIC_SETTINGS_HN_CONNECTION_TYPE_LABEL'

I Focus Change Connection Type    #USED
    [Documentation]    Keyword focuse Change Connection Type
    Move Focus to Setting    textKey:DIC_SETTINGS_HN_CONNECTION_TYPE_LABEL    DOWN

I Focus Audio Description    #USED
    [Documentation]    Focuses Audio Description
    Move Focus to Setting    textKey:DIC_SETTINGS_AUDIO_DESCRIPTION_LABEL    DOWN

I Change Audio Description Value    #USED
    [Documentation]    This keyword will change and validate the Audio Description value
    ${json_object}    Get Ui Json
    ${ancestor}     I retrieve json ancestor of level '2' for element 'textKey:DIC_SETTINGS_AUDIO_DESCRIPTION_LABEL'
    ${audio_description_before}    Extract Value For Key    ${ancestor}    id:settingFieldValueText_\\d+    textKey    ${True}
    I Press    OK
    Wait Until Keyword Succeeds    10 times    1 sec    assert json changed    ${json_object}
    ${ancestor}     I retrieve json ancestor of level '2' for element 'textKey:DIC_SETTINGS_AUDIO_DESCRIPTION_LABEL'
    ${audio_description_after}    Extract Value For Key    ${ancestor}    id:settingFieldValueText_\\d+    textKey    ${True}
    Should Not Be True  '${audio_description_before}' == '${audio_description_after}'    unable to change audio description

Verify Contextual Menu Items For Settings Page    #USED
    [Documentation]    This keyword obtains the list of elements in settings contextual menu
    ...    and verifies that predefined setting shows up first and there is no duplication in options displayed.
    ...    Precondition: Settings is opened through main menu
    ${ui_json}    Get Ui Json
    ${is_contextual_menu_found}    Is In Json    ${ui_json}    ${EMPTY}    id:contextualMainMenu
    Should Be True    ${is_contextual_menu_found}    Settings contextual menu not found
    Wait Until Keyword Succeeds And Verify Status    10 times    500ms    Unable to find CMM elements in Settings    I expect page contains 'id:contextualMainMenu-navigationContainer-SETTINGS_elements_container'
    ${contextual_menu_options}    Extract Value For Key    ${ui_json}
    ...    id:contextualMainMenu-navigationContainer-SETTINGS_elements_container    children
    Should Not Be Equal    ${contextual_menu_options}    None    No options are found in contextual menu
    ${length}    Get Length    ${contextual_menu_options}
    ${settings_contextual_menu_option_keys}    Create List
    :FOR    ${i}    IN RANGE    0    ${length}
    \    ${option_name}    Extract Value For Key    ${contextual_menu_options[${i}]}    id:title-undefined    textKey
    \    Append To List    ${settings_contextual_menu_option_keys}    ${option_name}
    Should Not Be Empty    ${settings_contextual_menu_option_keys}    Could not fetch settings contextual menu options
    Should Be Equal As Strings    ${settings_contextual_menu_option_keys[${0}]}    DIC_SETTINGS_PROFILE_CHANNELS_LABEL
    ...    Predefined options are not showing up first in settings contextual menu
    List Should Not Contain Duplicates    ${settings_contextual_menu_option_keys}    Duplicate contextual menu option found
    Log    ${settings_contextual_menu_option_keys}
    Set Suite Variable    ${CURRENT_SETTINGS_CONTEXTUAL_MENU_OPTION_KEYS}    ${settings_contextual_menu_option_keys}

Navigate To A Setting Not Available In Contextual Menu Of Setting    #USED
    [Documentation]    This keyword navigates to a setting option that is not displayed in settings contextual menu
    ...    but is present in the available static list of settings options
    Variable Should Exist    ${CURRENT_SETTINGS_CONTEXTUAL_MENU_OPTION_KEYS}    current settings contextual menu state not saved in CURRENT_SETTINGS_CONTEXTUAL_MENU_OPTION_KEYS
    Variable Should Exist    @{SETTINGS_CONTEXTUAL_MENU_STATIC_OPTION_KEYS}    static list of settings options not saved in SETTINGS_CONTEXTUAL_MENU_STATIC_OPTION_KEYS
    ${setting_to_navigate}    Retrieve A Setting Not Present In Current Contextual Menu
    Run Keyword If    '${setting_to_navigate}'=='DIC_SETTINGS_DIAG_LABEL'    I Open Diagnostics Through Settings
    Run Keyword If    '${setting_to_navigate}'=='DIC_SETTINGS_CHANGE_PIN_LABEL'    I open Change PIN through 'PARENTAL CONTROL'
    Run Keyword If    '${setting_to_navigate}'=='DIC_SETTINGS_ABOUT_LABEL'    I open About
    Run Keyword If    '${setting_to_navigate}'=='DIC_SETTINGS_LOCK_CHANNELS_LABEL'    I open Lock Channels through Parental Control
    Run Keyword If    '${setting_to_navigate}'=='DIC_SETTINGS_FACTORY_RESET_LABEL'
    ...    Run Keywords    Open Factory Reset From System Settings    I select 'Cancel' Factory reset
    Run Keyword If    '${setting_to_navigate}'=='DIC_SETTINGS_HN_CONNECTION_TYPE_LABEL'    I open Change Connection Type through 'NETWORK'
    Run Keyword If    '${setting_to_navigate}'=='DIC_SETTINGS_AUDIO_DESCRIPTION_LABEL'    I Change Audio Description Value From 'PROFILE' Setting
    Set Suite Variable    ${LAST_SELECTED_SETTINGS_OPTION}    ${setting_to_navigate}

Retrieve A Setting Not Present In Current Contextual Menu    #USED
    [Documentation]    This keyword verifies the difference between current set of options displayed
    ...    in settings contextual menu and the static list of settings options
    Variable Should Exist    ${CURRENT_SETTINGS_CONTEXTUAL_MENU_OPTION_KEYS}    current settings contextual menu state not saved in CURRENT_SETTINGS_CONTEXTUAL_MENU_OPTION_KEYS
    Variable Should Exist    @{SETTINGS_CONTEXTUAL_MENU_STATIC_OPTION_KEYS}    static list of settings options options not saved in SETTINGS_CONTEXTUAL_MENU_STATIC_OPTION_KEYS
    :FOR    ${item}    IN    @{SETTINGS_CONTEXTUAL_MENU_STATIC_OPTION_KEYS}
    \    ${is_in_list}    Run Keyword And Return Status    List Should Contain Value    ${CURRENT_SETTINGS_CONTEXTUAL_MENU_OPTION_KEYS}
    ...    ${item}
    \    Exit For Loop If    ${is_in_list}==${False}
    Should Not Be True    ${is_in_list}    No difference between current setting contextual menu options and the static list
    [Return]    ${item}

Verify That Last Visited Setting Is Available In Settings Contextual Menu    #USED
    [Documentation]    This keyword verifies that the last visited setting option is reflected in settings contextual menu
    ...    in such a way that it appears just after predefined settings options.
    [Arguments]    ${last_visited_setting}
    Verify Contextual Menu Items For Settings Page
    Should Be Equal As Strings    ${last_visited_setting}    ${CURRENT_SETTINGS_CONTEXTUAL_MENU_OPTION_KEYS[${1}]}
    ...    last visited option is not available in settings contextual menu