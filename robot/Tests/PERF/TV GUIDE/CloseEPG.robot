*** Settings ***
Suite Setup       Default Suite Setup
Suite Teardown    Default Suite Teardown
Resource          ./Settings.robot
#Library           Libraries.ElasticSearch
Force Tags        JIRA_CloseEPG    PROD-NL-EOS    PROD-NL-EOSV2    PROD-NL-APOLLO    PROD-CH-EOS    PREPROD-CH-EOS    PROD-NL-SELENE    PROD-UK-EOS  PREPROD-UK-EOS  PROD-IE-EOS    PREPROD-IE-EOS    PROD-PL-APOLLO    R4_29    PROD-CH-APOLLO    PREPROD-CH-EOSV2    PROD-CH-EOSV2    PROD-UK-BENTO    PREPROD-UK-BENTO    PROD-BE-EOSV2    PREPROD-BE-APOLLO-V1-PLUS

#Author    ShanmugaPriyan Mohan
#Modified  Khushal M Jain

*** Test Cases ***

Invoke Main Menu
    [Documentation]    Invokes Main Menu.
    [Setup]    Default First TestCase Setup
    set context     CloseEPG
    Run Keyword And Assert Failed Reason     I open Main Menu    'Unable to Open Main Menu'

Validate whether Main Menu is Displayed
    [Documentation]    Validates Main Menu is Displayed.
    [Setup]    Skip If Last Fail
    wait until keyword succeeds    20 times    0    Main Menu is shown

Open TVGuide
    [Documentation]    Opens TVGuide.
    [Setup]    Skip If Last Fail
    Run Keyword And Assert Failed Reason     I open Guide    'Cannot Open TVGuide'

Close EPG And Vallidate Main Menu
    [Documentation]     Close the EPG and goes back to Main Menu
    [Setup]   Skip If Last Fail
    I press    BACK
    log action    ExitEPG
    wait until keyword succeeds    20 times    0 s    Main Menu is shown
    log action    ExitEPG_Done
    I wait for 1 seconds

Validates Whether TVGuide is Opened Successfully
    [Documentation]    Validates Whether TVGuide is Opened Successfully.
    I press    GUIDE
    log action    GuideDisplayed
    wait until keyword succeeds    20 times    0 s    Validate TVGuide Is loaded
    log action  GuideDisplayed_Done
