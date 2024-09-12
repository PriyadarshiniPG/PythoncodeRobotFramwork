*** Settings ***
Documentation     Setting keywords
Resource          ../PA-08_Settings/Settings_Implementation.robot

*** Keywords ***
UI is responding
    [Documentation]    Navigates through all main functionality to check if content is available
    I open Main Menu
    I open Guide
    I open Channel Bar
    I tune to a channel with replay events
    I focus past replay event
    I open replay player
    About to start screen is shown
    I open On Demand through Main Menu

STB entitlements are refreshed and active
    [Documentation]    This keyword check if products are still active by comparing new product list with previous one
    ...    Precondition: The ${CPE_PRODUCTS} variable must have been set before.
    Variable should exist    ${CPE_PRODUCTS}    Previously product list was not saved.
    ${new_cpe_products}    Get CPE products    ${LAB_TYPE}    ${CPE_ID}
    Should Be Equal    ${CPE_PRODUCTS}    ${new_cpe_products}    Previous product list and new product list are not equal

I open Settings through Main Menu   #USED
    [Documentation]    Opens SETTINGS through MAIN MENU
    I open Main Menu
    I open Settings

I Focus On Settings In Main Menu    #USED
    [Documentation]    I focus on settings option in main menu
    I open Main Menu
    I focus Settings

I open Settings     #USED
    [Documentation]    This keyword opens SETTINGS and focus Preferences header
    I focus Settings
    I Press    OK
    Settings screen is shown
    Focus Profiles from any point in settings screen

Settings screen is shown    #USED
    [Documentation]    Checks if SETTINGS screen is shown
    wait until keyword succeeds    ${JSON_MAX_RETRIES}    ${JSON_RETRY_INTERVAL}    I expect page contains 'id:Settings.View'

I open Parental Control through Settings    #USED
    [Documentation]    Navigates to PARENTAL CONTROL header in SETTINGS screen
    I open Settings through Main Menu
    I open Parental Control

I select 'Cancel' Factory reset   #USED
    [Documentation]    Focus and select cancel Factory reset option in the Factory reset popup
    ${is_keep_recording_pop_up}   Run Keyword And Return Status   Wait Until Keyword Succeeds    ${JSON_MAX_RETRIES}    ${JSON_RETRY_INTERVAL}    I expect page contains 'textKey:DIC_FACTORY_RESET_MESSAGE_ASK_KEEP_RECORDINGS'
    Run Keyword If    ${is_keep_recording_pop_up}    Run Keywords    Move To Element Assert Provided Element Is Highlighted    textKey:DIC_FACTORY_RESET_BTN_KEEP    3    UP
    ...    AND    I Press  OK
    I focus 'Cancel' Factory reset
    I press    OK

I open Parental Control    #USED
    [Documentation]    Navigates to PARENTAL CONTROL header in SETTINGS screen
    'PARENTAL CONTROL' is shown in Section Navigation
    I focus Parental Control
    Parental Control is focused
    Parental Control section is open

I open Lock Channels    #USED
    [Documentation]    Change focus and opens Channel Locking
    I focus Lock Channels
    I Press    OK

I generate a new pin    #USED
    [Documentation]    Generate and set new PIN
    ${generatedpin}    Generate new pin
    Set Suite Variable    ${newpin}    ${generatedpin}

I enter a new valid pin in the change pin popup
    [Documentation]    Generate a random PIN other than the current master PIN, and enter it in the popup
    wait until keyword succeeds    10sec    ${JSON_RETRY_INTERVAL}    I expect page element 'id:pinEntryModalPopupBody' contains 'textKey:DIC_PIN_ENTRY_MESSAGE_ENTER_NEW'
    I generate a new pin
    I enter the new valid pin
    I Press    OK
    'Please enter your new PIN again' is shown
    I enter the new valid pin

I Enter A Randomly Generate Valid Pin In The Change Pin Popup    #USED
    [Documentation]    Generate a random PIN other than the current master PIN, and enter it in the popup
    wait until keyword succeeds    10sec    ${JSON_RETRY_INTERVAL}    I expect page element 'id:pinEntryModalPopupBody' contains 'textKey:DIC_PIN_ENTRY_MESSAGE_PC'
    I enter a valid PIN
    wait until keyword succeeds    10sec    ${JSON_RETRY_INTERVAL}    I expect page element 'id:pinEntryModalPopupBody' contains 'textKey:DIC_PIN_ENTRY_MESSAGE_ENTER_NEW'
    I generate a new pin
    I enter the new valid pin
    I Press    OK
    'Please enter your new PIN again' is shown
    I enter the new valid pin

PIN is changed
    [Documentation]    Verify PIN is changed, and new change is effective immediately
    'PIN changed' toast message is shown
    I open Channel Bar
    I open Parental control through Settings
    I open Change PIN
    I enter a valid PIN
    I Press    OK
    'Please enter your new PIN again' is shown
    I Press    BACK
    Pin Entry popup is not shown

