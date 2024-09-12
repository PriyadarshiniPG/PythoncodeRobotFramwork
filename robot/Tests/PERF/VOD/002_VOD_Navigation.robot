*** Settings ***
Suite Setup       Default Suite Setup
Suite Teardown    Default Suite Teardown
Force Tags        JIRA_VOD_Navigation    PROD-NL-SELENE    PROD-NL-EOS    PROD-NL-EOSV2    PROD-NL-APOLLO    PROD-CH-EOS    PREPROD-CH-EOS    PROD-UK-EOS  PREPROD-UK-EOS  PROD-IE-EOS    PREPROD-IE-EOS    PROD-PL-APOLLO    RERUN-PROD-UK    PROD-CH-APOLLO    PREPROD-CH-EOSV2    PROD-CH-EOSV2    PROD-UK-BENTO    PREPROD-UK-BENTO    PROD-BE-EOSV2    PREPROD-BE-APOLLO-V1-PLUS
Resource          ./Settings.robot
#Library           Libraries.ElasticSearch

#Author           ShanmugaPriyan Mohan
#Last Modified    Shanu Mopila

*** Test Cases ***
Open OnDemand From MainMenu
    [Documentation]    Open and verifies On demand page
    [Tags]    TOOL_CPE
    [Setup]    Default First TestCase Setup
    set context     VOD_Navigation
    Run Keyword And Assert Failed Reason    I open On Demand through Main Menu    'Unable to open ondemand from main menu.'
    I wait for 5 seconds

Navigate through available VOD Section
    [Documentation]    Verifies the VOD Sections
    @{sections}    Get VOD Section Json
    : FOR    ${index}  ${SECTION_JSON}    IN ENUMERATE    @{sections}
    \    ${section_title}    Extract Value For Key    ${SECTION_JSON}    ${EMPTY}    textValue
    \    Continue For Loop If    '${section_title}' == '${EMPTY}'
    \    ${report_label}    Get Action For Section Navigation      VOD    ${section_title}
    \    I Press    RIGHT
    \    log action    ${report_label}
    \    run keyword if    '${section_title}' == 'x'
    \    ...    Wait Until Keyword Succeeds    ${DEFAULT_RETRY_TIMEOUT}   ${DEFAULT_RETRY_INTERVAL}    VOD Grid Screen for given section is shown    ${section_title}    True
    \    ...   ELSE    Wait Until Keyword Succeeds    ${DEFAULT_RETRY_TIMEOUT}   ${DEFAULT_RETRY_INTERVAL}    VOD Grid Screen for given section is shown    ${section_title}  False  False
    \    log action    ${report_label}_Done
