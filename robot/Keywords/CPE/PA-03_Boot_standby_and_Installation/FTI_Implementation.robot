*** Settings ***
Documentation     First Time Install Keywords
Resource          ../Json/Json_handler.robot
#Resource          ../Serial/Serial.robot

*** Variables ***
${COUNTRY_RANGE}    13
${LANGUAGE_RANGE}    3
${NETWORK_RANGE}    2
${PERSONALIZATION_RANGE}    6
${WIFI_RANGE}     100
@{FTI_STATES}     COUNTRY_SEL_INITIAL    RCU_PAIRING    PLEASE_WAIT_STATE    PREFERENCE_SEL_NL_INITIAL    PREFERENCE_SEL_NL_EN    WARNING    LANGUAGE_SEL_INITIAL
...               RCU_PAIRING_REQUEST    RCU_PAIRING_TIPS_SCREEN    RECOMMENDATIONS    INSTALLATION_COMPLETION
${UNKNOWN_FTI_STATE}    UnknownState
${COUNTRY_SELECTION_PREFIX}    COUNTRY_SEL
${LANGUAGE_SELECTION_INIT_PREFIX}    LANGUAGE_SEL_INITIAL
${LANGUAGE_SELECTION_PREFIX}    LANGUAGE_SEL
${LANGUAGE_SELECTION_TRANSLATION_PREFIX}    LANGUAGE_SEL_TRANS
${NETWORK_SELECTION_PREFIX}    NETWORK_MEDIA_SEL
${INTERNET_OPTION_PREFIX}    INTERNET_OPTION
${PERSONALIZATION_SELECTION_PREFIX}    PERSONALIZATION_SEL
${ACTIVATE_RECOMMENDATIONS_PREFIX}    ACTIVATE_RECOMMENDATIONS
#${COUNTRY}    ${COUNTRY_CODE_BE}
#${LANGUAGE_OPTION}    ${LANGUAGE_ENGLISH} #${LANGUAGE_OPTION} TO ${OSD_LANGUAGE}
${CONNECTIVITY_OPTION}    ${DEFAULT_CONNECTIVITY_OPTION}
${PERSONALIZATION_OPTION}    ${DEFAULT_CONNECTIVITY_OPTION}

*** Keywords ***
Iterate through FTI list
    [Arguments]    ${WANTED_STATE}    ${MAX_RANGE}    ${NAVIGATE_KEY}
    [Documentation]    Keyword for iterating thorugh the FTI states based on the Navigation key and return true if found match with wanted state
    ...    else return false.
    ${WANTED_STATE}=    Convert To Uppercase    ${WANTED_STATE}
    : FOR    ${INDEX}    IN RANGE    ${MAX_RANGE}
    \    ${value}    Is FTI state    ${STB_SLOT}    ${WANTED_STATE}    convert_image_before_compare=${False}    platform=${PLATFORM}
    \    ...    resolution=${GFX_RESOLUTION}
    \    Run Keyword If    '${value}' == 'True'    Return From Keyword    ${True}
    \    I send IR key    ${NAVIGATE_KEY}
    \    I wait for 1 second
    Return From Keyword    ${False}

FTI state is
    [Arguments]    ${state}
    [Documentation]    Keyword to check FTI state matches the expected value
    ${ret}    Get Fti State
    should be equal as strings    ${state}    ${ret}

No ethernet connection detected
    [Documentation]    Keyword to verify that ethernet connection is not present using serial communication
    Drop input buffer and verify response
    Send command and verify response    /usr/sbin/ethtool eth2
    ${connection_status}    Wait until line match and verify response    (?im)^.+Link detected:.+
    Should Contain    ${connection_status}    NO    Link is not down    ignore_case=True

STB connected with ethernet
    [Documentation]    Keyword to check STB is connected with ethernet
    ethernet connection detected

