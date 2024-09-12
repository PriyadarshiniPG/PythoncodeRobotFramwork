*** Settings ***
Documentation     Common keywords definition , for example

Resource          ../../xap.basic.robot    #Enable CPE Tools
Resource          ../../basic.robot    #Clean Variables - failedReason
Resource          ../CommonPages/GridPage_Keywords.robot
Resource          ../CommonPages/SectionNavigation_Keywords.robot
Resource          ../Json/Json_handler.robot
Resource          ../PA-02_Stability_and_Performance/Stability_Keywords.robot
Resource          ../PA-04_User_Interface/ChannelBar_Keywords.robot
#Resource          ../Services/Cloud/ACS/ACS_Keywords.robot
Resource          ../PA-03_Boot_standby_and_Installation/FTI_Keywords.robot
Resource          ../PA-03_Boot_standby_and_Installation/PowerOperation_Keywords.robot
Resource          ../PA-05_Linear_TV/Tuner_Keywords.robot
Resource          ../PA-08_Settings/Settings_Keywords.robot
Resource          ../PA-09_Parental_Control/ParentalControl_Keywords.robot
#Resource          ../PA-13_Degraded_mode/DegradedMode_Keywords.robot
Resource          ../PA-14_RCU/VirtualKeyboard_Keywords.robot
Resource          ../PA-20_Search/Search_Keywords.robot
Resource          ../PA-18_Replay_TV/ReplayTV_Keywords.robot
Resource          ../PA-04_User_Interface/MainMenu_Keywords.robot
Resource          ../PA-26_Applications/Apps_Keywords.robot
#Resource          ../PA-01_HW_and_Platform_Support/Memory_Monitoring_Keywords.robot
#Resource          ../PA-01_HW_and_Platform_Support/Process_Monitoring_Keywords.robot
Resource          ./Fixtures.robot
Resource          ./PairingScreen.robot
Resource          ./ChannelTuning.robot
Resource          ./ContentChecks.robot
Resource          ./Waits.robot
Resource          ./CountryAndLanguage.robot
Resource          ./FirmwareUpgrade.robot
Resource          ./StbAllocation.robot
Resource          ./PowerOperations.robot
Resource          ./DebugSupport.robot
Resource          ./Stbinterface.robot
#Resource          ./Channel_Lineup.robot
Resource          ./obelix.basic.robot
Library           OperatingSystem
Library           String
Library           RequestsLibrary
Library           XML
Library           Libraries.Stb.IPRemote
Library           Libraries.Stb.AppServices
Library           Libraries.Common.DUTInfo     # To parse Rack_Details.yml
Library           Libraries.Common.CommonUtils
Library           Libraries.Stb.Vldms
Library           Libraries.MicroServices.PurchaseService

*** Variables ***
 # TODO - MOVE ALL THOSE VARIABLES TO CONFIG FILE IF NEED IT

${IS_SELENE_SWITCH_IMAGE}    ${False}

