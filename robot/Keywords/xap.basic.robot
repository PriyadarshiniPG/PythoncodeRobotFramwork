*** Settings ***
Library           Libraries.XAP
Library           String

*** Keywords ***
Check XAP Call Response    #USED
    [Arguments]    ${xap_call_result}    ${call_name}
    ${error}    Set Variable    ${EMPTY}
    ${check_result}    check_xap_call_result    ${xap_call_result}    ${call_name}
    Log    check_result: ${check_result}
    Log    Data: ${check_result[1]}
    ${error}    Set Variable if    ${check_result[0]} == True    ${EMPTY}    XAP: ${call_name} returned ${xap_call_result} on STB ${CPE_ID} in lab '${LAB_NAME}'.
    Log    XAP Call error (empty is no error): ${error}
    [Return]    ${error}

Reboot CPE    #USED
    [Documentation]    Keyword to Reboot the CPE using xap call. Used part of Xap Sanity
    ${result}    Run Keyword And Ignore Error    Reboot    ${LAB_CONF}    ${CPE_ID}
    ${failedReason}    Set variable If    "${result[0]}" == "PASS"    ${EMPTY}    ${result[1]}
    ${status}    Run Keyword If    "${result[0]}" != "PASS"
    ...    Run Keyword And Ignore Error    Get Power State of CPE
    ${failedReason}    Run Keyword If    "${result[0]}" != "PASS"    Set Variable If    "${status[0]}" == "FAIL"
    ...    ${EMPTY}    ${failedReason}
    ...    ELSE    Set Variable    ${EMPTY}
    Should Be Empty    ${failedReason}    ${failedReason}
    Log To Console    Rebooting CPE: ${CPE_ID} - Checking every 10 secs for 240 seconds
    Sleep    10s
    Wait Until Keyword Succeeds    16 times    10 sec     Enable CPE Tools

Reboot CPE Perf    #USED
    [Documentation]    Keyword to Reboot the CPE using xap call. Used part of Xap Sanity
    ${result}    Run Keyword And Ignore Error    Reboot    ${LAB_CONF}    ${CPE_ID}
    #Sleep    5s
    log action    Reboot
    ${failedReason}    Set variable If    "${result[0]}" == "PASS"    ${EMPTY}    ${result[1]}
    ${status}    Run Keyword If    "${result[0]}" != "PASS"
    ...    Run Keyword And Ignore Error    Get Power State of CPE
    ${failedReason}    Run Keyword If    "${result[0]}" != "PASS"    Set Variable If    "${status[0]}" == "FAIL"
    ...    ${EMPTY}    ${failedReason}
    ...    ELSE    Set Variable    ${EMPTY}
    Should Be Empty    ${failedReason}    ${failedReason}
    Log To Console    Rebooting CPE: ${CPE_ID} - Checking every 10 secs for 240 seconds
    #Sleep    10s
    #Wait Until Keyword Succeeds    50 times    4 sec     Enable CPE Tools
    Wait Until Keyword Succeeds    300s   100ms    Box is bootup from standby
    log action    Reboot_Done
    Sleep    10s

Get Power State of CPE
    [Documentation]    Keyword to Get the Power State of thee Box using xap call. Used as part of Xap Sanity
    ${result}    Get Power State    ${LAB_CONF}    ${CPE_ID}
    ${failedReason}    Check XAP Call Response    ${result}    send_standby
    Should Be Empty    ${failedReason}    ${failedReason}
    Set Suite Variable    ${power_state}    ${result[2]["payload"]["currentState"]}

Send Standby Command
    [Documentation]    Keyword to Send the Standby command to the Box using xap call. Used as part of Xap Sanity
    ${result}    Send Standby    ${LAB_CONF}    ${CPE_ID}
    ${failedReason}    Check XAP Call Response    ${result}    send_standby
    Should Be Empty    ${failedReason}    ${failedReason}
    Log To Console    Send Standby: ${CPE_ID} - Sleep for 60 seconds
    Sleep    60