ethernet connection detected
    [Documentation]    Keyword to verify that ethernet connection is present
    run keyword and return if    '${PLATFORM}'=='SMT-G7400' or '${PLATFORM}'=='SMT-G7401'    Log    No ethernet connection for selene, uses built-in cable modem    WARN
    ${sshhandle}    Remote.open connection    ${STB_IP}
    Remote.login    ${STB_IP}    ${sshhandle}
    ${out}    Remote.execute_command    ${STB_IP}    ${sshhandle}    /usr/sbin/ethtool eth2
    ${connection_status}=    Should Match Regexp    ${out}    (?im)^.+Link detected.+    msg=Link Detected not found
    Should Contain Any    ${connection_status}    YES    ignore_case=True    msg=Link Detected is not yes

STB detected ethernet connection
    [Documentation]    Keyword to verify that ethernet connection is present using serial communication
    Drop input buffer and verify response
    Send command and verify response    /usr/sbin/ethtool eth2
    ${connection_status}    Wait until line match and verify response    (?im)^.+Link detected:.+
    Should Contain    ${connection_status}    YES    Link is not up    ignore_case=True

BO connection is successful
    [Documentation]    Keyword to verify BO is reachable from the STB, by trying to retrieve
    ...    customer profile from Traxis
    ${customer_id}    Get application service setting    customer.customerId
    get traxis customer cpe profile    ${customer_id}    ${CPE_ID}

STB is provisioned
    [Documentation]    Keyword to verify STB is provisioned
    log    Not Implemented    WARN

first install is initiated
    [Documentation]    Verify first install has started and is progressing
    I verify STB is booting up

RCU pairing screen shown
    [Documentation]    Keyword to wait until RCU pairing screen is shown
    I wait until RCU pairing screen for 30 seconds

RCU pairing screen is not shown
    [Documentation]    Keyword to verify that RCU pairing screen is not shown during FTI
    ${status}=    run keyword and return status    RCU pairing screen shown
    should not be true    ${status}    RCU pairing screen is shown

first install completed successfully
    [Documentation]    Keyword to verify that FTI state value is completedAndNotified
    Fti state is    completedAndNotified

Eventually finish FTI scenario
    [Arguments]    ${country}=${DEFAULT_COUNTRY_CODE}    ${language}=${DEFAULT_LANGUAGE_OPTION}    ${internet_opt}=${DEFAULT_CONNECTIVITY_OPTION}    ${personalization}=${DEFAULT_PERSONALIZATION_OPTION}
    [Documentation]    Keyword is used to make sure that STB is in fti completed state if the box is in middle of FTI
    ${network_selection_init}    Catenate    SEPARATOR=_    ${INTERNET_OPTION_PREFIX}    ${internet_opt}
    ${personalization_selection_init}    Catenate    SEPARATOR=_    ${PERSONALIZATION_SELECTION_PREFIX}    ${language}
    ${language_selection_opt}    Catenate    SEPARATOR=_    ${LANGUAGE_SELECTION_INIT_PREFIX}    ${country}
    Append To List    ${FTI_STATES}    ${network_selection_init}    ${personalization_selection_init}    ${language_selection_opt}
    ${status}    run keyword and return status    first install completed successfully
    run keyword unless    '${status}'=='True'    perform FTI scenario    ${country}    ${language}    ${internet_opt}    ${personalization}

perform FTI scenario
    [Arguments]    ${country}    ${language}    ${internet_opt}    ${personalization}
    [Documentation]    Keyword is used to perfrom FTI scenarion. The keyword will execute until the FTI completes.
    wait until keyword succeeds    12 min    4s    Make sure that fti state completed    ${country}    ${language}    ${internet_opt}
    ...    ${personalization}

record fti screens history
    [Arguments]    ${fti_screen}
    [Documentation]    Keyword stores the history of the fti screens encountered, if ${FTI_SCREENS_HISTORY} is defined
    ${value_exists}    run keyword and return status    variable should exist    ${FTI_SCREENS_HISTORY}
    return from keyword if    ${value_exists}==${False}
    ${length}    Get length    ${FTI_SCREENS_HISTORY}
    ${length}    convert to integer    ${length}
    ${previous_fti_screen}    set variable if    ${length}>0    ${FTI_SCREENS_HISTORY[${length-1}]}    ${EMPTY}
    return from keyword if    '${previous_fti_screen}'=='${fti_screen}'
    Append To List    ${FTI_SCREENS_HISTORY}    ${fti_screen}

