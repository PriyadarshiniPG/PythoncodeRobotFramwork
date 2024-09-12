*** Settings ***
Suite Setup       Default Suite Setup
Suite Teardown    Default Suite Teardown
Force Tags        JIRA_SAVED_Navigation    PROD-NL-SELENE    PROD-NL-EOS    PROD-NL-EOSV2    PROD-NL-APOLLO    PROD-CH-EOS    PREPROD-CH-EOS    PROD-UK-EOS  PREPROD-UK-EOS  PROD-IE-EOS    PREPROD-IE-EOS    PROD-PL-APOLLO    PROD-CH-APOLLO    PREPROD-CH-EOSV2    PROD-CH-EOSV2       TV_APPS    PROD-BE-EOSV2    PREPROD-BE-APOLLO-V1-PLUS
Resource          ./Settings.robot
#Library           Libraries.ElasticSearch

#Author               ShanmugaPriyan Mohan
# Last Modifies By    Shanu Mopila

*** Test Cases ***
Open SAVED From MainMenu
    [Documentation]    Open and verifies On demand page
    [Tags]    TOOL_CPE
    [Setup]    Default First TestCase Setup
    set context    SAVED_Navigation
    Run Keyword And Assert Failed Reason    I open Saved through Main Menu    'Unable to open recording page from main menu.'
    Wait Until Keyword Succeeds    ${DEFAULT_RETRY_TIMEOUT}   ${DEFAULT_RETRY_INTERVAL}
    ...    Saved is shown

Navigate through available SAVED Section
    [Documentation]    Verifies the SAVED Sections
    log action    RECORDINGS
    Wait Until Keyword Succeeds    ${DEFAULT_RETRY_TIMEOUT}   ${DEFAULT_RETRY_INTERVAL}    SAVED Grid Screen for given section is shown    False  False
    log action    RECORDINGS_Done