*** Settings ***
Suite Setup       Default Suite Setup
Suite Teardown    Default Suite Teardown
Force Tags        LaunchAutoStart_and_Exit_App_2   PROD-NL-EOS    PROD-NL-EOSV2    PROD-NL-APOLLO    PROD-CH-EOS    PREPROD-CH-EOS    PROD-NL-SELENE    PROD-UK-EOS    PROD-CH-APOLLO    PREPROD-CH-EOSV2    PROD-CH-EOSV2    TV_APPS    PROD-BE-EOSV2    UK_33    PREPROD-BE-APOLLO-V1-PLUS
Resource          ./Settings.robot
#Library           Libraries.ElasticSearch

#Author           Khushal M Jain

*** Test Cases ***
Tune To PreDefined Channel
    [Documentation]   This keyword tunes to predefined channel
    [Setup]   Default First TestCase Setup
    Run Keyword And Assert Failed Reason    tune to channel ${CHANNEL_ZAP_THREE_DIGIT_INIT_CHANNEL}     'Failed to tune to predefined channel.'

#------------------------------ STEP 2 ------------------------------#
Tune to App Channel
    [Documentation]    This Keyword tunes to the app channel and checks that app is launched
    [Setup]    Skip If Last Fail
    [Tags]    TOOL_CPE
    set context    AutoStart_Launch_App_2
    ${converted_channel}    Convert To String    ${CHANNEL_APP_2}
    ${APP_Channel}    I Fetch App Name for given Logical Channel Number    ${converted_channel}
    set suite variable   ${app_channel_2}    ${APP_Channel}
    I press     ${converted_channel}

Validate app channel is launched
    [Documentation]    Validate if app channel is launched
    [Setup]    Skip If Last Fail
    log action    ApplicationLaunched
    Run Keyword And Assert Failed Reason    I check '${app_channel_2}' App is loaded    'APP not launched properly'
    log action    ApplicationLaunched_Done

Exit App channel
    [Documentation]    Exit the App channel
    [Setup]    Skip If Last Fail
    I wait for 20 seconds
    #I Long Press MENU for 1 seconds
    I Press   CHANNELUP
    I Press   OK
    ${app_view}    Set Variable    Native.View
    set context    AutoStart_Exit_App_2
    log action    ApplicationClosed
    Wait Until Keyword Succeeds    ${DEFAULT_RETRY_TIMEOUT}   ${DEFAULT_RETRY_INTERVAL}    I do not expect page contains 'id:${app_view}'
    log action    ApplicationClosed_Done