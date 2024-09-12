*** Settings ***
Documentation     Implementation Keywords for Discovery Service
Library           Libraries.MicroServices.DiscoveryService

*** Keywords ***
Get Recommendations Of Asset    #USED
    [Documentation]    Get all the recommendations available for the selected asset
    ...    Takes as parameters profile id, resource_content_source_id, resource id, start time and end time of the selected asset
    [Arguments]    ${profile_id}    ${resource_content_source_id}    ${resource_id}    ${start_time}    ${end_time}    ${client_type}=305
    ${response}    get recommendations    ${LAB_CONF}    ${client_type}    ${customer_id}    ${profile_id}    ${resource_id}    ${start_time}    ${end_time}    ${resource_content_source_id}
    [Return]    ${response}