I Validate PIN Is Changed    #USED
    [Documentation]    Verify PIN is changed, and new change is effective immediately
    'PIN changed' toast message is shown
    New Pin Updated In Backend
    I open Channel Bar
    I open Parental control through Settings
    I open Change PIN
    I enter a valid PIN
    I Press    OK
    'Please enter your new PIN again' is shown
    I Press    BACK
    Pin Entry popup is not shown

I enter the new valid pin    #USED
    [Documentation]    Enters the new valid PIN saved
    Variable should exist    ${newpin}    New PIN number was not generated
    LOG    ${newpin}
    @{digits}    Split String To Characters    ${newpin}
    : FOR    ${digit}    IN    @{digits}
    \    I Press    ${digit}

I enter a wrong pin
    [Documentation]    Enters a wrong PIN
    ...    This keyword also checks if the highlighted field is updated after each number entry and verifies if the maximum pin entry limit is reached
    ${current_pin}    get pin    ${CPE_ID}
    ${generatedpin}    wait until keyword succeeds    2min    3s    Generate wrong pin    ${current_pin}
    LOG    ${generatedpin}
    @{digits}    Split String To Characters    ${generatedpin}
    : FOR    ${index}    IN RANGE    ${4}
    \    wait until keyword succeeds    5 times    ${MOVE_ANIMATION_DELAY} ms    I expect page element 'id:pinEl${index+1}-dot' contains 'opacity:255'
    \    I Press    @{digits}[${index}]
    \    run keyword if    ${index} < ${3}    wait until keyword succeeds    6 times    ${MOVE_ANIMATION_DELAY} ms    I expect page element 'id:pinEl${index+1}-asterisk' contains 'opacity:255'
    set suite variable    ${INCORRECT_PIN_ENTRY_LIMIT}    ${INCORRECT_PIN_ENTRY_LIMIT-1}
    run keyword if    ${INCORRECT_PIN_ENTRY_LIMIT} > ${0}    wait until keyword succeeds    6 times    ${MOVE_ANIMATION_DELAY} ms    I expect page contains 'textKey:DIC_PIN_ENTRY_MESSAGE_ATTEMPTS_LEFT'
    ...    ELSE    wait until keyword succeeds    6 times    ${MOVE_ANIMATION_DELAY} ms    I expect page contains 'textKey:DIC_PIN_ENTRY_MESSAGE_LOCKED'
    wait until keyword succeeds    5 times    ${MOVE_ANIMATION_DELAY} ms    I expect page element 'id:pinEl1-dot' contains 'opacity:255'

I enter a valid pin    #USED
    [Documentation]    This keyword enters the valid PIN into modal popup window
    Pin Entry popup is shown
    Type a valid pin

I enter a valid pin for Factory reset
    [Documentation]    Enters a valid PIN in the pop-up at Factory Reset
    Pin entry for factory reset popup is shown
    Type a valid pin

Pin Entry popup is shown    #USED
    [Documentation]    Checks if PIN Entry popup is shown
    wait until keyword succeeds    10 times    500 ms    I expect page contains 'id:pinEntryModalPopupTitle'

Pin Entry popup is not shown    #USED
    [Documentation]    This keyword asserts PIN entry popup is not shown
    wait until keyword succeeds    10 times    1 sec    I do not expect page contains 'id:pinEntryModalPopupTitle'

Wrong Pin Entry popup is shown
    [Documentation]    This keyword asserts popup modal window for wrong PIN is shown
    wait until keyword succeeds    10 times    1 sec    I expect page element 'textKey:DIC_PIN_ENTRY_MESSAGE_ATTEMPTS_LEFT' contains 'textValue:^.*\\\\d*$' using regular expressions

Wrong Pin Entry popup is not shown
    [Documentation]    This keyword asserts popup modal window for wrong PIN is not shown
    wait until keyword succeeds    10 times    1 sec    I do not expect page element 'textKey:DIC_PIN_ENTRY_MESSAGE_ATTEMPTS_LEFT' contains 'textValue:^.*\\\\d*$' using regular expressions

Pin Entry Blocked popup is shown
    [Documentation]    This keyword asserts popup modal window for Blocked PIN Entry
    wait until keyword succeeds    ${JSON_MAX_RETRIES}    ${JSON_RETRY_INTERVAL}    I expect page element 'textKey:DIC_PIN_ENTRY_MESSAGE_LOCKED' contains 'textValue:^.+$' using regular expressions

The Processing screen for FTI is shown
    [Documentation]    This keyword checks for the FTI processing screen when performed through UI
    wait until keyword succeeds    ${JSON_MAX_RETRIES}    ${JSON_RETRY_INTERVAL}    I expect page contains 'textKey:DIC_SETTINGS_FACTORY_RESET_HINT'

