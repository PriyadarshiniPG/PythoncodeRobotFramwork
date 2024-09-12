*** Settings ***
Suite Setup       Default Suite Setup
Suite Teardown    Default Suite Teardown
Force Tags        PHS_Rails_Navigation
Resource          ./Settings.robot
#Library           Libraries.ElasticSearch

#Author           Khushal M Jain

*** Test Cases ***

Invoke Main Menu
    [Documentation]    Invokes Main Menu.
    [Setup]    Default First TestCase Setup
    Run Keyword And Assert Failed Reason    I open Main Menu    'Unable to open main menu'
    wait until keyword succeeds    10 times    0    Main Menu is shown
    I Press    DOWN
    I wait for 3 seconds


Navigate through all PHS Rails
    [Documentation]    Navigates through all the PHS Rails.
    [Setup]    Skip If Last Fail
    ${json_object}    Get Ui Focused Elements
    @{section_json}    Extract Value For Key    ${json_object}    id:shared-CollectionsBrowser    items    ${TRUE}
    Run Keyword And Assert Failed Reason    I open Main Menu    'Unable to open main menu'
    wait until keyword succeeds    10 times    0    Main Menu is shown
    set context    PHS_RAILS_NAVIGATION
    I Press    DOWN
    ${report_action}    Set Variable    ${EMPTY}
    : For    ${variable_key}    IN    @{section_json}
    \    log  ${variable_key}
    \    ${skip_ad}=  Evaluate   "crid" in """${variable_key}"""
    \    Continue For Loop If    ${skip_ad} == ${True}
    \    ${id}    extract value for key    ${variable_key}    ${EMPTY}    id
    \    ${report_action}    Set Variable    ${id}
    \    I Press    DOWN
    \    log action    ${report_action}
    \    I navigate PHS rails    ${id}
    \    log action    ${report_action}_Done