${VALUESETNAME}    ${EMPTY}
${CA}             False    #True
${ADD_PRODUCTS}    False
${JSON}           True
${OVERRIDE_JSON}    False
${LIGHT_RESTART}    ${False}
${USE_DEEPLINKS}    ${False}
${LAST_SCREENSHOT_PATH}    ${EMPTY}
${TYPE}           nightly_builds
${EmmCycleTime}    6 min
#${OSD_LANGUAGE}    nl
${username}       root
${password}       ${EMPTY}
${ignore_content_check_failures}    False
#${COUNTRY_CODE_BE}    BE
#${COUNTRY_CODE_NL}    NL
#${COUNTRY_CODE_GB}    GB
#${LANGUAGE_ENGLISH}    EN
#${DEFAULT_COUNTRY_CODE}    ${COUNTRY_CODE_BE}
#${DEFAULT_LANGUAGE_OPTION}    ${LANGUAGE_ENGLISH}
#${COUNTRY}    ${DEFAULT_COUNTRY_CODE}
#${LANGUAGE_OPTION}    ${DEFAULT_LANGUAGE_OPTION}   #${LANGUAGE_OPTION} TO ${OSD_LANGUAGE}
${FTI_STATE_COMPLETED}    completedAndNotified
${FTI_LANGUAGE_SCREEN_EXPECTED}    False
${DEFAULT_CONNECTIVITY_OPTION}    ETHERNET
${DEFAULT_PERSONALIZATION_OPTION}    ACTIVATE
${DEFAULT_SUITE_SETUP_TIMEOUT}    30 minutes
${STABILITY_SUITE_SETUP_TIMEOUT}    45 minutes
# USED ON FirmwareUpgrade.robot to determinate way to Update STB
${UPGRADEPROCESS}    ACSFactoryResetWithSkipFti
${SKIP_IR_CONNECTIVITY_CHECK}    False
${ROUTER_PC_USER}    lgi
${ROUTER_PC_PWD}    lgi
#${DEGRADEDMODE}    ${False}
${PLATFORM_IMAGE_POSTFIX}    .pkg
&{GENRE_SUBGENRE_DICTIONARY}    Sitcoms=Sitcoms    Documentaire=Documentary    Films=Films    Interests=Interests    Sport=Sport    Kids=Children's    Teken- en animatiefims=Animation
...               Entertainment=Entertainment    Vrije tijd=Shopping
${LINEUP_LENGTH}    408
${MOUNT_BRANCH}    False
${BUDGET_HIGH}    500
${REMOTE_FILES_MONITOR_WINDOW}    90    # Overall wait time to decide whether to copy file from STB or not
${REMOTE_FILES_CHANGE_DETECT_WINDOW}    10    # wait time to decide whether a file is being updated or not
${CHECK_FOR_REMOTE_PAIRING_TIPS_SCREEN}    ${False}    # To check whether remote pairing tips screen is displayed
${CHECK_FOR_REMOTE_PAIRING_REQ_POPUP}    ${False}    # To check whether remote pairing request popup is displayed
${IS_STABILITY_TEST}    ${False}
${DISABLE_AS_WEBSOCKET_LISTENER}    False
${MEMORY_MONITORING_ENABLED}    ${False}
${PROCESS_MONITORING_ENABLED}    ${False}
#${CITY_ID}    3001     #OLD ${CUSTOMER_CITY_ID} wrap it from RackDetails
${AUTOSTANDBY_4_HOURS}    240
${AUTOSTANDBY_5_HOURS}    300
${AUTOSTANDBY_6_HOURS}    360
${AUTOSTANDBY_24_HOURS}    1440
${COLLECT_LOGS}    ${False}
${MULTI_ROOM_UPGRADE}    ${False}
${CONTENT_CHECK_FAILURE_COUNTER}    ${0}
${CONTENT_CHECK_FAILURE_THRESHOLD}    ${10}

*** Keywords ***
Set GFX Resolution variable    #USED
    [Documentation]    Sets GFX resolution based on platform - We can use ${GFX_RESOLUTION} to force it
    ${exists}    run keyword and return status    variable should exist    ${GFX_RESOLUTION}
    run keyword if    '${PLATFORM}'=='DCX960' and ${exists}==${False}    set suite variable    ${GFX_RESOLUTION}    1080
    ...    ELSE IF    '${PLATFORM}'=='EOS1008C' and ${exists}==${False}    set suite variable    ${GFX_RESOLUTION}    1080
    ...    ELSE IF    '${PLATFORM}'=='SMT-G7401' and ${exists}==${False}    set suite variable    ${GFX_RESOLUTION}    1080
    ...    ELSE IF    '${PLATFORM}'=='SMT-G7400' and ${exists}==${False}    set suite variable    ${GFX_RESOLUTION}    1080

Create XAP Session    #USED
    [Arguments]    ${xap_session}
    [Documentation]    This keyword creates a XAP session
    Set Suite Variable    ${XAP_URL}    ${LAB_CONF["MICROSERVICES"]["OBOQBR"]}/xap
    create session    ${xap_session}    http://${XAP_URL}

Set STB platform specific variables    #USED
    [Documentation]    This keyword is used to set the platform specific variables
    Get CPE product class
    Set STB platform variable
    Set GFX Resolution variable

Set STB platform variable    #USED
    [Documentation]    This keyword is used to set the platform details form CPEID
    Run Keyword if    '${PLATFORM}' == 'SMT-G7401' or '${PLATFORM}' == 'SMT-G7400'    Set selene specific platform variables
    Log    ${PLATFORM_IMAGE_POSTFIX}

