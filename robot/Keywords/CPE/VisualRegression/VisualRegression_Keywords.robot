*** Settings ***
Documentation     Keywords for visual regression testing
Resource          ../Common/Common.robot
Library           OperatingSystem

*** Keywords ***
Settings screen is shown [VReg]
    [Documentation]    Keyword checks if Preferences view is properly displayed [Visual Regression]
    Compare images    ${EXECDIR}/Utils/visual_regression/baseline/Settings.png    --block-out 500,30,1400,100

Diagnostics screen is shown [VReg]
    [Documentation]    Keyword checks if Diagnostics view is properly displayed [Visual Regression]
    Compare images    ${EXECDIR}/Utils/visual_regression/baseline/Diagnostics.png    --block-out 500,30,1400,100 --block-out 200,700,1000,60 --block-out 200,825,1000,60

Compare images
    [Arguments]    ${base_screenshot}    ${block_out_areas}
    [Documentation]    Keyword gets screenshot of current ui state and compares with baseline
    ...    blocked out areas are not analyzed during comparison
    Set Suite Variable    ${VREG_OUTPUT_FOLDER}    ${TEMPDIR}/${TEST_NAME}
    Create Directory    ${VREG_OUTPUT_FOLDER}
    ${current_screenshot}    Get screenshot via xap    ${STB_IP}    ${CPE_ID}    ${VREG_OUTPUT_FOLDER}    xap=$[XAP}
    Set Suite Variable    ${DIFF_SCREENSHOT}    DIFF_${current_screenshot}
    ${return_code}    Run And Return Rc    node ${EXECDIR}/node_modules/blink-diff/bin/blink-diff --output ${VREG_OUTPUT_FOLDER}/${DIFF_SCREENSHOT} ${base_screenshot} ${VREG_OUTPUT_FOLDER}/${current_screenshot} ${block_out_areas} --compose-ltr
    Run Keyword If    ${return_code} > 1    Fail    'Unexpected error in blink-diff'
    Should Be Equal    '${return_code}'    '0'    'Images are different!'

Screenshot has the given background color
    [Arguments]    ${color}    ${region}
    [Documentation]    This keyword verifies if the given region of the screen contains the given background color
    I query screenshot from stb via Obelix
    ${status}    check screen area has specific colour    ${LAST_SCREENSHOT_PATH}    ${color}    ${region}
    should be true    ${status}    The screen area is not having the same background color

Visual Regression Suite Teardown
    [Documentation]    Teardown for Visual Regression Tests
    Remove Directory    ${VREG_OUTPUT_FOLDER}    True
    Default Suite Teardown
