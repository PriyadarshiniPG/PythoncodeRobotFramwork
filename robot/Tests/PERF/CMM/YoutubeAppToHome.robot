*** Settings ***
Suite Setup       Default Suite Setup
Suite Teardown    Default Suite Teardown
Force Tags        YouTubeAppToHome
Resource          ./Settings.robot
#Library           Libraries.ElasticSearch

#Author           Khushal M Jain

*** Test Cases ***
Navigate to Youtube App
    [Documentation]    Navigate to YouTube APP in Apps Store via Main Menu
    [Setup]    Default First TestCase Setup
    I open Apps through Main Menu
    I focus App Store in TV APPS for app
    I Select TV App    ${APP_Youtube}

Validate Youtube app is launched
    [Documentation]    Validate if youtube is launched
    [Setup]    Skip If Last Fail
    set context    YouTubeAppToHome
#    log action    ApplicationLaunched
    Run Keyword And Assert Failed Reason    I check '${APP_Youtube}' App is loaded    'YouTube APP not launched properly'
#    log action    ApplicationLaunched_Done

#Exit Youtube App
#    [Documentation]    Exit the Youtube App
#    [Setup]    Skip If Last Fail
#    I wait for 10 seconds
##    I Long Press MENU for 1 seconds
#    I Press   MENU
#    ${app_view}    Set Variable    WebApp.View
#    set context    Exit_Youtube
#    log action    ApplicationClosed
#    Wait Until Keyword Succeeds    20 times    0    I do not expect page contains 'id:${app_view}'
#    log action    ApplicationClosed_Done

Navigate to Home
    [Documentation]    This Keyword navigates to home
    [Setup]    Skip If Last Fail
    I wait for 5 seconds
    I Long Press MENU for 1 seconds
    I Press    MENU
    I wait for 1 seconds
    I Press    MENU
    log action    OpenMainMenu
    wait until keyword succeeds    ${DEFAULT_RETRY_TIMEOUT}   ${DEFAULT_RETRY_INTERVAL}    Home is shown
    log action    OpenMainMenu_Done