Set selene specific platform variables    #USED
    [Documentation]    This keyword is used to set the selene specific platform variables
    # TODO - CHECK ${VERSION} AND ${SELENE_SIGNED_IMAGE_POSTFIX}
    #set global variable    ${PLATFORM_IMAGE_POSTFIX}    ${SELENE_SIGNED_IMAGE_POSTFIX}
    #return from keyword if    '${VERSION}' == 'DoNotUpgrade'
    #${is_switch_image}    run keyword and return status    should contain    ${VERSION}    swt
    Log To Console    ToDo:Selene Specific Changes
    set global variable    ${IS_SELENE_SWITCH_IMAGE}    False

Set standby setting
    [Arguments]    ${given_standby_mode}
    [Documentation]    This keyword sets the standby mode via AS
    ${current_standby_mode}    get application service setting    cpe.standByMode
    return from keyword if    '${current_standby_mode}'=='${given_standby_mode}'
    Set application services setting    cpe.standByMode    ${given_standby_mode}

Stability Reset Recordings
    [Documentation]    Undo recordings or reminders on the STB. Because ideally recordings are not modified by tests
    Run Keyword And Warn On Failure    Reset All Recordings

Connect Obelix
    [Documentation]    This keywords connects obelix so that all obelix apis can be used
    Remote.connect    ${STB_SLOT}

Disconnect Obelix
    [Documentation]    This keywords disconnects obelix , part of tear down of suite
    Remote.disconnect    ${STB_SLOT}

Initialize full package
    [Documentation]    This keywords provisions stb with all nagra CA entitlements
    initialize all products    ${CA_ID}

Reset Channels    #USED
    [Arguments]    ${channel}
    [Documentation]    Keyword for resetting channels
    Reset Channels via as    ${STB_IP}    ${CPE_ID}    ${channel}    xap=${XAP}

Reset watchlist
    [Documentation]    Keyword for resetting watchlist
    reset watchlist via as    ${STB_IP}    ${CPE_ID}    xap=${XAP}

Skip Error popup
    [Documentation]    This keyword Skip the potentially shown Error popup (ex "Unfortunately this channel is unavailable")
    ...    by pressing BACK
    ${error_popup}    run keyword and return status    Error popup is shown
    Run Keyword If    ${error_popup}    I press    BACK
    Wait Until Keyword Succeeds    ${JSON_MAX_RETRIES}    ${JSON_RETRY_INTERVAL}    I do not expect page contains 'id:errorPopupPlaceholder'

Error popup is shown
    [Documentation]    Checks if an Error popup is shown
    wait until keyword succeeds    3 times    1 sec    I expect page contains 'id:errorPopupPlaceholder'

Error popup is not shown    #USED
    [Documentation]    Checks if an Error popup is NOT shown and print the error code
    ${error_popup_not_present}    run keyword and return status    I do not expect page contains 'id:Widget.ModalPopup'
    ${error_code}    run keyword if    not ${error_popup_not_present}    Get Error popup code
    Should be true    ${error_popup_not_present}    Error popup is being shown - Error: ${error_code}

Get Error popup code    #USED
    [Documentation]    Get the Error popup code and try to extract the CS Error Code From the textKey
    wait until keyword succeeds    3 times    1 sec    I expect page contains 'id:infoScreenErrorCode'
    ${error_code}    Extract Value For Key    ${LAST_FETCHED_JSON_OBJECT}    id:infoScreenErrorCode    textKey
    log to console    error_code: ${error_code}
    @{regexp_matches}    get regexp matches    ${error_code}    DIC_ERROR_(\\d{4,5})_CODE    1
    ${length}    Get Length    ${regexp_matches}
    run keyword if    ${length} != 0    set test variable    ${error_code}   CS${regexp_matches[0]}
    ...    ELSE    Log    Error code '${error_code}' is not correctly formatted: DIC_ERROR_(\\d{4,5})_CODE
    [Return]    ${error_code}

Usage limit error popup is shown
    [Documentation]    Checks if a usage limit Error popup is shown
    wait until keyword succeeds    10 times    1s    I expect page element 'id:interactiveModalPopupTitle' contains 'textKey:DIC_BUDGET_CONTROL_HEADER'
    wait until keyword succeeds    3 times    1 sec    I expect page contains 'textValue:Usage limit reached'

