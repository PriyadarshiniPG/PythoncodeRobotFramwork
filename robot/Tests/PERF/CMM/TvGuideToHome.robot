*** Settings ***
Suite Setup       Default Suite Setup
Suite Teardown    Default Suite Teardown
Force Tags        TVGuideToHome    INTERIM    BENTO    PREPROD-UK-BENTO    PROD-NL-EOS    PROD-NL-EOSV2    PROD-NL-APOLLO    PROD-NL-SELENE    PROD-UK-EOS   PREPROD-UK-EOS    PROD-IE-EOS    PREPROD-IE-EOS    PROD-PL-APOLLO    PROD-CH-APOLLO    PREPROD-CH-EOSV2    PROD-CH-EOSV2    PREPROD-CH-EOS    PROD-CH-EOS    PROD-UK-BENTO    PREPROD-UK-BENTO    PROD-BE-EOSV2    UK_BUG    PREPROD-BE-APOLLO-V1-PLUS
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

#I open Channel Bar
#    [Documentation]    This Keyword opens the Channel Bar
#    [Setup]   Default First TestCase Setup
#    Run Keyword And Assert Failed Reason    I tune to a channel with replay events    'Unable to Tune to replay event.'

Open EPG From LiveTV
    [Documentation]    This Keyword opens the EPG
    [Setup]    Skip If Last Fail
    set context     TVGuideToHome
    I press    GUIDE

Validates Whether TVGuide is Opened Successfully
    [Documentation]    Validates Whether TVGuide is Opened Successfully.
    [Setup]    Skip If Last Fail
#    log action    GuideDisplayed
    wait until keyword succeeds    20 times    0 s    Validate TVGuide Is loaded
#    log action  GuideDisplayed_Done

Navigate to Home
    [Documentation]    This Keyword navigates to home
    [Setup]    Skip If Last Fail
    I wait for 2 seconds
    I Press    MENU
    I wait for 1 second
    I Press    MENU
    log action    OpenMainMenu
    wait until keyword succeeds    ${DEFAULT_RETRY_TIMEOUT}   ${DEFAULT_RETRY_INTERVAL}    Home is shown
    log action    OpenMainMenu_Done