Enable CPE Tools    #USED
    [Documentation]    Keyword to Send the Standby command to the Box using xap call. Used as part of Xap Sanity
    ${enable_test_tools}    Enable_test_tools    ${LAB_CONF}    ${CPE_ID}
    Log    enable_test_tools: ${enable_test_tools}
    Log To Console   \nenable_test_tools: ${enable_test_tools}
    Log    enable_test_tools status_code: ${enable_test_tools[0]}
    Should Not Be Equal    "${enable_test_tools[0]}"    "None"    We can not reach XAP - trying Enable CPE Tools
    Log    enable_test_tools payload: ${enable_test_tools[2]["payload"]}
    ${failedReason}    Set Variable If    ${enable_test_tools[0]} != 200 or ${enable_test_tools[2]["payload"]} != None    XAP enable tests tools NOT working - Sanity FAILs
    Should Be Equal As Integers    ${enable_test_tools[0]}    200
    Should Be Equal    "${enable_test_tools[2]["payload"]}"    "None"

Check equal CPE version
    [Arguments]    ${cpe_version_orign}    ${cpe_version_need}
    [Documentation]    Keyword to Check both CPE Version are the same. Used as part of Xap Sanity
    ${failedReason}    Set Variable If    '${cpe_version_orign}'=='${cpe_version_need}'    ${EMPTY}    CPE Version: ${cpe_version_orign} is not equal as expected: ${cpe_version_need}
    Set Suite Variable    ${failedReason}    ${failedReason}
    Should Be Equal    ${cpe_version_orign}    ${cpe_version_need}

Get CPE build    #USED
    [Documentation]    Keyword to Get the CPE Version of the Box using xap call. Used as part of Xap Sanity
    ${result}    getConfigCPE    ${LAB_CONF}    ${CPE_ID}
    ${failedReason}    Check XAP Call Response    ${result}    getConfigCPE
    Should Be Empty    ${failedReason}    ${failedReason}
    ${data}    Set Variable    ${result[2]['payload']}
    Log    ${data}
    ${stb_model}    Get From Dictionary    ${data}    modelName
    ${stb_type}    Run Keyword If   ('${stb_model}'=='EOS-1008R') or ('${stb_model}'=='DX960-D')    Set Variable    HDD
    ...    ELSE    Set Variable    HDD-LESS
    ${ACTUAL_CPE_BUILD}    Set Variable    ${data['firmwareVersion']}
    @{Split_items}    Split String    ${ACTUAL_CPE_BUILD}    -
    Set Suite Variable    ${ACTUAL_CPE_VERSION}    ${Split_items[4]}-${Split_items[5]}
    ${ACTUAL_APP_VERSION}    Set Variable    ${data['appVersion']}
    @{Split_items}    Split String    ${ACTUAL_APP_VERSION}    _
    Set Suite Variable    ${ACTUAL_APP_VERSION}    R${Split_items[0]}
    Log To Console    Current APP VERSION: ${ACTUAL_APP_VERSION}
    Log To Console    Current CPE VERSION: ${ACTUAL_CPE_VERSION}
    Log To Console    Current CPE BUILD: ${ACTUAL_CPE_BUILD}
    Log To Console    Current STB Model : ${stb_model}
    Set Suite Variable    ${CPE_VERSION}    ${ACTUAL_CPE_VERSION}    children=${True}
    Set Suite Variable    ${ACTUAL_CPE_BUILD}    ${ACTUAL_CPE_BUILD}
    Set Suite Variable    ${STB_MODEL}    ${stb_model}
    Set Suite Variable    ${STB_TYPE}    ${stb_type}
    Set Suite Variable    ${COUNTRY}    ${data['country']}