Screenshot is available
    [Documentation]    This keyword verifies if screenshot is taken successfully
    Should not be empty    ${LAST_SCREENSHOT_PATH}

fail test
    [Arguments]    ${message}
    [Documentation]    Call this keyword on error cases with message to be logged , it will take a screenshot for reference as well
    ${path}    get screenshot    ${STB_SLOT}
    should not be empty    ${path}
    FAIL    ${message}

Make sure that Obelix is available
    [Documentation]    Keyword to make sure that Obelix is available by getting a screenshot
    ${path}    get screenshot    ${STB_SLOT}
    should not be empty    ${path}

STB is active for stability
    [Documentation]    Precondition for non functional tests to check stb is active. Tune to 301 , check if video is playing
    ${status}    run keyword and return status    Wait until Pairing Device popup tips screens are displayed    1m
    run keyword unless    ${status}    Log    Remote pair request popup expected: ${CHECK_FOR_REMOTE_PAIRING_REQ_POPUP}, Remote pair tips screen expected: ${CHECK_FOR_REMOTE_PAIRING_TIPS_SCREEN}    WARN
    wait until keyword succeeds    3times    10 sec    tune to scrambled channel and check content

Run Keyword And Warn On Failure
    [Arguments]    ${kw}    @{args}
    [Documentation]    When keyword fails, this passes, but a warning is issued.
    ${state}    ${output}    Run Keyword And Ignore Error    ${kw}    @{args}
    Run Keyword If    '${state}'!='PASS'    Log    Warning: Keyword failed: ${kw} @{args}{\n}${output}    WARN
    [Return]    ${output}

I set the STB User Settings to Default
    [Documentation]    Call to Application Service to reset all stb settings
    log    Not Implemented    WARN

Set value via application services
    [Arguments]    ${key}    ${value}
    [Documentation]    Sets the setting of the box based on the key, value and return the actual set value
    wait until keyword succeeds    1 min    5 sec    set application services setting    ${key}    ${value}
    ${value}    get application service setting    ${key}
    [Return]    ${value}

Get JiraID
    [Documentation]    Retrieves Jira ticket ID from test name
    LOG    ${TEST NAME}
    @{words}    Split String    ${TEST NAME}    _
    [Return]    @{words}[0]

Reset Application Services Setting
    [Arguments]    ${key}
    [Documentation]    Keyword for resetting Application Services Setting
    Reset Application Services Setting via as    ${STB_IP}    ${CPE_ID}    ${key}    xap=${XAP}

Set XAP connection details    #NOT_USED
    [Arguments]    ${xap_session}
    [Documentation]    Set XAP connection details and check the connection
    Import Library    Libraries.Common.XAPViaMQTT
    Create XAP Session    ${xap_session}

Check XAP Connection    #NOT_USED
    [Arguments]    ${xap_session}
    [Documentation]    Check if connection with XAP can be established
    ${status}    run keyword and return status    Get Request    ${xap_session}    /
    Run Keyword If    '${status}' == '${False}'    fail    Connection to XAP Failed - Cannot connect to XAP
    ${resp}    Get Request    ${xap_session}    /
    Run Keyword If    '${resp.status_code}' != '200'    fail    Connection to XAP Failed - Response status code is not 200

Check if STB responds to XAP    #USED
    [Documentation]    Check if STB responds to XAP
    ${status}    run keyword and return status    get fti state via as    ${STB_IP}    ${CPE_ID}    xap=${True}
    Run Keyword If    '${status}' == '${False}'    fail test    STB failed to respond to XAP

Set textKey identifiers    #USED
    [Documentation]    Sets dictionary keys - TO FIX THE MAIN MENU textKey VALUES :8125/v2/nodes/focused /state
    set suite variable    ${DIC_SETTINGS_PREFERNCES}    DIC_SETTINGS_SECTION_PREFERNCES
    set suite variable    ${DIC_SETTINGS_PROFILE}    DIC_SETTINGS_SECTION_PREFERENCES_PROFILE
    set suite variable    ${DIC_SETTINGS_PARENTAL_CONTROL}    DIC_SETTINGS_PARENTAL
    set suite variable    ${DIC_SETTINGS_SYSTEM}    DIC_SETTINGS_SECTION_SYSTEM
    set suite variable    ${DIC_SETTINGS_SOUND_IMAGE}    DIC_SETTINGS_SECTION_AV
    set suite variable    ${DIC_SETTINGS_NETWORK}    DIC_SETTINGS_HOME_NETWORK
    set suite variable    ${DIC_SETTINGS_INFO}    DIC_HELP
    set suite variable    ${DIC_SETTINGS_ABOUT}    DIC_SETTINGS_ABOUT_LABEL
    set suite variable    ${DIC_SETTINGS_DIAG}    DIC_SETTINGS_DIAG_LABEL
    set suite variable    ${DIC_SETTINGS_DIAG_SW_VER}    DIC_SETTINGS_DIAG_SW_VER

