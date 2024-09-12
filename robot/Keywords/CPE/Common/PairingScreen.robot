*** Settings ***
Documentation     Pairing screen related keywords

*** Keywords ***
Disable Pairing Device popup by spoofing paired device status
    [Documentation]    This keyword spoofs paired device status for pairing devices, so the popup is not shown
    wait until keyword succeeds    10times    2 sec    set dummy paired status to paired devices    ${STB_IP}    ${CPE_ID}    ${True}
    ...    xap=${XAP}

Wait until Pairing Device popup tips screens are displayed
    [Arguments]    ${duration}
    [Documentation]    This keyword waits until either of Pairing Device popup or tips screens are displayed. If there were already
    ...    presented and handled, then no need to return failure
    wait until keyword succeeds    ${duration}    0s    Exit both Pairing request tips screens

Exit either of Pairing request tips screens
    [Documentation]    This keyword checks if remote pairing tips or request screen is shown and attempts to exit it by pressing BACK key. If there were already
    ...    presented and handled, then no need to return failure
    return from keyword if    ${CHECK_FOR_REMOTE_PAIRING_TIPS_SCREEN}==${False} and ${CHECK_FOR_REMOTE_PAIRING_REQ_POPUP}==${False}
    ${is_pair_request_shown}    run keyword if    ${CHECK_FOR_REMOTE_PAIRING_REQ_POPUP}    Is remote pairing request popup displayed
    run keyword if    ${CHECK_FOR_REMOTE_PAIRING_REQ_POPUP} and ${is_pair_request_shown}    wait until keyword succeeds    10times    0s    Press back key to verify remote pairing request popup is exited
    ${is_pair_tips_shown}    run keyword if    ${CHECK_FOR_REMOTE_PAIRING_TIPS_SCREEN}    Is remote pairing tips screen displayed
    run keyword if    ${CHECK_FOR_REMOTE_PAIRING_TIPS_SCREEN} and ${is_pair_tips_shown}    wait until keyword succeeds    10times    0s    Press ok key to verify remote pairing tips screen is exited

Make sure that either of Pairing request tips screens exited
    [Documentation]    This keyword checks if remote pairing tips or request screen is shown and attempts to exit it by pressing BACK key. If there were already
    ...    presented and handled, then no need to return failure
    ${is_pair_request_shown}    Is remote pairing request popup displayed
    run keyword if    ${is_pair_request_shown}    wait until keyword succeeds    10times    0s    Make sure that remote pairing request popup is exited
    ${is_pair_tips_shown}    Is remote pairing tips screen displayed
    run keyword if    ${is_pair_tips_shown}    wait until keyword succeeds    10times    0s    Make sure that tips screen is exited

Exit both Pairing request tips screens
    [Documentation]    This keyword checks if remote pairing tips or request screen is shown and attempts to exit it by pressing BACK key. If there were already
    ...    presented and handled, then no need to return failure
    Exit either of Pairing request tips screens
    ${handled_details}    set variable    Remote pairing popup handled: ${CHECK_FOR_REMOTE_PAIRING_REQ_POPUP}, Remote pairing tips screen handled: ${CHECK_FOR_REMOTE_PAIRING_TIPS_SCREEN}
    should be true    ${CHECK_FOR_REMOTE_PAIRING_TIPS_SCREEN}==${False} and ${CHECK_FOR_REMOTE_PAIRING_REQ_POPUP}==${False}    ${handled_details}

Press back key to verify remote pairing request popup is exited
    [Documentation]    This keyword presses BACK key and checks if remote pairing request popup is exited or not
    send key via as    ${STB_IP}    ${CPE_ID}    BACK    xap=${XAP}
    wait until keyword succeeds    3times    0s    check if remote pairing request popup is exited
    Log    Applied ONEMT-22056 to exit Pairing device popup    WARN
    Set Suite Variable    ${CHECK_FOR_REMOTE_PAIRING_REQ_POPUP}    ${False}

Make Sure That Remote Pairing Request Popup Is Exited    #USED
    [Documentation]    This keyword checks for the remote pairing popup and Dismisses it
    ${result}    Run Keyword And Return Status    I expect page element 'id:ToastPopup' contains 'textKey:DIC_GENERIC_BTN_DISMISS' using regular expressions
    Run Keyword If    ${result}    Move to element assert focused elements    textKey:DIC_GENERIC_BTN_DISMISS    3    RIGHT
    Run Keyword If    ${result}    Run Keywords    I Press    OK    AND    Sleep    2s
    Wait Until Keyword Succeeds    5times    1s    I do not expect page element 'id:ToastPopup' contains 'textKey:DIC_GENERIC_BTN_DISMISS' using regular expressions

Press ok key to verify remote pairing tips screen is exited
    [Documentation]    This keyword presses Ok key and checks if remote pairing tips screen is exited or not
    send key via as    ${STB_IP}    ${CPE_ID}    OK    xap=${XAP}
    wait until keyword succeeds    3times    0s    check if remote pairing tips screen is exited
    Log    Applied ONEMT-22056 to skip Pairing tips screen    WARN
    Set Suite Variable    ${CHECK_FOR_REMOTE_PAIRING_TIPS_SCREEN}    ${False}

Make sure that tips screen is exited
    [Documentation]    This keyword presses Ok key and checks if remote pairing tips screen is exited or not
    send key via as    ${STB_IP}    ${CPE_ID}    OK    xap=${XAP}
    wait until keyword succeeds    3times    0s    check if remote pairing tips screen is exited

check if remote pairing request popup is exited
    [Documentation]    This keyword checks if the remote pairing request popup is exited
    ${is_pair_request_shown}    Is remote pairing request popup displayed
    should not be true    ${is_pair_request_shown}    Remote pairing request popup is still shown

check if remote pairing tips screen is exited
    [Documentation]    This keyword checks if the remote pairing tips screen is exited
    ${is_pair_tips_shown}    Is remote pairing tips screen displayed
    should not be true    ${is_pair_tips_shown}    Remote pairing tips screen is still shown

Set all the tips as already shown in the past via as    #USED
    [Documentation]    Set all tips as already shown in the past so they won't popup in standard user scenario
    ${ids}    Set Variable    "MENU_GO_TO_TOP","FLO_SELECTION","EPG_DAY_SKIP","ANOW_MOMENT","BACK_TO_TV","PLAY_IMMEDIATELY","TV_PAIRING","PULL_VOICE"
    ${timestamps}    Set Variable    0,0,0,0,0,0,0,0
    ${body}    Set Variable    {"ids":[${ids}],"timestamps":[${timestamps}]}
    Set application services setting as JSON    profile.tipsAndTricks    ${body}

Disable tips and tricks    #USED
    [Documentation]    This keyword enables(if disabled) test tools, then disables tips and tricks during suite setup.
    ${are_test_tools_enabled}    get application service setting    cpe.uiTestTools
    Run Keyword If    '${are_test_tools_enabled}' == '${FALSE}'    Change JSON Setting via Application Services    ${TRUE}
    Wait until keyword succeeds    10s    500ms    Set TipsAndTricks Ui Config to false
    Run Keyword If    '${are_test_tools_enabled}' != '${JSON}'    Change JSON Setting via Application Services    ${JSON}
