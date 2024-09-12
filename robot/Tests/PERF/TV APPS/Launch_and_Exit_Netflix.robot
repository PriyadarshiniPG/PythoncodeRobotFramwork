*** Settings ***
Suite Setup       Default Suite Setup
Suite Teardown    Default Suite Teardown
Force Tags        JIRA_CCNNetflix    PROD-NL-EOS    PROD-NL-EOSV2    PROD-NL-APOLLO    PROD-CH-EOS    PROD-CH-APOLLO    PROD-CH-EOSV2    PROD-NL-SELENE    PROD-UK-EOS  PREPROD-UK-EOS    TV_APPS    PROD-UK-BENTO    PREPROD-UK-BENTO    PROD-BE-EOSV2    PREPROD-BE-APOLLO-V1-PLUS
Resource          ./Settings.robot
#Library           Libraries.ElasticSearch

#Author           Khushal M Jain

*** Test Cases ***
Navigate to Netflix App
    [Documentation]    Navigate to netflix APP in Apps Store via Main Menu
    [Setup]    Default First TestCase Setup
    I open Apps through Main Menu
    I focus App Store in TV APPS for app
    I Select TV App    ${APP_Netflix}

Validate Netflix app is launched
    [Documentation]    Validate if netflix is launched
    [Setup]    Skip If Last Fail
    set context    Launch_Netflix
    log action    ApplicationLaunched
    Run Keyword And Assert Failed Reason    I check '${APP_Netflix}' App is loaded    'Netflix APP not launched properly'
    log action    ApplicationLaunched_Done

Exit Netflix App
    [Documentation]    Exit the Netflix App
    [Setup]    Skip If Last Fail
    I wait for 10 seconds
    #I Long Press MENU for 1 seconds
    I Press   MENU
    ${app_view}    Set Variable    Native.View
    set context    Exit_Netflix
    log action    ApplicationClosed
    Wait Until Keyword Succeeds    20 times    0    I do not expect page contains 'id:${app_view}'
    log action    ApplicationClosed_Done