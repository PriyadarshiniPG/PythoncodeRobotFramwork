*** Settings ***
Suite Setup       Default Suite Setup
Suite Teardown    Default Suite Teardown
Force Tags        JIRA_LTvToHome    INTERIM    BENTO    PREPROD-UK-BENTO    PROD-NL-EOS    PROD-NL-EOSV2    PROD-NL-APOLLO    PROD-NL-SELENE    PROD-UK-EOS   PREPROD-UK-EOS    PROD-IE-EOS    PREPROD-IE-EOS    PROD-PL-APOLLO    PROD-CH-APOLLO    PREPROD-CH-EOSV2    PROD-CH-EOSV2    PREPROD-CH-EOS    PROD-CH-EOS    PROD-UK-BENTO    PREPROD-UK-BENTO    PROD-BE-EOSV2    UK_BUG    PREPROD-BE-APOLLO-V1-PLUS
Resource          ./Settings.robot
#Library           Libraries.ElasticSearch

#Author           ShanmugaPriyan Mohan
#Modified         Khushal M Jain


*** Test Cases ***
Tune To LiveTV Channel
    [Documentation]   This keyword tunes to predefined channel
    [Setup]   Default First TestCase Setup
    Run Keyword And Assert Failed Reason    tune to channel ${CHANNEL_ZAP_THREE_DIGIT_INIT_CHANNEL}     'Failed to tune to predefined channel.'
    I wait for 1 seconds
    ${channel_bar_shown}  Run Keyword And Return Status    I expect page contains 'id:NowAndNext.View'
    Run Keyword If    not ${channel_bar_shown}    I PRESS    DOWN

Navigate to Home
    [Documentation]    This Keyword navigats to Home
    [Setup]    Skip If Last Fail
    set context     JIRA_LTvToHome
    I Press    MENU
    log action    OpenMainMenu
    wait until keyword succeeds    ${DEFAULT_RETRY_TIMEOUT}   ${DEFAULT_RETRY_INTERVAL}    Home is shown
    log action    OpenMainMenu_Done