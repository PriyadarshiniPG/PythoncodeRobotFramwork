*** Settings ***
Suite Setup       Default Suite Setup
Suite Teardown    Default Suite Teardown
Force Tags        JIRA_SETTINGS_Navigation  PROD-NL-EOS    PROD-NL-EOSV2    PROD-NL-APOLLO    PROD-CH-EOS    PREPROD-CH-EOS    PROD-NL-SELENE    PROD-UK-EOS  PREPROD-UK-EOS  PROD-IE-EOS    PREPROD-IE-EOS    PROD-PL-APOLLO    RERUN-PROD-UK    PROD-CH-APOLLO    PREPROD-CH-EOSV2    PROD-CH-EOSV2    PROD-UK-BENTO    PREPROD-UK-BENTO    PROD-BE-EOSV2    PREPROD-BE-APOLLO-V1-PLUS
Resource          ./Settings.robot
#Library           Libraries.ElasticSearch

#Author           Khushal M Jain


*** Test Cases ***
Open Settings From MainMenu
    [Documentation]    Open and verifies settings page
    [Setup]    Default First TestCase Setup
    I open Main Menu
    wait until keyword succeeds    10 times    0    run keywords    Main Menu is shown
    ...    AND    I focus Settings
    ...    AND    I Press    OK
    set context     SETTINGS_Navigation
    log action  SettingsIsOpened
    wait until keyword succeeds    20 times    0    Settings screen is shown
    log action  SettingsIsOpened_Done
    Move Focus to the top level Section Navigation

Navigate through available SETTINGS Section
    [Documentation]    Verifies the SETTINGS sections
    [Setup]    Skip If Last Fail
    set context     SETTINGS_Navigation
    @{sections}    Get SETTINGS Section Json
    : FOR    ${index}  ${SECTION_JSON}    IN ENUMERATE    @{sections}
    \    ${section_title}    Extract Value For Key    ${SECTION_JSON}    ${EMPTY}    textValue
    \    Continue For Loop If    '${section_title}' == '${EMPTY}'
    \    ${report_label}    Get Action For Section Navigation      SETTINGS    ${section_title}
    \    I Press    RIGHT
    \    log action    ${report_label}
    \    run keyword if    '${section_title}' == 'x'    I focus SETTINGS Section    ${section_title}    textValue    True
    \    ...    ELSE    I focus SETTINGS Section    ${section_title}    textValue
    \    log action    ${report_label}_Done