I open Change PIN through 'PARENTAL CONTROL'    #USED
    [Documentation]    Opens Change PIN option under PARENTAL CONTROL
    I open Parental Control through Settings
    I open Change PIN

I open Change PIN    #USED
    [Documentation]    Navigate down to Change PIN option and selects the option
    I focus Change PIN
    I Press    OK
    Pin Entry popup is shown

'Please enter a new 4 digit PIN' code is shown
    [Documentation]    This keyword asserts if the modal pop-up contains message 'Please enter a new 4-digit PIN'
    wait until keyword succeeds    10 times    ${JSON_RETRY_INTERVAL}    I expect page contains 'textKey:DIC_PIN_ENTRY_HEADER_CHANGE'

'Please enter your new PIN again' is shown    #USED
    [Documentation]    This keyword asserts if the modal pop-up contains message 'Please enter a your new PIN again'
    wait until keyword succeeds    ${JSON_MAX_RETRIES}    ${JSON_RETRY_INTERVAL}    I expect page contains 'textKey:DIC_PIN_ENTRY_HEADER_CHANGE'

'PIN changed' toast message is shown
    [Documentation]    This keyword asserts if the toast message for Successfull PIN change is shown
    wait until keyword succeeds    10 times    ${JSON_RETRY_INTERVAL}    I expect page contains 'textKey:DIC_MESSAGE_PIN_CHANGE_SUCCESS'

'PROFILES' is shown in Section Navigation
    [Documentation]    This keyword asserts PROFILES header is shown
    wait until keyword succeeds    ${JSON_MAX_RETRIES}    ${JSON_RETRY_INTERVAL}    I expect page contains 'textKey:${DIC_SETTINGS_PROFILE}'

'PARENTAL CONTROL' is shown in Section Navigation    #USED
    [Documentation]    This keyword asserts parental control header is shown
    wait until keyword succeeds    ${JSON_MAX_RETRIES}    ${JSON_RETRY_INTERVAL}    I expect page contains 'textKey:${DIC_SETTINGS_PARENTAL_CONTROL}'

'SYSTEM' is shown in Section Navigation
    [Documentation]    This keyword asserts system header is shown
    wait until keyword succeeds    ${JSON_MAX_RETRIES}    ${JSON_RETRY_INTERVAL}    I expect page contains 'textKey:${DIC_SETTINGS_SYSTEM}'

'IMAGE AND SOUND' is shown in Section Navigation
    [Documentation]    This keyword asserts sound and image header is shown
    wait until keyword succeeds    ${JSON_MAX_RETRIES}    ${JSON_RETRY_INTERVAL}    I expect page contains 'textKey:${DIC_SETTINGS_SOUND_IMAGE}'

'NETWORK' is shown in Section Navigation
    [Documentation]    This keyword asserts network header is shown
    wait until keyword succeeds    ${JSON_MAX_RETRIES}    ${JSON_RETRY_INTERVAL}    I expect page contains 'textKey:${DIC_SETTINGS_NETWORK}'

'INFO' is shown in Section Navigation
    [Documentation]    This keyword asserts info header is shown
    wait until keyword succeeds    ${JSON_MAX_RETRIES}    ${JSON_RETRY_INTERVAL}    I expect page contains 'textKey:DIC_HELP'

Open Factory Reset From System Settings
    [Documentation]    Initiate factory reset from System Settings menu
    I open System through Settings
    I focus Factory reset
    I Press    OK
    I enter a valid pin for Factory reset

The preferred standby setting is set to
    [Arguments]    ${new_standbymode}
    [Documentation]    To set the standby settings in the stb
    ${current_standbymode}    Get current standby mode
    ${matches}    Get Regexp Matches    ${current_standbymode}    ${new_standbymode}
    ${is_mode_found}    Run Keyword And Return Status    Should Not Be Empty    ${matches}    standby mode not matched for now
    return from keyword if    ${is_mode_found}
    I Press    OK
    repeat keyword    3 times    I press    UP
    Move Focus to Option in Value Picker    textKey:${${new_standbymode}}    DOWN    4
    I Press    OK

The standby timer is set to
    [Arguments]    ${prefered_standby_timer}
    [Documentation]    To set the 'standby timer' settings in the stb
    I open System through Settings
    I focus Standby timer
    ${current_standby_timer}    Read Current Standby Timer from Current Standby Menu
    LOG    ${current_standby_timer}
    return from keyword if    '${current_standby_timer}' == '${prefered_standby_timer}'
    I Press    OK
    repeat keyword    4 times    press key    UP
    ${new_standbytimer_id_action_menu}    Read Standby Power Consumption Element from System Page    ${prefered_standby_timer}
    Move Focus to Option in Value Picker    id:picker-item-text-${new_standbytimer_id_action_menu}    DOWN    4
    I Press    OK