Make sure that fti state completed
    [Arguments]    ${country}    ${language}    ${internet_opt}    ${personalization}
    [Documentation]    Keyword is used to verify wheather FTI is completed or not. The keyword will first read the the current screen and will compare with from list fo fti states. It will check for look for each
    ...    the predefined screens. If it matches , the the corresponding action will execute.
    ${network_selection_init}    Catenate    SEPARATOR=_    ${INTERNET_OPTION_PREFIX}    ${internet_opt}
    ${personalization_selection_init}    Catenate    SEPARATOR=_    ${PERSONALIZATION_SELECTION_PREFIX}    ${language}
    ${language_selection_opt}    Catenate    SEPARATOR=_    ${LANGUAGE_SELECTION_INIT_PREFIX}    ${country}
    ${fti_screen}    Get the FTI screen
    record fti screens history    ${fti_screen}
    run keyword and return if    '${fti_screen}'=='WARNING'    Perform skip-fti action and apply configuration
    run keyword if    '${fti_screen}'=='RCU_PAIRING'    I send IR key    OK
    run keyword if    '${fti_screen}'=='COUNTRY_SEL_INITIAL'    I select the country and language    ${country}    ${language}
    run keyword if    '${fti_screen}'=='${language_selection_opt}'    I select the language    ${country}    ${language}
    run keyword if    '${fti_screen}'=='${network_selection_init}'    I enable network config and choose the internet connection    ${internet_opt}
    run keyword if    '${fti_screen}'=='${personalization_selection_init}'    I set the personalization option to    ${language}    ${personalization}
    run keyword if    '${fti_screen}'=='INSTALLATION_COMPLETION'    I accept the installation completion via IR key
    run keyword if    '${fti_screen}'=='RECOMMENDATIONS'    I activate the recommendations via IR key    ${language}
    run keyword if    '${fti_screen}'=='PLEASE_WAIT_STATE'    I wait until please wait screen got dismissed
    run keyword if    '${fti_screen}'=='PREFERENCE_SEL_NL_INITIAL'    I select the preference
    run keyword if    '${fti_screen}'=='LANGUAGE_SEL_INITIAL'    I select the language    ${country}    ${language}
    ${status}    run keyword and return status    first install completed successfully
    run keyword unless    '${status}'=='True'    fail test    Fti state is not completed yet and current state is ${fti_screen}

Get the FTI screen
    [Documentation]    Keyword is used to get the current FTI screen from list fo fti states. It will check for look for each
    ...    screen and find the perfect match and return the state value. If it doenst match with any state, it will return the
    ...    value UnknownState
    : FOR    ${ELEMENT}    IN    @{FTI_STATES}
    \    Log    ${ELEMENT}
    \    ${value}    Is FTI state    ${STB_SLOT}    ${ELEMENT}    convert_image_before_compare=${False}    platform=${PLATFORM}
    \    ...    resolution=${GFX_RESOLUTION}
    \    return from keyword if    '${value}' == 'True'    ${ELEMENT}
    Return From Keyword    ${UNKNOWN_FTI_STATE}

Is remote pairing tips screen displayed
    [Documentation]    Keyword is check if the remote pairing tips screen is displayed
    ${is_pair_tips_shown}    Is FTI state    ${STB_SLOT}    RCU_PAIRING_TIPS_SCREEN    min_state_match=0.85    convert_image_before_compare=${False}    platform=${PLATFORM}
    ...    resolution=${GFX_RESOLUTION}
    run keyword if    ${is_pair_tips_shown} and ${IS_STABILITY_TEST}    Log    Remote pairing tips screen is seen    WARN
    [Return]    ${is_pair_tips_shown}

