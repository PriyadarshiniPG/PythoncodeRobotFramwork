*** Settings ***
Documentation     First Time Install Keywords
Resource          ./FTI_Implementation.robot

*** Keywords ***
I see fti country selection initial screen
    [Documentation]    Keyword is used to verify the initial country selection screen during FTI
    Wait for FTI country selection caption    ${STB_SLOT}    platform=${PLATFORM}    resolution=${GFX_RESOLUTION}
    ${caption_displayed}    Get FTI thread return value    310 s
    Wait for FTI country selection progress dot    ${STB_SLOT}    platform=${PLATFORM}    resolution=${GFX_RESOLUTION}
    ${progress_dot_displayed}    Get FTI thread return value    310 s
    Should be true    ${caption_displayed} and ${progress_dot_displayed}    fti country selection initial screen is not shown

I wait until fti language selection initial screen
    [Arguments]    ${country}=${DEFAULT_COUNTRY_CODE}
    [Documentation]    Keyword to wait until the the country selection during the FTI. The default value is Belgium. The screen is different for different countries.
    ${language_selection_opt}    Catenate    SEPARATOR=_    ${LANGUAGE_SELECTION_INIT_PREFIX}    ${country}
    Wait for FTI language selection    ${STB_SLOT}    ${language_selection_opt}
    ${result}    Get FTI thread return value    40 s
    Should be true    ${result}    fti language selection initial screen is not shown

I wait until initial welcome screen is shown
    [Arguments]    ${wait_in_secs}
    [Documentation]    Verifying welcome screen is shown or not in given time
    wait for welcome screen    ${STB_SLOT}    ${wait_in_secs}    platform=${PLATFORM}    resolution=${GFX_RESOLUTION}
    ${timeout}    Evaluate    ${wait_in_secs} + ${10}
    ${status}    Get FTI thread return value    ${timeout} s
    Run Keyword if    '${status}' == 'False'    fail test    Welcome screen is not shown

I wait until no signal screen is shown
    [Arguments]    ${wait_in_secs}
    [Documentation]    Verifying welcome screen is dismissed and showing no video in given time
    run keyword if    '${PANORAMIX_SUPPORT}' == 'False'    Wait until no signal screen is shown for obelix    ${wait_in_secs}
    ...    ELSE    wait until keyword succeeds    ${wait_in_secs}s    0s    video output is blackscreen

I wait until please wait screen is shown
    [Arguments]    ${wait_in_secs}
    [Documentation]    Verifying please wait screen is shown or not in given time
    wait for please wait screen    ${STB_SLOT}    ${wait_in_secs}    platform=${PLATFORM}    resolution=${GFX_RESOLUTION}
    ${timeout}    Evaluate    ${wait_in_secs} + ${10}
    ${status}    Get FTI thread return value    ${timeout} s
    Run Keyword if    '${status}' == 'False'    fail test    Please wait screen is not shown

I wait until please wait screen got dismissed
    [Documentation]    Keyword to wait until please wait screen got dismissed
    wait until keyword succeeds    12 times    10s    I verify please wait screen got dismissed

I verify please wait screen got dismissed
    [Documentation]    Verifying please wait screen is not shown
    wait for please wait screen    ${STB_SLOT}    platform=${PLATFORM}    resolution=${GFX_RESOLUTION}
    ${is_present}    Get FTI thread return value    40 s
    Run Keyword if    '${is_present}' == 'True'    fail test    Please wait screen present

I wait until fti internet connection initial screen
    [Arguments]    ${language}=${DEFAULT_LANGUAGE_OPTION}
    [Documentation]    Keyword is used to wait until fti internet connecvity screen
    ${network_selection_init}    Catenate    SEPARATOR=_    ${NETWORK_SELECTION_PREFIX}    ${language}
    Wait for FTI network selection    ${STB_SLOT}    ${network_selection_init}    platform=${PLATFORM}    resolution=${GFX_RESOLUTION}
    ${ret}    Get FTI thread return value    310 s
    Should be true    ${ret}    fti internet connection initial screen is not shown

