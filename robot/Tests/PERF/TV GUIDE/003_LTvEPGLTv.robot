*** Settings ***
Suite Setup       Default Suite Setup
Suite Teardown    Default Suite Teardown
Force Tags        JIRA_LTvEPGLTv    INTERIM    PROD-NL-EOS    PROD-NL-EOSV2    PROD-NL-APOLLO    PROD-CH-EOS    PREPROD-CH-EOS    PROD-NL-SELENE    PROD-UK-EOS  PREPROD-UK-EOS    PROD-IE-EOS    PREPROD-IE-EOS    PROD-PL-APOLLO    PROD-CH-APOLLO    PREPROD-CH-EOSV2    PROD-CH-EOSV2    PROD-UK-BENTO    PREPROD-UK-BENTO
Resource          ./Settings.robot
#Library           Libraries.ElasticSearch

#Author           ShanmugaPriyan Mohan
#Modified         Khushal M Jain

*** Test Cases ***
I open Channel Bar
    [Documentation]    This Keyword opens the Channel Bar
    [Setup]   Default First TestCase Setup
    Run Keyword And Assert Failed Reason    I tune to a channel with replay events    'Unable to Tune to replay event.'

Open EPG From LiveTV
    [Documentation]    This Keyword opens the EPG
    [Setup]    Skip If Last Fail
    set context     LTvEPGLTv
    I Press    MENU
    log action    OpenMainMenu
    wait until keyword succeeds    20 times    0    Main Menu is shown
    log action    OpenMainMenu_Done
    I focus TV Guide
    I Press    OK

Validates Whether TVGuide is Opened Successfully
    [Documentation]    Validates Whether TVGuide is Opened Successfully.
    [Setup]    Skip If Last Fail
    log action    GuideDisplayed
    wait until keyword succeeds    20 times    0 s    Validate TVGuide Is loaded
    log action  GuideDisplayed_Done

Tune To Replay Event
    [Documentation]    ReplayTV - Tune to replay event.
    [Setup]    Skip If Last Fail
    Run Keyword And Assert Failed Reason    I Tune To A Channel With Replay Events From TV Guide    'Unable to Tune to replay event'

Play Current Event
    [Documentation]    This Keyword plays the content.
    [Setup]    Skip If Last Fail
    ${converted_channel}    Convert To String    ${tv_guide_replay_channel_tuned}
    ${channel_id}    I Fetch All Channel ID for given Logical Channel Number    ${converted_channel}
    Run Keyword And Assert Failed Reason    I open Live TV    'Unable to play the live TV.'
    log action    LiveTVStarted
    wait until keyword succeeds    20 times   100 ms    Channel Bar for live event is Shown    ${converted_channel}
    Wait Until Keyword Succeeds    20times    100ms    Verify Linear TV is Tuned via VLDMS     ${channel_id}
    log action    LiveTVStarted_Done

Open detail page of replay event from TV Guide
    [Documentation]    This Keyword opens details page of replay event from TV GUIDE
    [Tags]    TOOL_TV_GUIDE
    [Setup]    Skip If Last Fail
    I Press    MENU
    wait until keyword succeeds    20 times    0    Main Menu is shown
    I focus TV Guide
    I Press    OK
    wait until keyword succeeds    20 times    0 s    Validate TVGuide Is loaded
    I Press    INFO
    I wait for 2 seconds
    I Press    OK
    log action    ValidateInfo
    wait until keyword succeeds    20 times    0 s    Details Page is Shown
    log action    ValidateInfo_Done



