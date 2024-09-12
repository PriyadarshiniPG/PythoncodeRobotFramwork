*** Settings ***
Documentation     Implementation Keywords for ReplayCatalogService
Resource          ../../api.basic.robot
Library           Libraries.MicroServices.ReplayCatalogService

*** Keywords ***
Get Replay Channels Via ReplayCatalogService    #USED
    [Documentation]    This keyword Get the replay channels via ReplayCatalogService and
    ...    [return]  response [response.status_code; response.reason; response.json()]
    ${response}    Get Replay Channels    ${LAB_CONF}    ${OSD_LANGUAGE}    ${CITY_ID}
    Check Respond Status And failedReason    ${response}
    [Return]    ${response}


Return List Of Replay Channels
    [Documentation]    This keyword returns list of all replay channels.
    [Arguments]    ${replay_response}
    ${response_channels}    Set Variable    ${replay_response.json()}
    @{replay_channels}    Create List
    ${list_len}    Get Length    ${response_channels['replayChannels']}
    : FOR    ${channel}    IN RANGE    0    ${list_len}
    \    ${channel_id}    Set Variable    ${response_channels['replayChannels'][${channel}]['id']}
    \    Append To List    ${replay_channels}    ${channel_id}
    [Return]    ${replay_channels}

Get Most Relevant Instance Via ReplayCatalogService    #USED
    [Documentation]    This keyword returns the most relevant instance from the ReplayCatalogService
    ...    for the progarm id and type. possible values for type: show/asset.
    [Arguments]    ${program_id}    ${type}
    ${response}    Get Most Relevant Instance     ${LAB_CONF}    ${program_id}    ${OSD_LANGUAGE}    ${CITY_ID}    ${type}
    Check Respond Status And failedReason    ${response}
    [Return]    ${response}
