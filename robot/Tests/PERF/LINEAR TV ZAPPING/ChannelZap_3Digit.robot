*** Settings ***
Suite Setup       Default Suite Setup
Suite Teardown    Default Suite Teardown
Resource          ./Settings.robot
#Library           Libraries.ElasticSearch
Force Tags        JIRA_ChannelZap_3Digit    INTERIM   PROD-NL-SELENE   PROD-CH-EOS    PREPROD-CH-EOS    PROD-UK-EOS   PREPROD-UK-EOS    PROD-IE-EOS    PREPROD-IE-EOS    PROD-NL-EOS    PROD-NL-EOSV2    PROD-NL-APOLLO    PROD-PL-APOLLO    PROD-CH-APOLLO    PREPROD-CH-EOSV2    PROD-CH-EOSV2       TV_APPS    PROD-UK-BENTO    PREPROD-UK-BENTO    PREPROD-BE-APOLLO-V1-PLUS

#Author           ShanmugaPriyan Mohan
#Last Mofified      Shanu Mopila

*** Test Cases ***
#------------------------------ STEP 1 ------------------------------#
Tune To PreDefined Channel
    [Documentation]   This keyword tunes to predefined channel
    [Setup]   Default First TestCase Setup
    Run Keyword And Assert Failed Reason    tune to channel ${CHANNEL_ZAP_THREE_DIGIT_INIT_CHANNEL}     'Failed to tune to predefined channel.'

#------------------------------ STEP 2 ------------------------------#
Tune to 3 Digit Channel
    [Documentation]    This Keyword tunes to the 3 digit channel and checks that Channel Bar is shown and tuner status
    [Setup]    Skip If Last Fail
    set context    ChannelZap_3Digit
    ${converted_channel}    Convert To String    ${CHANNEL_ZAP_THREE_DIGIT_FINAL_CHANNEL}
    ${channel_id}    I Fetch All Channel ID for given Logical Channel Number    ${converted_channel}
    I press     ${converted_channel}
    log action   ChannelTuned
    wait until keyword succeeds    ${DEFAULT_RETRY_TIMEOUT}   ${DEFAULT_RETRY_INTERVAL}    Channel Bar for live event is Shown    ${converted_channel}
    Wait Until Keyword Succeeds    ${DEFAULT_RETRY_TIMEOUT}    ${DEFAULT_RETRY_INTERVAL}    Verify Linear TV is Tuned via VLDMS     ${channel_id}
    log action    ChannelTuned_Done