Info screen is shown
    [Documentation]    Info screen is shown
    wait until keyword succeeds    ${JSON_MAX_RETRIES}    ${JSON_RETRY_INTERVAL}    I expect page element 'id:settingsSubMenuContainer2' contains 'textValue:Diagnostics'

I open Diagnostics  #USED
    [Documentation]    Opens 'Diagnostics' option under INFO header
    I focus Diagnostics
    I Press    OK
    Diagnostics is show

I open Diagnostics through Info     #USED
    [Documentation]    Navigates and selects 'Diagnostics' option under INFO header
    I open Info
    I open Diagnostics

I Open Diagnostics Through Settings    #USED
    [Documentation]    Navigates to diagnostic option through settings option in main menu
    I open Settings through Main Menu
    I open Diagnostics through Info

Pin Entry popup is dismissed
    [Documentation]    This keyword verifies that the PIN entry pop up is not shown
    Pin Entry popup is not shown

Operator PIN entry popup is shown
    [Documentation]    Checks if the Pin Entry popup has the correct title and text for Operator Locked Channel
    Pin Entry popup is shown
    Default popup title is shown
    wait until keyword succeeds    ${JSON_MAX_RETRIES}    ${JSON_RETRY_INTERVAL}    I expect page element 'id:pinEntryModalPopupBody' contains 'textKey:DIC_PIN_BODY_OPERATOR_LOCK'

Adult channel PIN entry popup is shown
    [Documentation]    Checks if the Pin Entry popup has the correct title and text for Adult Channel
    Pin Entry popup is shown
    Default popup title is shown
    wait until keyword succeeds    ${JSON_MAX_RETRIES}    ${JSON_RETRY_INTERVAL}    I expect page element 'id:pinEntryModalPopupBody' contains 'textKey:DIC_PIN_BODY_ADULT_CHANNEL'

Reset pin attempts via as in teardown
    [Documentation]    This keywords clears the failed pin attempts count and resets the pin timeout via application
    ...    services, changing the pinSuspensionTimeout setting to 0 and reverting the change.
    ...    Calling 'get remaining pin attempts via AS' is needed for the attempts to refresh when setting the timeout
    ${original_timeout}    get pin suspension timeout via as    ${STB_IP}    ${CPE_ID}
    Wait Until Keyword Succeeds    3times    1 sec    set pin suspension timeout via as    ${STB_IP}    ${CPE_ID}    timeout=${0}
    ...    xap=${XAP}
    get remaining pin attempts via as    ${STB_IP}    ${CPE_ID}    xap=${XAP}
    Wait Until Keyword Succeeds    3times    1 sec    set pin suspension timeout via as    ${STB_IP}    ${CPE_ID}    timeout=${original_timeout}
    ...    xap=${XAP}

I enter a valid PIN on Adult channel PIN entry popup
    [Documentation]    This keyword checks for adult pin entry popup and enters the pin
    adult channel pin entry popup is shown
    I enter a valid PIN

I enter a valid PIN on Operator time-frame Pin Entry popup
    [Documentation]    This keyword checks for Operator time-frame pin entry popup and enters the pin
    Operator time-frame PIN entry popup is shown
    I enter a valid PIN

I enter a valid PIN on Operator Pin Entry popup
    [Documentation]    This keyword checks for Operator pin entry popup and enters the pin
    Operator PIN entry popup is shown
    I enter a valid PIN

I enter a valid PIN on Adult programme Pin Entry popup
    [Documentation]    This keyword checks for Adult programme PIN entry popup and enters the pin
    Adult programme PIN entry popup is shown
    I enter a valid pin

I focus Settings through Contextual Main Menu
    [Documentation]    Checks if Main Menu is focused
    I open Main Menu
    I focus Settings
    I expect page element 'id:contextualMainMenu-navigationContainer-SETTINGS_title_0' contains 'textKey:DIC_CONTEXTUAL_MAIN_MENU_INITIAL_SETTINGS'

I open first tile
    [Documentation]    Opens the first tile
    I Press    DOWN
    I Press    OK
    I wait for 2 seconds

Primary video setting is HDMI
    [Documentation]    This changes the Primary Video setting on the STB to HDMI from settings area
    I open Sound&Image through Settings
    Move Focus to Setting    textKey:DIC_SETTINGS_PRIM_VIDEO_OUTPUT_LABEL    DOWN
    I Press    OK
    wait until keyword succeeds    ${JSON_MAX_RETRIES}    ${JSON_RETRY_INTERVAL}    Layer is not empty    CURRENT_POPUP_LAYER    ${False}
    I Press    OK
    Wait until keyword succeeds    ${JSON_MAX_RETRIES}    ${JSON_RETRY_INTERVAL}    I expect page element 'id:settingFieldValueText_0' contains 'textKey:DIC_SETTINGS_HDMI'