Is remote pairing request popup displayed
    [Documentation]    Keyword is check if the remote pairing tips screen is displayed
    ${is_pair_request_shown}    Is FTI state    ${STB_SLOT}    RCU_PAIRING_REQUEST    min_state_match=0.85    convert_image_before_compare=${False}    platform=${PLATFORM}
    ...    resolution=${GFX_RESOLUTION}
    run keyword if    ${is_pair_request_shown} and ${IS_STABILITY_TEST}    Log    Remote pairing request popup is seen    WARN
    [Return]    ${is_pair_request_shown}

speed test is successful
    [Documentation]    Keyword to do speed test on STB
    ${threshold_speed}    get application service configuration    speedTest.lowThresholdMbps
    ${speed_test_url}    get application service configuration    speedTest.speedTestUrl
    verify connection speed through SSH    ${speed_test_url}    ${threshold_speed}

verify connection speed through SSH
    [Arguments]    ${url}    ${threshold}
    [Documentation]    Gets the connection speed and verifies it with threshold
    ${speed_in_kbytes}    get connection speed via SSH    ${url}
    ${speed_in_mbits}    Evaluate    ${speed_in_kbytes}/128
    should be true    ${speed_in_mbits} > ${threshold}    Connection speed is low

get connection speed via SSH
    [Arguments]    ${url}
    [Documentation]    Executes a command over SSH and returns the connection speed
    ${command}    catenate    curl -o /dev/null    ${url}    2>&1    |    awk
    ...    'BEGIN    {RS="\\r"}{A=$7}    END    {print A}'
    ${sshhandle}    Remote.open connection    ${STB_IP}
    Remote.login    ${STB_IP}    ${sshhandle}
    ${output}    Remote.execute_command    ${STB_IP}    ${sshhandle}    ${command}
    ${speed}=    Should Match Regexp    ${output}    ^[0-9]+    Speed not known
    Remote.close connection    ${STB_IP}    ${sshhandle}
    ${speed}    Replace String    ${speed}    k    ${EMPTY}
    [Return]    ${speed}

get application service configuration
    [Arguments]    ${key}
    [Documentation]    Retrieves configuration setting through app services
    ${ret}    get application service configuration via as    ${STB_IP}    ${CPE_ID}    ${key}    xap=${XAP}
    [Return]    ${ret}

I Make sure that STB doesn't detect ethernet connection
    [Documentation]    Keyword to disable the ethernet connection using ifconfig command
    Drop input buffer and verify response
    Send command and verify response    /sbin/ifconfig eth2 down

I Make sure that STB detects ethernet connection
    [Documentation]    Keyword to enable the ethernet connection using ifconfig command
    Drop input buffer and verify response
    Send command and verify response    /sbin/ifconfig eth2 up

FTI teardown
    [Documentation]    The specific teardown for the FTI tests
    ${status}    run keyword and return status    Try to verify that FTI state is completed
    run keyword unless    ${status}    Handle FTI scenarios eventually with skip-fti if fails and make sure STB is active
    Default Suite Teardown

FFI teardown
    [Documentation]    The specific teardown for the FFI tests
    ${status}    run keyword and return status    Try to verify that FTI state is completed
    run keyword unless    ${status}    Eventually finish FTI scenario    ${COUNTRY}    ${OSD_LANGUAGE}    ${CONNECTIVITY_OPTION}    ${PERSONALIZATION_OPTION}
    Default Suite Teardown

FTI Specific Suite Setup
    [Documentation]    This keyword contains the FTI Tests specific Setup Steps.
    [Timeout]    ${DEFAULT_SUITE_SETUP_TIMEOUT}
    Default Suite Setup
    run keyword if    ${SKIP_IR_CONNECTIVITY_CHECK}!=${True}    Check IR connectivity
    Reset FTI history list

