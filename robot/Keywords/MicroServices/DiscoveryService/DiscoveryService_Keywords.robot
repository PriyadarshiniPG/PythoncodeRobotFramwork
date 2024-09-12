*** Settings ***
Documentation    Keywords for DiscoveryService
Resource         ./DiscoveryService_Implementation.robot

*** Keywords ***
Get All Recommendations For The Selected Asset    #USED
    [Documentation]    Get all the recommendations available for the selected asset
    ...    Takes as parameters resource_content_source_id, resource_id, start_time, end_time
    ...    resource_content_source_id should take value as 1(LTV) or 2(VOD) or 3(PVR)
    [Arguments]    ${resource_content_source_id}    ${resource_id}    ${start_time}=${EMPTY}    ${end_time}=${EMPTY}    ${client_type}=305
    ${profile_id}    Get Current Profile Id
    ${response}    Get Recommendations Of Asset    ${profile_id}    ${resource_content_source_id}    ${resource_id}    ${start_time}    ${end_time}    ${client_type}
    Return From Keyword If    ${response.status_code} != 200
    [Return]    ${response.json()}