*** Settings ***
Documentation     Keywords for ReplayCatalogService
Resource          ./ReplayCatalogService_Implementation.robot

*** Keywords ***
I Fetch All Replay Channels    #USED
    [Documentation]    This keyword returns the list of all replay enabled channels.
    ${response}    Get Replay Channels Via ReplayCatalogService
    ${replay_channels}    Return List Of Replay Channels    ${response}
    ${failedReason}    Set Variable If    ${replay_channels}    ${EMPTY}    Unable to get all the replay channels
    Should Be Empty    ${failedReason}
    [Return]    ${replay_channels}

Get Most Relevant Instance For ${program_id} and ${type}    #USED
    [Documentation]    This keyword returns the most relevant instance for the program id.
    ...    Possible values for type: show/asset
    ${response}    Get Most Relevant Instance Via ReplayCatalogService    ${program_id}    ${type}
    ${failedReason}    Set Variable If    ${response}    ${EMPTY}    Unable to get the most relevant instance
    Should Be Empty    ${failedReason}
    [Return]    ${response}
