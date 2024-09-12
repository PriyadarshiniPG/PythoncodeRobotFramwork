*** Settings ***
Documentation     Keywords concerning information specific to an individual channel
Resource          ../PA-05_Linear_TV/ChannelInfo_Implementation.robot
Resource          ../../MicroServices/SessionService/SessionService_Keywords.robot

*** Variables ***
${disallowFastForward}    disallowFastForward
${adRestrictionOnly}      adRestrictionOnly

*** Keywords ***
channel logo metadata is accessible on
    [Arguments]    ${channel_number}
    [Documentation]    This keyword fails if channel logo metadata is not accessible
    ${status}    Check Is Logo For Channel Number From Linear Service    ${channel_number}
    run keyword unless    ${status}    fail    logo metadata not available

Check Linear Channel Is Trickplay Enabled    #USED
    [Documentation]    This keyword will check whether the replay channel is trickplay enabled and doesn't have ad retrictions.
    ...    [returns] True if trickplay enabled else False.
    ...    param: ${channel_id} : Id of the channel
    [Arguments]    ${channel_id}
    ${response}    Get Hollow Data From Session Service    ${channel_id}
    ${disallowFastForward}    Set Variable If    '''${disallowFastForward}''' not in '''${response}'''    ${True}    ${False}
    ${adRestrictionOnly}    Set Variable If    '''${adRestrictionOnly}''' not in '''${response}'''    ${True}    ${False}
    ${is_trickplay_enabled}    Set Variable If    ${disallowFastForward} and ${adRestrictionOnly}    ${True}    ${False}
    [Return]    ${is_trickplay_enabled}