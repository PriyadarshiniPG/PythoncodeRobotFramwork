*** Settings ***
Suite Setup       Default Suite Setup
Suite Teardown    Default Suite Teardown
Force Tags        JIRA_LiveTVToEPG    PROD-NL-EOS    PROD-NL-bEOSV2    PROD-NL-APOLLO    PROD-CH-EOS    PREPROD-CH-EOS    PROD-NL-SELENE    PROD-UK-EOS  PREPROD-UK-EOS   PROD-IE-EOS    PREPROD-IE-EOS    PROD-PL-APOLLO    PROD-CH-APOLLO    PREPROD-CH-EOSV2    PROD-CH-EOSV2    PROD-UK-BENTO    PREPROD-UK-BENTO    PROD-BE-EOSV2    PREPROD-BE-APOLLO-V1-PLUS
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
    set context     LiveTVToEPG
    I press    GUIDE

Validates Whether TVGuide is Opened Successfully
    [Documentation]    Validates Whether TVGuide is Opened Successfully.
    [Setup]    Skip If Last Fail
    log action    GuideDisplayed
    wait until keyword succeeds    20 times    0 s    Validate TVGuide Is loaded
    log action  GuideDisplayed_Done

