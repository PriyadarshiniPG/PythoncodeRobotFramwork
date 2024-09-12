*** Settings ***
Suite Setup       Default Suite Setup
Suite Teardown    Default Suite Teardown
Resource          ./Settings.robot
#Library           Libraries.ElasticSearch
Force Tags        JIRA_ScrambledToScrambled    INTERIM    PROD-NL-EOS    PROD-NL-EOSV2    PROD-NL-APOLLO   PROD-CH-EOS    PREPROD-CH-EOS   PROD-NL-SELENE    PROD-PL-APOLLO   PROD-UK-EOS    PROD-IE-EOS    PROD-CH-APOLLO    PREPROD-CH-EOSV2    PROD-CH-EOSV2    PROD-UK-BENTO    PREPROD-UK-BENTO    PREPROD-BE-APOLLO-V1-PLUS

#Author           Khushal M Jain

*** Test Cases ***
#------------------------------ STEP 1 ------------------------------#
Tune To PreDefined Scrambled Channel
    [Documentation]   This keyword tunes to predefined channel
    [Setup]   Default First TestCase Setup
    Run Keyword And Assert Failed Reason    tune to channel ${CHANNEL_ZAP_Scrambled_HD_CHANNEL}     'Failed to tune to predefined channel.'

#------------------------------ STEP 2 ------------------------------#
Tune to Non Scrambled Channel
    [Documentation]    This Keyword tunes to the non scrambled channel and checks that Channel Bar is shown and tuner status
    [Setup]    Skip If Last Fail
    set context    ScrambledToScrambled
    ${converted_channel}    Convert To String    ${CHANNEL_ZAP_Scrambled_HD_CHANNEL_2}
    ${channel_id}    I Fetch All Channel ID for given Logical Channel Number    ${converted_channel}
    I press     ${converted_channel}
    log action   ChannelTuned
    wait until keyword succeeds    ${DEFAULT_RETRY_TIMEOUT}   ${DEFAULT_RETRY_INTERVAL}    Channel Bar for live event is Shown    ${converted_channel}
    Wait Until Keyword Succeeds    ${DEFAULT_RETRY_TIMEOUT}    ${DEFAULT_RETRY_INTERVAL}    Verify Linear TV is Tuned via VLDMS     ${channel_id}
    log action    ChannelTuned_Done