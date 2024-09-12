*** Settings ***
Documentation     Keywords related to STB allocation for Pabot
Library           pabot.PabotLib

*** Keywords ***
Allocate STB    #USED
    [Documentation]    Keyword prepares STB environment for test
    Log    "Allocate STB"
    Run Keyword if    '${PABOT}' == 'True'    Pabot Requeriments
    Acquire STB data

Open Serial Port
    [Documentation]    Keyword opens serial port and makes sure that it is opened
    open port    ${SERIAL_PORT}
    ${thread_response}    Verify Serial response
    should be true    ${thread_response}    Serial port is not opened

Close Serial Port
    [Documentation]    Keyword closes serial port and makes sure that it is closed
    close port    ${SERIAL_PORT}
    Verify Serial response

Acquire STB data    #USED
    [Documentation]    Sets STB DATA as a suite variables - Use DUTInfo.py Library - RackDetails.yml
    ${ip}    Get CPE IP    ${RACK_SLOT_ID}
    Set Suite Variable    ${STB_IP}    ${ip}
    ${id}    Get CPE ID    ${RACK_SLOT_ID}
    Set Suite Variable    ${CPE_ID}    ${id}
    ${ca}    Get CA ID    ${RACK_SLOT_ID}
    Set Suite Variable    ${CA_ID}    ${ca}
    ${exact_platform}    Get Exact Platform    ${RACK_SLOT_ID}
    Set Suite Variable    ${EXACT_PLATFORM}    ${exact_platform}
    ${acquired_platform}    Get General Platform    ${RACK_SLOT_ID}
    Set Suite Variable    ${PLATFORM}    ${acquired_platform}
    ${panoramix}    Get Panoramix Support    ${RACK_SLOT_ID}
    Set Suite Variable    ${PANORAMIX_SUPPORT}    ${panoramix}
    ${pdu_slot}    Get Pdu Slot    ${RACK_SLOT_ID}
    Set Suite Variable    ${STB_PDU_SLOT}    ${pdu_slot}
    ${router_pc_ip}    Get Router Pc Ip    ${RACK_SLOT_ID}
    Set Suite Variable    ${ROUTER_PC}    ${router_pc_ip}
    ${obelix}    Get Obelix Support    ${RACK_SLOT_ID}
    Set Suite Variable    ${OBELIX}    ${obelix}
    Run Keyword If    ${OBELIX}    Set Obelix Variables
    ${serialcom}    ${serial_port}    Get Serial Port    ${RACK_SLOT_ID}
    Set Suite Variable    ${SERIALCOM}    ${serialcom}
    Set Suite Variable    ${SERIAL_PORT}    ${serial_port}
    Run Keyword if    '${SERIALCOM}' == 'True'    Log To Console    \nINFO: SERIALCOM IS ENABLE\n
    ${city_id}    Get City ID    ${RACK_SLOT_ID}
    ${city_id}    convert to string    ${city_id}
    Set Suite Variable    ${CITY_ID}    ${city_id}
    Run Keyword If    '${CITY_ID}' != 'default'    log to console   \nENV Var: CITY_ID is not 'default' - so using it RackDetails value: ${CITY_ID}\n
    Run Keyword If    '${OSD_LANGUAGE}' != 'default'    log to console   \nENV Var: OSD_LANGUAGE is not 'default' - so using it RackDetails(default 'en'): ${OSD_LANGUAGE}\n
    ${osd_language_details}    Run Keyword If    '${OSD_LANGUAGE}' == 'default'    Get OSD Language Details    ${RACK_SLOT_ID}
    Run Keyword If    '${OSD_LANGUAGE}' == 'default'    Set Suite Variable    ${OSD_LANGUAGE}   ${osd_language_details}
    log to console    OSD_LANGUAGE is going to be set to: ${OSD_LANGUAGE}
    ${elastic_stb}    Get Elastic    ${RACK_SLOT_ID}
    ${elastic_stb}    convert to string    ${elastic_stb}
    Run Keyword if    '${ELASTIC}' == 'True' and '${elastic_stb}' == 'False'     Set Suite Variable    ${ELASTIC}    False
    log to console    ELASTIC: ${ELASTIC}

    #Red Rat Specific
    ${RED_RAT_IR_IP}    Get Red Rat IR IP    ${RACK_SLOT_ID}
    Set Suite Variable    ${RED_RAT_IR_IP}    ${RED_RAT_IR_IP}
    ${RED_RAT_IR_PORT}    Get Red Rat IR Port    ${RACK_SLOT_ID}
    Set Suite Variable    ${RED_RAT_IR_PORT}    ${RED_RAT_IR_PORT}
    ${RED_RAT_DEVICE}    Get Red Rat IR Device    ${RACK_SLOT_ID}
    Set Suite Variable    ${RED_RAT_DEVICE}    ${RED_RAT_DEVICE}
    ${RED_RAT_DEVICE_OUTPUT_PORT}    Get Red Rat IR Device Output Port    ${RACK_SLOT_ID}
    Set Suite Variable    ${RED_RAT_DEVICE_OUTPUT_PORT}    ${RED_RAT_DEVICE_OUTPUT_PORT}

Get A Free CPE Slot Pabot    #USED
    [Documentation]    Keyword acquieres STB from Pabot pool for test
    [Timeout]    2 minutes
    Log    Get A Free CPE Slot Pabot
    log to console    Get A Free CPE Slot Pabot
    ${valuesetname}    Acquire Value Set
    Set Global Variable    ${VALUESETNAME}    ${valuesetname}
    Set Suite Variable    ${RACK_SLOT_ID}    ${VALUESETNAME}
    Log    Get a free cpe slot Pabot - RACK_SLOT_ID: ${RACK_SLOT_ID}
    Log to console    Get a free cpe slot Pabot - RACK_SLOT_ID: ${RACK_SLOT_ID}
#    ${tmp}    Get Value From Set    address
#    Set Global Variable    ${ADDRESS}    ${tmp}
#    ${tmp}    Get Value From Set    port
#    Set Global Variable    ${PORT}    ${tmp}
#    ${tmp}    Get Value From Set    tftpserver
#    Set Global Variable    ${TFTPSRV}    ${tmp}

Release STB    #USED
    [Documentation]    Keyword releases STB from Pabot pool
    Run Keyword if    '${SERIALCOM}' == 'True'    Close Serial Port
    Run Keyword if    '${PABOT}' == 'True'    Release Value Set
    Log    "Release STB"

Load remote library    #NOT_USED
    [Documentation]    This keywords loads remote library . This provides robot execution on remote machine
    LOG    ${PORT}
    LOG    ${ADDRESS}
    Import Library    Remote    http://${ADDRESS}:${PORT}

Pabot Requeriments    #USED
    [Documentation]    Keyword releases STB and load Lib from Pabot pool
    Get A Free CPE Slot Pabot
#    Load remote library
# comment   the Load remote Library as we already import the libs on RobotFramework code and it is duplicated
#Multiple keywords with name 'get fti state via as' found. Give the full name of the keyword you want to use:
#    Libraries.Stb.AppServices.Get Fti State Via As
#    Remote.Get Fti State Via As

Set Obelix Variables    #USED
    [Documentation]    Keyword sets Suite Variable for Obelix Details Like IP and Slot
    ${rack_pc_ip}    Get Rack Pc Ip    ${RACK_SLOT_ID}
    Set Suite Variable    ${RACK_PC_IP}    ${rack_pc_ip}
    ${stb_slot}    Get Slot    ${RACK_SLOT_ID}
    Set Suite Variable    ${STB_SLOT}    ${stb_slot}
