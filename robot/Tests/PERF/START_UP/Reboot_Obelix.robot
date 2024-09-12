*** Settings ***
Suite Setup       Default Suite Setup
Suite Teardown    Default Suite Teardown
Force Tags        JIRA_Reboot_Obelix    PROD-NL-SELENE
Resource          ./Settings.robot
#Library           Libraries.ElasticSearch

#Author              Rajaram Suyamboo

*** variables ***
${CLEAR_CACHE}    false
*** Variables ***
${Slot_No}             6
${Rack_IP}             10.64.15.122

*** Test Cases ***
Wakeup stb
    [Documentation]    Wakeup stb.
    [Tags]    XCCN-9999
    Run Keyword    Connect session    ${Rack_IP}    ${Slot_No}
    set context    Wakeup
    Run Keyword And Assert Failed Reason    Wakeup CPE Perf   'Unable to Reboot CPE'
    I wait for 30 seconds
    Run Keyword    Disconnect session    ${Rack_IP}    ${Slot_No}

*** Keywords ***
Connect session
    [Documentation]    connect session
    [Arguments]    ${Rack_IP}   ${Slot_No}
    connect    ${Rack_IP}    ${Slot_No}    rsuyamboo    rsuyamboo_laptop

Wakeup CPE Perf    #USED
    [Documentation]    Keyword to Wakeup the CPE using xap call. Used part of Xap Sanity
    Run Keyword And Ignore Error    I press Button    PowerCycle
    log action    Wakeup
    Log To Console    Powering up the CPE
    Wait Until Keyword Succeeds    300s   100ms    Box is bootup from standby
    log action    Wakeup_Done
    Sleep    10s

I press Button
    [Documentation]    send keys
    [Arguments]    ${key_code}
    pass command    ${Rack_IP}   ${Slot_No}    ${key_code}

Disconnect session
    [Documentation]    disconnect session
    [Arguments]    ${Rack_IP}   ${Slot_No}
    disconnect    ${Rack_IP}   ${Slot_No}    rsuyamboo