Make sure that age rating is set to
    [Arguments]    ${given_age_rating}
    [Documentation]    Keyword that tries to set age rating via application services
    wait until keyword succeeds    3times    1 sec    I Set to age lock via AS to    ${given_age_rating}

The CPE has the default User settings
    [Documentation]    Keyword to check that STB default settings are valid for the specific country
    ${country}    convert to lowercase    ${COUNTRY}
    Validate applied country settings    ${STB_IP}    ${CPE_ID}    ${COUNTRY}    is_default=${False}    xap=${XAP}

Set application services setting    #USED
    [Arguments]    ${key}    ${value}
    [Documentation]    Keyword to set the given value to the set-top box settings
    Set application services setting via as    ${STB_IP}    ${CPE_ID}    ${key}    ${value}    xap=${XAP}

Set application services setting as JSON
    [Arguments]    ${key}    ${json_value}
    [Documentation]    Keyword to set the given raw JSON value to the set-top box settings
    Set application services setting via as    ${STB_IP}    ${CPE_ID}    ${key}    ${json_value}    xap=${XAP}    raw=${True}

Get application service setting    #USED
    [Arguments]    ${key}
    [Documentation]    Keyword to get the value of the set-top box settings
    ${ret}    get application service setting via as    ${STB_IP}    ${CPE_ID}    ${key}    xap=${XAP}
    [Return]    ${ret}

Check IR connectivity
    [Documentation]    This keyword is used to check the connectivy of IR emitter to STB
    I send IR key    OK

Context Menu Displays Action
    [Arguments]    ${option_name}
    [Documentation]    This keyword asserts context menu is displayed with given option
    Wait Until Keyword Succeeds    10 times    300 ms    I expect page element 'id:picker-item-text-\\\\d+' contains 'textValue:${option_name}' using regular expressions

I focus Context Menu Action
    [Arguments]    ${option_name}
    [Documentation]    This keyword asserts the context menu is displayed with the given option and focuses
    ...    ${option_name} in the context menu
    Context Menu Displays Action    ${option_name}
    Move Focus to Option in Value Picker    textValue:${option_name}    DOWN

Create event recording
    [Arguments]    ${channel_id}    ${event}    ${epoch_event_start_time}
    [Documentation]    Create event recording via application service
    ${recording_id}    create event record via as    ${STB_IP}    ${CPE_ID}    ${channel_id}    ${event}    ${epoch_event_start_time}
    ...    xap=${XAP}
    [Return]    ${recording_id}

Get recording session from session service
    [Arguments]    ${customer_id}    ${recording_id}
    [Documentation]    Get recording session using session servive via AS
    ${recording_url}    get recording session using session service via as    ${STB_IP}    ${CPE_ID}    ${customer_id}    ${recording_id}    xap=${XAP}
    [Return]    ${recording_url}

Request to play recording in media streamer
    [Arguments]    ${recording_id}    ${recording_url}
    [Documentation]    Open request to play recording in media steamer via vldms
    ${session_status}    open request to play recording in media streamer via vldms    ${STB_IP}    ${CPE_ID}    ${recording_id}    ${recording_url}
    should match    '${session_status['openStatus']['status']}'    'True'    Player session ${recording_id} not opened
    [Return]    ${session_status['openStatus']['sessionId']}

Request to close player session in media streamer
    [Arguments]    ${session_id}    ${recording_id}
    [Documentation]    Close request to current player session identified by ${session_id} and ${recording_id} in media steamer via vldms
    ${close_status}    close request to player session in media streamer via vldms    ${STB_IP}    ${CPE_ID}    ${session_id}    ${recording_id}
    should match    '${close_status['closeStatus']['status']}'    'True'    Player session ${session_id} for refId:${recording_id} not closed

