*** Keywords ***
Get VOD Asset From Fabrix
    [Documentation]    Gets a short VOD asset ID from Fabfix and sets it in ${vod_asset_id} suite variable
    ${min_duration_seconds}    Set Variable    10
    ${max_duration_seconds}    Set Variable    60
    ${vod_assets}    Get Assets    ${LAB_CONF["FABRIX"]["host"]}    ${LAB_CONF["FABRIX"]["port"]}    ${min_duration_seconds}    ${max_duration_seconds}
    Set Suite Variable    ${failedReason}    ${EMPTY}
    Run Keyword If    ${vod_assets.__len__()} == 0    Set Suite Variable    ${failedReason}    No VOD assets found with ${min_duration_seconds} <= duration <= ${max_duration_seconds} seconds
    Should Not Be Empty    ${vod_assets}
    Set Suite Variable    ${vod_asset_id}    ${vod_assets[1]}

Get Customer ID From Traxis
    [Documentation]    Gets a customer ID from Traxis and sets it in ${customer_id} suite variable
    ${customer_id}    Get Traxis Profiles Customer Id    ${LAB_CONF}    ${LAB_CONF["CPE_ID"]}
    Log    CustomerID: ${customer_id}
    Set Suite Variable    ${failedReason}    ${EMPTY}
    Run Keyword If    '${customer_id}' == '${EMPTY}' or '${customer_id}' == '${None}'    Set Suite Variable    ${failedReason}    Error to get customer from Traxis
    Should Be True    len('${customer_id}') > 5    ${failedReason}
    Set Suite Variable    ${customer_id}    ${customer_id.split("_")[0]}

Get Index From EPG
    [Documentation]    Gets index data from EPG and sets ${epg_index} suite variable
    ${http_response}    Get EPG Index    ${LAB_CONF}    ${COUNTRY}    ${LANGUAGE}
    Run Keyword If    ${http_response.status_code} != 200    Set Suite Variable    ${failedReason}    Error to get EPG index: ${http_response.status_code} ${http_response.reason}
    Should Be Equal As Integers    ${http_response.status_code}    200
    ${epg_index}    Set Variable    ${http_response.json()}
    Log    ${epg_index}
    Run Keyword If    len(${epg_index})==0    Set Suite Variable    ${failedReason}    Error to get EPG index: response body is empty
    Should Not Be Empty    ${epg_index}
    Set Suite Variable    ${epg_index}    ${epg_index}

Get Segment From EPG
    [Documentation]    Gets segment data from EPG and sets ${epg_segment} suite variable
    ${http_response}    Get EPG Segment    ${LAB_CONF}    ${COUNTRY}    ${LANGUAGE}    ${segment_hash}
    Run Keyword If    ${http_response.status_code} != 200    Set Suite Variable    ${failedReason}    Error to get EPG segment ${segment_hash}: ${http_response.status_code} ${http_response.reason}
    Should Be Equal As Integers    ${http_response.status_code}    200
    ${epg_segment}    Set Variable    ${http_response.json()}
    Run Keyword If    len(${epg_segment}) == 0    Set Suite Variable    ${failedReason}    Error to get EPG segment ${segment_hash}: response body is empty
    Log    ${epg_segment}
    Should Not Be Empty    ${epg_segment}
    Set Suite Variable    ${epg_segment}    ${epg_segment}

Validate Manifest CDN Playout
    [Arguments]    ${web_obj}
    [Documentation]    Reads robot/resources/stages/cdn/${LAB_NAME}_cdn_${web_obj}.txt file and uses ${manifest_url} suite variable
    ${content}    OperatingSystem.Get File    ${CURDIR}${/}..${/}resources/stages/cdn/${LAB_NAME}_cdn_${web_obj}.txt
    ${lines}    Split To Lines    ${content}
    : FOR    ${line}    IN    @{lines}
    \    ${manifest}    Evaluate    "/".join(${manifest_url.split("/")[3:]})
    \    ${url}    Set Variable    http://${line}/${manifest}
    \    ${result}    Play    ${url}
    \    Log    ${result.manifest_str}
    \    Run Keyword And Continue On Failure    Should Not Be Empty    ${result.manifest_str}    ${failedReason} Could not READ manifest ${url}.
    \    ${failedReason}    Set Variable If    """${result.manifest_str}""" == ""    ${failedReason} Could not READ manifest ${url}.    ${failedReason}
    \    Log    ${result.played_ok}
    \    Run Keyword And Continue On Failure    Should Be True    ${result.played_ok}    ${failedReason} Could not PLAY manifest ${url}.
    \    ${failedReason}    Set Variable If    ${result.played_ok}    ${failedReason}    ${failedReason} Could not PLAY manifest ${url}.
    Set Suite Variable    ${failedReason}    ${failedReason}