Set CPE Resolution
    [Documentation]    Keyword to Set Current CPE resolution
    ${RESOLUTION}    Get hdmi resolution    ${LAB_CONF}    ${CPE_ID}
    Log    ${RESOLUTION}
    ${SCREEN_WIDTH}    Set Variable If    "${RESOLUTION}"=="720p"    1280    1920
    ${SCREEN_HEIGHT}    Set Variable If    "${RESOLUTION}"=="720p"    720    1080
    Set Global Variable    ${SCREEN_WIDTH}
    Set Global Variable    ${SCREEN_HEIGHT}

Xap Sanity And Setup
    [Documentation]    Keyword to Execute Sanity Steps to make sure CPE is accessible through Xap and ready for the test.
    ${CPE_FW_VERSION}    Get Environment Variable    CPE_FW_VERSION    ${E2E_CONF["${LAB_NAME}"]["CPE_FW_VERSION"]}    # This variable is expected to be defined in Jenkins
    Set Suite Variable    ${CPE_FW_VERSION}    ${CPE_FW_VERSION}    children=${True}
    Log    ${CPE_FW_VERSION}
    Enable CPE Tools
    Run Keyword And Ignore Error    Reboot CPE
    Enable CPE Tools
    Get Power State of CPE
    Run Keyword If    '${power_state}'!='Operational'    Send Standby Command
    Run Keyword If    '${power_state}'!='Operational'    Get Power State of CPE
    Should Be Equal    ${power_state}    Operational
    ${fti_completed}    run keyword and return status    Try to verify that FTI state is completed
    Should Be True    ${fti_completed}    FTI state is not completed
    Get CPE build
    Set CPE Resolution

Xap Sanity And Setup Not Reboot
    [Documentation]    Keyword to Execute Sanity Steps to make sure CPE is accessible through Xap and ready for the test.
    ${CPE_FW_VERSION}    Get Environment Variable    CPE_FW_VERSION    ${E2E_CONF["${LAB_NAME}"]["CPE_FW_VERSION"]}    # This variable is expected to be defined in Jenkins
    Set Suite Variable    ${CPE_FW_VERSION}    ${CPE_FW_VERSION}    children=${True}
    Log    ${CPE_FW_VERSION}
    Enable CPE Tools
    Get Power State of CPE
    Run Keyword If    '${power_state}'!='Operational'    Send Standby Command
    Run Keyword If    '${power_state}'!='Operational'    Get Power State of CPE
    Should Be Equal    ${power_state}    Operational
    ${fti_completed}    run keyword and return status    Try to verify that FTI state is completed
    Should Be True    ${fti_completed}    FTI state is not completed
    Get CPE build
    Set CPE Resolution

Get Current Profile Id    #USED
    [Documentation]    This keyword fetched current profile Id for the CPE
    ${response}    Get Current Profile    ${LAB_CONF}    ${CPE_ID}
    ${profile_id}    Set Variable    ${response[2]['payload']['id']}
    ${failedReason}    Set Variable If    '${profile_id}'    ${EMPTY}    Unable to retreive profile Id for ${CPE_ID}
    should be empty    ${failedReason}    ${failedReason}
    [Return]    ${profile_id}

Get Osd Language    #USED
    [Documentation]    This keyword returns the current language of the CPE
    ${response}    Osd Lang    ${LAB_CONF}    ${CPE_ID}
    ${osd_lang}    Set Variable    ${response[2]['payload']}
    ${failedReason}    Set Variable If    '${osd_lang}'    ${EMPTY}    Unable to retreive language for ${CPE_ID}
    should be empty    ${failedReason}    ${failedReason}
    [Return]    ${osd_lang}

I Check Power State Of CPE
    [Documentation]
    Should Be Equal    ${power_state}    Operational