Delete recording via application service    #USED
    [Arguments]    ${recording_id}
    [Documentation]    Delete recording via application service
    delete recording via as    ${STB_IP}    ${CPE_ID}    ${recording_id}    xap=${XAP}

Delete Recording With Id '${Recording_Id}' Via Application Service    #USED
    [Documentation]    Delete recording with id '${Recording_Id}' via application service
    Delete recording via application service        ${Recording_Id}


add all products with itfaker
    [Documentation]    Adds all products using the IT Faker tool if there's a mismatch
    ...    between current product list and the list of supported products
    ${customer_has_only_supported_products}    Is customer product list matching supported products    ${LAB_NAME}    ${CPE_ID}
    Run Keyword If    '${customer_has_only_supported_products}' == '${False}'    Run Keywords    Delete all products    ${LAB_NAME}    ${CPE_ID}
    ...    AND    Add all products    ${LAB_NAME}    ${CPE_ID}

Convert Traxis date '${date}' to datetime date
    [Documentation]    This keyword converts a traxis date stamp to a RobotFramework datetime date
    ${date}    Replace String    ${date}    T    ${SPACE}
    ${date}    split string    ${date}    .
    ${date}    Set variable    ${date[0]}
    [Return]    ${date}

Create missing profile
    [Documentation]    This keyword checks if CPE profile is valid. If CPE profile is not valid or not existing, will create a new CPE profile
    # TODO - Get Customer City Id  is using ITFAKER - We can not used on PREPROD PROD (Maybe added to rack details if no retriable from backend)
    # TODO - ${CITY_ID}  Is on RACK DETAILS - Check if we can get it from backend
    ${is_profile_active}    ${city_id}    run keyword and ignore error    Get Customer City Id    ${LAB_NAME}    ${CPE_ID}    ${CA_ID}
    ${is_valid_customer}    run keyword and return status    should be equal as strings    ${city_id}    ${CITY_ID}
    run keyword if    '${is_profile_active}' == 'PASS' and ${is_valid_customer} == ${False}    Delete CPE Profile    ${LAB_NAME}    ${CPE_ID}
    ...    ELSE IF    '${is_profile_active}' == 'PASS' and ${is_valid_customer} == ${True}    return from keyword
    ${exact_platform}    Get Exact Platform    ${RACK_SLOT_ID}
    Create CPE Profile    ${CITY_ID}    ${LAB_NAME}    ${CPE_ID}    ${CA_ID}    ${exact_platform}

Set 'cpe.autoStandby' value to
    [Arguments]    ${autostandby_value}
    [Documentation]    This keyword sets the 'cpe.autoStandby' value via AS to ${autostandby_value}
    ...    Note: Allowed values : [240,300,360,1440] in minutes.
    ${autostandby_value}    Convert to integer    ${autostandby_value}
    ${retrieved_autostandby}    get application service setting    cpe.autoStandby
    Run Keyword Unless    '${autostandby_value}'=='${retrieved_autostandby}'    Set application services setting    cpe.autoStandby    ${autostandby_value}
    ${retrieved_autostandby}    get application service setting    cpe.autoStandby
    Should Be Equal As Strings    '${autostandby_value}'    '${retrieved_autostandby}'    Failed to set cpe.autoStandby value.

Get CPE product class    #USED
    [Documentation]    This keyword gets and returns the CPE product class from the ${CPE_ID} variable
    ${split_stb_id}    Split String From Right    ${CPE_ID}    -
    Set Suite Variable    ${CPE_PRODUCT_CLASS}    ${split_stb_id[1]}
    Log    CPE_PRODUCT_CLASS: ${CPE_PRODUCT_CLASS}

Run Keyword And Assert Failed Reason    #USED
    [Documentation]    This keyword runs another keyword and assert the failure reason.
    [Arguments]    ${keyword}    ${reason}
    ${status}    Run Keyword And Ignore Error    ${keyword}
    ${failedReason}    Set Variable If    '${status[0]}'=='FAIL'    ${reason}    ${EMPTY}
    ${robotError}    Set Variable If    '${status[0]}'=='FAIL'    ${status[1]}    ${EMPTY}
    Set suite variable    ${failedReason}    ${failedReason}
    Set suite variable    ${robotError}    ${robotError}
    Run Keyword If    '${status[0]}'=='FAIL'    LOG TO CONSOLE    \n\n\nfailedReason: ${failedReason}\n\n======== RobotFramework failedReason Error ========\n${status[1]}\n\n
    Should Be Empty    ${failedReason}    ${failedReason}

