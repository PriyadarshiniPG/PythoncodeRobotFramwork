*** Keywords ***
Set Suite Variables
    ${lab_name}    Get Lab Name From Jenkins    LAB_NAME    labe2esi
    Set Suite Variable    ${lab_name}    ${lab_name}    children=true
    Set Suite Variable    ${failedReason}    ${None}    children=true
    Set Suite Variable    ${firstTestCaseFail}    ${EMPTY}    children=true

Get LIVE Streaming Deatails
    [Arguments]    ${lab}    ${conf}
    ${streams_details}    Get Channels Streaming Details    ${lab}    ${conf}    ${conf["${lab}"]["OESP"]["country"]}    ${conf["${lab}"]["OESP"]["language"]}    ${conf["${lab}"]["OESP"]["device"]}
    Set Suite Variable    ${streams_details}    ${streams_details}
    ${no_errors_found}    Evaluate    "error" not in ${streams_details[0].keys()}
    ${failedReason}    Set Variable If    ${no_errors_found}    ${EMPTY}    ${streams_details[0]["error"]}
    Should Be True    ${no_errors_found}
    ${failedReason}    Set Variable If    ${streams_details}    ${EMPTY}    No Streaming URLs for any type (protocol) of Manifests were found
    Log List    ${streams_details}
    Should Not Be Empty    ${streams_details}
    [Teardown]    Set Suite Variable    ${failedReason}    ${failedReason}
    [Return]    ${streams_details}

Get VOD Streaming Deatails
    [Arguments]    ${lab}    ${conf}    ${search}
    ${streams_details}    Get VODSearch Streaming Details    ${lab}    ${conf}    ${search}    ${conf["${lab}"]["OESP"]["country"]}    ${conf["${lab}"]["OESP"]["language"]}
    ...    ${conf["${lab}"]["OESP"]["device"]}
    Log List    ${streams_details}
    Set Suite Variable    ${streams_details}    ${streams_details}
    ${count}    Get Length    ${streams_details}
    ${failedReason}    Set Variable If    ${count} > 0    ${EMPTY}    No Streaming URLs for any type (protocol) of Manifests were found
    Should Not Be Empty    ${streams_details}
    ${no_errors_found}    Evaluate    "error" not in ${streams_details[0].keys()}
    ${failedReason}    Set Variable If    ${no_errors_found}    ${EMPTY}    ${streams_details[0]["error"]}
    Should Be True    ${no_errors_found}
    [Teardown]    Set Suite Variable    ${failedReason}    ${failedReason}
    [Return]    ${streams_details}

Filter Streams URLs
    [Arguments]    ${streams_details}    ${get_dash}    ${get_hss}    ${get_hls}    # get_xxx variables need boolean values (${True} or ${False})
    ${manifests_urls}    Collect Streaming URLs    ${streams_details}    ${get_dash}    ${get_hss}    ${get_hls}
    Set Suite Variable    ${manifests_urls}    ${manifests_urls}
    ${failedReason}    Set Variable If    ${manifests_urls}    ${EMPTY}    No URLs for desired type (protocol) of Manifests were found
    Log List    ${manifests_urls}
    Should Not Be Empty    ${manifests_urls}    ${failedReason}
    [Teardown]    Set Suite Variable    ${failedReason}    ${failedReason}
    [Return]    ${manifests_urls}

Play URLs on OTT Devices
    [Arguments]    ${urls}    ${protocol}=${None}    ${tries}=1    ${interval}=0.2    ${verbosity}=1
    ${errors_msg}    Set Variable    ${EMPTY}
    : FOR    ${url}    IN    @{urls}
    \    ${result}    OTT.Play    ${url}    ${protocol}    ${tries}    ${interval}
    \    ...    ${verbosity}
    \    Log Dictionary    ${result.__dict__}
    \    Run Keyword And Continue On Failure    Should Be True    ${result.played_ok}    Failed to play Manifest: ${url} .\nManifest content is:\n${result.manifest_str}
    \    ${errors_msg}    Run Keyword If    not ${result.played_ok}    Catenate    SEPARATOR=\n    ${errors_msg}
    \    ...    Failed to play Manifest: ${url} .\n    #Failed to play Manifest: ${url} .\nManifest content is:\n${result.manifest_str}\n
    ${failedReason}    Set Variable If    "${failedReason}" == "${None}"    ${errors_msg}    ${failedReason}\n${errors_msg}
    Should Be Empty    ${errors_msg}    ${errors_msg}
    [Teardown]    Set Suite Variable    ${failedReason}    ${failedReason}
    [Return]    ${failedReason}

Play URLs on OTT Devices Concurrently
    [Arguments]    ${urls}    ${protocol}=${None}    ${tries}=1    ${interval}=0.2    ${verbosity}=1
    ${failedReason}    Play Manifests Concurrently    ${urls}    ${protocol}    ${tries}    ${interval}    ${verbosity}
    Log    ${failedReason}
    Should Be Empty    ${failedReason}    ${failedReason}
    [Teardown]    Set Suite Variable    ${failedReason}    ${failedReason}
    [Return]    ${failedReason}