Check If Build Is '${RegExp}'    #USED
    [Documentation]    This keyword checks is ${RegExp} is present in build
    ${CPE_Build_Exists}    Run Keyword And Ignore Error    Variable Should Exist    ${ACTUAL_CPE_BUILD}
    Run Keyword If    '${CPE_Build_Exists[0]}' != 'PASS'    Get CPE build
    ${CPE_BUILD_SPLITS}    Split String    ${ACTUAL_CPE_BUILD}    -
    Should Not be Empty    ${CPE_BUILD_SPLITS}    'Build could not be captured'
    ${IS_PRD_BUILD}    Get Regexp Matches    ${ACTUAL_CPE_BUILD}    (?i)${RegExp}
    ${IS_PRD_BUILD}    Set Variable If    ${IS_PRD_BUILD}    ${True}    ${False}
    [Return]    ${IS_PRD_BUILD}

Check Screenshot Can Be Captured Via XAP    #USED
    [Documentation]    This Keyword checks if screen shots can be captured via XAP(if build is not PRD)
    ${IS_PRD_BUILD}    Check If Build Is 'PRD'
    Run Keyword If    ${IS_PRD_BUILD}    Fail    'Screenshot cannot be captured via XAP as build is PRD'
    Set Suite Variable    ${TEMP_OUTPUT_FOLDER}    ${TEMPDIR}/${TEST_NAME}
    Create Directory    ${TEMP_OUTPUT_FOLDER}
    ${current_screenshot}    Run Keyword If    ${IS_PRD_BUILD} == ${False}    Get screenshot via xap    ${STB_IP}    ${CPE_ID}    ${TEMP_OUTPUT_FOLDER}    xap=${XAP}
    Run Keyword If    ${IS_PRD_BUILD} == ${False}    Should Be True    '${current_screenshot}' != ${Null}    'Screenshot could not be captured via XAP'
    Remove Directory    ${TEMP_OUTPUT_FOLDER}    recursive=true
    [Return]    'Screenshot captured via XAP'

Check XAP Screenshot Is Not A Black Screen    #USED
    [Documentation]    This keyword checks whether the screenshot available in XAP is not a black screen
    ${IS_PRD_BUILD}    Check If Build Is 'PRD'
    Run Keyword If    ${IS_PRD_BUILD}    Fail    'Screenshot cannot be captured via XAP as build is PRD'
    Set Suite Variable    ${TEMP_OUTPUT_FOLDER}    ${TEMPDIR}/${TEST_NAME}
    Create Directory    ${TEMP_OUTPUT_FOLDER}
    ${current_screenshot}    Run Keyword If    ${IS_PRD_BUILD} == ${False}    Get screenshot via xap    ${STB_IP}    ${CPE_ID}    ${TEMP_OUTPUT_FOLDER}    xap=${XAP}
    Run Keyword If    ${IS_PRD_BUILD} == ${False}    Should Be True    '${current_screenshot}' != ${Null}    'Screenshot could not be captured via XAP'
    ${is_black_screenshot}    Black Image Detection    ${TEMP_OUTPUT_FOLDER}/${current_screenshot}
    Remove Directory    ${TEMP_OUTPUT_FOLDER}    recursive=true
    Run Keyword If    not ${is_black_screenshot}    Log    'XAP screenshot is OK'    WARN
    ...    ELSE    Run Keywords    Log    'XAP screenshot is a black screen'    WARN    AND    FAIL    'XAP screenshot is a black screen'

#######################CPE PERFORMANCE######################
Check if box is connected
    [Documentation]    Keyword to Send the Standby command to the Box using xap call to check if box connected
    ${status}    run keyword and return status    Get Current Profile Id
    Should Be True    ${status}  "Box is disconnected"