Read the discovery image version from CDN
    [Documentation]    Keyword to read the discovery iamge version from CDN
    ${connection_index}    Open Connection And Log In
    SSHLibrary.Get Connections
    ${RECOVERY_MANIFEST_LOCATION}    run keyword if    '${PLATFORM}'=='DCX960'    Catenate    SEPARATOR=/    ${CDN_HOME_LOCATION}    ${ARRIS_STB_BUILD_LOCATION}
    ...    manifest.cms
    ...    ELSE IF    '${PLATFORM}'=='EOS1008C'    Catenate    SEPARATOR=/    ${CDN_HOME_LOCATION}    ${HUMAX_STB_BUILD_LOCATION}
    ...    manifest.cms
    ...    ELSE IF    '${PLATFORM}'=='SMT-G7400' or '${PLATFORM}'=='SMT-G7401'    Catenate    SEPARATOR=/    ${CDN_HOME_LOCATION}    ${SELENE_STB_BUILD_LOCATION}
    ...    manifest.cms
    ...    ELSE IF    '${PLATFORM}'=='APOLLO'    Catenate    SEPARATOR=/    ${CDN_HOME_LOCATION}    ${APOLLO_STB_BUILD_LOCATION}
    ...    manifest.cms
    log    ${RECOVERY_MANIFEST_LOCATION}
    ${is_recovery_image_manifest_present}    run keyword and return status    SSHLibrary.File Should Exist    ${RECOVERY_MANIFEST_LOCATION}
    should be true    ${is_recovery_image_manifest_present}    The recovery image manifest file is not present in CDN
    ${manifest_file}    SSHLibrary.Execute Command    cat ${RECOVERY_MANIFEST_LOCATION}
    ${root_element}    Parse XML    ${manifest_file}
    run keyword if    '${PLATFORM}'=='EOS1008C'     should be equal    ${root_element.tag}    ${HUMAX_EOS_MANIFEST_FILE_ROOT_ELEMENT}
    ...    ELSE    should be equal    ${root_element.tag}    ${COMMON_MANIFEST_FILE_ROOT_ELEMENT}
    Element Should Exist    ${root_element}    image/version
    ${image_data}    Get Element    ${root_element}    image/version
    ${image_version}    run keyword if    '${PLATFORM}'=='EOS1008C'    Get Line    ${image_data.text}    0
    ...    ELSE    Remove String    ${image_data.text}    ${PLATFORM_IMAGE_POSTFIX}
    [Return]    ${image_version}

Make sure that FTI state is changed
    [Arguments]    ${fti_state}
    [Documentation]    Keyword to make sure that FTI state got changed from the given FTI state
    wait until keyword succeeds    3times    2s    Verify FTI state is changed    ${fti_state}

Verify FTI state is changed
    [Arguments]    ${fti_state}
    [Documentation]    Keyword to verify that FTI state is changed from the given FTI state
    ${match}    Is FTI state    ${STB_SLOT}    ${fti_state}    convert_image_before_compare=${False}    platform=${PLATFORM}    resolution=${GFX_RESOLUTION}
    should not be true    ${match}    FTI state is failed to change to new state

Wait until no signal screen is shown for obelix
    [Arguments]    ${wait_in_secs}
    [Documentation]    Verifying welcome screen is shown or not in given time
    wait for no signal screen    ${STB_SLOT}    ${wait_in_secs}    platform=${PLATFORM}    resolution=${GFX_RESOLUTION}
    ${timeout}    Evaluate    ${wait_in_secs} + ${10}
    ${status}    Get FTI thread return value    ${timeout} s
    should be true    ${status}    No signal screen screen is not shown

Check if FTI thread finished
    [Documentation]    Check if thread for FTI waiting screen logic has finished
    ${result}    Is FTI Thread Finished    ${STB_SLOT}
    Should Be True    ${result}    FTI thread waiting for a screen was not finished

Get FTI thread return value
    [Arguments]    ${retry_time}
    [Documentation]    Waits until FTI thread finishes and returns its return value
    Wait Until Keyword Succeeds    ${retry_time}    0.5 s    Check if FTI thread finished
    ${result}    Get FTI Thread Result    ${STB_SLOT}
    [Return]    ${result}