I wait until RCU pairing screen for ${time} seconds
    [Documentation]    Keyword is used to wait until RCU pairing screen for the given time
    Wait for FTI rcu pairing    ${STB_SLOT}    ${time}    platform=${PLATFORM}    resolution=${GFX_RESOLUTION}
    ${timeout}    Evaluate    ${time} + ${10}
    ${ret}    Get FTI thread return value    ${timeout} s
    Should be true    ${ret}    RCU pairing screen is not shown

I perform a 3 button full factory reset
    [Documentation]    Keyword to perform and complete a full factory reset via 3 button factory reset
    run keyword if    '${PLATFORM}'=='DCX960'    Perform 3 button factory reset on Arris box and verify rescue image downloaded completely
    ...    ELSE IF    '${PLATFORM}'=='EOS1008C'    Perform 3 button factory reset on Humax box and verify rescue image downloaded completely
    ...    ELSE IF    '${PLATFORM}'=='SMT-G7400' or '${PLATFORM}'=='SMT-G7401'    Perform 3 button factory reset on Selene box
    ...    ELSE    fail    ${PLATFORM} doesnt support 3 button reset yet

Perform 3 button factory reset on Arris box and verify rescue image downloaded completely
    [Documentation]    Keyword to trigger 3 button factory reset and verify rescue image downloaded completely.
    wait Until Keyword Succeeds    3x    0s    I perform full factory reset
    Rescue downloader starts
    Rescue Downlaod is in progress
    I wait until the rescue loader downloaded

I select the country and language
    [Arguments]    ${country}=${DEFAULT_COUNTRY_CODE}    ${language}=${DEFAULT_LANGUAGE_OPTION}
    [Documentation]    Keyword to choose the country and language during the FTI. The default values are Belgium and English
    I select the country    ${country}
    I wait until fti language selection initial screen    ${country}
    I select the language    ${country}    ${language}

I select the country
    [Arguments]    ${country}=${DEFAULT_COUNTRY_CODE}
    [Documentation]    Keyword to choose the country during the FTI. The default value is Belgium
    ${country_selection_opt}    Catenate    SEPARATOR=_    ${COUNTRY_SELECTION_PREFIX}    ${country}
    ${FOUND_IN_LIST}    Iterate through FTI list    ${country_selection_opt}    ${COUNTRY_RANGE}    DOWN
    Should be true    ${FOUND_IN_LIST}    Unable to select the country
    I send IR key    OK
    Make sure that FTI state is changed    ${country_selection_opt}

I select the language
    [Arguments]    ${country}=${DEFAULT_COUNTRY_CODE}    ${language}=${DEFAULT_LANGUAGE_OPTION}
    [Documentation]    Keyword to choose the language during the FTI. The default value is English
    # TODO ONEMT-6903-Rework on FTI keywords
    ${languge_selection_opt}    Catenate    SEPARATOR=_    ${LANGUAGE_SELECTION_PREFIX}    ${country}    ${language}
    ${FOUND_IN_LIST}    Iterate through FTI list    ${languge_selection_opt}    ${LANGUAGE_RANGE}    DOWN
    Should be true    ${FOUND_IN_LIST}    Unable to select the language
    I send IR key    OK
    Make sure that FTI state is changed    ${languge_selection_opt}

I enable network config and choose the internet connection
    [Arguments]    ${internet_opt}=${DEFAULT_CONNECTIVITY_OPTION}
    [Documentation]    Keyword to enable the network configuration and choose the internet connectivity. The default value is Ethernet
    I enable and restart the network config via serial
    I select the internet connection    ${internet_opt}

I enable and restart the network config via serial
    [Documentation]    Keyword to enable and restart the network configuration via serial
    Drop input buffer and send command    mount -o remount,rw / && systemctl enable om-netconfig && systemctl restart om-netconfig