4:3 handling set to Full Mode
    [Documentation]    This changes the aspect ratio of 4:3 handling to Full mode
    I open Sound&Image through Settings
    Move Focus to Setting    textKey:DIC_SETTINGS_43_HANDLING_LABEL    DOWN
    I Press    OK
    wait until keyword succeeds    ${JSON_MAX_RETRIES}    ${JSON_RETRY_INTERVAL}    Layer is not empty    CURRENT_POPUP_LAYER    ${False}
    Move Focus to First Option in Value Picker
    I Press    OK
    wait until keyword succeeds    ${JSON_MAX_RETRIES}    ${JSON_RETRY_INTERVAL}    I expect page element 'id:settingFieldValueText_2' contains 'textKey:DIC_SETTINGS_TV_FORMAT_FULL_SCREEN' using regular expressions

4:3 handling set to Zoom Mode
    [Documentation]    This changes the aspect ratio of 4:3 handling to Zoom mode
    4:3 handling set to Full Mode
    I Press    OK
    wait until keyword succeeds    ${JSON_MAX_RETRIES}    ${JSON_RETRY_INTERVAL}    Layer is not empty    CURRENT_POPUP_LAYER    ${False}
    Move Focus to Option in Value Picker    textKey:DIC_SETTINGS_TV_FORMAT_ZOOM    DOWN    3
    I Press    OK
    wait until keyword succeeds    ${JSON_MAX_RETRIES}    ${JSON_RETRY_INTERVAL}    I expect page element 'id:settingFieldValueText_2' contains 'textKey:DIC_SETTINGS_TV_FORMAT_ZOOM' using regular expressions

4:3 handling set to Bars
    [Documentation]    This changes the aspect ratio of 4:3 handling to Bars
    4:3 handling set to Full Mode
    I Press    OK
    wait until keyword succeeds    ${JSON_MAX_RETRIES}    ${JSON_RETRY_INTERVAL}    Layer is not empty    CURRENT_POPUP_LAYER    ${False}
    Move Focus to Option in Value Picker    textKey:DIC_SETTINGS_TV_FORMAT_PILLAR_BOX    DOWN    2
    I Press    OK
    wait until keyword succeeds    ${JSON_MAX_RETRIES}    ${JSON_RETRY_INTERVAL}    I expect page element 'id:settingFieldValueText_2' contains 'textKey:DIC_SETTINGS_TV_FORMAT_PILLAR_BOX' using regular expressions

I Confirm cancellation of Scheduled recordings by entering pin
    [Documentation]    Open Cancel all recordings and confirm the cancellation by entering PIN
    I press OK on 'Cancel all recordings' option
    I enter a valid pin
    Wait Until Keyword Succeeds    10 times    ${JSON_RETRY_INTERVAL}    I expect page contains 'textKey:DIC_TOAST_CANCEL_ALL_PLANNED_RECORDINGS'
    Wait Until Keyword Succeeds    10 times    ${JSON_RETRY_INTERVAL}    I expect page contains 'textKey:DIC_TOAST_ALL_PLANNED_RECORDINGS_CANCELLED'

I open Cancel all scheduled recordings from Settings
    [Documentation]    Navigate to Settings and click OK to open the Cancel all scheduled recordings modal
    I open System through Settings
    I focus Cancel all scheduled recordings
    I press    OK
    Wait Until Keyword Succeeds    ${JSON_MAX_RETRIES}    ${JSON_RETRY_INTERVAL}    Interactive modal with options 'Cancel all recordings' and 'Close' is shown

'Incorrect PIN. You have ${number_of_attempts} attempt(s) left.' is displayed
    [Documentation]    Verifies if the 'Incorrect PIN. You have x attempt(s) left.' is being displayed when an incorrect PIN has been entered when trying to factory reset
    wait until keyword succeeds    ${JSON_MAX_RETRIES}    ${JSON_RETRY_INTERVAL}    I expect page element 'textKey:DIC_PIN_ENTRY_MESSAGE_ATTEMPTS_LEFT' contains 'textValue:Incorrect PIN. You have ${number_of_attempts} attempt(s) left.'

Factory reset confirmation popup is not shown
    [Documentation]    Checks the Factory reset windows is not being displayed
    I do not expect page contains 'textKey:DIC_FACTORY_RESET_MESSAGE_CONFIRM_HDDLESS'