Run Iteration Keyword And Assert Failed Reason    #USED
    [Documentation]    This keyword runs another keyword and assert the failure reason.
    [Arguments]    ${iteration}    ${keyword}    ${reason}
    ${iteration}    convert to integer    ${iteration}
    ${iteration}    Evaluate    ${iteration} + 1
    : FOR    ${iteration_num}    IN RANGE    1    ${iteration}
    \    ${status}    Run Keyword And Ignore Error    ${keyword}
    \    ${failedReason}    Set Variable If    '${status[0]}'=='FAIL'    ${reason} - Iteration: ${iteration_num}    ${EMPTY}
    \    ${robotError}    Set Variable If    '${status[0]}'=='FAIL'    ${status[1]}    ${EMPTY}
    \    Set Suite Variable    ${failedReason}    ${failedReason}
    \    Set Suite Variable    ${robotError}    ${robotError}
    \    Run Keyword If    '${status[0]}'=='FAIL'    LOG TO CONSOLE    \n\n\nfailedReason: ${failedReason}\n\n======== RobotFramework failedReason Error ========\n${status[1]}\n\n
    \    Should Be Empty    ${failedReason}    ${failedReason}

Get Root Id From Purchase Service    #USED
    [Documentation]    This keyword try to retrieve the rootid from the purchase services,
    ...    if not present it will assign with the fallback rootid, and the same rootid will used in Vod Structure call to get the correct rootid used for VOD backend calls
    ${response}    Run Keyword    Get Entitlements    ${LAB_CONF}    customer_id=${CUSTOMER_ID}
    ${response_data}    Set Variable    ${response.json()}
    log  ${response_data}
    ${screenhint_presence}    Run Keyword And Return Status    Should Contain    ${response_data}    homeScreenHint
    ${home_screen_hint}    Set Variable If    ${screenhint_presence}    ${response_data['homeScreenHint']}    ${EMPTY}
    ${homescreenhint_root_id}    Run Keyword If    '${home_screen_hint}' != '${EMPTY}'    Catenate    SEPARATOR=_   ${home_screen_hint}   ${OSD_LANGUAGE}
    ...    ELSE    Set Variable    ${LAB_CONF["fallback_root_id"][0]}
    ${homescreenhint_root_id}    Set Variable If    '${COUNTRY}' == 'be'    omw_basic    ${homescreenhint_root_id}
    ${vodstructure_root_id}    Run Keyword    I Get Root Id From Vod Structure    ${homescreenhint_root_id}
    ${root_id}    Run Keyword If    '${vodstructure_root_id}' != '${EMPTY}'    Set Variable    ${vodstructure_root_id}
    ...    ELSE    Set Variable    ${homescreenhint_root_id}
    set suite variable  ${ROOT_ID}    ${root_id}

Wait Until Keyword Succeeds And Verify Status    #USED
    [Documentation]    This skeyword runs the specified keyword and retries if it fails. If the keyword does not succeed
    ...    regardless of retries, this keyword fails and logs the user defined error message.
    ...    param: retry - ths argument defines how long or how many times you want to execute the keyword e.g. 1x, 2x, etc.
    ...    param: retry_interval - this is the time to wait before trying to run the keyword again after the previous run has failed e.g. 100ms, 1s, etc.
    ...    param: keyword - keyword to execute and retry if it fails.
    ...    param: keyword_args - arguments for the keyword.
    ...    param: error_msg - User defined failure error message.
    [Arguments]    ${retry}    ${retry_interval}    ${error_msg}    ${keyword}    @{keyword_args}
    ${status}    Run Keyword And Return Status    Wait Until Keyword Succeeds    ${retry}    ${retry_interval}    ${keyword}    @{keyword_args}
    Should Be True    ${status}    ${error_msg}

