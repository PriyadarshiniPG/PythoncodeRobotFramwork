*** Settings ***
Library           Collections
Library           String
Library           DateTime
Library           OperatingSystem
Library           Libraries.Obelix


*** Keywords ***
Obelix Specific Suite Setup
    [Documentation]    This keyword connects slot before test suite execution starts.
    Basic Suite Setup
    Set textKey identifiers     #TO FIX THE MAIN MENU textKey VALUES
    Allocate STB

Connect To Obelix    #USED
    [Documentation]    This keyword connects slot before test suite execution starts.
    Log    connecting to Obelix
    ${status}    Connect    ${RACK_PC_IP}    ${STB_SLOT}    Automation    E2EROBOT
    ${failedReason}    Set Variable If    ${status}==True    ${EMPTY}    Obelix already connected to some user
    Should Be Empty    ${failedReason}

Disconnect From Obelix    #USED
    [Documentation]    This keyword disconnects slot after test suite execution ends.
    Log    disconnecting from Obelix
    ${status}    Disconnect    ${RACK_PC_IP}    ${STB_SLOT}    Automation
    ${failedReason}    Set Variable If    ${status}==True    ${EMPTY}    Releasing Obelix failed
    Should Be Empty    ${failedReason}

Press    #USED
    [Arguments]    ${button}
    [Documentation]    This keyword presses the given(argument) button.
    ${press_value}    pass command    ${RACK_PC_IP}    ${STB_SLOT}    ${button}
    sleep    2
    ${failedReason}    Set Variable If    ${press_value}==True    ${EMPTY}    Press button not working
    Should Be Empty    ${failedReason}

Press n times
    [Arguments]    ${button}    ${times}
    [Documentation]    This press a key n times
    : FOR    ${INDEX}    IN RANGE    0    ${times}
    \    Press    ${button}
    \    Log    ${button}

I Press Power Button And Wait For '${seconds}'    #USED
    Press    power button
    Sleep    ${seconds}

Take Screenshot Via Obelix    #USED
    [Arguments]    ${IP}=${RACK_PC_IP}    ${SLOT}=${STB_SLOT}    ${DIR_PATH}=${TEMPDIR}/${TEST_NAME}/    ${SCREEN_NAME}=Screenshot_${TEST_NAME}_${STB_SLOT}.png
    [Documentation]    This Keyword captures a screenshot via obelix. Saves the path of the taken screenshot in suite variable LAST_SCREENSHOT_PATH.
    Take Screenshot    ${IP}    ${SLOT}    ${DIR_PATH}/${SCREEN_NAME}
    ${screenshot_status}    Run Keyword And Ignore Error    OperatingSystem.File Should Exist    ${DIR_PATH}/${SCREEN_NAME}
    Run Keyword If    "${screenshot_status[0]}" == "FAIL"    Fail    'Screenshot could not be captured via OBELIX'
    Set Suite Variable    ${LAST_SCREENSHOT_PATH}    "${DIR_PATH}/${SCREEN_NAME}"

Check Screenshot Can Be Captured Via Obelix    #USED
    [Documentation]    This Keyword checks if screen shots can be captured via Obelix(is OBELIX_SUPPORT is TRUE)
    Run Keyword If    not ${OBELIX}    Fail    'Box setup does not have Obelix support'
    Set Suite Variable    ${TEMP_OUTPUT_FOLDER}    ${TEMPDIR}/${TEST_NAME}
    Create Directory    ${TEMP_OUTPUT_FOLDER}
    Take Screenshot Via Obelix    ${RACK_PC_IP}    ${STB_SLOT}    ${TEMP_OUTPUT_FOLDER}    Test_Screenshot.jpg
    Remove Directory    ${TEMP_OUTPUT_FOLDER}    recursive=true
    Run Keyword If    ${LAST_SCREENSHOT_PATH} != "${TEMP_OUTPUT_FOLDER}/Test_Screenshot.jpg"    FAIL    "Screenshot could not captured via OBELIX"

Check OBELIX Screenshot Is Not A Black Screen    #USED
    [Documentation]    This keyword checks whether the screenshot available in OBELIX is not a black screen
    Run Keyword If    not ${OBELIX}    Fail    'Box setup does not have Obelix support'
    Set Suite Variable    ${TEMP_OUTPUT_FOLDER}    ${TEMPDIR}/${TEST_NAME}
    Create Directory    ${TEMP_OUTPUT_FOLDER}
    Take Screenshot Via Obelix    ${RACK_PC_IP}    ${STB_SLOT}    ${TEMP_OUTPUT_FOLDER}    Test_Screenshot.jpg
    Run Keyword If    ${LAST_SCREENSHOT_PATH} != "${TEMP_OUTPUT_FOLDER}/Test_Screenshot.jpg"    FAIL    "OBELIX screenshot could not be captured"
    ${is_black_screenshot}    Black Image Detection    ${TEMP_OUTPUT_FOLDER}/Test_Screenshot.jpg
    Remove Directory    ${TEMP_OUTPUT_FOLDER}    recursive=true
    Run Keyword If    not ${is_black_screenshot}    Log    'OBELIX screenshot is OK'    WARN
    ...    ELSE    Run Keywords    Log    'OBELIX screenshot is a black screen'    WARN