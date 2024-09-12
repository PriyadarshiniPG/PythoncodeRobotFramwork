*** Settings ***
Suite Setup       Default Suite Setup
Suite Teardown    Default Suite Teardown
Force Tags        JIRA_CCNAPP_2   INTERIM    PREPROD-UK-EOS  PROD-IE-EOS    PREPROD-IE-EOS    PROD-PL-APOLLO    TV_APPS    PROD-BE-EOSV2    PREPROD-BE-APOLLO-V1-PLUS
Resource          ./Settings.robot
#Library           Libraries.ElasticSearch

#Author           Khushal M Jain

*** Test Cases ***
Navigate to App
    [Documentation]    Navigate to APP in Apps Store via Main Menu
    [Setup]    Default First TestCase Setup
    I open Apps through Main Menu
    I focus App Store in TV APPS for app
    I Select TV App    ${APP_2}

Validate app is launched
    [Documentation]    Validate if app is launched
    [Setup]    Skip If Last Fail
    set context    Launch_APP_2
    log action    ApplicationLaunched
    Run Keyword And Assert Failed Reason    I check '${APP_2}' App is loaded    'APP not launched properly'
    log action    ApplicationLaunched_Done