Check Whether Screenshot Can Be Captured Via XAP Or Obelix    #USED
    [Documentation]    This Keyword checks if screen shots can be captured via XAP(is build is not PRD) or Obelix(is OBELIX_SUPPORT is TRUE)
    ${status_XAP}    Run Keyword And Ignore Error    Check Screenshot Can Be Captured Via XAP
    ${status_Obelix}    Run Keyword And Ignore Error    Check Screenshot Can Be Captured Via Obelix
    ${status1}    Set Variable If    "${status_XAP[0]}" == "PASS"    'Screenshot captured Via XAP'    'Screenshot could not be captured Via XAP'
    ${status2}    Set Variable If    "${status_Obelix[0]}" == "PASS"    'Screenshot captured Via OBELIX'    'Screenshot could not be captured Via OBELIX'
    [Return]    ${status_1},${status_2}

Get Maximum Allowed Age Rating For Watershed Lane    #USED
    [Documentation]    This keyword determines maximum allowed age rating for current watershed lane. It does with respect to current UK time
    ...    if time is given as a string in HH:MM(:SS) format, it compares this time with watershed time to do the same
    [Arguments]    ${broadcast_time_string}=${None}    ${is_watershed_compliant}=${False}
    Run Keyword If    ${is_watershed_compliant}    Should Not Be True    '${broadcast_time_string}'=='${None}'
    ...    Event broadcast time not provided for watershed compliant channel
    ${current_country_code}    Get Country Code from Stb
    ${current_country_code}     Convert To Uppercase    ${current_country_code}
    Return From Keyword If    '${current_country_code}' != 'GB'    ${None}
    ${time}    Get Current Time    Europe/London
    ${current_time_string}    Evaluate   $time.strftime('%H:%M')    modules=datetime
    ${current_lane_rating}    Find Current Watershed Lane    ${current_time_string}
    Return From Keyword If    not ${is_watershed_compliant}    ${current_lane_rating}
    Return From Keyword If    ${current_lane_rating}==${-1}    ${False}
    ${broadcast_lane_rating}    Find Current Watershed Lane    ${broadcast_time_string}
    ${is_lock_and_pin_entry}    Run Keyword And Return Status    Should Be True    ${current_lane_rating}<${broadcast_lane_rating}
    [Return]    ${is_lock_and_pin_entry}

Find Current Watershed Lane    #USED
    [Documentation]    Calculates the current watershed lane when HH:MM time is passed as parameter time_string
    ...    assert_on_no_age_restriction parameter is True, it asserts failure if current lane has no age restriction. If False, does not assert
    [Arguments]    ${time_string}
    Get Watershed Lane Configuration
    @{split_string}    Split String    ${time_string}    :
    ${hours}    Convert To Integer    ${split_string[0]}
    ${minutes}    Convert To Integer    ${split_string[1]}
    ${check_time}    Evaluate    datetime.time(${hours},${minutes},0)    modules=datetime
    ${age_rating}    Get Current Watershed Lane    ${WATERSHED_LANE_CONFIGURATION}    ${check_time}
    [Return]    ${age_rating}

Get Watershed Lane Configuration    #USED
    [Documentation]    This keyword retrieves watershed lane configuration from app service
    ${cpe_config}    Get Application Service Configuration    app
    ${watershed_lane_list}    Create List
    ${watershed_lane_info}    Set Variable    ${cpe_config['watershedPeriods']}
    :FOR    ${lane}    IN    @{watershed_lane_info}
    \    ${lane_dict}    Create Dictionary
    \    @{start_time_components}    Split String    ${lane['intervalStartTime']}    :
    \    ${start_hours}    Convert To Integer    ${start_time_components[0]}
    \    ${start_minutes}    Convert To Integer    ${start_time_components[1]}
    \    ${start_time}    Evaluate    datetime.time(${start_hours},${start_minutes},0)    modules=datetime
    \    @{end_time_components}    Split String    ${lane['intervalEndTime']}    :
    \    ${end_hours}    Convert To Integer    ${end_time_components[0]}
    \    ${end_minutes}    Convert To Integer    ${end_time_components[1]}
    \    ${end_time}    Evaluate    datetime.time(${end_hours},${end_minutes},0)    modules=datetime
    \    Set To Dictionary    ${lane_dict}    ageRating    ${lane['ageRating']}    intervalStartTime    ${start_time}
    ...    intervalEndTime    ${end_time}
    \    Append To List    ${watershed_lane_list}    ${lane_dict}
    Set Suite Variable    ${WATERSHED_LANE_CONFIGURATION}    ${watershed_lane_list}