Box is bootup from standby
    [Documentation]   This keyword verifies if the box is boot up from standby and live tv or any pop up message is shown
    ${json_object}    Get Ui Json
    ${live_tv_header_shown}    Is In Json    ${json_object}    ${EMPTY}    textKey:DIC_HEADER_SOURCE_LIVE
    run keyword if  ${live_tv_header_shown}     return from keyword
    ${fullscreen_view}    Is In Json    ${json_object}    ${EMPTY}    id:FullScreen.View
    run keyword if  ${fullscreen_view}     return from keyword
    ${connection_error_status}    Is In Json    ${json_object}    ${EMPTY}    id:Widget.ModalPopup
    run keyword if  ${connection_error_status}     return from keyword
    ${InteractiveModal_status}    Is In Json    ${json_object}    ${EMPTY}    id:InteractiveModalPopup
    run keyword if  ${InteractiveModal_status}     return from keyword
    ${pin_pop_up_status}    Is In Json    ${json_object}    ${EMPTY}    id:pinEntryModalPopupTitle
    run keyword if  ${pin_pop_up_status}     return from keyword
    ${setting_modal_status}    Is In Json    ${json_object}    ${EMPTY}    textKey:DIC_COLD_STARTUP_CONSOLIDATED_MODE
    run keyword if  ${setting_modal_status}     return from keyword
    should be true  ${fullscreen_view} or ${setting_modal_status} or ${pin_pop_up_status} or ${live_tv_header_shown} or ${connection_error_status} or ${InteractiveModal_status}    'Box is not on from stand by'

After Box is bootup from standby
    [Documentation]   This keyword verifies after the box is boot up from standby any pop up message is shown and performs actions
    ${json_object}    Get Ui Json
    ${connection_error_status}    Is In Json    ${json_object}    ${EMPTY}    textKey:DIC_ERROR_9003_MESSAGE
    run keyword if    ${connection_error_status}    I press    OK
    run keyword if    ${connection_error_status}    I enter a valid pin
    ${pin_pop_up_status}    Is In Json    ${json_object}    ${EMPTY}    id:pinEntryModalPopupTitle
    run keyword if    ${pin_pop_up_status}    I enter a valid pin
    run keyword if  ${pin_pop_up_status}     return from keyword
    ${setting_modal_status}    Is In Json    ${json_object}    ${EMPTY}    textKey:DIC_COLD_STARTUP_CONSOLIDATED_MODE
    run keyword if    ${setting_modal_status}    I press    DOWN
    run keyword if    ${setting_modal_status}    I press    OK

Box is connected and up after reboot
    [Documentation]   This keyword verifies if the box is up and running after reboot and live tv or any pop up message is shown
    ${status}    run keyword and return status    Get Current Profile Id
    Should Be True    ${status}  "Box is disconnected"
    ${json_object}    Get Ui Json
    ${live_tv_header_shown}    Is In Json    ${json_object}    ${EMPTY}    textKey:DIC_HEADER_SOURCE_LIVE
    run keyword if  ${live_tv_header_shown}     return from keyword
    ${fullscreen_view}    Is In Json    ${json_object}    ${EMPTY}    id:FullScreen.View
    run keyword if  ${fullscreen_view}     return from keyword
    ${connection_error_status}    Is In Json    ${json_object}    ${EMPTY}    id:Widget.ModalPopup
    run keyword if  ${connection_error_status}     return from keyword
    ${InteractiveModal_status}    Is In Json    ${json_object}    ${EMPTY}    id:InteractiveModalPopup
    run keyword if  ${InteractiveModal_status}     return from keyword
    ${pin_pop_up_status}    Is In Json    ${json_object}    ${EMPTY}    id:pinEntryModalPopupTitle
    run keyword if  ${pin_pop_up_status}     return from keyword
    ${setting_modal_status}    Is In Json    ${json_object}    ${EMPTY}    textKey:DIC_COLD_STARTUP_CONSOLIDATED_MODE
    run keyword if  ${setting_modal_status}     return from keyword
    should be true  ${fullscreen_view} or ${setting_modal_status} or ${pin_pop_up_status} or ${live_tv_header_shown} or ${connection_error_status} or ${InteractiveModal_status}    'Box is not on from stand by'