I select the internet connection
    [Arguments]    ${internet_opt}=${DEFAULT_CONNECTIVITY_OPTION}
    [Documentation]    Keyword to choose the internet connectivity during the FTI. The default value is Ethernet
    ${network_selection_opt}    Catenate    SEPARATOR=_    ${INTERNET_OPTION_PREFIX}    ${internet_opt}
    ${FOUND_IN_LIST}    Iterate through FTI list    ${network_selection_opt}    ${NETWORK_RANGE}    RIGHT
    Should be true    ${FOUND_IN_LIST}    Unable to select the internet connection
    I send IR key    OK
    Make sure that FTI state is changed    ${network_selection_opt}

ethernet connection was detected during FTI
    [Documentation]    Checks if 'NETWORK_MEDIA_SEL_EN' network selection screen is not presented during FTI. This is populated via fti.py
    ${ethernet_detected}    Evaluate    'NETWORK_MEDIA_SEL_EN' not in ${FTI_SCREENS_HISTORY}
    [Return]    ${ethernet_detected}

speed test was successful during FTI
    [Documentation]    Checks if warning screen is not presented during FTI, which might be speed low indication, or something else.
    ${speed_test_done}    Evaluate    'WARNING' not in ${FTI_SCREENS_HISTORY}
    [Return]    ${speed_test_done}

I set the personalization option to
    [Arguments]    ${language}=${DEFAULT_LANGUAGE_OPTION}    ${personalization_opt}=${DEFAULT_PERSONALIZATION_OPTION}
    [Documentation]    Keyword to choose the personalization option during the FTI. The default value is Activate personalization
    ${personalization_selection_opt}    Catenate    SEPARATOR=_    ${PERSONALIZATION_SELECTION_PREFIX}    ${language}    ${personalization_opt}
    ${FOUND_IN_LIST}    Iterate through FTI list    ${personalization_selection_opt}    ${PERSONALIZATION_RANGE}    DOWN
    Should be true    ${FOUND_IN_LIST}    Unable to select the personalization option
    I send IR key    OK
    Make sure that FTI state is changed    ${personalization_selection_opt}

I select the preference
    [Documentation]    Keyword to choose the personalization option during the FTI. The default value is Activate personalization
    # TODO ONEMT-6903-Rework on FTI keywords
    ${FOUND_IN_LIST}    Iterate through FTI list    PREFERENCE_SEL_NL_EN    10    DOWN
    Should be true    ${FOUND_IN_LIST}    Unable to select the preference option
    I send IR key    OK
    Make sure that FTI state is changed    PREFERENCE_SEL_NL_EN

I perform FTI through ACS
    [Documentation]    Keyword to trigger FTI through ACS
    log    Not Implemented    WARN

I perform 3 button factory reset
    [Arguments]    ${country}=${DEFAULT_COUNTRY_CODE}    ${language}=${DEFAULT_LANGUAGE_OPTION}    ${internet_opt}=${DEFAULT_CONNECTIVITY_OPTION}    ${personalization}=${DEFAULT_PERSONALIZATION_OPTION}
    [Documentation]    Keyword to perform 3 button factory reset in the STB
    I trigger 3 button disaster recovery
    Eventually finish FTI scenario    ${country}    ${language}    ${internet_opt}    ${personalization}

I verify STB is booting up until no signal screen is shown
    [Documentation]    Verifying STB is booting up until no signal screen is shown by the screen comparison using Obelix.
    I wait until initial welcome screen is shown    60
    I wait until no signal screen is shown    240

I bring up the STB through disaster recovery
    [Documentation]    Keyword to bring the box to run with rescue image using the 3 button disaster recovery.
    ...    Initially, the keyword will copy the rescue image in CDN to the corresponding folder of the STB and then
    ...    will bring the box to up and run using 3 button disaster recovery
    ${disaster_image_version}    Read the discovery image version from CDN
    Verify the build is available in CDN    ${disaster_image_version}
    run keyword if    '${SKIP_IR_CONNECTIVITY_CHECK}' == 'False'    Check IR connectivity
    I perform 3 button factory reset
    ${running}    Read the STB software version
    Should be equal    ${disaster_image_version}    ${running}    STB is failed to upgrade to disaster image version

