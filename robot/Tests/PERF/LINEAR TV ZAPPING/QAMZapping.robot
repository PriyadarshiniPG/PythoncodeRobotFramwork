*** Settings ***
Suite Setup       Default Suite Setup
Suite Teardown    Default Suite Teardown
Resource          ./Settings.robot
#Library           Libraries.ElasticSearch
Force Tags        JIRA_QAMZapping    PROD-NL-EOS    PROD-NL-EOSV2    PROD-NL-APOLLO   PROD-CH-EOS    PREPROD-CH-EOS   PROD-NL-SELENE    PROD-UK-EOS  PREPROD-UK-EOS   PROD-IE-EOS    PREPROD-IE-EOS    PROD-UK-BENTO    PREPROD-UK-BENTO

#Author           Shanu Mopila

*** Test Cases ***
#------------------------------ STEP 1 ------------------------------#
Tune To PreDefined QAM Channel
    [Documentation]   This keyword tunes to predefined QAM channel
    [Setup]   Default First TestCase Setup
    Run Keyword And Assert Failed Reason    tune to channel ${CHANNEL_ZAP_QAM_INIT_CHANNEL}     'Failed to tune to predefined channel.'

#------------------------------ STEP 2 ------------------------------#
Tune to anothe QAM channel in different frequency range
    [Documentation]    This Keyword tunes to another QAM channel in different frequency and checks that Channel Bar is shown and tuner status
    [Setup]    Skip If Last Fail
    set context    QAMZapping
    ${converted_channel}    Convert To String    ${CHANNEL_ZAP_QAM_FINAL_CHANNEL}
    ${channel_id}    I Fetch All Channel ID for given Logical Channel Number    ${converted_channel}
    I press     ${converted_channel}
    log action   ChannelTuned
    wait until keyword succeeds    ${DEFAULT_RETRY_TIMEOUT}   ${DEFAULT_RETRY_INTERVAL}    Channel Bar for live event is Shown    ${converted_channel}
    Wait Until Keyword Succeeds    ${DEFAULT_RETRY_TIMEOUT}    ${DEFAULT_RETRY_INTERVAL}    Verify Linear TV is Tuned via VLDMS     ${channel_id}
    log action    ChannelTuned_Done