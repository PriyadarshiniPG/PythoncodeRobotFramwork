*** Settings ***
Suite Setup       Default Suite Setup
Suite Teardown    Default Suite Teardown
Force Tags        JIRA_CCN-1035    PROD-NL-EOS    PROD-NL-EOSV2    PROD-NL-APOLLO    PROD-CH-EOS    PREPROD-CH-EOS    PROD-NL-SELENE    PROD-UK-EOS  PREPROD-UK-EOS   PROD-IE-EOS    PREPROD-IE-EOS    PROD-PL-APOLLO    PROD-CH-APOLLO    PREPROD-CH-EOSV2    PROD-CH-EOSV2    TV_APPS    PROD-UK-BENTO    PREPROD-UK-BENTO    PROD-BE-EOSV2    PREPROD-BE-APOLLO-V1-PLUS
Resource          ./Settings.robot

#Author           Khushal M Jain

*** Test Cases ***

Open Contextual Mainmenu
    [Documentation]    Open Apps in Mainmenu
    Run Keyword And Assert Failed Reason    I open Main Menu    'Failed to open Main Menu.'

Navigate to TV Apps
    [Documentation]    Navigates to TV Apps
    set context     TVAPPS
    Run Keyword And Assert Failed Reason    I focus Apps    'Unable to navigate to Apps in Mainmenu.'

Validate APP is Opened
    [Documentation]    Validate Apps Screen is Opened
    [Setup]    Skip If Last Fail
    I Press    OK
    log action  TvAppsLaunched
    I check if TV APPS is opened
    log action  TvAppsLaunched_Done

Navigate through available TV APPS Section
    [Documentation]    Verifies the TV APPS Sections
    [Setup]    Skip If Last Fail
    @{sections}    Get TV APPS Section Json
    : FOR    ${index}  ${SECTION_JSON}    IN ENUMERATE    @{sections}
    \    ${section_title}    Extract Value For Key    ${SECTION_JSON}    ${EMPTY}    textValue
    \    Continue For Loop If    '${section_title}' == '${EMPTY}'
    \    ${report_label}    Get Action For Section Navigation      TVAPPS    ${section_title}
    \    I Press    RIGHT
    \    log action    ${report_label}
    \    run keyword if    '${section_title}' == 'x'    I focus TV APPS Section    ${section_title}    textValue    True
    \    ...    ELSE    I focus TV APPS Section    ${section_title}    textValue
    \    log action    ${report_label}_Done