I am presented with the currently playing programme information
    [Documentation]    Checks the playing programme title header and current time are displayed
    Header Is Shown For Linear Player
    wait until keyword succeeds    ${JSON_MAX_RETRIES}    ${JSON_RETRY_INTERVAL}    I expect page element 'id:mastheadTime' contains 'textValue:^.+$' using regular expressions
    ${time}    I retrieve value for key 'textValue' in element 'id:mastheadTime'
    Should Match Regexp    ${time}    ^[0-2][0-9]:[0-9][0-9]$

I can see the current screen title
    [Documentation]    Checks the current screen title is displayed
    wait until keyword succeeds    ${JSON_MAX_RETRIES}    ${JSON_RETRY_INTERVAL}    I expect page element 'id:mastheadScreenTitle' contains 'textValue:^.+$' using regular expressions

Validate all details on Diagnostics Screen  #USED
    [Documentation]    Check for the Signal Quality, Connection type (Ethernet|Wi-Fi), IPv4/IPv6 address, DHCP server address & DNS server 1 and 2 addresses
    Check signal strength
    Check internet connectivity
    Check IPv4 address
    Check IPv6 address
    Check DHCP server
    Check DNS Server1
    Check DNS Server2

Check signal strength   #USED
    [Documentation]    Checks for signal strength on CPE
    wait until keyword succeeds    ${JSON_MAX_RETRIES}    ${JSON_RETRY_INTERVAL}    I expect page contains 'textKey:DIC_SETTINGS_DIAG_SIGNAL_QUALITY'
    ${signal_strength}    I retrieve value for key 'textValue' in element 'id:valueText-0' using regular expressions
    log to console  \n Signal Strenth = ${signal_strength}

Check internet connectivity     #USED
    [Documentation]    Checks for internet connectivity on CPE ETHERNET OR WI-FI
    wait until keyword succeeds    ${JSON_MAX_RETRIES}    ${JSON_RETRY_INTERVAL}    I expect page contains 'textKey:DIC_DIAGNOSTICS_STRING_CONNECTIVITY'
    ${connect_type}    I retrieve value for key 'textValue' in element 'id:valueText-1' using regular expressions
    log to console  \n Internet Connectivity Type= ${connect_type}

Check IPv4 address  #USED
    [Documentation]    Checks for IPV4 address
    wait until keyword succeeds    ${JSON_MAX_RETRIES}    ${JSON_RETRY_INTERVAL}    I expect page contains 'textKey:DIC_SETTINGS_NW_INFO_LABEL_IP4_ADDRESS'
    ${IPV4_addr}    I retrieve value for key 'textValue' in element 'id:valueText-2' using regular expressions
    log to console  \n IPv4 address= ${IPV4_addr}

Check IPv6 address  #USED
    [Documentation]    Checks for IPV6 address
    wait until keyword succeeds    ${JSON_MAX_RETRIES}    ${JSON_RETRY_INTERVAL}    I expect page contains 'textKey:DIC_SETTINGS_NW_INFO_LABEL_IP6_ADDRESS'
    ${IPV6_addr}    I retrieve value for key 'textValue' in element 'id:valueText-4' using regular expressions
    log to console  \n IPv6 address= ${IPV6_addr}

Check DHCP server   #USED
    [Documentation]    Checks for DHCP Server IP
    wait until keyword succeeds    ${JSON_MAX_RETRIES}    ${JSON_RETRY_INTERVAL}    I expect page contains 'textKey:DIC_SETTINGS_NW_INFO_LABEL_DHCP_SERVER'
    ${IPV6_addr}    I retrieve value for key 'textValue' in element 'id:valueText-6' using regular expressions
    log to console  \n DHCP server IP= ${IPV6_addr}

Check DNS Server1   #USED
    [Documentation]    Checks for DNS Server 1 IP
    wait until keyword succeeds    ${JSON_MAX_RETRIES}    ${JSON_RETRY_INTERVAL}    I expect page contains 'textKey:DIC_SETTINGS_NW_INFO_LABEL_DNS_SERVER_1'
    ${IPV6_addr}    I retrieve value for key 'textValue' in element 'id:valueText-7' using regular expressions
    log to console  \n DNS Server1 IP= ${IPV6_addr}

Check DNS Server2   #USED
    [Documentation]    Checks for DNS Server 2 IP
    wait until keyword succeeds    ${JSON_MAX_RETRIES}    ${JSON_RETRY_INTERVAL}    I expect page contains 'textKey:DIC_SETTINGS_NW_INFO_LABEL_DNS_SERVER_2'
    ${IPV6_addr}    I retrieve value for key 'textValue' in element 'id:valueText-8' using regular expressions
    log to console  \n DNS Server2 IP= ${IPV6_addr}

Change your pin
    [Documentation]    Randomly generate a new 4 digit pin and validate with toast message and by navigating again on chnage pin screen
    I enter a new valid pin in the change pin popup
    PIN is changed

Change Your Pin With Randomly Generate Pin     #USED
    [Documentation]    Randomly generate a new 4 digit pin and change in the pin screen
    I Enter A Randomly Generate Valid Pin In The Change Pin Popup

