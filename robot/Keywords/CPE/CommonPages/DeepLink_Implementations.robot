*** Settings ***
Documentation     UI DeepLink Navigation Keywords
Resource          ../Common/Common.robot

*** Keywords ***
Open View through DeepLink
    [Arguments]    ${path}    ${params}={}
    [Documentation]    Sends a Deeplink request to the UI via WebSocket with a path and optional parameters
    navigate to view via deeplink    ${STB_IP}    ${CPE_ID}    ${path}    ${params}    ${XAP}
    I wait for ${UI_LOAD_DELAY} ms

Open Recording Details Page through DeepLink
    [Arguments]    ${recording_id}
    [Documentation]    Opens a Recording Details Page via DeepLink using a valid crid
    Open View through DeepLink    /Vod/DP/saved    {"crid": "${recording_id}"}
