*** Settings ***
Suite Setup       Default Suite Setup
Suite Teardown    Default Suite Teardown
Force Tags        JIRA_CMM_Navigation   PROD-NL-EOS    PROD-NL-EOSV2    PROD-NL-APOLLO    PROD-NL-SELENE    PROD-UK-EOS   PREPROD-UK-EOS    PROD-IE-EOS    PREPROD-IE-EOS    PROD-PL-APOLLO    PROD-CH-APOLLO    PREPROD-CH-EOSV2    PROD-CH-EOSV2    PREPROD-CH-EOS    PROD-CH-EOS    PROD-UK-BENTO    PREPROD-UK-BENTO    PROD-BE-EOSV2    UK_BUG    PREPROD-BE-APOLLO-V1-PLUS
Resource          ./Settings.robot
#Library           Libraries.ElasticSearch

#Author           ShanmugaPriyan Mohan
#Modified         Khushal M Jain

*** Test Cases ***

Invoke Main Menu
    [Documentation]    Invokes Main Menu.
    [Setup]    Default First TestCase Setup
    Run Keyword And Assert Failed Reason    I open Main Menu    'Unable to open main menu'
    wait until keyword succeeds    10 times    0    Main Menu is shown

Get all CMM Sections
    [Documentation]    Navigates through all the sections in CMM.
    [Setup]    Skip If Last Fail
    ${json_object}    Get Ui Focused Elements
    @{section_json}    Extract Value For Key    ${json_object}    id:ctxmm-sectionNavigation|personalhome-sectionNavigation    data    ${TRUE}

    @{cleaned_sections}    create list
    : FOR    ${index}  ${SECTION_JSON}    IN ENUMERATE    @{section_json}
    \    ${section_title}    Extract Value For Key    ${SECTION_JSON}    ${EMPTY}    title
    \    Continue For Loop If    '${section_title}' == '${EMPTY}'
    \    Append To List    ${cleaned_sections}    ${SECTION_JSON}

    ${rotate}    Set Variable        ${-1}
    #Arrange in the next available menu order.
    : FOR    ${index}  ${SECTION_JSON}    IN ENUMERATE    @{cleaned_sections}
    \    ${section_title}    Extract Value For Key    ${SECTION_JSON}    ${EMPTY}    title
    \    ${data}    Extract Value For Key    ${json_object}    id:ctxmm-sectionNavigation.*|personalhome-sectionNavigation.*    data    ${TRUE}
    \    ${focused_section}    Extract Value For Key    ${data}    ${EMPTY}    title
    \    Exit for loop if    '${focused_section}' == '${section_title}'
    \    ${rotate}    Set Variable    ${rotate-1}
    @{section_json}    rotate list   ${cleaned_sections}    ${rotate}

    #Navigate one by one to each section on the right and record the time taken
    set context    CMM_NAVIGATION
    I Press    LEFT
    ${report_action}    Set Variable    ${EMPTY}
    : For    ${variable_key}    IN    @{section_json}
    \    ${id}    extract value for key    ${variable_key}    ${EMPTY}    title
    \    ${report_action}    Get Action For Section Navigation      CMM    ${id}
    \    ${section_id}    run keyword if   '${id}' == 'x' or '${id}' == 'w' or '${id}' == 'ǥ'
    \    ...    CMM modify textValue    ${id}
    \    ${section_id}   set variable if    '${section_id}' == 'None'    ${id}    ${section_id}
    \    I Press    RIGHT
    \    log action    ${report_action}
    \    run keyword if   '${section_id}' == 'x ' or '${section_id}' == 'w ' or '${section_id}' == 'ǥ '
    \    ...    I navigate CMM     ${section_id}    textValue
    \    ...    ELSE    I navigate CMM     ${section_id}    textKey
    \    log action    ${report_action}_Done