Validate Manifest CDN Playout Concurrently
    [Arguments]    ${web_obj}    ${limit}=3    ${timeout}=1200    # limit number of CDN endpoints and timeout in seconds for one manifest
    [Documentation]    Reads robot/resources/stages/cdn/${LAB_NAME}_cdn_${web_obj}.txt file and uses ${manifest_url} suite variable.
    ...
    ...    Python3 executable should be specified in robot command:
    ...
    ...    --variable python3:python
    ${content}    OperatingSystem.Get File    ${CURDIR}${/}..${/}resources/stages/cdn/${LAB_NAME}_cdn_${web_obj}.txt
    ${lines}    Split To Lines    ${content}
    ${lines}    Evaluate    sorted(${lines}, key=lambda x: random.random())    random
    ${platform}    Evaluate    sys.platform    sys
    ${failed_manifests}    Create List
    : FOR    ${line}    IN    @{lines[:${limit}]}
    \    ${manifest}    Evaluate    "http://${line}/" + "/".join(${manifest_url.split("/")[3:]})
    \    ${cmd}    Set Variable    python3 ${CURDIR}${/}..${/}Libraries${/}OTT${/}asyncplay.py
    \    ${cmd}    Set Variable If    ${platform.find("win")} == -1    timeout ${timeout} ${cmd} '${manifest}' 1 0.1 0 1    ${cmd} "${manifest}" 1 0.1 0 1    # Note: differences in quotes for Windows & Linux
    \    ${output}    OperatingSystem.Run    ${cmd}
    \    Log to console    ${output}
    \    Log    ${output}
    \    Run Keyword If    ${output.find("Traceback")} != -1    Append To List    ${failed_manifests}    Got Traceback for ${manifest}. Please contact automation engineers.
    \    Run Keyword If    ${output.find("Cannot connect to host")} != -1    Append To List    ${failed_manifests}    Fail related to connectivity issue. Please contact automation engineers.
    \    Run Keyword If    ${output.find("Manifest FAIL")} > -1    Append To List    ${failed_manifests}    Manifest FAILED: ${manifest}
    \    Run Keyword If    ${output.find("Manifest ")} == -1    Append To List    ${failed_manifests}    Manifest timed out: ${manifest}
    ${failedReason}    Concatenate List Values    ${failed_manifests}    .${SPACE}
    Log    ${failedReason}
    Set Suite Variable    ${failedReason}    ${failedReason}
    Should Be Empty    ${failedReason}

Check Poster Availability
    [Documentation]    Uses poster_url suite variable
    ${status}    Run Keyword And Return Status    Should Contain    ${poster_url}    /${LAB_CONF["CDN"]["poster"]}/
    ${failedReason}    Set Variable If    ${status}    ${EMPTY}    Poster URL ${poster_url} is invalid.
    ${http_response}    Evaluate    requests.get("${poster_url}")    requests
    ${failedReason}    Run Keyword If    ${http_response.status_code} != 200    Log Response    ${http_response}    ${failedReason} Could Not retrieve poster ${poster_url}:
    ...    ELSE    Set Variable    ${failedReason}
    Set Suite Variable    ${failedReason}    ${failedReason}
    Should Be Equal As Integers    ${http_response.status_code}    200

Delete Recording
    [Arguments]    ${conf}    ${customer}    ${recording}
    ${http_response}    RecordingService.Delete Recording    ${conf}    ${customer}    ${recording}
    ${failedReason}    Run Keyword If    ${http_response.status_code} != 204    Log Response    ${http_response}    ${failedReason} Could Not delete recording:
    ...    ELSE    Set Variable    ${failedReason}
    Should Be Equal As Integers    ${http_response.status_code}    204    Could Not delete recording: ${http_response.status_code} ${http_response.reason}
