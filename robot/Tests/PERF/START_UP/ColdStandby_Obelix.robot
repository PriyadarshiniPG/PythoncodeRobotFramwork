*** Settings ***
Suite Setup       Default Suite Setup
Suite Teardown    Default Suite Teardown
Force Tags        JIRA_Cold_Standby_Obelix    PROD-NL-SELENE
Resource          ./Settings.robot
#Library           Libraries.ElasticSearch

#Author              Rajaram Suyamboo

*** variables ***
${CLEAR_CACHE}    false
*** Variables ***

${Slot_No}             4
#${Rack_IP}             10.64.15.115
${RACK_PC_IP}             10.64.15.115

*** Test Cases ***
I Change the PowerConsumption To ColdStandby
    [Documentation]     This step change the power consumption to ColdStandby
    [Setup]    Default First TestCase Setup
    #I Tune To Random Replay Channel
    #I set standby mode to    ColdStandby
    I set standby mode to    LukewarmStandby

Makes STB To PowerOFF
    [Documentation]    This test makes the STB to PowerOFF
    [Setup]    Skip If Last Fail
    Run Keyword And Assert Failed Reason     I put stb in standby    'Tune cannot be done.'
    sleep    310s
    #sleep    10s

Wakeup stb
    [Documentation]    Wakeup stb.
    [Tags]    XCCN-9999
    #${Slot_No} set variables BuiltIn().get_variable_value("${Slot_No}")
    #${Slot_No}    Set Variable     get_variable_value
    Log To Console   ${Slot_No}
    Run Keyword    Connect session    ${RACK_PC_IP}    ${Slot_No}
    set context    Wakeup
    Run Keyword And Assert Failed Reason    Wakeup CPE Perf   'Unable to Reboot CPE'
    I wait for 10 seconds
    I set standby mode to    ActiveStandby
    Run Keyword    Disconnect session    ${RACK_PC_IP}    ${Slot_No}

*** Keywords ***
Connect session
    [Documentation]    connect session
    [Arguments]    ${RACK_PC_IP}   ${Slot_No}
    connect    ${RACK_PC_IP}    ${Slot_No}    rsuyamboo    rsuyamboo_laptop

Wakeup CPE Perf    #USED
    [Documentation]    Keyword to Wakeup the CPE using xap call. Used part of Xap Sanity
    Run Keyword And Ignore Error    I press Button    power button
    log action    Wakeup
    Log To Console    Waking up the CPE
    wait until keyword succeeds    300s   0ms    Check if box is connected
    Wait Until Keyword Succeeds    300s   100ms    Box is bootup from standby
    log action    Wakeup_Done
    Sleep    10s

I press Button
    [Documentation]    send keys
    [Arguments]    ${key_code}
    pass command    ${RACK_PC_IP}   ${Slot_No}    ${key_code}

Disconnect session
    [Documentation]    disconnect session
    [Arguments]    ${RACK_PC_IP}   ${Slot_No}
    disconnect    ${RACK_PC_IP}   ${Slot_No}    rsuyamboo

