*** Settings ***
Suite Setup       Default Suite Setup
Suite Teardown    Default Suite Teardown
Force Tags        ForYouToHome    INTERIM    BENTO    PREPROD-UK-BENTO    PROD-NL-EOS    PROD-NL-EOSV2    PROD-NL-APOLLO    PROD-NL-SELENE    PROD-UK-EOS   PREPROD-UK-EOS    PROD-IE-EOS    PREPROD-IE-EOS    PROD-PL-APOLLO    PROD-CH-APOLLO    PREPROD-CH-EOSV2    PROD-CH-EOSV2    PREPROD-CH-EOS    PROD-CH-EOS    PROD-UK-BENTO    PREPROD-UK-BENTO    PROD-BE-EOSV2    UK_BUG    PREPROD-BE-APOLLO-V1-PLUS
Resource          ./Settings.robot

#Author           Khushal M Jain

*** Test Cases ***

Open Contextual Mainmenu
    [Documentation]    Open Apps in Mainmenu
#    run keyword if   '${PRODUCT}' == 'BENTO'
#    ...    Run Keyword And Assert Failed Reason    Bento Main Menu is shown    'Failed to open Main Menu.'
#    run keyword if   '${PRODUCT}' != 'BENTO'
#    ...    Run Keyword And Assert Failed Reason    I open Main Menu    'Unable to open main menu'
    Run Keyword And Assert Failed Reason    I open Main Menu    'Unable to open main menu'

Navigate to TV Apps
    [Documentation]    Navigates to TV Apps
    set context     ForYouToHome
    Run Keyword And Assert Failed Reason    I focus Apps    'Unable to navigate to Apps in Mainmenu.'

Validate APP is Opened
    [Documentation]    Validate Apps Screen is Opened
    [Setup]    Skip If Last Fail
    I Press    OK
#    log action  TvAppsLaunched
    I check if TV APPS is opened
#    log action  TvAppsLaunched_Done
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