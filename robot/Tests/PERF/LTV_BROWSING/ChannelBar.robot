*** Settings ***
Suite Setup       Default Suite Setup
Suite Teardown    Default Suite Teardown
Resource          ./Settings.robot
#Library           Libraries.ElasticSearch
Force Tags        JIRA_ChannelBar     INTERIM    PROD-NL-SELENE    PROD-NL-EOS    PROD-NL-EOSV2    PROD-NL-APOLLO    PROD-CH-EOS    PREPROD-CH-EOS    PROD-UK-EOS   PREPROD-UK-EOS    PROD-IE-EOS    PREPROD-IE-EOS    PROD-PL-APOLLO    PROD-CH-APOLLO    PREPROD-CH-EOSV2    PROD-CH-EOSV2    PROD-UK-BENTO    PREPROD-UK-BENTO    PROD-BE-EOSV2    PREPROD-BE-APOLLO-V1-PLUS

#Author                ShanmugaPriyan Mohan
#Last Modified by      Shanu Mopila

*** Test Cases ***

#------------------------------ STEP 1 ------------------------------#
I open Channel Bar
    [Documentation]    This Keyword opens the Channel Bar
    [Setup]   Default First TestCase Setup
    I Tune To Random Replay Channel
    I dismiss channel bar
    I Press    OK

#------------------------------ STEP 2 ------------------------------#
Channel Bar is verified
    [Documentation]    This Keyword checks that Channel Bar is shown
    [Setup]    Skip If Last Fail
    set context     ChannelBar
    log action    ChannelBarValidation
    wait until keyword succeeds    ${DEFAULT_RETRY_TIMEOUT}    ${DEFAULT_RETRY_INTERVAL}    Channel Bar for live event is Shown    ${TUNED_CHANNEL_NUMBER}
    log action  ChannelBarValidation_Done

#------------------------------ STEP 3 ------------------------------#
I Navigate Previous Channel In Channel Bar
     [Documentation]   This keyword validates the channel bar navigation to Previous channel
     [Setup]    Skip If Last Fail
     set context     CBarBrowsingPreviousChannel
     ${previous_channel_number}    Get the Adjacent Channel      ${TUNED_CHANNEL_NUMBER}    -1
    I Press    UP
    log action    ChannelBarValidation
    wait until keyword succeeds    ${DEFAULT_RETRY_TIMEOUT}    ${DEFAULT_RETRY_INTERVAL}    Channel Bar for live event is Shown    ${previous_channel_number}
    log action  ChannelBarValidation_Done
#------------------------------ STEP 4 ------------------------------#
I Dismiss the ChannelBar and bring back again
     [Documentation]   This keyword dismisses the channebar and activates it again
     [Setup]    Skip If Last Fail
     set context     None
     I dismiss channel bar
     I Press    OK
     wait until keyword succeeds    ${DEFAULT_RETRY_TIMEOUT}    ${DEFAULT_RETRY_INTERVAL}    Channel Bar for live event is Shown    ${TUNED_CHANNEL_NUMBER}
#------------------------------ STEP 5 ------------------------------#
I Navigate to Next Channel In Channel Bar
    [Documentation]   This keyword validates the channel bar navigation to Next channel
    [Setup]    Skip If Last Fail
    set context     CBarBrowsingNextChannel
    ${next_channel_number}    Get the Adjacent Channel      ${TUNED_CHANNEL_NUMBER}    1
    I Press    DOWN
    log action    ChannelBarValidation
    wait until keyword succeeds    ${DEFAULT_RETRY_TIMEOUT}    ${DEFAULT_RETRY_INTERVAL}    Channel Bar for live event is Shown    ${next_channel_number}
    log action  ChannelBarValidation_Done
#------------------------------ STEP 6 ------------------------------#
I Dismiss the ChannelBar and bring back again for future event validation
     [Documentation]   This keyword dismisses the channebar and activates it again
     [Setup]    Skip If Last Fail
     set context     None
     I dismiss channel bar
     I Press    OK
     wait until keyword succeeds    ${DEFAULT_RETRY_TIMEOUT}    ${DEFAULT_RETRY_INTERVAL}    Channel Bar for live event is Shown    ${TUNED_CHANNEL_NUMBER}
 #------------------------------ STEP 7 ------------------------------#
I Navigate to Future Event In Channel Bar
    [Documentation]   This keyword validates the channel bar navigation to Future Event
    [Setup]    Skip If Last Fail
    set context     CBarBrowsingFutureEvent
    I Press    RIGHT
    log action    CBarBrowsingFutureEventValidation
    wait until keyword succeeds    ${DEFAULT_RETRY_TIMEOUT}    ${DEFAULT_RETRY_INTERVAL}    Channel Bar for future event is Shown    ${TUNED_CHANNEL_NUMBER}
    log action  CBarBrowsingFutureEventValidation_Done
#------------------------------ STEP 8 ------------------------------#
I Dismiss the ChannelBar and bring back again for past event validation
     [Documentation]   This keyword dismisses the channebar and activates it again
     [Setup]    Skip If Last Fail
     set context     None
     I dismiss channel bar
     I Press    OK
     wait until keyword succeeds    ${DEFAULT_RETRY_TIMEOUT}    ${DEFAULT_RETRY_INTERVAL}    Channel Bar for live event is Shown    ${TUNED_CHANNEL_NUMBER}
 #------------------------------ STEP 9 ------------------------------#
I Navigate to Past Event In Channel Bar
    [Documentation]   This keyword validates the channel bar navigation to Past Event
    [Setup]    Skip If Last Fail
    set context     CBarBrowsingPreviousEvent
    I Press    LEFT
    log action    CBarBrowsingPreviousEventtValidation
    wait until keyword succeeds    ${DEFAULT_RETRY_TIMEOUT}    ${DEFAULT_RETRY_INTERVAL}    Channel Bar for past event is Shown    ${TUNED_CHANNEL_NUMBER}
    log action  CBarBrowsingPreviousEventtValidation_Done