I Enter A Valid PIN On Age Rated Pin Entry Popup    #USED
    [Documentation]    This keyword checks for Age Rated PIN entry popup and enters the pin
    Age Restricted PIN Entry Popup Is Shown
    I enter a valid pin

I Open Change Connection Type through 'NETWORK'    #USED
    [Documentation]    Opens Change PIN option under PARENTAL CONTROL
    I Open Network Through Settings
    I Open Change Connection Type

I Open Change Connection Type    #USED
    [Documentation]    Change focus and opens Change Connection Type
    I Focus Change Connection Type
    I Press    OK
    Wait Until Keyword Succeeds    ${JSON_MAX_RETRIES}    ${JSON_RETRY_INTERVAL}    I expect page contains 'textKey:DIC_OLD_HOME_NETWORK_SETUP_WIZARD'

I Open Network Through Settings    #USED
    [Documentation]    This keyword naviagte to Network Tab through Setting
    I open Settings through Main Menu
    I Open Network

I Open Network    #USED
    [Documentation]    Open and validate Network tab
    'NETWORK' is shown in Section Navigation
    I Focus Network
    Network Is Focused
    Network Section Is Open

I Change Audio Description Value From 'PROFILE' Setting    #USED
    [Documentation]    This keyword naviagte to Audio Description under PROFILE tab through setting
    I open Profiles through Settings
    I Focus Audio Description
    Wait Until Keyword Succeeds    ${JSON_MAX_RETRIES}    ${JSON_RETRY_INTERVAL}    I Change Audio Description Value

I Verify Contextual Menu Items For Settings Page    #USED
    [Documentation]    This keyword obtains the list of elements in settings contextual menu
    ...    and verifies that predefined setting shows up first and there is no duplication in options displayed.
    ...    Precondition: Settings is opened through main menu
    Verify Contextual Menu Items For Settings Page

I Navigate To A Setting Not Available In Contextual Menu Of Setting    #USED
    [Documentation]    This keyword navigates to a setting option that is not displayed in settings contextual menu
    ...    but is present in the available static list of settings options
    Navigate To A Setting Not Available In Contextual Menu Of Setting

I Verify Last Visited '${last_visited_setting}' Setting Is Available In Setting Contextual Menu    #USED
    [Documentation]    This keyword verifies that the last visited setting option is reflected in settings contextual menu
    ...    in such a way that it appears just after predefined settings options.
    Verify That Last Visited Setting Is Available In Settings Contextual Menu    ${last_visited_setting}

Validate NetflixESN Key Available In About     #USED
    [Documentation]    Validate netflix ESN key present in About screen with the ESN retrieve from AS
    Retrieve NetflixESN Key Via AS
    Wait Until Keyword Succeeds    ${JSON_MAX_RETRIES}    ${JSON_RETRY_INTERVAL}    I expect page contains 'textKey:DIC_SETTINGS_DIAG_NETFLIX_ESN'
    ${netflix_esn}    I retrieve value for key 'textValue' in element 'id:infoScreenListNodeValue5'
    Should Not Be Empty    ${netflix_esn}    netflix ESN key is missing
    Set Suite Variable    ${UI_NETFLIX_ESN}    ${netflix_esn}
    Should Be Equal As Strings    ${AS_NETFLIX_ESN}    ${UI_NETFLIX_ESN}    Netflix ESN from XAP is not matching with netflixEsn in HZN4UI

Validate NetflixESN Key Format    #USED
    [Documentation]    Check for 'Netflix ESN' key format in 'About' screen in all Prod and supesetlab environment.
    ${company_esn}  Set Variable    LG
    ${current_country_code}    get country code from stb
    ${current_country_code}     Convert To Uppercase    ${current_country_code}
    #As the netflix key format is different for CL, a cl_esn variable with expected format is defined so that same can eb compared with actual netflix esn value
    ${cl_esn}  Set Variable    LGVTRCLEOS
    Should Be Equal As Strings    ${UI_NETFLIX_ESN[0:2]}    ${company_esn}    Company parameter in NetflixESN not correct
    #NetflixESN key validation for CL prod and pre prod tenants
    Run Keyword if    '${current_country_code}' == 'CL'    Should Be Equal As Strings    ${UI_NETFLIX_ESN[0:10]}    ${cl_esn}    CL parameter in NetflixESN is not correct
    #NetflixESN key validation for Prod and pre prod tenants
    Run Keyword if    '${current_country_code}' != 'CL' and '${LAB_NAME}' != 'labe2esuperset'   Should Be Equal As Strings    ${UI_NETFLIX_ESN[2:4]}    ${current_country_code}    Country parameter in NetflixESN not correct
    Run Keyword if    '${current_country_code}' != 'CL' and '${LAB_NAME}' != 'labe2esuperset'   Should Be Equal As Strings    ${UI_NETFLIX_ESN[4:10]}    &{PRD_model_dictionary}[${MODEL_NAME}]    NetflixESN key format not correct
    #NetflixESN key validation for Lab tenants
    Run Keyword if    '${LAB_NAME}' == 'labe2esuperset'     Should Be Equal As Strings    ${UI_NETFLIX_ESN[0:10]}    &{SS_model_dictionary}[${MODEL_NAME}]    NetflixESN key format not correct in supersetlab
    Check Data Regexp    ${UI_NETFLIX_ESN}    ^[A-Z0-9\-\:]+$    NETFLIX_ESNKEY is not in correct format

