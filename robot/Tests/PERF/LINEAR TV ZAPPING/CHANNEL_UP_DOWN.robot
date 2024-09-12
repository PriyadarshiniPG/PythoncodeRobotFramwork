*** Settings ***
Suite Setup       Default Suite Setup
Suite Teardown    Default Suite Teardown
Resource          ./Settings.robot
#Library           Libraries.ElasticSearch
Force Tags        JIRA_ChannelUPDown    INTERIM   PROD-NL-EOS    PROD-NL-EOSV2   PROD-NL-APOLLO   PROD-CH-EOS    PREPROD-CH-EOS   PROD-NL-SELENE    PROD-UK-EOS   PREPROD-UK-EOS    PROD-IE-EOS    PREPROD-IE-EOS    PROD-PL-APOLLO    PROD-CH-APOLLO    PREPROD-CH-EOSV2    PROD-CH-EOSV2    PROD-UK-BENTO    PREPROD-UK-BENTO    PREPROD-BE-APOLLO-V1-PLUS

#Author           Shanu Mopila
*** *** Variables ***
@{KEYS}  CHANNELUP    CHANNELDOWN

*** Test Cases ***
#------------------------------ STEP 1 ------------------------------#
Tune To PreDefined SD Channel
    [Documentation]   This keyword tunes to predefined SD channel
    [Setup]   Default First TestCase Setup
    [Tags]    TOOL_CPE
    Run Keyword And Assert Failed Reason    tune to channel ${CHANNEL_ZAP_SD_CHANNEL}     'Failed to tune to predefined channel.'

#------------------------------ STEP 2 ------------------------------#
Perform and Validate Channel/Down
    [Documentation]    This Keyword performs channel up/down and verify channel change
    [Setup]    Skip If Last Fail
    [Tags]    TOOL_CPE
    set context    CHANNEL_UP_DOWN
    ${choice}  Evaluate  random.choice($KEYS)  random
    ${index}    run keyword if    '${choice}'=='CHANNELUP'    set variable    1
    ...    ELSE    set variable    -1
    ${new_channel_number}    Get the Adjacent Channel      ${TUNED_CHANNEL_NUMBER}    ${index}
    ${channel_id}    I Fetch All Channel ID for given Logical Channel Number    ${new_channel_number}
    I press     ${choice}
    log action   ChannelTuned
    wait until keyword succeeds    ${DEFAULT_RETRY_TIMEOUT}   ${DEFAULT_RETRY_INTERVAL}    Channel Bar for live event is Shown    ${new_channel_number}
    Wait Until Keyword Succeeds    ${DEFAULT_RETRY_TIMEOUT}   ${DEFAULT_RETRY_INTERVAL}    Verify Linear TV is Tuned via VLDMS     ${channel_id}
    log action    ChannelTuned_Done