I try to finish fti scenario and make sure that box is up and running
    [Documentation]    Keyword is used to make sure that STB is in fti completed state if the box is in middle of FTI
    run keyword if    '${SKIP_IR_CONNECTIVITY_CHECK}' == 'False'    Check IR connectivity
    ${status}    run keyword and return status    eventually finish fti scenario
    return from keyword if    '${status}'=='True'
    I reboot the STB
    I verify STB is booting up until no signal screen is shown
    eventually finish fti scenario

I try to finish fti scenario using skip-fti and make sure that box is up and running
    [Documentation]    Keyword is used to make sure that STB is in completed FTI state if the box is in middle of FTI
    Perform skip-fti action and apply configuration
    Try to verify that FTI state is completed

I accept the installation completion via IR key
    [Documentation]    Keyword to accept the FTI installation completion during the FTI via IR key.
    Fti state is    personalised
    I press DOWN 6 times
    I send IR key    OK
    Make sure that FTI state is changed    INSTALLATION_COMPLETION

I activate the recommendations via IR key
    [Arguments]    ${language}=${DEFAULT_LANGUAGE_OPTION}
    [Documentation]    Keyword to activate the recommendations during the FTI via IR key.
    ${activate_recommendations_opt}    Catenate    SEPARATOR=_    ${ACTIVATE_RECOMMENDATIONS_PREFIX}    ${language}
    ${found_in_list}    Iterate through FTI list    ${activate_recommendations_opt}    10    DOWN
    Should be true    ${found_in_list}    Unable to activate recommendations
    I send IR key    OK
    Make sure that FTI state is changed    ${activate_recommendations_opt}

I flash the FFI build
    [Documentation]    Keyword is used to flash the FFI build
    Run Keyword if    '${FFI_VERSION}' == 'DoNotUpgrade'    fail test    FFI version is not given
    run keyword if    '${PLATFORM}'=='EOS1008C'    Flash FFI build on Humax box    ${FFI_VERSION}
    ...    ELSE IF    '${PLATFORM}'=='DCX960'    fail test    Queued up for coming automation

I reboot the STB on FFI build and disable the network
    [Documentation]    Keyword is used to reboot the STB on FFI build and disable the network
    run keyword if    '${PLATFORM}'=='EOS1008C'    I reboot the Humax box and disable the network via serial
    ...    ELSE IF    '${PLATFORM}'=='DCX960'    fail test    Queued up for coming automation

I wait until software download screen is shown
    [Arguments]    ${wait_in_secs}
    [Documentation]    Keyword is used to verify the software download screen
    wait for download screen    ${STB_SLOT}    ${wait_in_secs}    platform=${PLATFORM}    resolution=${GFX_RESOLUTION}
    ${timeout}    Evaluate    ${wait_in_secs} + ${10}
    ${ret}    Get FTI thread return value    ${timeout} s
    Should be true    ${ret}    software download screen is not shown

I wait until software installation screen is shown
    [Arguments]    ${wait_in_secs}
    [Documentation]    Keyword is used to verify the software installation screen
    wait for installation screen    ${STB_SLOT}    ${wait_in_secs}    platform=${PLATFORM}    resolution=${GFX_RESOLUTION}
    ${timeout}    Evaluate    ${wait_in_secs} + ${10}
    ${ret}    Get FTI thread return value    ${timeout} s
    Should be true    ${ret}    software installation screen is not shown

I disable and stop network configuration via serial
    [Documentation]    Keyword to disable and stop the network configuration using serial connection
    Drop input buffer and send command    mount -o remount,rw / && systemctl disable om-netconfig && systemctl stop om-netconfig

config update is successful
    [Documentation]    Keyword to verify the config update is successful by checking the VERSION details from the
    ...    UI of the STB matches with the expected value
    ${running_version}    Get STB build version
    ${running_version}    Convert To Lowercase    ${running_version}
    I open About
    ${ui_sw_version}    retrieve sw version from about screen
    should match    ${running_version}    ${ui_sw_version}    Version mismatch noticed in About tab

Perform 3 button factory reset and eventually finish FTI
    [Documentation]    Keyword to perform 3 button factory reset and eventually finish FTI
    I perform a 3 button full factory reset
    I verify STB is booting up    300
    Eventually finish FTI scenario