Retrieve NetflixESN Key Via AS    #USED
    [Documentation]    Get Model name of the CPE & netflix ESN via AS
    ${result}    getConfigCPE    ${LAB_CONF}    ${CPE_ID}
    ${data}    Set Variable    ${result[2]['payload']}
    ${model_name}    Set Variable    ${data['modelName']}
    Set Suite Variable    ${MODEL_NAME}    ${model_name}
    ${as_netflix_esn}    Set Variable    ${data['netflixEsn']}
    Set Suite Variable    ${AS_NETFLIX_ESN}    ${as_netflix_esn}
# ************CPE PERFORMANCE TESTING*************
Get SETTINGS Section Json
    [Documentation]    This keyword return json for the sections
    @{cleaned_sections}    create list
    ${rotate}    Set Variable        ${-1}
    I wait for 2 seconds
    Get UI Json
    @{sections}    Extract Value For Key    ${LAST_FETCHED_JSON_OBJECT}    id:settings-sectionNavigation-actionContainer
    ...    children
    # Remove the menus with empty text values

    : FOR    ${index}  ${SECTION_JSON}    IN ENUMERATE    @{sections}
    \    ${section_title}    Extract Value For Key    ${SECTION_JSON}    ${EMPTY}    textValue
    \    Continue For Loop If    '${section_title}' == '${EMPTY}'
    \    Append To List    ${cleaned_sections}    ${SECTION_JSON}

    #Arrange in the next available menu order.
    : FOR    ${index}  ${SECTION_JSON}    IN ENUMERATE    @{cleaned_sections}
    \    ${section_title}    Extract Value For Key    ${SECTION_JSON}    ${EMPTY}    textValue
    \    ${focused_section}    Get Enclosing Json    ${LAST_FETCHED_JSON_OBJECT}    ${EMPTY}    textValue:${section_title}    ${1}
    \    ${text_color}    Extract Value For Key    ${focused_section}    ${EMPTY}    color
    \    Exit for loop if    '${text_color}' == '${HIGHLIGHTED_NAVIGATION_COLOUR}'
    \    ${rotate}    Set Variable    ${rotate-1}
    @{cleaned_sections}    rotate list   ${cleaned_sections}    ${rotate}
    [Return]     ${cleaned_sections}

I focus SETTINGS Section
    [Documentation]    This keyword focuses the SETTINGS section and checks if content is loaded.
    [Arguments]  ${section_name}    ${key}=textValue    ${only_highlight_check}=False
    wait until keyword succeeds    10 times    0    SETTINGS Screen for given section is shown    ${section_name}    ${key}    ${only_highlight_check}

SETTINGS Screen for given section is shown
    [Documentation]    This keyword focuses the SETTINGS section and checks if content is loaded.
    [Arguments]  ${section_name}    ${key}=textValue    ${only_highlight_check}=False
    ${json_object}    Get Ui Json
    ${elem}    set variable    ${key}:${section_name}
    ${tab_highlighted_status}    set variable    ${FALSE}
    ${highlighted_elem}    set variable    ${section_name}
    @{section_json}    Extract Value For Key    ${json_object}    id:settings-sectionNavigation-actionContainer    children    ${FALSE}
    :FOR    ${item}    IN    @{section_json}
    \    ${elem}    set variable    ${key}:${section_name}
    \    ${tab_highlighted_status}    Is In Json    ${item}    ${EMPTY}    color:${HIGHLIGHTED_NAVIGATION_COLOUR}
    \    ${highlighted_elem}    Run Keyword if    ${tab_highlighted_status}    Extract Value For Key    ${item}    ${EMPTY}    textValue
    \    exit for loop if     '${section_name}' == '${highlighted_elem}'
    Should Be True    '${section_name}' == '${highlighted_elem}'    Settings sub menu not highlighted
    ${settings_section_submenu}    Is In Json    ${json_object}    ${EMPTY}    id:settingsSubMenuContainer.*    ${EMPTY}    ${True}
    Should Be True    ${settings_section_submenu}    Settings sub menu not loaded

