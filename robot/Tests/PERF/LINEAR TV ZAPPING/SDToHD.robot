*** Settings ***
Suite Setup       Default Suite Setup
Suite Teardown    Default Suite Teardown
Resource          ./Settings.robot
#Library           Libraries.ElasticSearch
Force Tags        JIRA_SDToHD    PROD-NL-EOS    PROD-NL-EOSV2    PROD-NL-APOLLO   PROD-CH-EOS    PREPROD-CH-EOS   PROD-NL-SELENE    PROD-UK-EOS  PREPROD-UK-EOS  PROD-IE-EOS    PREPROD-IE-EOS    PROD-PL-APOLLO    PROD-CH-APOLLO    PREPROD-CH-EOSV2    PROD-CH-EOSV2    PROD-UK-BENTO    PREPROD-UK-BENTO    PREPROD-BE-APOLLO-V1-PLUS

#Author           Shanu Mopila

*** Test Cases ***
#------------------------------ STEP 1 ------------------------------#
Tune To PreDefined SD Channel
    [Documentation]   This keyword tunes to predefined SD channel
    [Setup]   Default First TestCase Setup
    [Tags]    TOOL_CPE
    Run Keyword And Assert Failed Reason    tune to channel ${CHANNEL_ZAP_SD_CHANNEL}     'Failed to tune to predefined channel.'

#------------------------------ STEP 2 ------------------------------#
Tune to HD Channel
    [Documentation]    This Keyword tunes to the HD channel and checks that Channel Bar is shown and tuner status
    [Setup]    Skip If Last Fail
    [Tags]    TOOL_CPE
    set context    SDToHD
    ${converted_channel}    Convert To String    ${CHANNEL_ZAP_HD_CHANNEL}
    ${channel_id}    I Fetch All Channel ID for given Logical Channel Number    ${converted_channel}
    I press     ${converted_channel}
    log action   ChannelTuned
    wait until keyword succeeds    ${DEFAULT_RETRY_TIMEOUT}   ${DEFAULT_RETRY_INTERVAL}    Channel Bar for live event is Shown    ${converted_channel}
    Wait Until Keyword Succeeds    ${DEFAULT_RETRY_TIMEOUT}    ${DEFAULT_RETRY_INTERVAL}    Verify Linear TV is Tuned via VLDMS     ${channel_id}
    log action    ChannelTuned_Done